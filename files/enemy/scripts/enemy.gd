class_name Enemy extends Node2D

signal enemyActive(enemy_pos: int)

var enemy_type:    String = "normal"
var currentHP:     int
@export var maxHp: int = 30
var pos:           int = 0
var currentAction: int = 0
var currentshield: int = 0
var Actions:       Array = []
var moveset:       Array = []

# ── Boss phase system ──────────────────────────────────────────────────────
var current_phase:    int   = 1
var phase_thresholds: Array = []
var phase_movesets:   Array = []
var enraged:          bool  = false
var summon_used:      bool  = false

# ── Reverse Time: accumulates all damage received this fight ───────────────
var damage_taken_this_fight: int = 0

# ── Intent label ──────────────────────────────────────────────────────────
var next_intent_label: Label

@onready var hpBar = get_node_or_null("HP Bar")
var statusManager: StatusEffectManager


# =========================================================
# Setup — called by CombatManager after add_child
# =========================================================
func setup(data: Dictionary, index: int) -> void:
	pos        = index
	enemy_type = data.get("type",    "normal")
	maxHp      = data.get("hp",      30)
	currentHP  = maxHp
	moveset    = data.get("moveset", [1, 2, 3, 4])

	if enemy_type == "boss":
		if hpBar:
			hpBar.modulate = Color(1, 0.3, 0.3)
		phase_thresholds = data.get("phase_thresholds", [0.33])
		phase_movesets   = data.get("phase_movesets", [
			[1, 2, 4, 1],
			[4, 1, 2, 4]
		])
		moveset       = phase_movesets[0]
		current_phase = 1

	elif enemy_type == "elite":
		if hpBar:
			hpBar.modulate = Color(1, 0.6, 0.2)

	if hpBar:
		hpBar.max_value = maxHp
		hpBar.value     = currentHP

	if data.has("sprite") and data["sprite"] != "":
		_apply_sprite(data["sprite"])

	update_intent_label()


# ── Sprite helper ──────────────────────────────────────────────────────────
func _apply_sprite(path: String) -> void:
	if not has_node("Sprite2D"):
		return
	var tex = load(path)
	if tex:
		$Sprite2D.texture = tex
	else:
		push_warning("Enemy sprite not found: " + path)


# =========================================================
# Phase transitions
# =========================================================
func check_phase_transition() -> bool:
	if enemy_type != "boss":
		return false

	var hp_ratio  = float(currentHP) / float(maxHp)
	var new_phase = 1

	for i in range(phase_thresholds.size()):
		if hp_ratio <= phase_thresholds[i]:
			new_phase = i + 2

	if new_phase > current_phase:
		current_phase = new_phase
		var ms_index  = min(current_phase - 1, phase_movesets.size() - 1)
		moveset       = phase_movesets[ms_index]
		currentAction = 0
		enraged       = false
		print("Boss entered Phase %d!" % current_phase)
		return true

	return false


# =========================================================
# Intent label
# =========================================================
func update_intent_label() -> void:
	if not is_instance_valid(next_intent_label):
		return
	if Actions.is_empty() or moveset.is_empty():
		next_intent_label.text = "?"
		return

	var move_index   = currentAction % moveset.size()
	var action_index = moveset[move_index]
	if action_index < 0 or action_index >= Actions.size():
		next_intent_label.text = "?"
		return

	var action = Actions[action_index]
	match action.type:
		"simple":
			if action.damage > 0 and action.shield > 0:
				next_intent_label.text = "⚔ %d / 🛡 %d" % [action.damage, action.shield]
			elif action.damage > 0:
				next_intent_label.text = "⚔ %d" % action.damage
			else:
				next_intent_label.text = "🛡 %d" % action.shield
		"special":
			match action.name:
				"Vulnerability":  next_intent_label.text = "⚠ VULNERABLE"
				"Enrage":         next_intent_label.text = "💢 ENRAGE"
				"Summon":         next_intent_label.text = "👁 SUMMON"
				"Time Skip":      next_intent_label.text = "⏩ TIME SKIP"
				"Reverse Time":   next_intent_label.text = "⏪ REVERSE TIME"
				"Chrono Blast":   next_intent_label.text = "☠ DECAY 25"
				"Clock Shield":   next_intent_label.text = "🛡 CLOCK SHIELD"
				"Mind Wipe":      next_intent_label.text = "🧠 MIND WIPE + SKIP"
				"darkness grasp": next_intent_label.text = "🌑 DARKNESS GRASP"
				_:                next_intent_label.text = "? %s" % action.name
		_:
			next_intent_label.text = action.name


# =========================================================
# HP / Damage
# =========================================================
func setHp(newHp: int):
	currentHP = clamp(newHp, 0, maxHp)


func apply_damage_to_enemy(damage: int):
	if damage <= 0:
		return
	var remaining = damage
	if currentshield > 0:
		if remaining <= currentshield:
			currentshield -= remaining
			return
		else:
			remaining     -= currentshield
			currentshield  = 0
	damage_taken_this_fight += remaining
	currentHP -= remaining
	if currentHP < 0:
		currentHP = 0
	check_phase_transition()


func apply_shield_to_enemy(amount: int):
	currentshield += amount


func shred_enemy_shield():
	currentshield = 0


func heal(amount: int):
	currentHP = min(currentHP + amount, maxHp)


func reverse_time_heal() -> int:
	var restored = min(damage_taken_this_fight, maxHp - currentHP)
	currentHP = min(currentHP + damage_taken_this_fight, maxHp)
	damage_taken_this_fight = 0
	return restored


# =========================================================
# Action class
# =========================================================
class enemy_action:
	var type:       String
	var name:       String
	var identifier: int
	var damage:     int
	var shield:     int

	func _init(_type, _name, _id, _dmg, _shld):
		type       = _type
		name       = _name
		identifier = _id
		damage     = _dmg
		shield     = _shld

	func display():
		print("%s [%s] - DMG: %d  SHD: %d" % [name, type, damage, shield])


func add_enemy_action_to_Actions(action: enemy_action) -> void:
	Actions.append(action)


# =========================================================
# Ready — action table
#  0  huh?           placeholder
#  1  Claw Swipe     8 dmg        — normal / warden
#  2  Vulnerability  special      — warden phase 1
#  3  Nut Cracker    20 dmg       — warden / normal
#  4  Summon         special      — warden phase 2 only
#  5  Time Skip      special      — boss/elite only
#  6  Clock Shield   special      — chronofiend only
#  7  Chrono Blast   special      — chronofiend phase 1: 25 Decay
#  8  Reverse Time   special      — chronofiend: heals stored damage
#  9  Mind Wipe      special      — chronofiend phase 2: 50 Decay + Time Skip
# 10  darkness grasp special      — darkness only, 100 raw damage
# 11  Harden         15 shield    — elite only
# =========================================================
func _ready() -> void:
	add_enemy_action_to_Actions(enemy_action.new("special", "huh?",           0,   0,   0))  #  0
	add_enemy_action_to_Actions(enemy_action.new("simple",  "Claw Swipe",     1,   8,   0))  #  1
	add_enemy_action_to_Actions(enemy_action.new("special", "Vulnerability",  2,   0,   0))  #  2
	add_enemy_action_to_Actions(enemy_action.new("simple",  "Nut Cracker",    3,  20,   0))  #  3
	add_enemy_action_to_Actions(enemy_action.new("special", "Summon",         4,   0,   0))  #  4
	add_enemy_action_to_Actions(enemy_action.new("special", "Time Skip",      5,   0,   0))  #  5
	add_enemy_action_to_Actions(enemy_action.new("special", "Clock Shield",   6,   0, 100))  #  6
	add_enemy_action_to_Actions(enemy_action.new("special", "Chrono Blast",   7,   0,   0))  #  7
	add_enemy_action_to_Actions(enemy_action.new("special", "Reverse Time",   8,   0,   0))  #  8
	add_enemy_action_to_Actions(enemy_action.new("special", "Mind Wipe",      9,   0,   0))  #  9
	add_enemy_action_to_Actions(enemy_action.new("special", "darkness grasp", 10, 100,  0))  # 10
	add_enemy_action_to_Actions(enemy_action.new("simple",  "Harden",         11,  0,  15))  # 11

	currentHP       = maxHp
	if hpBar:
		hpBar.max_value = maxHp
		hpBar.value     = currentHP
	# Default moveset for plain enemies
	moveset = [1, 2, 3, 3]

	next_intent_label          = Label.new()
	next_intent_label.position = Vector2(-80, -60)
	next_intent_label.z_index  = 10
	add_child(next_intent_label)

	statusManager = StatusEffectManager.new()
	add_child(statusManager)


func _process(_delta: float) -> void:
	if hpBar:
		hpBar.value = currentHP


func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_pressed("mouseClick"):
		enemyActive.emit(pos)
