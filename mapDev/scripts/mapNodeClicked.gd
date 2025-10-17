extends Node2D
@onready var map_node: mapNode = $".."

# have func take in a mapObject
# var mapObj = mapNode.new(1, 20, "testName")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	# if map_node is active, is clickable
	if (event.is_action_pressed("mouseClick") && map_node.isActive):
		print("Node is clicked") 
		print(map_node.getLevelInfo())
		
