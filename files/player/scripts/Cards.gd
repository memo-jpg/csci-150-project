class_name Cards
extends Node2D

signal cardActive(cardId: int)

var id: int
var type: String = "None"
var cardName: String = "Default Card Name"
var description: String = "None"
var damage: int = 0
var shield: int = 0
var energyCost: int = 0
var sprite: String
var exhaust: bool = false
var special: Dictionary = {}

# -------------------------
# Setters
# -------------------------
func setID(newID: int): id = newID
func setType(newType: String): type = newType
func setName(newName: String): cardName = newName
func setDamage(newDamage: int): damage = newDamage
func setShield(newShield: int): shield = newShield
func setEnergyCost(newCost: int): energyCost = newCost
func setSprite(newSprite: String): sprite = newSprite
func setExhaust(value: bool): exhaust = value
func setSpecial(data: Dictionary): special = data

# -------------------------
# Getters
# -------------------------
func getID(): return id
func getType(): return type
func getCardName(): return cardName
func getDamage(): return damage
func getShield(): return shield
func getEnergyCost(): return energyCost
func getSprite(): return sprite
func doesExhaust(): return exhaust
func getSpecial(): return special

# -------------------------
# Click Handling
# -------------------------
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouseClick"):
		print(cardName + " is active")
		cardActive.emit(id)
