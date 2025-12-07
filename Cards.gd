extends Node
class_name notCards

# -------------------------
# Card definition
# -------------------------
class Card:
	var type: String
	var name: String
	var damage: int
	var shield: int
	var energy: int
	var exhaust: bool = false 
	var sprite: String


	func _init(_type: String, _name: String, _damage: int, _shield: int, _energy: int, _exhaust := false) -> void:
		type = _type
		name = _name
		damage = _damage
		shield = _shield
		energy = _energy
		exhaust = _exhaust


	func initCard(_type: String, _name: String, _damage: int, _shield: int, _energy: int, _sprite: String, _exhaust := false):
		type = _type
		name = _name
		damage = _damage
		shield = _shield
		energy = _energy
		exhaust = _exhaust
		sprite = _sprite
		
		# effect= *statuseffect #to be added
	func display() -> void:
		print("%s [%s] - Damage: %d, Shield: %d, Energy: %d Exhaust:%s" % [name, type, damage, shield, energy, str(exhaust)])

# -------------------------
# Deck / hand / discard arrays
# -------------------------
var deck: Array = []
var combatdeck: Array = []    # secondary deck for combat
var hand: Array = []
var exhaust: Array = []    # secondary discard where cards don't cyce back in
var discard: Array = []
var card_list: Array = []   #list of all cards in the game
var drawlimit: int = 5


func register_card(card: Card) -> void:
	# Adds card template to registry
	card_list.append(card)

func get_card_by_name(card_name: String) -> Card:
	for c in card_list:
		if c.name == card_name:
			return c
	return null

func add_card_to_main_deck_by_name(card_name: String) -> bool:
	#this is fluff so you don't need to consider it, just add the cards name and it will be added
	#you are free to fully modify the card
	var template := get_card_by_name(card_name)
	if template == null:
		return false
	
	var newcard := Card.new(
		template.type,
		template.name,
		template.damage,
		template.shield,
		template.energy,
		template.exhaust
	)

	deck.append(newcard)
	return true
	
	
# -------------------------
# Utility functions
# -------------------------
func shuffle_cards(deck: Array) -> void:
	deck.shuffle()
func add_card_to_deck(deck: Array, card: Card) -> void:
	deck.append(card)
func Increase_draw_limit(deck: Array, card: Card) -> void:
	drawlimit = (drawlimit + 1)

func remove_card_from_deck(deck: Array, index: int) -> void:
	if index >= 0 and index < deck.size():
		deck.remove_at(index)
func draw_cards_manual(deck: Array, hand: Array, draw_limit: int) -> void: #debug tool, could be a fun mechanic
	for i in range(draw_limit):
		if deck.size() == 0:
			break
		hand.append(deck.pop_back())

func draw_cards() -> void:
	for i in range(drawlimit):
		if combatdeck.size() == 0:
			break
		hand.append(combatdeck.pop_back())

func discard_card_manual(hand: Array, discard: Array, index: int) -> void:#debug tool
	if index >= 0 and index < hand.size():
		discard.append(hand[index])
		hand.remove_at(index)

func discard_card(index: int) -> void:
	if index >= 0 and index < hand.size():
		discard.append(hand[index])
		hand.remove_at(index)

func exhaust_card_manual(hand: Array, exhaust: Array, index: int) -> void: #debug tool
	if index >= 0 and index < hand.size():
		exhaust.append(hand[index])
		hand.remove_at(index)
		
func exhaust_card(index: int) -> void:
	if index >= 0 and index < hand.size():
		exhaust.append(hand[index])
		hand.remove_at(index)
		
func reset_combat_manual(deck: Array, hand: Array, discard: Array) -> void: #debug tool
	hand.clear()
	discard.clear()
	combatdeck.clear()
	exhaust.clear()
func reset_combat() -> void:
	hand.clear()
	discard.clear()
	exhaust.clear()
	combatdeck.clear()

func build_combat_deck() -> void:
	# Make a deep copy of deck so combat can modify it freely
	combatdeck.clear()
	for c in deck:
		var copy := Card.new(
			c.type, c.name, c.damage, c.shield, c.energy, c.exhaust
		)
		combatdeck.append(copy)

	shuffle_cards(combatdeck)


func discard_to_combatdeck(deck: Array, discard: Array) -> void:
	combatdeck += discard
	discard.clear()
	shuffle_cards(combatdeck)


func hand_to_combatdeck(deck: Array, hand: Array) -> void:
	combatdeck += hand
	hand.clear()
	shuffle_cards(combatdeck)

func hand_to_discard(hand: Array, discard: Array) -> void:
	discard += hand
	hand.clear()

func try_get_card(card_name: String, cost := -1, chance := -1, player_gold := 0) -> bool:
	#a tool to add cards to deck, by either paying or by chance or both or neither
	# If cost is used, player must pay
	if cost > 0:
		if player_gold < cost:
			return false
		player_gold -= cost

	# If chance is used, roll for success
	if chance > 0:
		if randi() % 100 >= chance:
			return false
	# Finally try to add card
	return add_card_to_main_deck_by_name(card_name)

#example usage:
#try_get_card("Slash")                          # direct award
#try_get_card("Guard", 30, -1, player.gold)     # buy card for 30
#try_get_card("Hollow strike", -1, 50)          # 50% chance reward

func getdrawlimit():
	return drawlimit
func getdeck():
	return deck
func gethand():
	return hand
func getdiscard():
	return discard
# -------------------------
# Example setup
# -------------------------
func _ready() -> void:
	print("=== Starting Card Deck Simulation ===")

	# Example registry creation
	register_card(Card.new("Attack", "Strike", 8, 0, 1))
	register_card(Card.new("Defense", "Block", 0, 5, 0))
	register_card(Card.new("Attack", "Slash", 10, 0, 1))
	register_card(Card.new("Attack", "Heavy Blow", 12, -2, 2))
	register_card(Card.new("Defense", "Guard", 0, 8, 1))
	register_card(Card.new("Defense", "Giant Shield", 0, 30, 5))
	register_card(Card.new("Special", "Confuse", 0, 0, 0))
	register_card(Card.new("Special", "Time Control", 0, 0, 10, true))
	register_card(Card.new("Special", "Sword & Shield", 8, 8, 2))
	register_card(Card.new("Special", "Shield Slam", 0, 0, 2))
	register_card(Card.new("Attack", "Hollow strike", 20, 0, 1, true))
	register_card(Card.new("Defense", "Hollow Shield", 0, 5, 0, true))

	# Add some cards to your actual deck
	add_card_to_main_deck_by_name("Strike")
	add_card_to_main_deck_by_name("Block")
	add_card_to_main_deck_by_name("Slash")

	build_combat_deck() #an example so it can get printed
	draw_cards()

	print("Your Hand:")
	for c in hand:
		c.display()
