extends Node

@export var player: PackedScene
@export var enemy: PackedScene
@export var card_scene: PackedScene   # visual card scene

var playerNode: Player
var enemyNodes: Array[Node2D] = []
var cardNodes: Array[Node2D] = []

var activeCardIndex: int = -1
var turn: String = "player"

var expecting_meta_input = false
var meta_damage = 10
var turn_counter = 0

@onready var energyBar = get_node("ProgressBar")

# ========= Artifacts ========= #
var protection_charm = false
var protien_bar = false
var handy_shield = false
var gold_totem = false
# ============================== #


# =========================================================
# READY
# =========================================================
func _ready():
	playerNode = player.instantiate()
	playerNode.setMaxHP(300)
	playerNode.setCurrentHP(100)
<<<<<<< HEAD:combat manager.gd
	playerNode.global_position = Vector2(60, 60)
=======
	playerNode.global_position = Vector2(200,200)
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/combat/scripts/combat manager.gd
	add_child(playerNode)

	energyBar.max_value = playerNode.getMaxEnergy()
<<<<<<< HEAD:combat manager.gd

	var enemyNode = enemy.instantiate()
	enemyNodes.append(enemyNode)
	enemyNode.position = Vector2(800, 300)
	enemyNode.enemyActive.connect(_enemy_selected)
	add_child(enemyNode)

=======
	#TODO enemy spawning needs to be set by the outside map call
	var enemyNode = enemy.instantiate() #create enemy
	enemyNodes.append(enemyNode) #add enemy to our enemy array
	enemyNode.position.x=800 #temp hardcoded positions
	enemyNode.position.y=300
	#enemy scale added
	enemyNode.enemyActive.connect(_enemy_selected) #connect signal for when enemy is clicked
	add_child(enemyNode) #display enemy
	
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/combat/scripts/combat manager.gd
	print("Combat started.")
	start_player_turn()


# =========================================================
# TURN CONTROL
# =========================================================
func start_player_turn():
	turn_counter += 1
	turn = "player"

	if protien_bar:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy() + 2)
	else:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy())

	energyBar.value = playerNode.getCurrentEnergy()

	print("\n-- PLAYER TURN START --")
<<<<<<< HEAD:combat manager.gd

	playerNode.shield = 0
=======
	#print(playerNode.getdeck())
	playerNode.draw_cards(playerNode.getdeck(), playerNode.gethand(), playerNode.getMaxHandSize())#draw cards at turn start
	#print(playerNode.getdeck())
	var cardPos=0
	cardNodes=[] # clear card array since this should be a fresh hand
	for card in playerNode.gethand(): #iterates througn hand and creates card scenes for each
		var tempCard = load_card(card)
		tempCard.setID(cardPos) 
		tempCard.position.y = 400
		tempCard.position.x = 100+200*cardPos 
		tempCard.scale *= 0.6
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
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/combat/scripts/combat manager.gd
	if handy_shield:
		playerNode.shield += 4

	playerNode.draw_cards()

	render_hand()


func end_player_turn():
	print("-- PLAYER TURN END --")

	playerNode.discard_hand()
	clear_visual_hand()

	start_enemy_turn()


func start_enemy_turn():
	turn = "enemy"
	print("\n-- ENEMY TURN START --")

	for enemy in enemyNodes:
		enemy_action(enemy.currentAction, enemy)
		enemy.currentAction += 1
		await get_tree().create_timer(1.0).timeout

	end_enemy_turn()


func end_enemy_turn():
	print("-- ENEMY TURN END --")
	for enemy in enemyNodes:
		enemy.currentshield = 0

	start_player_turn()


# =========================================================
# HAND RENDERING
# =========================================================
func render_hand():
	clear_visual_hand()

	var hand = playerNode.get_hand()

	for i in range(hand.size()):
		var cardData: CardData = hand[i]

		var visual = card_scene.instantiate()
		visual.data = cardData
		visual.set_index(i)
		visual.position = Vector2(100 + 200 * i, 500)
		visual.cardActive.connect(_card_selected)

		add_child(visual)
		cardNodes.append(visual)


func clear_visual_hand():
	for card in cardNodes:
		card.queue_free()

	cardNodes.clear()
	activeCardIndex = -1


# =========================================================
# CARD SELECTION
# =========================================================
func _card_selected(index):
	if activeCardIndex == index:
		cardNodes[index].scale = Vector2.ONE
		activeCardIndex = -1
		return

	if activeCardIndex != -1:
		cardNodes[activeCardIndex].scale = Vector2.ONE

	cardNodes[index].scale = Vector2(1.3, 1.3)
	activeCardIndex = index


func _enemy_selected(enemyIndex):
	if activeCardIndex == -1:
		return

	var success = attempt_play_card(activeCardIndex, enemyNodes[enemyIndex])

	if success:
		render_hand()

	check_combat_state()


# =========================================================
# CARD PLAY LOGIC
# =========================================================
func attempt_play_card(index: int, enemyNode: Node2D) -> bool:
	if turn != "player":
		return false

	var hand = playerNode.get_hand()
	if index < 0 or index >= hand.size():
		return false

	var card: CardData = hand[index]

	if playerNode.getCurrentEnergy() < card.energy:
		print("Not enough energy!")
		return false

	playerNode.setCurrentEnergy(playerNode.getCurrentEnergy() - card.energy)
	energyBar.value = playerNode.getCurrentEnergy()

	resolve_card_effect(card, enemyNode)

	playerNode.play_card(index)   # Handles discard/exhaust

	return true


func resolve_card_effect(card: CardData, enemyNode: Node2D):
	match card.type:
		"attack":
			enemyNode.apply_damage_to_enemy(card.damage)

		"defense":
			playerNode.add_shield(card.shield)

		"status":
			print("Status card used:", card.name)
			# future extension


# =========================================================
# DAMAGE
# =========================================================
func apply_damage_to_player(damage: int):
	if protection_charm:
		damage -= 5

	if damage <= 0:
		return

	playerNode.apply_damage(damage)
	check_combat_state()


# =========================================================
# ENEMY ACTIONS
# =========================================================
func trigger_meta_damage(damage: int):
	print("Type X to avoid damage!")
	expecting_meta_input = true
	meta_damage = damage


func _input(event):
	if expecting_meta_input and event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			print("You dodged the damage!")
		else:
			apply_damage_to_player(meta_damage)

		expecting_meta_input = false


func enemy_action(intent: int, enemy: Node2D):
	var action
	if intent == -1:
		action = enemy.Actions[randi() % enemy.Actions.size()]
	else:
		action = enemy.Actions[intent]

	print("Enemy uses:", action.name)

	match action.type:
		"simple":
			apply_damage_to_player(action.damage)
			enemy.apply_shield_to_enemy(action.shield)

		"special":
			match action.name:
				"Meta":
					trigger_meta_damage(20)

	check_combat_state()


# =========================================================
# STATE CHECK
# =========================================================
func check_combat_state():
	if playerNode.getCurrentHP() <= 0:
		print("💀 Player defeated!")
		return

<<<<<<< HEAD:combat manager.gd
	for enemy in enemyNodes:
		if enemy.currentHp <= 0:
			enemy.queue_free()
			print("✅ Enemy defeated!")
=======

func _on_end_combat_test_pressed() -> void:
	var prevScene = Global.prev_scene_path
	
	if (prevScene != ""):
		#Global.curNodeId += 1
		#print("Global.curNodeId: ", Global.curNodeId)
		get_tree().change_scene_to_file(prevScene)


func _on_end_turn_pressed() -> void:
	end_player_turn()
	pass # Replace with function body.
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/combat/scripts/combat manager.gd
