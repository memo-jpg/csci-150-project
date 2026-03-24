class_name Enemy extends Node2D

signal enemyActive(enemyPos: int)

var currentHp: int
@export var maxHp: int
var pos: int
var currentAction: int
var statusEffect
var currentshield: int
var Actions: Array = []
var moveset: Array = [] #the moves the enemy is allowed to use
@onready var hpBar = get_node("HP Bar")

func setHp(newHp):
	if newHp < maxHp:
		currentHp = newHp
	else:
		currentHp = maxHp
func apply_damage_to_enemy(damage: int):
	if damage <= 0:
		return # No damage to apply

	var damage_remaining = damage

	# 1. Apply damage to shield first
	if currentshield > 0:
		if damage_remaining <= currentshield:
			currentshield -= damage_remaining
			damage_remaining = 0 # All damage was absorbed
		else:
			damage_remaining -= currentshield # Only remaining damage
			currentshield = 0 # Shield is destroyed

	# 2. Apply remaining damage to HP
	if damage_remaining > 0:
		currentHp -= damage_remaining
		# Ensure HP doesn't go below zero, we could remove this to make the player feel cooler but it might glitch
		if currentHp < 0:
			currentHp = 0
func apply_shield_to_enemy(shield):
	currentshield += shield
func shred_enemy_shield():
	currentshield = 0

# ENEMY ACTIONS
class enemy_action:
	var type: String
	var name: String
	var identifier: int #to keep easier track of actions and make it easier to call if needed
	var damage: int
	var shield: int
	#var energy: int    # we could leave this and have enemies have costs too

	func _init(_type: String, _name: String,_identifier: int,  _damage: int, _shield: int) -> void: #add energy back
		type = _type
		name = _name
		identifier= _identifier 
		damage = _damage
		shield = _shield
		#energy = _energy
		# effect= *status effect #to be added
	func display() -> void:
		print("%s [%s] - Damage: %d, Shield: %d" % [name, type, damage, shield]) #add energy here
func add_enemy_action_to_Actions(action: enemy_action) -> void:
	Actions.append(action)
#set up
func _ready() -> void:
	print("Enemies are ready for combat")
	add_enemy_action_to_Actions(enemy_action.new("special", "huh?", 0, 0, 0))
	add_enemy_action_to_Actions(enemy_action.new("simple", "Claw Swipe", 1, 8, 0))
	add_enemy_action_to_Actions(enemy_action.new("simple", "Turtle Up", 2, 0, 10))
	add_enemy_action_to_Actions(enemy_action.new("special", "Roar", 3, 0, 3))
	add_enemy_action_to_Actions(enemy_action.new("simple", "Nut cracker", 4, 20, 0))
	add_enemy_action_to_Actions(enemy_action.new("simple", "Survive", 5, 0, 20))
	add_enemy_action_to_Actions(enemy_action.new("special", "time stop", 6, 0, 0))
	add_enemy_action_to_Actions(enemy_action.new("special", "confuse", 7, 0, 0))
	add_enemy_action_to_Actions(enemy_action.new("special", "Meta", 8, 0, 0))
	
	
	#for action in Actions:
		#action.display()
	currentHp = maxHp
	hpBar.max_value = maxHp
	hpBar.value = currentHp
	moveset = [1, 2, 3, 4, 7]  # abilities of the default monster
		
		
func _process(delta: float) -> void:
	hpBar.value = currentHp


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event.is_action_pressed("mouseClick")):
		enemyActive.emit(pos)
