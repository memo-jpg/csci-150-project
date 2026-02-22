class_name Player
extends Node2D

# =========================
# References
# =========================
var hud: HUD
var status_manager

# =========================
# Core stats
# =========================
var characterName: String = "Elliot"

var maxHP: int = 87
var currentHP: int = maxHP
var shield: int = 0

var maxEnergy: int = 3
var currentEnergy: int = maxEnergy

var maxHandSize: int = 5

var gold: int = 0

# =========================
# Deck System
# =========================
var deck_manager: DeckManager


<<<<<<< HEAD:player.gd
# =========================
# Lifecycle
# =========================
=======
var characterName : String = "Elliot"
var shield : int = 0
var maxHP : int = 100
var currentHP : int = maxHP
var maxEnergy : int = 3
var currentEnergy : int = maxEnergy
var maxHandSize : int = 5
var currentHandSize : int = maxHandSize #default amount of cards we can hold on our turn 
var positon : int = 0 #will always stay 0,
var gold : int = 0 #new 
#var statusList = [] #we don't have out statusEffect class done yet, so leaving this here.
#var speed = 50
#var angular_speed = speed * PI
var deck: Array = []
var hand: Array = []
var discard: Array = []



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

	if deck.size() == 0:
		discard_to_deck(deck, discard)
	for i in range(draw_limit):
		if deck.size() == 0:
			break
		hand.append(deck.pop_back())
func discard_card(hand: Array, discard: Array, index: int) -> void:
	if index >= 0 and index < hand.size():
		discard.append(hand[index])
		hand.remove_at(index)
func reset_combat(deck: Array, hand: Array, discard: Array) -> void:
	for card in hand:
		deck.append(card)
	for card in discard:
		deck.append(card)
	discard.clear()
	shuffle_cards(deck)
func discard_to_deck(deck: Array, discard: Array) -> void:
	for card in discard:
		deck.append(card)
	discard.clear()
	shuffle_cards(deck)
func hand_to_deck(deck: Array, hand: Array) -> void:
	for card in hand:
		deck.append(card)
	hand.clear()
	shuffle_cards(deck)
func hand_to_discard(hand: Array, discard: Array) -> void:
	for card in hand:
		discard.append(card)
	hand.clear()
func getdeck():
	return deck
func gethand():
	return hand
func getdiscard():
	return discard

func Apply_shield_to_player(shld: int):
	shield += shld
func _init():
	print("Hello World!")

# Called when the node enters the scene tree for the FIRST time.
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/player/scripts/player.gd
func _ready() -> void:
	currentHP = maxHP
	currentEnergy = maxEnergy

	deck_manager = DeckManager.new()
	add_child(deck_manager)

	hud = get_tree().get_root().get_node_or_null("CombatScene/HUD")

	if has_node("StatusEffectManager"):
		status_manager = get_node("StatusEffectManager")

	update_hud()

# null instance on "hud.update_all(self)

<<<<<<< HEAD:player.gd
# =========================
# DAMAGE / HEALING API
# =========================
func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
=======
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation += angular_speed * delta
	if Input.is_action_pressed("ui_left"):
		print("Left is pressed")
		currentHP -= 2 #TODO can you explain what this is for?
		print("current hp is now: ", currentHP)
		#print("Left is pressed")
		currentHP -= 2
		#print("current hp is now: ", currentHP)
		
	if Input.is_action_pressed("ui_right"):
		#print("Right is pressed")
		currentEnergy -= 1
	
	
	
	
var curNodeId : int
	
func on_save_game(saved_data:Array[savedData]):
	
	var my_data = SavedPlayerData.new()
	my_data.scene_path = scene_file_path
	my_data.position = global_position
	
	my_data.currentHP = currentHP
	my_data.characterName = characterName
	my_data.curNodeId = curNodeId
	
	saved_data.append(my_data)
	
	
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/player/scripts/player.gd

	var remaining := amount

<<<<<<< HEAD:player.gd
	# Apply to shield first
	if shield > 0:
		if remaining <= shield:
			shield -= remaining
			remaining = 0
		else:
			remaining -= shield
			shield = 0

	# Apply leftover to HP
	if remaining > 0:
		currentHP -= remaining

	check_death()
	update_hud()


func take_raw_damage(amount: int) -> void:
	if amount <= 0:
		return

	currentHP -= amount
	check_death()
	update_hud()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	currentHP = min(currentHP + amount, maxHP)
	update_hud()


func add_shield(amount: int) -> void:
	if amount <= 0:
		return

	shield += amount
	update_hud()


# =========================
# Energy
# =========================
func setCurrentEnergy(value: int):
	currentEnergy = clamp(value, 0, maxEnergy)
	update_hud()

func getCurrentEnergy() -> int:
	return currentEnergy

func getMaxEnergy() -> int:
	return maxEnergy


# =========================
# HP
# =========================
func getCurrentHP() -> int:
	return currentHP

func getMaxHP() -> int:
	return maxHP

func setMaxHP(value: int):
	maxHP = value

func setCurrentHP(value: int):
	currentHP = value


# =========================
# Death Handling
# =========================
func check_death() -> void:
	if currentHP > 0:
		return

	currentHP = 0
	print("Player has died")


# =========================
# HUD
# =========================
func update_hud() -> void:
	if hud:
		hud.update_all(self)


# =========================
# Deck Wrappers
# =========================
func build_combat_deck():
	deck_manager.build_combat_deck()

func draw_cards():
	deck_manager.draw_cards(deck_manager.get_draw_limit())

func get_hand() -> Array[CardData]:
	return deck_manager.get_hand()

func play_card(index: int) -> CardData:
	return deck_manager.play_card(index)

func discard_hand():
	deck_manager.discard_hand()

func add_card_to_deck(card: CardData):
	deck_manager.add_card_to_deck(card)
=======
func on_load_game(saved_data:savedData):
	var my_data:SavedPlayerData = saved_data as SavedPlayerData
	
	global_position = my_data.position
	currentHP = my_data.currentHP
	characterName = my_data.characterName
	curNodeId = my_data.curNodeId
	#print("on_laod_game curNodeId: ",Global.curNodeId)
	

func _on_deck_ready() -> void:
	var temp = get_node("./Deck")
	deck = temp.cards
>>>>>>> f05144573c9836166d408bced6341f4b3ec962c7:files/player/scripts/player.gd
