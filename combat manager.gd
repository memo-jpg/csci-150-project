extends Node

@export var player: Node
@export var enemy: Node
@export var cards: Node

var turn: String = "player"  # can be "player" or "enemy" might not be needed since enemies 
#don't technically have a turn

var expecting_meta_input = false # possibly implementing meta elements
var meta_damage = 10

func _ready():
	# Called when combat starts
	print("Combat started.")
	if not player or not enemy: #debug
		push_warning("⚠️ Missing player or enemy reference in CombatManager!")
	start_player_turn()

# TURN CONTROL
func start_player_turn():
	turn = "player" #probably not needed
	player.setCurrentEnergy(player.getMaxEnergy()) #recover energy
	print("\n-- PLAYER TURN START --")
	cards.draw_cards(cards.getdeck(), cards.gethand(), cards.getdrawlimit())#draw cards at turn start
	player.shield = 0 #shield expires at the start of turn
	#TODO # low priority but I should create a draw cards with no arguments to call later probably
	#NEED FIX #I should create a draw cards with no arguments to call later probably

func end_player_turn():
	print("-- PLAYER TURN END --")
	cards.hand_to_discard(cards.gethand(), cards.discard()) #discard cards at turn end
	start_enemy_turn()

func start_enemy_turn(): #NEED FIX # not too sure about this stuff
	turn = "enemy"
	print("\n-- ENEMY TURN START --")
	enemy_action()
	await get_tree().create_timer(1.0).timeout
	end_enemy_turn()

func end_enemy_turn():
	print("-- ENEMY TURN END --")
	enemy.shield = 0 #shield expires at the start of turn
	start_player_turn()

# CARD LOGIC
func use_card(card):
	
	if turn != "player":
		print("Can't use cards during enemy turn!")
		return

	if player.getCurrentEnergy() < card["cost"]:
		print("Not enough energy!")
		return

	player.setCurrentEnergy(player.getCurrentEnergy() - card["cost"]) #reduce energy by the cost of the card

	match card["type"]: #NEED FIX TO MAKE IT MORE FLEXIBLE
		"attack":
			apply_damage_to_enemy(card["damage"])
		"block":
			apply_block_to_player(card["block"])
		"special":
			print("this will relate to status effects probably: ", card["special"])

	# NEED FIX, Move card to discard pile, currently it works with index, idk how to implement
	cards.discard_card(cards.gethand(),cards.getdiscard(), 1) #1 is where the index goes

	check_combat_state()

# DAMAGE & STATUS
func apply_damage_to_enemy(amount: int):
	# NEED FIX not sure how it works with shield
	#var new_hp = enemy.currentshield - amount
	var new_hp = enemy.currenthp - amount
	enemy.setHp(new_hp)
	print("Enemy took ", amount, " damage. HP now: ", enemy.currentHp)

func apply_damage_to_player(amount: int):
	#NEED FIX need to add shields
	player.setCurrentHP(player.getCurrentHP() - amount)
	print("Player took ", amount, " damage. HP now: ", player.getCurrentHP())

func apply_block_to_player(amount: int):
	#NEED FIX need to code in shields
	print("Applied block of ", amount, " (no actual shield implemented yet)")

# ENEMY ACTIONS
func enemy_action():
	var dmg = 10 #deal 10 damage for right now
	print("Enemy attacks for ", dmg)
	apply_damage_to_player(dmg)

# STATE CHECK
func check_combat_state():
		if player.getCurrentHP() <= 0:
			print("💀 Player defeated!")
			#check if player died first
			# TODO,HANDLE DEATH
		elif enemy.currentHp <= 0:
			print("✅ Enemy defeated!")
			# NEED FIX
