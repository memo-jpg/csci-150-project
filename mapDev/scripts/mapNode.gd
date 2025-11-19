extends Area2D

class_name mapNode


@export var nodeId : int
@export var nodeName : String
@export var nodeData : int
@export var isActive : bool

@export var nodePos : Vector2

func _ready():
	pass

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	# if map_node is active, is clickable
	if (event.is_action_pressed("mouseClick") && isActive):
		print("Node is clicked") 
		print(getLevelInfo())
		# Current scene becomes previous globally
		Global.prev_scene_path = get_tree().current_scene.scene_file_path
		
		get_tree().change_scene_to_file("res://combat.tscn")


func on_save_game(saved_data:Array[savedData]):
	
	var my_data = SavedMapData.new()
	my_data.position = global_position
	my_data.scene_path = scene_file_path
	my_data.isActive = isActive
	my_data.nodeData = nodeData
	my_data.nodeName = nodeName
	#my_data.nodePos = global_position
	my_data.nodeId = nodeId
	
	
	saved_data.append(my_data)
	

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()
	
func on_load_game(saved_data:savedData):
	var my_data:SavedMapData = saved_data as SavedMapData
	
	global_position = my_data.position
	isActive = my_data.isActive
	nodeData = my_data.nodeData
	nodeName = my_data.nodeName
	#nodePos = my_data.nodePos
	nodeId = my_data.nodeId
	
	

# figure out where to draw lines later



func _init(argId: int = -1, argName: String = "noName", argData: int = -1):
	nodeId = argId
	nodeName = argName
	nodeData = argData
	isActive = false
	
	


func getLevelInfo():
	return ("Name: %s\nLevel %s\n" % [str(nodeName), str(nodeId)])

func setNodeId(argId : int):
	nodeId = argId

func setNodeName(argName : String):
	nodeName = str(argName)

func setNodePos(argX : float, argY : float):
	nodePos = Vector2(argX, argY)

func getNodeName():
	return nodeName

func getId():
	return nodeId;
	
	
func getNodePos():
	return nodePos;
