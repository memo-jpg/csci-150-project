extends Area2D

class_name mapNode

@export var nodeId : int
@export var nodeName : String
@export var nodeData : int
@export var isActive : bool

@export var nodePos : Vector2

func _ready():
	input_pickable = true  # ensure it can receive input
	position = nodePos     # if you’re placing it dynamically

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	# if map_node is active, is clickable
	if (event.is_action_pressed("mouseClick") && isActive):
		print("Node is clicked") 
		print(getLevelInfo())
		# Current scene becomes previous globally
		Global.prev_scene_path = get_tree().current_scene.scene_file_path
		
		get_tree().change_scene_to_file("res://mapDev/_fakeCombat.tscn")

func on_save_game(saved_data:Array[SavedData]):
	var my_data = SavedData.new()
	my_data.position = global_position
	my_data.scene_path = scene_file_path
	
	saved_data.append(my_data)
	

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()
	
func on_load_game(saved_data:SavedData):
	global_position = saved_data.position


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
