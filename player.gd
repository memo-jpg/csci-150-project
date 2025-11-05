class_name Player extends Sprite2D
var characterName : String = "Elliot"
var maxHP : int = 87
var currentHP : int = maxHP
var maxEnergy : int = 3
var currentEnergy : int = maxEnergy
var maxHandSize : int = 5
var currentHandSize : int = maxHandSize #default amount of cards we can hold on our turn 
var positon : int = 0 #will always stay 0,
#var statusList = [] #we don't have out statusEffect class done yet, so leaving this here.
#var sprite : Sprite = $Sprite
#var speed = 50
#var angular_speed = speed * PI
var deck: Array = []
var hand: Array = []
var discard: Array = []
var drawlimit: int = 5

#Getters
func getCharacterName():
	return characterName
func getCurrentHP():
	return currentHP
func getMaxHP():
	return maxHP
func getCurrentEnergy():
	return currentEnergy
func getMaxEnergy():
	return maxEnergy
func getCurrentHandSize():
	return currentHandSize
func getMaxHandSize():
	return maxHandSize
func getPosition():
	return positon
#Setters	
func setCurrentHP(newHP : int):
	currentHP = newHP
	#return currentHP
func setMaxHP(newMaxHP : int):
	maxHP = newMaxHP
	#return maxHP
func setCurrentEnergy(newCurrentEnergy : int):
	currentEnergy = newCurrentEnergy
	#return currentEnergy
func setMaxEnergy(newMaxEnergy : int):
	maxEnergy = newMaxEnergy
	#return maxEnergy
func setCurrentHandSize(newHandSize : int):
	currentHandSize = newHandSize
	#return currentHandSize
func setMaxHandSize(newMaxHandSize : int):
	maxHandSize = newMaxHandSize
	#return maxHandSize
		
 #-------------------------
 #Deck / hand / discard arrays
 #-------------------------
#var deck: Array = []
#var hand: Array = []
#var discard: Array = []
#var drawlimit: int = 5

 #-------------------------
 #Utility functions
 #-------------------------
func shuffle_cards(deck: Array) -> void:
	deck.shuffle()
func add_card_to_deck(deck: Array, card: Cards) -> void:
	deck.append(card)
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


func _init():
	print("Hello World!")

# Called when the node enters the scene tree for the FIRST time.
func _ready() -> void:
	#When the player first enters combat 
		#or any other scene for the FIRST time.
	currentHP = getCurrentHP()
	currentEnergy = getMaxEnergy()
	positon = getPosition()
	currentHandSize = getMaxHandSize()
	#print("HP:", currentHP)
	#print("Energy: ", currentEnergy)
	#print("position: ", positon)
	#print("Hand Size: ", currentHandSize)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation += angular_speed * delta
	if Input.is_action_pressed("ui_left"):
		#print("Left is pressed")
		currentHP -= 2
		#print("current hp is now: ", currentHP)
	if Input.is_action_pressed("ui_right"):
		#print("Right is pressed")
		currentEnergy -= 1
	
	
