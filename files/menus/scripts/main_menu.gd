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
