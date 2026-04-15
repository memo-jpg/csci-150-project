extends Node2D

signal cardActive(index)

var data: CardData
var index: int = -1

@onready var nameLabel = $NameLabel
@onready var costLabel = $CostLabel
@onready var descLabel = $DescriptionLabel
@onready var spriteNode = $Sprite2D


func _ready():
	update_visuals()


func set_index(i: int):
	index = i


func update_visuals():
	if data == null:
		return

	nameLabel.text = data.name
	costLabel.text = str(data.energy)

	if data.type == "attack":
		descLabel.text = "Deal %d damage" % data.damage
	elif data.type == "defense":
		descLabel.text = "Gain %d block" % data.shield
	else:
		descLabel.text = data.description

	if data.sprite != "":
		spriteNode.texture = load(data.sprite)


func _on_area_2d_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("CARDS.GD input event clicked")
		cardActive.emit(index)
