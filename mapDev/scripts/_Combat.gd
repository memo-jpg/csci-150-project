extends Node2D

func _ready() -> void:
	pass
	# Simulate combat
	# After combat, return to the previous scene
	# end_combat()

func end_combat():
	# Get the path to the previous scene (map)
	var prevScene = Global.prev_scene_path
	if (prevScene != ""):
		get_tree().change_scene_to_file(prevScene)
