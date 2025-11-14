extends Sprite2D
var characterName : String = "Elliot"
var shield : int = 0
var maxHP : int = 87
var currentHP : int = maxHP
var maxEnergy : int = 3
var currentEnergy : int = maxEnergy
var maxHandSize : int = 5
var currentHandSize : int = maxHandSize #default amount of cards we can hold on our turn 
var positon : int = 0 #will always stay 0,
var gold : int = 0 #new 
#var statusList = [] #we don't have out statusEffect class done yet, so leaving this here.
#var sprite : Sprite = $Sprite
var speed = 50
var angular_speed = speed * PI

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
func setCurrentHandSize(newHandSize : int):
	currentHandSize = newHandSize
	return currentHandSize
func setMaxHandSize(newMaxHandSize : int):
	maxHandSize = newMaxHandSize
	return maxHandSize

func Apply_shield_to_player(shld: int):
	shield += shld
func _init():
	print("Hello World!")

# Called when the node enters the scene tree for the FIRST time.
func _ready() -> void:
	currentHP = getMaxHP()
	currentEnergy = getMaxEnergy()
	positon = getPosition()
	currentHandSize = getMaxHandSize()
	print("HP:", currentHP)
	print("Energy: ", currentEnergy)
	print("position: ", positon)
	print("Hand Size: ", currentHandSize)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation += angular_speed * delta
	if Input.is_action_pressed("ui_left"):
		print("Left is pressed")
		currentHP -= 2 #TODO can you explain what this is for?
		print("current hp is now: ", currentHP)
	if Input.is_action_pressed("ui_right"):
		print("Right is pressed")
	
	
