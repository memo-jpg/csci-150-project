class_name CardDatabase
extends Node

var card_templates: Dictionary = {}

func _ready():
	load_cards("res://cards.json")


func load_cards(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open cards.json")
		return

	var json_text = file.get_as_text()
	file.close()

	var parser := JSON.new()
	var result := parser.parse(json_text)

	if result != OK:
		push_error("JSON Parse Error: " + parser.get_error_message())
		return

	var data = parser.get_data()
	var card_array = data["cards"]

	for card_dict in card_array:
		var normalized_type := normalize_type(card_dict["type"])

		var card := CardData.new(
			card_dict["id"],
			normalized_type,
			card_dict["cardName"],
			card_dict["damage"],
			card_dict["shield"],
			card_dict["energyCost"],
			card_dict["sprite"],
			card_dict.get("exhaust", false),
			card_dict.get("special", {})
		)

		card_templates[card.name] = card

	print("Loaded ", card_templates.size(), " card templates.")


func get_template(card_name: String) -> CardData:
	return card_templates.get(card_name)


func normalize_type(t: String) -> String:
	match t.to_lower():
		"atk":
			return "attack"
		"def":
			return "defense"
		"status":
			return "status"
		_:
			return t.to_lower()
		
