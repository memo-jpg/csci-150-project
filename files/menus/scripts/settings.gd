extends Control


func _ready() -> void:
	var settings_box := get_node("MarginContainer/VBoxContainer")
	var deck_label := Label.new()
	deck_label.text = "Starter Deck"
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_box.add_child(deck_label)

	var starter_options := OptionButton.new()
	starter_options.add_item("Normal")
	starter_options.add_item("Elemental")
	starter_options.selected = 1 if Global.starter_deck_mode == "elemental" else 0
	starter_options.item_selected.connect(_on_starter_deck_selected)
	settings_box.add_child(starter_options)

	var row_label := Label.new()
	row_label.text = "Map Rows"
	row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_box.add_child(row_label)

	var row_options := OptionButton.new()
	for rows in [3, 4, 5]:
		row_options.add_item("%d Rows" % rows, rows)
	row_options.selected = clamp(Global.map_rows, 3, 5) - 3
	row_options.item_selected.connect(_on_map_rows_selected.bind(row_options))
	settings_box.add_child(row_options)


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_mute(0,value)


func _on_button_pressed() -> void:
	queue_free()


func _on_starter_deck_selected(index: int) -> void:
	Global.starter_deck_mode = "elemental" if index == 1 else "normal"


func _on_map_rows_selected(index: int, row_options: OptionButton) -> void:
	Global.map_rows = int(row_options.get_item_id(index))
