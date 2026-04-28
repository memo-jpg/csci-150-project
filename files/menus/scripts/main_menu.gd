extends Node2D
@export var settingsScene: PackedScene
@export var mapScene: String
@onready var scene_transition = $SceneTransition/AnimationPlayer

func _on_play_pressed() -> void:
	print('pressed')
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(mapScene)




func _on_settings_pressed() -> void:
	var childNode = settingsScene.instantiate()
	add_child(childNode)


func _on_del_save_pressed() -> void:
	var file_path = "user://savegame.tres"
	
	if FileAccess.file_exists(file_path):
		var error = DirAccess.remove_absolute(file_path)
	
		if error == OK:
			print("File deleted successfully")
		else:
			print("Error deleting file: ", error)
	else:
		print("File does not exist")
	
