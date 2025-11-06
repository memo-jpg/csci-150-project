extends Button
@export var playScene: String

func _pressed():
	print('pressed')
	get_tree().change_scene_to_file(playScene)
