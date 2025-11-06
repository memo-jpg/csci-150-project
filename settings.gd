extends Control



func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_mute(0,value)


func _on_button_pressed() -> void:
	queue_free()
