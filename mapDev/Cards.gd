class_name Cards extends Node2D

signal cardActive(cardId: int)

var id : int
var type: String = "None"
var cardName: String = "Default Card Name"
var description : String = " None"
var damage: int = 0
var shield: int = 0
var energyCost: int = 0
var sprite: String

#Setters
func setID(newID : int):
	id = newID
func setType(newType : String):
	type = newType
	#return type
func setName(newName : String):
	cardName = newName
	#return name
func setDamage(newDamage : int):
	damage = newDamage
	#return damage
func setShield(newShield : int):
	shield = newShield
	#return shield
func setEnergyCost(newCost : int):
	energyCost = newCost
	#return energyCost
func setSprite(newSprite : String):
	sprite = newSprite

#Getters
func getID():
	return id
func getType():
	return type
func getCardName():
	return cardName
func getDamage():
	return damage
func getShield():
	return shield
func getEnergyCost():
	return energyCost
func getSprite():
	return sprite

func _init() -> void:
	type = getType()
	cardName = getCardName()
	damage = getDamage()
	shield = getShield()
	energyCost = getEnergyCost()
	# effect= *status effect #to be added
	

# -------------------------
# Deck / hand / discard arrays
# -------------------------
#var deck: Array = []
#var hand: Array = []
#var discard: Array = []
#var drawlimit: int = 5

# -------------------------
# Utility functions
# -------------------------
#func shuffle_cards(deck: Array) -> void:
	#deck.shuffle()
#func add_card_to_deck(deck: Array, card: Card) -> void:
	#deck.append(card)
#func remove_card_from_deck(deck: Array, index: int) -> void:
	#if index >= 0 and index < deck.size():
		#deck.remove_at(index)
#
#
#func draw_cards(deck: Array, hand: Array, draw_limit: int) -> void:
	#for i in range(draw_limit):
		#if deck.size() == 0:
			#break
		#hand.append(deck.pop_back())
#
#
#func discard_card(hand: Array, discard: Array, index: int) -> void:
	#if index >= 0 and index < hand.size():
		#discard.append(hand[index])
		#hand.remove_at(index)
#
#
#func reset_combat(deck: Array, hand: Array, discard: Array) -> void:
	#deck += hand
	#hand.clear()
	#deck += discard
	#discard.clear()
	#shuffle_cards(deck)
#
#
#func discard_to_deck(deck: Array, discard: Array) -> void:
	#deck += discard
	#discard.clear()
	#shuffle_cards(deck)
#
#
#func hand_to_deck(deck: Array, hand: Array) -> void:
	#deck += hand
	#hand.clear()
	#shuffle_cards(deck)
#
#func hand_to_discard(hand: Array, discard: Array) -> void:
	#discard += hand
	#hand.clear()
	#
#func getdrawlimit():
	#return drawlimit
#func getdeck():
	#return deck
#func gethand():
	#return hand
#func getdiscard():
	#return discard
## -------------------------
## Example setup
## -------------------------
#func _ready() -> void:
	#print("=== Starting Card Deck Simulation ===")
#
	#add_card_to_deck(deck, Card.new("Attack", "Strike", 8, 0, 1))
	#add_card_to_deck(deck, Card.new("Defense", "Block", 0, 5, 0))
	#add_card_to_deck(deck, Card.new("Attack", "Slash", 10, 0, 1))
	#add_card_to_deck(deck, Card.new("Attack", "Heavy Blow", 12, -2, 2))
	#add_card_to_deck(deck, Card.new("Defense", "Guard", 0, 8, 1))
	#add_card_to_deck(deck, Card.new("Defense", "Giant Shield", 0, 30, 5))
	#add_card_to_deck(deck, Card.new("Special", "Confuse", 0, 0, 0))
#
	#shuffle_cards(deck)
	#draw_cards(deck, hand, drawlimit)
#
	#print("Your Hand:")
	#for i in range(hand.size()):
		#hand[i].display()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event.is_action_pressed("mouseClick")):
		print(cardName + ' is active')
		cardActive.emit(id)
