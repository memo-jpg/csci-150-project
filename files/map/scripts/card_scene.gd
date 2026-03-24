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
	# Position the labels so they don't overlap
	sprite.position = Vector2(0, -30)

	name_label.position = Vector2(-45, 50)
	name_label.size = Vector2(90, 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 10)

	cost_label.position = Vector2(-45, -85)
	cost_label.size = Vector2(20, 20)
	cost_label.add_theme_font_size_override("font_size", 12)

	description_label.position = Vector2(-45, 20)
	description_label.size = Vector2(90, 40)
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 9)

	if data != null:
		update_display()

func update_display() -> void:
	if name_label:
		name_label.text = data.name
	if cost_label:
		cost_label.text = str(data.energy)
	if description_label:
		var desc = ""
		if data.damage > 0:
			desc += "DMG: %d\n" % data.damage
		if data.shield > 0:
			desc += "DEF: %d" % data.shield
		if desc == "":
			desc = data.type
		description_label.text = desc
	if sprite and data.sprite != "":
		var tex = load(data.sprite)
		if tex:
			sprite.texture = tex
			sprite.scale = Vector2(0.3, 0.3)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("mouseClick"):
		cardActive.emit(card_index)
