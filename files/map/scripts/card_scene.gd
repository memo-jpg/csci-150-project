extends Node2D

signal cardActive(index: int)

var data: CardData = null
var card_index: int = -1

@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var description_label = $DescriptionLabel
@onready var sprite = $Sprite2D

func set_index(i: int) -> void:
	card_index = i

func _ready() -> void:
	if data != null:
		update_display()

func update_display() -> void:
	if name_label:
		name_label.text = data.name
		name_label.add_theme_color_override("font_color", Color.GOLD)
		name_label.add_theme_font_size_override("font_size", 32)

	if cost_label:
		cost_label.text = str(data.energy)
		cost_label.add_theme_color_override("font_color", Color.GOLD)
		cost_label.add_theme_font_size_override("font_size", 36)

	if description_label:
		var desc = ""
		if data.type == "attack":
			desc = "Deal %d damage" % data.damage
		elif data.type == "defense":
			desc = "Gain %d block" % data.shield
		else:
			desc = data.description if data.description != "" else data.type
		description_label.text = desc
		description_label.add_theme_color_override("font_color", Color.BLACK)
		description_label.add_theme_font_size_override("font_size", 32)

	if sprite and data.sprite != "":
		var tex = load(data.sprite)
		if tex:
			sprite.texture = tex

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("mouseClick"):
		if card_index >= 0:
			cardActive.emit(card_index)
