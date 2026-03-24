extends Node2D

var playerNode
var db
var cardScene = preload("res://files/map/scenes/card_scene.tscn")

var cardNodes = []

func _ready():
	# Find player via group
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_error("_Combat: No player found in group 'player'")
		return
	playerNode = players[0]

	db = CardDatabase.new()
	add_child(db)

	# Reset deck
	playerNode.deckManager.deck.clear()

	var atk = db.get_template("Basic Attack")
	var def = db.get_template("Basic Defense")

	if atk == null or def == null:
		push_error("_Combat: Card templates not found!")
		return

	for i in range(3):
		playerNode.deckManager.add_card_to_deck(atk.duplicate_instance())
	for i in range(2):
		playerNode.deckManager.add_card_to_deck(def.duplicate_instance())

	playerNode.deckManager.build_combat_deck()
	playerNode.deckManager.draw_cards(5)

	render_hand()


func render_hand():
	clear_hand()

	var hand = playerNode.deckManager.hand

	for i in range(hand.size()):
		var cardData = hand[i]
		var card = cardScene.instantiate()
		card.data = cardData
		if "set_index" in card:
			card.set_index(i)
		card.position = Vector2(250 + i * 200, 650)
		add_child(card)
		cardNodes.append(card)


func clear_hand():
	for c in cardNodes:
		c.queue_free()
	cardNodes.clear()
