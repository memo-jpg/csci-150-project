extends Node

@export var player: Node
@export var enemy: Node
@export var cards: Node

var turn: String = "player"  # can be "player" or "enemy" might not be needed since enemies 
#don't technically have a turn

<<<<<<< HEAD
var expecting_meta_input = false # possibly implementing meta elements
var meta_damage = 10

=======
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
func _ready():
	# Called when combat starts
	print("Combat started.")
	if not player or not enemy: #debug
		push_warning("⚠️ Missing player or enemy reference in CombatManager!")
	start_player_turn()

<<<<<<< HEAD
# TURN CONTROL #TODO it might be best to turn it into a state machine, completely seperating everything
func start_player_turn(): 
=======
# TURN CONTROL
func start_player_turn():
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
	turn = "player" #probably not needed
	player.setCurrentEnergy(player.getMaxEnergy()) #recover energy
	print("\n-- PLAYER TURN START --")
	cards.draw_cards(cards.getdeck(), cards.gethand(), cards.getdrawlimit())#draw cards at turn start
<<<<<<< HEAD
	player.shield = 0 #shield expires at the start of turn
	#TODO # low priority but I should create a draw cards with no arguments to call later probably
=======
	#NEED FIX #I should create a draw cards with no arguments to call later probably
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1

func end_player_turn():
	print("-- PLAYER TURN END --")
	cards.hand_to_discard(cards.gethand(), cards.discard()) #discard cards at turn end
	start_enemy_turn()

<<<<<<< HEAD
func start_enemy_turn(): #TODO someone double check my work here
	turn = "enemy"
	print("\n-- ENEMY TURN START --")
	enemy_action(-1) #pass the enemy intention, if nothing it'll be random
	await get_tree().create_timer(1.0).timeout #delay between enemy actions
	#TODO to be modified further to handle multiple enemies
=======
func start_enemy_turn(): #NEED FIX # not too sure about this stuff
	turn = "enemy"
	print("\n-- ENEMY TURN START --")
	enemy_action()
	await get_tree().create_timer(1.0).timeout
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
	end_enemy_turn()

func end_enemy_turn():
	print("-- ENEMY TURN END --")
<<<<<<< HEAD
	enemy.shield = 0 #shield expires at the start of turn
=======
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
	start_player_turn()

# CARD LOGIC
func use_card(card):
<<<<<<< HEAD

=======
	
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
	if turn != "player":
		print("Can't use cards during enemy turn!")
		return

<<<<<<< HEAD
	if player.getCurrentEnergy() < card.energy:
		print("Not enough energy!")
		return

	player.setCurrentEnergy(player.getCurrentEnergy() - card.energy)

	match card.type:
		"attack":
			enemy.apply_damage_to_enemy(card.damage)
		"block":
			apply_block_to_player(card.shield)
		"special":
			match card.name:
				"confuse":
					print("TODO: add debuffs here")
				"time control":
					start_player_turn()
				"Sword & shield":
					enemy.apply_damage_to_enemy(card.damage)
					apply_block_to_player(card.shield)
				"Shield slam":
					enemy.apply_damage_to_enemy(player.shield)

	# Properly discard the played card
	var hand = cards.gethand()
	var discard = cards.getdiscard()
	var index = hand.find(card)#part of godots logic
	cards.discard_card(hand, discard, index) #discard the card that was just used

	check_combat_state()


# DAMAGE & STATUS 
#//use the one in enemy for below
#func apply_damage_to_enemy(amount: int):
	# NEED FIX not sure how it works with shield
	#var new_hp = enemy.currentshield - amount
	#var new_hp = enemy.currenthp - amount
	#enemy.setHp(new_hp)
	#print("Enemy took ", amount, " damage. HP now: ", enemy.currentHp)

func apply_damage_to_player(damage: int):
	if damage <= 0:
		return # No damage to apply

	var damage_remaining = damage

	# 1. Apply damage to shield first
	if player.shield > 0:
		if damage_remaining <= player.shield:
			player.shield -= damage_remaining
			damage_remaining = 0 # All damage was absorbed
		else:
			damage_remaining -= player.shield # Only remaining damage
			player.shield = 0 # Shield is destroyed

	# 2. Apply remaining damage to HP
	if damage_remaining > 0:
		player.hp -= damage_remaining
		check_combat_state()


func apply_block_to_player(amount: int):
	player.shield += amount
	print("Applied block of ", amount)

# ENEMY ACTIONS
func trigger_meta_damage(damage: int): #prepare meta
	print("Type X to avoid damage!")
	expecting_meta_input = true
	meta_damage = damage

func _input(event): #use this to implement meta damage anywhere
	if expecting_meta_input and event is InputEventKey and event.pressed:
		if event.scancode == KEY_X: #TODO #I'm not sure how to make this flexible and pass the key req
			print("You dodged the damage!")
			expecting_meta_input = false
		else:
			print("Wrong key!")
			apply_damage_to_player(meta_damage)
			check_combat_state()
		expecting_meta_input = false

func enemy_action(intent: int): # send -1 to have it be randomized, or select yourself
	var intention = 0
	if intent == -1: #Select a random action if no intent is chosen
		intention = enemy.Actions[randi() % enemy.Actions.size()]#this is the enemy intention selector
	else:# proceeds with the given intention
		intention = enemy.Actions[intent]
	# Grab the damage and shield from that action
	var dmg = intention.damage
	var shld = intention.shield
	var type = intention.type
	var name = intention.name
	
	print("Enemy uses:", name, "(", type, ")")
	
	# Perform action similarly to player cards
	match intention["type"]:
		"simple":# we can add an exclusion to not type anything when its 0
			print("Enemy attacks for", dmg)
			apply_damage_to_player(dmg)
			print("Enemy guards for", shld)
			enemy.apply_shield_to_enemy(shld)
		"special":
			match intention["id"]:
				"confuse":
					print("Enemy inflicts confusion!")
					# TODO: Add debuff logic here
				"time_stop":
					print("Enemy manipulates time!")
					end_enemy_turn()
					start_enemy_turn()
				"huh?":
					print("Enemy is drooling and staring blankly")
				"Roar":
					print("Enemy is preparing a big attack!")
					#TODO add buff here
				"Meta":
					trigger_meta_damage(20) #press X to avoid 20 damage! #TODO we should either scrap this
					#or add timing and other details around this. eitherway we can leave it be and never call it
	check_combat_state()

=======
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
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1

# STATE CHECK
func check_combat_state():
		if player.getCurrentHP() <= 0:
			print("💀 Player defeated!")
			#check if player died first
<<<<<<< HEAD
			# TODO,HANDLE DEATH
		elif enemy.currentHp <= 0:
			print("✅ Enemy defeated!")
			# TODO
=======
			# NEED FIX,HANDLE DEATH
		elif enemy.currentHp <= 0:
			print("✅ Enemy defeated!")
			# NEED FIX
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
