extends Node
class_name Cards

# -------------------------
# Card definition
# -------------------------
class Card:
	var type: String
	var name: String
	var damage: int
	var shield: int
	var energy: int

	func _init(_type: String, _name: String, _damage: int, _shield: int, _energy: int) -> void:
		type = _type
		name = _name
		damage = _damage
		shield = _shield
		energy = _energy
		# effect= *status effect #to be added
	func display() -> void:
		print("%s [%s] - Damage: %d, Shield: %d, Energy: %d" % [name, type, damage, shield, energy])


# -------------------------
# Deck / hand / discard arrays
# -------------------------
var deck: Array = []
var hand: Array = []
var discard: Array = []
var drawlimit: int = 5


# -------------------------
# Utility functions
# -------------------------
func shuffle_cards(deck: Array) -> void:
	deck.shuffle()


func add_card_to_deck(deck: Array, card: Card) -> void:
	deck.append(card)
<<<<<<< HEAD
func Increase_draw_limit(deck: Array, card: Card) -> void:
	drawlimit = (drawlimit + 1)
=======

>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1

func remove_card_from_deck(deck: Array, index: int) -> void:
	if index >= 0 and index < deck.size():
		deck.remove_at(index)


func draw_cards(deck: Array, hand: Array, draw_limit: int) -> void:
	for i in range(draw_limit):
		if deck.size() == 0:
			break
		hand.append(deck.pop_back())


func discard_card(hand: Array, discard: Array, index: int) -> void:
	if index >= 0 and index < hand.size():
		discard.append(hand[index])
		hand.remove_at(index)


func reset_combat(deck: Array, hand: Array, discard: Array) -> void:
	deck += hand
	hand.clear()
	deck += discard
	discard.clear()
	shuffle_cards(deck)


func discard_to_deck(deck: Array, discard: Array) -> void:
	deck += discard
	discard.clear()
	shuffle_cards(deck)


func hand_to_deck(deck: Array, hand: Array) -> void:
	deck += hand
	hand.clear()
	shuffle_cards(deck)

func hand_to_discard(hand: Array, discard: Array) -> void:
	discard += hand
	hand.clear()
	
func getdrawlimit():
	return drawlimit
func getdeck():
	return deck
func gethand():
	return hand
func getdiscard():
	return discard
<<<<<<< HEAD

=======
>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
# -------------------------
# Example setup
# -------------------------
func _ready() -> void:
	print("=== Starting Card Deck Simulation ===")

	add_card_to_deck(deck, Card.new("Attack", "Strike", 8, 0, 1))
	add_card_to_deck(deck, Card.new("Defense", "Block", 0, 5, 0))
	add_card_to_deck(deck, Card.new("Attack", "Slash", 10, 0, 1))
	add_card_to_deck(deck, Card.new("Attack", "Heavy Blow", 12, -2, 2))
	add_card_to_deck(deck, Card.new("Defense", "Guard", 0, 8, 1))
	add_card_to_deck(deck, Card.new("Defense", "Giant Shield", 0, 30, 5))
	add_card_to_deck(deck, Card.new("Special", "Confuse", 0, 0, 0))
<<<<<<< HEAD
	add_card_to_deck(deck, Card.new("Special", "Time control", 0, 0, 10))
	add_card_to_deck(deck, Card.new("Special", "Sword & shield", 8, 8, 2))
	add_card_to_deck(deck, Card.new("Special", "Shield slam", 0, 0, 2))
=======

>>>>>>> 31680f1b18f72913f42324819c6b75811811c8f1
	shuffle_cards(deck)
	draw_cards(deck, hand, drawlimit)

	print("Your Hand:")
	for i in range(hand.size()):
		hand[i].display()
