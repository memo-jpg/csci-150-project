extends Sprite2D
var characterName : String = "Elliot"
var currentHP : int = 80
var maxHP : int = 100
var currentEnergy : int = 80
var maxEnergy : int = 100
var handSize : int = 5 #default amount of cards we can hold on our turn 
var positon : int = 0 #will always stay 0,
#var satusList = [] #we don't have out statusEffect class done yet, so leaving this here.
#var sprite : Sprite = $Sprite

#var speed = 400
#var angular_speed = PI


func _init():
	pass#print("Hello World!")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
func getHandSize():
	return handSize
func getPosition():
	return positon
	
func setCurrentHP(newHP : int):
	currentHP = newHP
	return currentHP
	
func setMaxHP(newMaxHP : int):
	maxHP = newMaxHP
	return maxHP
	
func setCurrentEnergy(newCurrentEnergy : int):
	currentEnergy = newCurrentEnergy
	return currentEnergy
	
func setMaxEnergy(newMaxEnergy : int):
	maxEnergy = newMaxEnergy
	return maxEnergy
	
func setHandSize(newHandSize : int):
	handSize = newHandSize
	return handSize


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass#rotation += angular_speed * delta
