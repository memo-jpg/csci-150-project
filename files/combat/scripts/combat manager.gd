extends Node
@export var player: PackedScene
@export var enemy: PackedScene
@export var cards: PackedScene

@onready var scene_transition = $SceneTransition/AnimationPlayer

	#scene_transition.play("fade_in")
	#await get_tree().create_timer(0.5).timeout

	#scene_transition.get_parent().get_node("ColorRect").color.a = 255
	#scene_transition.play("fade_out")
	
var playerNode
var enemyNodes: Array[Node2D]
var cardNodes: Array[Node2D]

var activeCard = null
var turn: String = "player"  # can be "player" or "enemy" might not be needed since enemies 
#don't technically have a turn

var expecting_meta_input = false # possibly implementing meta elements
var meta_damage = 10
var turn_counter = 0

@onready var energyBar = get_node("ProgressBar")

#========= Artifacts =============#
var protection_charm = false #reduce all sources of damage
var protien_bar = false # extra energy at turn start
var handy_shield = false # gain shield at turn start
var gold_totem = false # gain shield at turn start
#========= Artifacts =============#

func _ready():
	# Scene transition
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")
	# Called when combat starts
	playerNode = player.instantiate();
	#Temp value instantiation
	playerNode.setMaxHP(300)
	playerNode.setCurrentHP(100)
	playerNode.global_position = Vector2(200,300)
	add_child(playerNode)
	energyBar.max_value = playerNode.getMaxEnergy()
	#TODO enemy spawning needs to be set by the outside map call
	var enemyNode = enemy.instantiate() #create enemy
	enemyNodes.append(enemyNode) #add enemy to our enemy array
	enemyNode.position.x=900 #temp hardcoded positions
	enemyNode.position.y=300
	#enemy scale added
	enemyNode.enemyActive.connect(_enemy_selected) #connect signal for when enemy is clicked
	add_child(enemyNode) #display enemy
	
	print("Combat started.")
	if not playerNode or not enemy: #debug
		push_warning("⚠️ Missing player or enemy reference in CombatManager!")
	start_player_turn()

# TURN CONTROL #TODO it might be best to turn it into a state machine, completely seperating everything
func start_player_turn(): 
	turn_counter += 1
	turn = "player" #probably not needed
	if protien_bar:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy()+2) #recover extra energy
	else:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy()) #recover energy
		energyBar.value=playerNode.getCurrentEnergy()
	print("\n-- PLAYER TURN START --")
	#print(playerNode.getdeck())
	playerNode.draw_cards(playerNode.getdeck(), playerNode.gethand(), playerNode.getMaxHandSize())#draw cards at turn start
	#print(playerNode.getdeck())
	var cardPos=0
	cardNodes=[] # clear card array since this should be a fresh hand
	for card in playerNode.gethand(): #iterates througn hand and creates card scenes for each
		var tempCard = load_card(card)
		tempCard.setID(cardPos) 
		tempCard.position.y = 600
		tempCard.position.x = 200*cardPos + 300
		tempCard.scale *= 0.35
		tempCard.cardActive.connect(_card_active) #card tells us when it is clicked
		cardNodes.append(tempCard) #add card Node object to our array
		cardPos+=1
		#var newCard = cards.instantiate()
		#newCard.texture = load(card.sprite)
		#newCard.position.x = 90
		#add_child(newCard)
	#print(playerNode.gethand())
	#print_tree()
	playerNode.shield = 0 #shield expires at the start of turn
	if handy_shield:
		playerNode.shield += 4
	#TODO # low priority but I should create a draw cards with no arguments to call later probably

func _card_active(cardIndex):
	#print(cardIndex)
	if(activeCard!=cardIndex):
		if(activeCard != null):
			cardNodes[activeCard].scale.x-=.3
			cardNodes[activeCard].scale.y-=.3
			# POS Should go back down here if negative
			cardNodes[activeCard].position.y += 100
			cardNodes[activeCard].z_index -= 99
			
		cardNodes[cardIndex].scale.x += .3
		cardNodes[cardIndex].scale.y += .3
		# Increase the position to move the card up
		cardNodes[cardIndex].position.y -= 100
		cardNodes[cardIndex].z_index += 99
		activeCard = cardIndex
	else:
		cardNodes[activeCard].scale.x-=.3
		cardNodes[activeCard].scale.y-=.3
		# otherwise lower the postiion back to the starting point 
		cardNodes[activeCard].position.y += 100
		cardNodes[activeCard].z_index -= 99
		activeCard = null
		
func _enemy_selected(enemyIndex):
	if(activeCard!=null):
		#print(cardNodes[activeCard].getType())
		if(cardNodes[activeCard].getType()=='atk'):
			if(use_card(cardNodes[activeCard],enemyNodes[enemyIndex])):
				playerNode.discard_card(playerNode.hand,playerNode.discard,activeCard)
				cardNodes[activeCard].queue_free()
				cardNodes.pop_at(activeCard)
				activeCard=null
				
	check_combat_state()
func end_player_turn():
	print("-- PLAYER TURN END --")
	playerNode.hand_to_discard(playerNode.gethand(), playerNode.getdiscard())
	for card in cardNodes:
		card.queue_free()
	start_enemy_turn()

func start_enemy_turn(): #TODO someone double check my work here
	turn = "enemy"
	print("\n-- ENEMY TURN START --")
	@warning_ignore("shadowed_variable")
	for enemy in enemyNodes:
		enemy_action(enemy.currentAction, enemy) #pass the enemy intention, if nothing it'll be random
		enemy.currentAction+=1
		await get_tree().create_timer(1.0).timeout #delay between enemy actions
	#TODO to be modified further to handle multiple enemies
	end_enemy_turn()

func end_enemy_turn():
	print("-- ENEMY TURN END --")
	for enemy in enemyNodes:
		enemy.currentshield = 0 #shield expires at the start of turn
	start_player_turn()

# CARD LOGIC
func use_card(card, enemyNode):
	print('in use card func')
	if turn != "player":
		print("Can't use cards during enemy turn!")
		return 0

	if playerNode.getCurrentEnergy() < card.getEnergyCost():
		print("Not enough energy!")
		return 0

	playerNode.setCurrentEnergy(playerNode.getCurrentEnergy() - card.getEnergyCost())
	energyBar.value=playerNode.getCurrentEnergy()
	
	match card.type:
		"atk":
			enemyNode.apply_damage_to_enemy(card.damage)
			#print(card.damage)
			return 1
		"block":
			apply_block_to_player(card.shield)
		"special":
			match card.name:
				"confuse":
					print("TODO: add debuffs here")
				
				"time control":
					print("Player takes an extra turn!")
					cards.hand_to_discard(cards.gethand(), cards.getdiscard())
					start_player_turn()  # enemy turn is skipped
					return 0
				"Sword & shield":
					enemyNode.apply_damage_to_enemy(card.damage)
					apply_block_to_player(card.shield)
				"Shield slam":
					enemyNode.apply_damage_to_enemy(player.shield)

	# Properly discard the played card
	#var hand = card.gethand()
	#var discard = cards.getdiscard()
	#var index = hand.find(card)#part of godots logic
	#if card.exhaust:
		#cards.exhaust_card(index)
	#else:
		#cards.discard_card(index)

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
	if protection_charm:
		damage = damage - 5
	if damage <= 0:
		return # No damage to apply

	var damage_remaining = damage
	# 1. Apply damage to shield first
	if playerNode.shield > 0:
		if damage_remaining <= playerNode.shield:
			playerNode.shield -= damage_remaining
			damage_remaining = 0 # All damage was absorbed
		else:
			damage_remaining -= playerNode.shield # Only remaining damage
			playerNode.shield = 0 # Shield is destroyed

	# 2. Apply remaining damage to HP
	if damage_remaining > 0:
		playerNode.currentHP -= damage_remaining
		check_combat_state()


func apply_block_to_player(amount: int):
	playerNode.shield += amount
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

func enemy_action(intent: int,enemy: Node2D): # send -1 to have it be randomized, or select yourself
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
	match intention.type:
		"simple":# we can add an exclusion to not type anything when its 0
			print("Enemy attacks for", dmg)
			apply_damage_to_player(dmg)
			print("Enemy guards for", shld)
			enemy.apply_shield_to_enemy(shld)
		"special":
			match intention["name"]:
				"confuse":
					print("Enemy inflicts confusion!")
					# TODO: Add debuff logic here
				"time stop":
					print("Enemy manipulates time!")
				#give all other enemies an extra move here
				"huh?":
					print("Enemy is drooling and staring blankly")
				"Roar":
					print("Enemy is preparing a big attack!")
					#TODO add buff here
				"Meta":
					trigger_meta_damage(20) #press X to avoid 20 damage! #TODO we should either scrap this
					#or add timing and other details around this. eitherway we can leave it be and never call it
	print(playerNode.currentHP)
	check_combat_state()

func load_card(card: Object):
	var newCard = cards.instantiate()
	newCard.setName(card.cardName)
	newCard.setType(card.type)
	newCard.setDamage(card.damage)
	newCard.setShield(card.shield)
	newCard.setEnergyCost(card.energyCost)
	#TODO set card info
	#print_tree()
	var cardSprite = newCard.find_child('Sprite2D')
	cardSprite.texture = load(card.sprite)
	
	add_child(newCard) 
	return newCard
# STATE CHECK
func check_combat_state():
		if playerNode.getCurrentHP() <= 0:
			print("💀 Player defeated!")
			var prevScene = Global.prev_scene_path
			if (prevScene != ""):
				get_tree().change_scene_to_file(prevScene)
			#check if player died first
			turn_counter = 0 
			# TODO,HANDLE DEATH
		for enemy in enemyNodes:
			if enemy.currentHp <= 0:
				
				# Paueses the game for .75s before fade in animation
				# Could add a victory screen to this(?)
				await get_tree().create_timer(.75).timeout
				scene_transition.play("fade_in")
				await get_tree().create_timer(.5).timeout
				
				enemy.queue_free()
				enemyNodes.pop_at(enemy.pos)
				
				
				if !enemyNodes.size():
					var prevScene = Global.prev_scene_path
					if (prevScene != ""):
						get_tree().change_scene_to_file(prevScene)
				print("✅ Enemy defeated!")
				if gold_totem:
					playerNode.gold += randi_range(50, 75)
				else:
					playerNode.gold += randi_range(25, 50)
			# TODO


func _on_end_combat_test_pressed() -> void:
	var prevScene = Global.prev_scene_path
	handlePlayerVictory()
	await get_tree().create_timer(2.0).timeout
	# Scene transition
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
	if (prevScene != ""):
		#Global.curNodeId += 1
		#print("Global.curNodeId: ", Global.curNodeId)
		get_tree().change_scene_to_file(prevScene)


func _on_end_turn_pressed() -> void:
	end_player_turn()
	pass # Replace with function body.

@onready var saver_loader: saverLoader = %SaverLoader

func handlePlayerVictory() -> void:
		var loadedDict = saver_loader.loadGame() # takes array here and appens the map nodes to it
		
		
		saver_loader.updateSaveGame(loadedDict)
		
		var playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		
		if(playerRestored):
			print("Player exists in combat manager.gd!")
			playerRestored.curNodeId += 1
			saver_loader.saveGame() # saving here saves nothing
			#saver_loader.loadGame()
		else:
			print("Player is NULL in combat manager.gd")
			
		
		pass
