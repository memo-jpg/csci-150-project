extends Node
@export var player: PackedScene
@export var enemy: PackedScene
@export var card_scene: PackedScene

var playerNode
var enemyNodes: Array[Node2D] = []
var cardNodes: Array[Node2D] = []
var hp_label: Label
var shield_label: Label
var gold_label: Label
var activeCardIndex: int = -1
var turn: String = "player"
@export var cards: PackedScene

@onready var scene_transition = $SceneTransition/AnimationPlayer

	#scene_transition.play("fade_in")
	#await get_tree().create_timer(0.5).timeout

	#scene_transition.get_parent().get_node("ColorRect").color.a = 255
	#scene_transition.play("fade_out")
	


#var activeCard = null
#var turn: String = "player"  # can be "player" or "enemy" might not be needed since enemies 
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

# =========================================================
# READY
# =========================================================
func _ready():
	# Scene transition
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")
	# Called when combat starts
	playerNode = saver_loader.loadPlayer()
	playerNode.setMaxHP(300)
	playerNode.setCurrentHP(100)
	playerNode.global_position = Vector2(200,300)
	add_child(playerNode)
	var enemyNode = enemy.instantiate()
	enemyNodes.append(enemyNode)
	enemyNode.position.x = 900
	enemyNode.position.y = 300
	enemyNode.enemyActive.connect(_enemy_selected)
	add_child(enemyNode)
	
	energyBar.max_value = playerNode.getMaxEnergy()
	
	hp_label = Label.new()
	hp_label.position = Vector2(20, 50)
	add_child(hp_label)

	shield_label = Label.new()
	shield_label.position = Vector2(20, 70)
	add_child(shield_label)
	
	gold_label = Label.new()
	gold_label.position = Vector2(20, 90)
	add_child(gold_label)
	energyBar.max_value = playerNode.getMaxEnergy()

	var db = CardDatabase.new()
	add_child(db)

	if db.cards.is_empty():
		push_error("No cards loaded from cards.json!")
		return

	for card_name in db.cards:
		playerNode.deckManager.add_card_to_deck(db.cards[card_name].duplicate_instance())

	playerNode.deckManager.build_combat_deck()


	if not playerNode or not enemyNode:
		push_warning("⚠️ Missing player or enemy reference in CombatManager!")

	print("Combat started.")
	start_player_turn()


# =========================================================
# TURN CONTROL
# =========================================================
func start_player_turn():
	refresh_hud()
	turn_counter += 1
	turn = "player" #probably not needed
	
	if protien_bar:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy()+2) #recover extra energy
	else:
		playerNode.setCurrentEnergy(playerNode.getMaxEnergy()) #recover energy
	
	energyBar.value=playerNode.getCurrentEnergy()
	print("\n-- PLAYER TURN START --")

	playerNode.shield = 0
	if handy_shield:
		playerNode.shield += 4
	#TODO # low priority but I should create a draw cards with no arguments to call later probably

	playerNode.deckManager.draw_cards(
		playerNode.deckManager.get_draw_limit()
	)
	refresh_hud()
	render_hand()
	



func refresh_hud():
	if hp_label:
		hp_label.text = "HP: %d / %d" % [playerNode.currentHP, playerNode.maxHP]
	if shield_label:
		shield_label.text = "Shield: %d" % playerNode.shield
	if gold_label:
		gold_label.text = "Gold: %d" % playerNode.gold
	energyBar.value = playerNode.getCurrentEnergy()

func end_player_turn():
	print("-- PLAYER TURN END --")
	playerNode.deckManager.discard_hand()
	clear_visual_hand()


func start_enemy_turn(): #TODO someone double check my work here
	turn = "enemy"
	print("\n-- ENEMY TURN START --")
	refresh_hud()

	for enemy in enemyNodes:
		var move_index = enemy.currentAction % enemy.moveset.size()
		var action_index = enemy.moveset[move_index]
		enemy_action(action_index, enemy)
		enemy.currentAction += 1
		await get_tree().create_timer(1.0).timeout

	end_enemy_turn()

func end_enemy_turn():
	print("-- ENEMY TURN END --")
	for enemy in enemyNodes:
		enemy.currentshield = 0
		refresh_hud()
	start_player_turn()


# =========================================================
# HAND RENDERING
# =========================================================
func render_hand():
	clear_visual_hand()

	var hand = playerNode.deckManager.get_hand()

	for i in range(hand.size()):
		var cardData: CardData = hand[i]

		var visual = card_scene.instantiate()
		visual.data = cardData
		visual.set_index(i)
		visual.position = Vector2(200 + 200 * i, 600)
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
func _card_selected(cardIndex):
	if cardIndex < 0 or cardIndex >= cardNodes.size():
		return
	
	if activeCardIndex == cardIndex:
		_reset_card_visuals(activeCardIndex)
		activeCardIndex = -1
		return
	
	if activeCardIndex != -1:
		_reset_card_visuals(activeCardIndex)
		
	
	cardNodes[cardIndex].scale = Vector2(.75, .75)
	cardNodes[cardIndex].position.y -= 100
	cardNodes[cardIndex].z_index = 100
	activeCardIndex = cardIndex

func _reset_card_visuals(cardIndex):
	if cardIndex != -1 and cardIndex < cardNodes.size():
		cardNodes[cardIndex].scale = Vector2(.45, .45) # Reset to exactly 100%
		cardNodes[cardIndex].position.y += 100
		cardNodes[cardIndex].z_index = 0
		
		

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
		print("Can't use cards during enemy turn!")
		return false

	var hand = playerNode.deckManager.get_hand()
	if index < 0 or index >= hand.size():
		return false

	var card: CardData = hand[index]

	if playerNode.getCurrentEnergy() < card.energy:
		print("Not enough energy!")
		return false

	playerNode.setCurrentEnergy(playerNode.getCurrentEnergy() - card.energy)
	energyBar.value = playerNode.getCurrentEnergy()

	resolve_card_effect(card, enemyNode)

	playerNode.deckManager.play_card(index)
	refresh_hud()
	return true


func resolve_card_effect(card: CardData, enemyNode: Node2D):

	# ===== BASIC TYPES =====
	match card.type:
		"attack":
			enemyNode.apply_damage_to_enemy(card.damage)

		"defense":
			apply_block_to_player(card.shield)

		"status":
			print("Status card used:", card.name)
	
	# ===== SPECIAL LOGIC =====
	if card.special.is_empty():
		return

	if card.special.get("skip_enemy_turn", false):
		print("Enemy turn skipped!")
		turn = "player"

	if card.special.get("damage_equal_shield", false):
		var dmg = playerNode.shield
		print("Dealing damage equal to shield:", dmg)
		enemyNode.apply_damage_to_enemy(dmg)

	if card.special.get("double_damage", false):
		print("Double damage applied")
		enemyNode.apply_damage_to_enemy(card.damage)

	if card.special.get("sword_and_shield", false):
		enemyNode.apply_damage_to_enemy(card.damage)
		apply_block_to_player(card.shield)
	refresh_hud()

# =========================================================
# DAMAGE & BLOCK
# =========================================================
func apply_damage_to_player(damage: int):
	if protection_charm:
		damage -= 5
	
	if damage <= 0:
		return # No damage to apply

	var damage_remaining = damage

	if playerNode.shield > 0:
		if damage_remaining <= playerNode.shield:
			playerNode.shield -= damage_remaining
			damage_remaining = 0
		else:
			damage_remaining -= playerNode.shield
			playerNode.shield = 0

	if damage_remaining > 0:
		playerNode.currentHP -= damage_remaining

	check_combat_state()
	refresh_hud()


func apply_block_to_player(amount: int):
	playerNode.shield += amount
	print("Applied block of ", amount)


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
			print("Wrong key!")
			apply_damage_to_player(meta_damage)
		expecting_meta_input = false


func enemy_action(intent: int, enemy: Node2D):
	var action
	if intent == -1:
		action = enemy.Actions[randi() % enemy.Actions.size()]
	else:
		action = enemy.Actions[intent]

	var dmg = action.damage
	var shld = action.shield
	print("Enemy uses:", action.name, "(", action.type, ")")

	match action.type:
		"simple":
			print("Enemy attacks for ", dmg)
			apply_damage_to_player(dmg)
			print("Enemy guards for ", shld)
			enemy.apply_shield_to_enemy(shld)

		"special":
			match action.name:
				"confuse":
					print("Enemy inflicts confusion!")
				"time stop":
					print("Enemy manipulates time!")
				"huh?":
					print("Enemy is drooling and staring blankly")
				"Roar":
					print("Enemy is preparing a big attack!")
				"Meta":
					trigger_meta_damage(20)

	print("Player HP:", playerNode.currentHP)
	check_combat_state()
	refresh_hud()


# =========================================================
# STATE CHECK
# =========================================================
func check_combat_state():
	if playerNode.getCurrentHP() <= 0:
		print("💀 Player defeated!")
		turn_counter = 0
		var prevScene = Global.prev_scene_path
		if prevScene != "":
			get_tree().change_scene_to_file(prevScene)
		return

	for i in range(enemyNodes.size() - 1, -1, -1):
		var enemyNode = enemyNodes[i]
		print("Enemy HP check: ", enemyNode.currentHp) #TODO debug, remove this
		if enemyNode.currentHp <= 0:
			print("✅ Enemy defeated!")
			if gold_totem:
				playerNode.gold += randi_range(50, 75)
			else:
				playerNode.gold += randi_range(25, 50)
			print("Gold awarded: ", playerNode.gold)
			enemyNode.queue_free()
			enemyNodes.remove_at(i)

	if enemyNodes.is_empty():
		print("All enemies defeated! Returning to map.")
		var prevScene = Global.prev_scene_path
		if prevScene != "":
			get_tree().change_scene_to_file(prevScene)


# =========================================================
# BUTTONS
# =========================================================
func _on_end_combat_test_pressed() -> void:
	handlePlayerVictory()
	var prevScene = Global.prev_scene_path
	
	
	await get_tree().create_timer(0.5).timeout
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
	
	var player = get_tree().get_first_node_in_group("game_events")
	
	if player is Player:
		player.curNodeId += 1
	
	saver_loader.savePlayer()
	
