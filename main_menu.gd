extends Node2D
@export var settingsScene: PackedScene

func _on_play_pressed() -> void:
	print('pressed')
	get_tree().change_scene_to_file('res://mapDev/mapScene.tscn')


func _on_settings_pressed() -> void:
	var childNode = settingsScene.instantiate()
	add_child(childNode)
