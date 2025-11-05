extends Node2D
@onready var map_node: mapNode = $".."

# have func take in a mapObject
# var mapObj = mapNode.new(1, 20, "testName")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	# if map_node is active, is clickable
	if (event.is_action_pressed("mouseClick") && map_node.isActive):
		print("Node is clicked") 
		print(map_node.getLevelInfo())
		# Current scene becomes previous globally
		Global.prev_scene_path = get_tree().current_scene.scene_file_path
		
		get_tree().change_scene_to_file("res://mapDev/_mapTestScene.tscn")

		# does change scene, just need to make temp combat scene
		# get_tree().change_scene_to_file("res://mapDev/spriteCharMap.tscn")
		
	# on body intered would be the player spritePos matches the mapNode pos, "_body" would be player sprite	
	#	func _on_body_entered(_body):
	#		if Input.is_action_pressed(“click”):
	#    		get_tree().change_scene_to_file(“res://apartment stairway.tscn”)
		
		# trigger area could have the signal called "body_entered", if the signal is emitted, change the scene
