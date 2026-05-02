extends Node

@export var player:     PackedScene
@export var enemy:      PackedScene
@export var card_scene: PackedScene

var playerNode
var enemyNodes: Array[Node2D] = []
var cardNodes:  Array[Node2D] = []
var hp_label:     Label
var shield_label: Label
var gold_label:   Label
var artifact_row: HBoxContainer
var status_row:   HBoxContainer
var tooltip_panel: ColorRect
var status_icon_nodes: Array[Control] = []
var activeCardIndex: int = -1
var turn: String = "player"

var turn_counter:         int  = 0
var vulnerability_active: bool = false
var enrage_bonus_damage:  int  = 0
var player_turn_skipped:  bool = false

@onready var energyBar    = get_node("ProgressBar")
@onready var saver_loader: saverLoader = %SaverLoader
@onready var scene_transition = $SceneTransition/AnimationPlayer

var arena_bg:            ColorRect
var boss_announce_label: Label
var skip_label:          Label

# ── Artifacts ─────────────────────────────────────────────────────────────
var protection_charm := false
var protien_bar      := false
var handy_shield     := false
var gold_totem       := false

# ── Card reward ────────────────────────────────────────────────────────────
var _db:                  CardDatabase      = null
var _reward_manager:      CardRewardManager = null
var _last_encounter_type: String            = "normal"


# =========================================================
# READY
# =========================================================
func _ready():
	print("DEBUG [combat_manager] _ready() start")

	# Fade in from black
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")

	# Arena background
	arena_bg             = ColorRect.new()
	arena_bg.color       = Color(0.08, 0.08, 0.12)
	arena_bg.size        = get_viewport().get_visible_rect().size
	arena_bg.z_index     = -100
	arena_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(arena_bg)

	# Player — loaded from save so progress carries over
	playerNode = saver_loader.loadPlayer()
	var loaded_player := playerNode != null
	if playerNode == null:
		# Fallback: instantiate fresh if no save exists
		playerNode = player.instantiate()
	playerNode.setMaxHP(300)
	if loaded_player:
		playerNode.setCurrentHP(max(1, playerNode.getCurrentHP()))
	else:
		playerNode.setCurrentHP(playerNode.getMaxHP())
	playerNode.setCurrentEnergy(playerNode.getMaxEnergy())
	playerNode.global_position = Vector2(200, 300)
	add_child(playerNode)

	Global.ensure_starting_artifact()
	protection_charm = Global.has_artifact("protection_charm")
	protien_bar = Global.has_artifact("protein_bar")
	handy_shield = Global.has_artifact("handy_shield")
	gold_totem = Global.has_artifact("gold_totem")

	if playerNode.statusManager and "combat_manager" in playerNode.statusManager:
		playerNode.statusManager.combat_manager = self

	# HUD labels
	hp_label = Label.new()
	hp_label.position = Vector2(20, 50)
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_label)

	shield_label = Label.new()
	shield_label.position = Vector2(20, 70)
	shield_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shield_label)

	gold_label = Label.new()
	gold_label.position = Vector2(20, 90)
	gold_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gold_label)

	artifact_row = HBoxContainer.new()
	artifact_row.position = Vector2(20, 118)
	artifact_row.size = Vector2(360, 36)
	add_child(artifact_row)

	status_row = HBoxContainer.new()
	status_row.position = Vector2(20, get_viewport().get_visible_rect().size.y - 58)
	status_row.size = Vector2(get_viewport().get_visible_rect().size.x - 40, 42)
	add_child(status_row)

	# Boss announcement
	boss_announce_label = Label.new()
	boss_announce_label.position = Vector2(300, 200)
	boss_announce_label.add_theme_font_size_override("font_size", 32)
	boss_announce_label.visible = false
	boss_announce_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(boss_announce_label)

	# Time Skip notification
	skip_label = Label.new()
	skip_label.position = Vector2(300, 260)
	skip_label.add_theme_font_size_override("font_size", 24)
	skip_label.modulate = Color(1, 0.3, 0.3)
	skip_label.visible  = false
	skip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(skip_label)

	energyBar.max_value = playerNode.getMaxEnergy() + (2 if protien_bar else 0)

	# Cards
	_db = CardDatabase.new()
	add_child(_db)
	if _db.cards.is_empty():
		push_error("DEBUG [combat_manager] No cards loaded from cards.json!")
		return
	print("DEBUG [combat_manager] Loaded %d cards from database" % _db.cards.size())
	if Global.player_deck.is_empty():
		var starting_deck: Dictionary
		if Global.starter_deck_mode == "elemental":
			starting_deck = {
				"Earth": 1,
				"Fire": 1,
				"Water": 1,
				"Wind": 1,
				"Basic Defense": 2,
			}
		else:
			starting_deck = {
				"Basic Attack": 4,
				"Basic Defense": 4,
				"Poison": 2,
			}
		for card_name in starting_deck:
			for _i in range(starting_deck[card_name]):
				Global.player_deck.append(card_name)
	for card_name in Global.player_deck:
		var template := _db.get_template(card_name)
		if template == null:
			push_warning("DEBUG [combat_manager] Card not found in DB: '%s'" % card_name)
			continue
		playerNode.deckManager.add_card_to_deck(template.duplicate_instance())
	playerNode.deckManager.build_combat_deck()

	_spawn_enemies()
	_apply_arena_bg()
	_check_boss_intro()

	print("DEBUG [combat_manager] _ready() complete — calling start_player_turn()")
	start_player_turn()


# =========================================================
# ARENA BACKGROUND
# =========================================================
func _apply_arena_bg() -> void:
	for data in Global.encounter_data:
		if data.has("bg_color"):
			arena_bg.color = data["bg_color"]
			return


# =========================================================
# BOSS INTRO
# =========================================================
func _check_boss_intro() -> void:
	for e in enemyNodes:
		if e.enemy_type == "boss":
			boss_announce_label.text    = "⚠  BOSS ENCOUNTER  ⚠"
			boss_announce_label.visible = true
			get_tree().create_timer(2.5).timeout.connect(
				func(): boss_announce_label.visible = false
			)
			break


# =========================================================
# ENEMY SPAWNING
# =========================================================
func _spawn_enemies() -> void:
	var encounter: Array = Global.encounter_data
	if encounter.is_empty():
		print("DEBUG [combat_manager] encounter_data empty — using fallback enemy")
		encounter = [{"type": "normal", "hp": 30, "moveset": [1, 3, 1, 3]}]

	var total       = encounter.size()
	var start_x     = 600
	var spacing     = 220
	var enemy_y     = 300
	var group_width = (total - 1) * spacing
	var origin_x    = start_x - int(group_width / 2.0)

	_last_encounter_type = "normal"
	for d in encounter:
		var t: String = d.get("type", "normal")
		if t == "boss":
			_last_encounter_type = "boss"
			break
		elif t == "elite":
			_last_encounter_type = "elite"

	for i in range(total):
		var data      = encounter[i]
		var enemyNode = enemy.instantiate()
		enemyNode.position = Vector2(origin_x + i * spacing, enemy_y)
		add_child(enemyNode)
		enemyNode.setup(data, i)
		enemyNode.enemyActive.connect(_enemy_selected)
		if "combat_manager" in enemyNode.statusManager:
			enemyNode.statusManager.combat_manager = self
		enemyNodes.append(enemyNode)


# =========================================================
# SUMMON — Warden Phase 2
# =========================================================
func _summon_minion(summoner: Node2D) -> void:
	if summoner.summon_used:
		return
	summoner.summon_used = true
	var minionNode = enemy.instantiate()
	minionNode.position = summoner.position + Vector2(140, 40)
	add_child(minionNode)
	minionNode.setup({"type": "normal", "hp": 20, "moveset": [1, 5, 1, 3]}, enemyNodes.size())
	minionNode.enemyActive.connect(_enemy_selected)
	if "combat_manager" in minionNode.statusManager:
		minionNode.statusManager.combat_manager = self
	enemyNodes.append(minionNode)


# =========================================================
# TURN CONTROL
# =========================================================
func start_player_turn():
	refresh_hud()
	turn_counter += 1
	turn = "player"

	for e in enemyNodes:
		e.statusManager.on_turn_start()

	if playerNode.statusManager and playerNode.statusManager.has_method("on_turn_start"):
		playerNode.statusManager.on_turn_start()

	if player_turn_skipped:
		print("DEBUG [combat_manager] Turn skipped!")
		player_turn_skipped = false
		_show_skip_notification()
		playerNode.deckManager.draw_cards(playerNode.deckManager.get_draw_limit())
		playerNode.deckManager.discard_hand()
		start_enemy_turn()
		return

	playerNode.currentEnergy = playerNode.getMaxEnergy() + (2 if protien_bar else 0)
	energyBar.value = playerNode.getCurrentEnergy()

	playerNode.shield = 0
	if handy_shield:
		playerNode.shield += 4

	playerNode.deckManager.draw_cards(playerNode.deckManager.get_draw_limit())
	refresh_hud()
	render_hand()

	for e in enemyNodes:
		e.update_intent_label()


func _show_skip_notification() -> void:
	skip_label.text    = "YOUR TURN WAS SKIPPED!"
	skip_label.visible = true
	get_tree().create_timer(1.5).timeout.connect(
		func(): skip_label.visible = false
	)


func refresh_hud():
	if hp_label:
		hp_label.text     = "HP: %d / %d" % [playerNode.currentHP, playerNode.maxHP]
	if shield_label:
		shield_label.text = "Shield: %d" % playerNode.shield
	if gold_label:
		gold_label.text   = "Gold: %d"   % playerNode.gold
	_refresh_positioned_icon_huds()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close_tooltip_panel()


func _refresh_icon_huds() -> void:
	if artifact_row:
		_clear_children(artifact_row)
		for artifact_id in Global.artifacts:
			var artifact := _artifact_info(artifact_id)
			var icon := _make_info_icon(
				artifact.get("emoji", "⭐"),
				artifact.get("name", artifact_id),
				artifact.get("description", "")
			)
			artifact_row.add_child(icon)

	if status_row:
		_clear_children(status_row)
		for e in enemyNodes:
			if not is_instance_valid(e) or e.statusManager == null:
				continue
			for status in e.statusManager.negative_statuses:
				if status.is_expired:
					continue
				var info := _status_info(status.type)
				var icon := _make_info_icon(
					"%s %d" % [info.get("emoji", "❔"), status.duration],
					"%s on Enemy %d" % [status.name, e.pos + 1],
					info.get("description", status.name)
				)
				status_row.add_child(icon)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _refresh_positioned_icon_huds() -> void:
	if artifact_row:
		_clear_children(artifact_row)
		for artifact_id in Global.artifacts:
			var artifact := _artifact_info(artifact_id)
			var icon := _make_info_icon(
				artifact.get("emoji", "⭐"),
				artifact.get("name", artifact_id),
				artifact.get("description", "")
			)
			artifact_row.add_child(icon)

	for node in status_icon_nodes:
		if is_instance_valid(node):
			node.queue_free()
	status_icon_nodes.clear()

	for e in enemyNodes:
		if not is_instance_valid(e) or e.statusManager == null:
			continue
		var row := HBoxContainer.new()
		row.position = e.global_position + Vector2(-70, 58)
		row.z_index = 450
		add_child(row)
		status_icon_nodes.append(row)

		for status in e.statusManager.negative_statuses:
			if status.is_expired:
				continue
			var info := _status_info(status.type)
			var icon := _make_info_icon(
				"%s %d" % [info.get("emoji", "❔"), status.duration],
				"%s on Enemy %d" % [status.name, e.pos + 1],
				info.get("description", status.name)
			)
			row.add_child(icon)


func _make_info_icon(text: String, title: String, body: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.tooltip_text = "%s\n%s" % [title, body]
	btn.custom_minimum_size = Vector2(42, 32)
	btn.pressed.connect(_show_tooltip_panel.bind(title, body))
	return btn


func _show_tooltip_panel(title: String, body: String) -> void:
	_close_tooltip_panel()
	tooltip_panel = ColorRect.new()
	tooltip_panel.color = Color(0, 0, 0, 0.72)
	tooltip_panel.size = Vector2(430, 170)
	tooltip_panel.position = Vector2(24, 160)
	tooltip_panel.z_index = 500
	add_child(tooltip_panel)

	var close := Button.new()
	close.text = "X"
	close.size = Vector2(34, 30)
	close.position = Vector2(tooltip_panel.size.x - 42, 8)
	close.pressed.connect(_close_tooltip_panel)
	tooltip_panel.add_child(close)

	var title_label := Label.new()
	title_label.text = title
	title_label.position = Vector2(14, 12)
	title_label.size = Vector2(360, 28)
	title_label.add_theme_font_size_override("font_size", 18)
	tooltip_panel.add_child(title_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.position = Vector2(14, 52)
	body_label.size = Vector2(395, 96)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 14)
	tooltip_panel.add_child(body_label)


func _close_tooltip_panel() -> void:
	if tooltip_panel:
		tooltip_panel.queue_free()
		tooltip_panel = null


func _status_info(status_type: String) -> Dictionary:
	match status_type:
		"poison":
			return {"emoji": "☠️", "description": "Poison deals raw HP damage at the start of the owner's turn, then loses 1 stack."}
		"burn":
			return {"emoji": "🔥", "description": "Burn deals damage through shield rules at the start of the owner's turn, then loses 1 stack."}
		"confuse":
			return {"emoji": "❓", "description": "Confuse makes the enemy use Huh? instead of its planned action, consuming 1 stack."}
		"decay":
			return {"emoji": "⌛", "description": "Decay damages the player at turn start and then loses 1 stack."}
		"element_fire":
			return {"emoji": "🔥", "description": "Fire Mark is permanent until consumed. Water consumes it for +50% damage per stack."}
		"element_water":
			return {"emoji": "💧", "description": "Water Mark is permanent until consumed. Wind consumes it to splash damage to other enemies."}
		"element_wind":
			return {"emoji": "💨", "description": "Wind Mark is permanent until consumed. Fire consumes it for bonus damage; Earth consumes it for confuse."}
		"element_earth":
			return {"emoji": "🪨", "description": "Earth Mark is permanent until consumed by future elemental rules."}
		_:
			return {"emoji": "❔", "description": status_type}


func _artifact_info(artifact_id: String) -> Dictionary:
	for artifact in Global.ARTIFACT_POOL:
		if artifact.get("id", "") == artifact_id:
			var copy := artifact.duplicate()
			copy["emoji"] = _artifact_emoji(artifact_id)
			return copy
	return {"name": artifact_id, "description": "Unknown artifact.", "emoji": "⭐"}


func _artifact_emoji(artifact_id: String) -> String:
	match artifact_id:
		"protection_charm":
			return "🛡️"
		"healing_sprout":
			return "🌱"
		"protein_bar":
			return "⚡"
		"handy_shield":
			return "🔰"
		"gold_totem":
			return "🪙"
		"ember_core":
			return "🔥"
		_:
			return "⭐"
	energyBar.value = playerNode.getCurrentEnergy()


func end_player_turn():
	playerNode.deckManager.discard_hand()
	clear_visual_hand()
	start_enemy_turn()
	refresh_hud()


func start_enemy_turn():
	turn = "enemy"
	var snapshot = enemyNodes.duplicate()
	for e in snapshot:
		if not is_instance_valid(e):
			continue
		var action_index := 0
		if e.statusManager.get_negative_stacks("confuse") > 0:
			e.statusManager.consume_negative_stack("confuse")
			e.currentAction = 0
		else:
			var move_index = e.currentAction % e.moveset.size()
			action_index = e.moveset[move_index]
		enemy_action(action_index, e)
		e.currentAction += 1
		await get_tree().create_timer(1.0).timeout
	end_enemy_turn()


func end_enemy_turn():
	for e in enemyNodes:
		e.currentshield = 0
	vulnerability_active = false
	refresh_hud()
	start_player_turn()


# =========================================================
# HAND RENDERING
# =========================================================
func render_hand():
	clear_visual_hand()
	var hand = playerNode.deckManager.get_hand()
	for i in range(hand.size()):
		var visual = card_scene.instantiate()
		visual.position = Vector2(200 + 125 * i, 600)
		visual.cardActive.connect(_card_selected)
		add_child(visual)       # _ready() fires here — @onready vars are now valid
		visual.data = hand[i]   # set data after tree entry
		visual.set_index(i)     # set index after tree entry
		visual.update_display() # explicitly draw with the real data
		cardNodes.append(visual)


func clear_visual_hand():
	for card in cardNodes:
		card.queue_free()
	cardNodes.clear()
	activeCardIndex = -1


# =========================================================
# CARD SELECTION & PLAY
# =========================================================
func _card_selected(index: int):
	if index < 0 or index >= cardNodes.size():
		activeCardIndex = -1
		return

	if activeCardIndex == index:
		_reset_card_visuals(activeCardIndex)
		activeCardIndex = -1
		return

	if activeCardIndex != -1 and activeCardIndex < cardNodes.size():
		_reset_card_visuals(activeCardIndex)

	cardNodes[index].scale       = Vector2(0.75, 0.75)
	cardNodes[index].position.y -= 100
	cardNodes[index].z_index    += 99
	activeCardIndex = index


func _reset_card_visuals(card_idx: int):
	if card_idx != -1 and card_idx < cardNodes.size():
		cardNodes[card_idx].scale       = Vector2(0.45, 0.45)
		cardNodes[card_idx].position.y += 100
		cardNodes[card_idx].z_index     = 0


func _enemy_selected(enemy_pos: int):
	if activeCardIndex == -1:
		return
	var target: Node2D = null
	for e in enemyNodes:
		if e.pos == enemy_pos:
			target = e
			break
	if target == null:
		return
	var success = attempt_play_card(activeCardIndex, target)
	if success:
		render_hand()
	check_combat_state()


func attempt_play_card(index: int, enemyNode: Node2D) -> bool:
	if turn != "player":
		return false
	var hand = playerNode.deckManager.get_hand()
	if index < 0 or index >= hand.size():
		return false
	var card: CardData = hand[index]
	if playerNode.getCurrentEnergy() < card.energy:
		return false

	playerNode.setCurrentEnergy(playerNode.getCurrentEnergy() - card.energy)
	energyBar.value = playerNode.getCurrentEnergy()
	resolve_card_effect(card, enemyNode)
	playerNode.deckManager.play_card(index)
	refresh_hud()
	return true


func resolve_card_effect(card: CardData, enemyNode: Node2D):
	var base_damage = card.damage
	if vulnerability_active and base_damage > 0:
		base_damage = int(base_damage * 1.5)

	match card.type:
		"attack":
			_deal_damage_to_enemy(enemyNode, base_damage)
		"defense":
			apply_block_to_player(card.shield)
		"status":
			print("DEBUG [combat_manager] Status card used: %s" % card.name)

	if card.special.is_empty():
		return

	if card.special.get("element", "") != "":
		base_damage = _resolve_elemental_card(card, enemyNode, base_damage)
	if card.special.get("all_enemies", false) and base_damage > 0:
		for e in enemyNodes:
			if e != enemyNode and is_instance_valid(e):
				_deal_damage_to_enemy(e, base_damage)

	if card.special.get("poison", 0) > 0:
		enemyNode.statusManager.apply_effect("poison", "Poison", card.special["poison"], true, enemyNode)
	if card.special.get("burn", 0) > 0:
		enemyNode.statusManager.apply_effect("burn", "Burn", card.special["burn"], true, enemyNode)
	if card.special.get("confuse", 0) > 0:
		enemyNode.statusManager.apply_effect("confuse", "Confuse", card.special["confuse"], true, enemyNode)
	if card.special.get("gold", 0) > 0:
		playerNode.gold += int(card.special["gold"])
	if card.special.get("all_statuses", false):
		_apply_all_statuses(enemyNode)
	if card.special.get("skip_enemy_turn", false):     turn = "player"
	if card.special.get("damage_equal_shield", false): _deal_damage_to_enemy(enemyNode, playerNode.shield)
	if card.special.get("double_damage", false):       _deal_damage_to_enemy(enemyNode, base_damage)
	if card.special.get("sword_and_shield", false):
		_deal_damage_to_enemy(enemyNode, base_damage)
		apply_block_to_player(card.shield)

	refresh_hud()


func _resolve_elemental_card(card: CardData, enemyNode: Node2D, base_damage: int) -> int:
	var element: String = card.special.get("element", "")
	var damage := base_damage
	if Global.has_artifact("ember_core") and damage > 0:
		damage += 3

	match element:
		"fire":
			var wind_stacks: int = enemyNode.statusManager.remove_negative_status("element_wind")
			if wind_stacks > 0:
				damage = int(damage * (1.0 + 0.5 * wind_stacks))
			var water_stacks: int = enemyNode.statusManager.remove_negative_status("element_water")
			if water_stacks > 0:
				enemyNode.statusManager.apply_effect("confuse", "Confuse", water_stacks, true, enemyNode)
			var earth_stacks: int = enemyNode.statusManager.remove_negative_status("element_earth")
			if earth_stacks > 0:
				damage += 4 * earth_stacks
			enemyNode.statusManager.apply_effect("element_fire", "Fire Mark", 1, true, enemyNode)
			enemyNode.statusManager.apply_effect("burn", "Burn", 2, true, enemyNode)
		"water":
			var fire_stacks: int = enemyNode.statusManager.remove_negative_status("element_fire")
			if fire_stacks > 0:
				damage = int(damage * (1.0 + 0.5 * fire_stacks))
			var wind_stacks: int = enemyNode.statusManager.remove_negative_status("element_wind")
			if wind_stacks > 0:
				for e in enemyNodes:
					if e != enemyNode and is_instance_valid(e):
						e.statusManager.apply_effect("confuse", "Confuse", wind_stacks, true, e)
			var earth_stacks: int = enemyNode.statusManager.remove_negative_status("element_earth")
			if earth_stacks > 0:
				enemyNode.statusManager.apply_effect("poison", "Poison", earth_stacks * 2, true, enemyNode)
			enemyNode.statusManager.apply_effect("element_water", "Water Mark", 1, true, enemyNode)
		"wind":
			var water_stacks: int = enemyNode.statusManager.remove_negative_status("element_water")
			if water_stacks > 0:
				for e in enemyNodes:
					if e != enemyNode and is_instance_valid(e):
						_deal_damage_to_enemy(e, 3 * water_stacks)
			var fire_stacks: int = enemyNode.statusManager.remove_negative_status("element_fire")
			if fire_stacks > 0:
				for e in enemyNodes:
					if is_instance_valid(e):
						e.statusManager.apply_effect("burn", "Burn", fire_stacks, true, e)
			var earth_stacks: int = enemyNode.statusManager.remove_negative_status("element_earth")
			if earth_stacks > 0:
				enemyNode.statusManager.apply_effect("confuse", "Confuse", earth_stacks, true, enemyNode)
			enemyNode.statusManager.apply_effect("element_wind", "Wind Mark", 1, true, enemyNode)
		"earth":
			var wind_for_stun: int = enemyNode.statusManager.remove_negative_status("element_wind")
			if wind_for_stun > 0:
				enemyNode.statusManager.apply_effect("confuse", "Confuse", wind_for_stun, true, enemyNode)
			var fire_stacks: int = enemyNode.statusManager.remove_negative_status("element_fire")
			if fire_stacks > 0:
				apply_block_to_player(5 * fire_stacks)
			var water_stacks: int = enemyNode.statusManager.remove_negative_status("element_water")
			if water_stacks > 0:
				playerNode.currentHP = min(playerNode.maxHP, playerNode.currentHP + 3 * water_stacks)
			apply_block_to_player(4)
			enemyNode.statusManager.apply_effect("element_earth", "Earth Mark", 1, true, enemyNode)

	if damage != base_damage and damage > 0:
		_deal_damage_to_enemy(enemyNode, damage - base_damage)
	return damage


func _apply_all_statuses(enemyNode: Node2D) -> void:
	enemyNode.statusManager.apply_effect("poison", "Poison", 3, true, enemyNode)
	enemyNode.statusManager.apply_effect("burn", "Burn", 3, true, enemyNode)
	enemyNode.statusManager.apply_effect("confuse", "Confuse", 2, true, enemyNode)
	enemyNode.statusManager.apply_effect("element_fire", "Fire Mark", 1, true, enemyNode)
	enemyNode.statusManager.apply_effect("element_water", "Water Mark", 1, true, enemyNode)
	enemyNode.statusManager.apply_effect("element_wind", "Wind Mark", 1, true, enemyNode)
	enemyNode.statusManager.apply_effect("element_earth", "Earth Mark", 1, true, enemyNode)


# =========================================================
# DAMAGE & BLOCK
# =========================================================
func _deal_damage_to_enemy(target: Node2D, damage: int) -> void:
	if target == null or damage <= 0:
		return
	var before: int = target.currentHP
	target.apply_damage_to_enemy(damage)
	var dealt: int = max(0, before - target.currentHP)
	if dealt > 0:
		_show_floating_number("-%d" % dealt, target.global_position + Vector2(0, -70), Color(1.0, 0.25, 0.15))


func _show_floating_number(text: String, pos: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.global_position = pos
	label.z_index = 600
	label.modulate = color
	label.add_theme_font_size_override("font_size", 28)
	add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "global_position", pos + Vector2(0, -34), 0.45)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.45)
	tween.finished.connect(label.queue_free)


func apply_damage_to_player(damage: int):
	damage += enrage_bonus_damage
	if protection_charm:
		damage -= 5
	if damage <= 0:
		return
	var remaining = damage
	if playerNode.shield > 0:
		if remaining <= playerNode.shield:
			playerNode.shield -= remaining
			return
		else:
			remaining         -= playerNode.shield
			playerNode.shield  = 0
	playerNode.currentHP -= remaining
	_show_floating_number("-%d" % remaining, playerNode.global_position + Vector2(0, -70), Color(1.0, 0.2, 0.2))
	check_combat_state()
	refresh_hud()


func apply_block_to_player(amount: int):
	playerNode.shield += amount


# =========================================================
# ENEMY ACTIONS
# =========================================================
func enemy_action(intent: int, e: Node2D):
	if intent < 0 or intent >= e.Actions.size():
		intent = randi() % e.Actions.size()
	var action = e.Actions[intent]

	match action.type:
		"simple":
			apply_damage_to_player(action.damage)
			e.apply_shield_to_enemy(action.shield)

		"special":
			match action.name:
				"Vulnerability":
					vulnerability_active = true
				"Summon":
					_summon_minion(e)
				"Time Skip":
					player_turn_skipped = true
				"Clock Shield":
					e.apply_shield_to_enemy(100)
				"Chrono Blast":
					playerNode.statusManager.apply_effect("decay", "Decay", 25, true, playerNode)
				"Reverse Time":
					var restored = e.reverse_time_heal()
					print("DEBUG [combat_manager] Reverse Time — restored %d HP" % restored)
				"Mind Wipe":
					playerNode.statusManager.apply_effect("decay", "Decay", 50, true, playerNode)
					player_turn_skipped = true
				# Darkness boss is disabled for now; this unfinished move was dealing 100 damage.
				# "darkness grasp":
				# 	apply_damage_to_player(100)
				"Meta":    print("DEBUG [combat_manager] Meta — dodge with X!")
				"Roar":    print("DEBUG [combat_manager] Roar")
				"Confuse": print("DEBUG [combat_manager] Confuse")
				_:
					print("DEBUG [combat_manager] Unknown special: %s" % action.name)

	check_combat_state()
	refresh_hud()


# =========================================================
# STATE CHECK
# =========================================================
func check_combat_state():
	if playerNode.getCurrentHP() <= 0:
		print("DEBUG [combat_manager] Player HP <= 0 - returning to main menu")
		turn_counter = 0
		Global.new_run()
		var tree := get_tree()
		if tree != null:
			tree.change_scene_to_file("res://files/menus/scenes/main_menu.tscn")
		return

	for i in range(enemyNodes.size() - 1, -1, -1):
		var e = enemyNodes[i]
		if e.currentHP <= 0:
			playerNode.gold += randi_range(50, 75) if gold_totem else randi_range(25, 50)
			e.queue_free()
			enemyNodes.remove_at(i)

	if enemyNodes.is_empty():
		if Global.pending_artifact_reward:
			var artifact := Global.award_random_artifact()
			Global.optional_boss_defeated = true
			Global.pending_artifact_reward = false
			print("Artifact acquired: %s" % artifact.get("name", "Nothing new"))
		Global.encounter_data.clear()
		clear_visual_hand()
		_show_card_reward()


func _show_card_reward() -> void:
	_reward_manager = CardRewardManager.new()
	add_child(_reward_manager)
	_reward_manager.reward_closed.connect(_on_reward_closed)
	_reward_manager.show_reward(null, _db, _last_encounter_type)


func _on_reward_closed() -> void:
	print("DEBUG [combat_manager] Reward closed — saving player and returning to map")
	handlePlayerVictory()
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	var target := Global.prev_scene_path
	if target == "":
		target = "res://files/map/scenes/mapScene.tscn"
	var tree := get_tree()
	if tree != null:
		tree.change_scene_to_file(target)


func handlePlayerVictory() -> void:
	if Global.has_artifact("healing_sprout"):
		playerNode.currentHP = min(playerNode.maxHP, playerNode.currentHP + 5)
	saver_loader.savePlayer()


# =========================================================
# BUTTONS
# =========================================================
func _on_end_turn_pressed():
	end_player_turn()

func _on_end_combat_test_pressed():
	handlePlayerVictory()
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	if Global.prev_scene_path != "":
		get_tree().change_scene_to_file(Global.prev_scene_path)
