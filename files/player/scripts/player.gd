class_name Player extends Node2D
# =============================
# Core Stats
# =============================
var characterName : String = "Elliot"
var shield : int = 0
var maxHP : int = 87
var currentHP : int = 87
var maxEnergy : int = 3
var currentEnergy : int = 3
var maxHandSize : int = 5
var deck: Dictionary = {}
var curNodeId : int
var gold: int = 0

# =============================
# Deck System (NEW)
# =============================
var deckManager


# =============================
# Getters
# =============================

func getCharacterName(): return characterName
func getCurrentHP(): return currentHP
func getMaxHP(): return maxHP
func getCurrentEnergy(): return currentEnergy
func getMaxEnergy(): return maxEnergy
func getMaxHandSize(): return maxHandSize
func getPosition(): return position


# =============================
# Setters
# =============================

func setCurrentHP(newHP : int):
	currentHP = clamp(newHP, 0, maxHP)

func setMaxHP(newMaxHP : int):
	maxHP = newMaxHP

func setCurrentEnergy(newEnergy : int):
	currentEnergy = clamp(newEnergy, 0, maxEnergy)

func setMaxEnergy(newMaxEnergy : int):
	maxEnergy = newMaxEnergy


# =============================
# Combat Helpers
# =============================

func apply_damage(amount: int):
	var damage_remaining = amount

	# Shield first
	if shield > 0:
		if damage_remaining <= shield:
			shield -= damage_remaining
			damage_remaining = 0
		else:
			damage_remaining -= shield
			shield = 0

	# Then HP
	if damage_remaining > 0:
		currentHP -= damage_remaining


func add_shield(amount: int):
	shield += amount


# =============================
# Deck Delegation
# =============================

func draw_cards():
	deckManager.draw_cards(maxHandSize)

func play_card(index: int):
	deckManager.play_card(index)

func discard_hand():
	deckManager.discard_hand()

func get_hand():
	return deckManager.hand


# =============================
# Initialization
# =============================

func _ready():
	add_to_group("player")
	currentHP = maxHP
	currentEnergy = maxEnergy
	if has_node("DeckManager"):
		deckManager = $DeckManager
	else:
		deckManager = DeckManager.new()
		add_child(deckManager)
# =============================
# Save / Load
# =============================

func on_save_game(saved_data:Array[savedData]):
	var my_data = SavedPlayerData.new()
	my_data.scene_path = scene_file_path
	my_data.position = global_position
	my_data.currentHP = currentHP
	my_data.characterName = characterName
	my_data.curNodeId = curNodeId
	my_data.gold = gold
	saved_data.append(my_data)

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()
	


func _on_deck_ready():
	pass


func on_load_game(saved_data:savedData):
	var my_data:SavedPlayerData = saved_data as SavedPlayerData
	global_position = my_data.position
	currentHP = my_data.currentHP
	characterName = my_data.characterName
	curNodeId = my_data.curNodeId
	gold = my_data.gold
