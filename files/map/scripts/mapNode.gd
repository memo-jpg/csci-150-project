extends Area2D

class_name mapNode


@export var nodeId : int
@export var nodeName : String
@export var nodeData : Array # rand array of ints to test
@export var isActive : bool
@export var isCompleted : bool

#@export_enum("COMBAT:0","SHOP:1") var nodeType : int = -1
enum nodeTypes {EMPTY, COMBAT, SHOP}
@export var curNodeType : int

@export var nodePos : Vector2

func _ready():
	pass
	


func _init(argId: int = -1, argName: String = "noName", argNodeType: nodeTypes = nodeTypes.EMPTY, argData: Array = [0, 1, 2, 3]):
	nodeId = argId
	nodeName = argName
	curNodeType = argNodeType
	nodeData = argData
	isActive = false
	isCompleted = false
	
	

@onready var scene_transition = $SceneTransition/AnimationPlayer

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	# if map_node is active, is clickable
	if (event.is_action_pressed("mouseClick") && isActive): # && nodeName == COMBAT
		print("Node is clicked") 
		print(getLevelInfo())
		print(getNodeId())
		
		# Current scene becomes previous globally
		Global.prev_scene_path = get_tree().current_scene.scene_file_path
		
		scene_transition.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		
		if(nodeName == "COMBAT"):
			print("Combat Node is clicked") 
			get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn") #Change to combat
			
		elif(nodeName == "SHOP"):
			print("Shop Node is clicked") 
			get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn") #Change to shop
			
		
		#Global.curNodeId += 1
		
		

@onready var saver_loader: saverLoader = %SaverLoader


func on_save_game(saved_data:Array[savedData]):
	
	var my_data = SavedMapData.new()
	my_data.scene_path = scene_file_path
	my_data.position = global_position
	
	my_data.nodeId = nodeId
	my_data.nodeName = nodeName
	my_data.isActive = isActive
	my_data.nodeData = nodeData
	my_data.nodePos = global_position
	my_data.isCompleted = isCompleted
	
	
	saved_data.append(my_data)
	

func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()
	
func on_load_game(saved_data:savedData):
	var my_data:SavedMapData = saved_data as SavedMapData
	
	global_position = my_data.position
	nodeId = my_data.nodeId
	nodeName = my_data.nodeName
	isActive = my_data.isActive
	isCompleted = my_data.isCompleted
	nodeData = my_data.nodeData
	
	

# figure out where to draw lines later
func updateSprite():
	if isCompleted:
		$mapNodeSprites.region_rect = Rect2(820, 0, 400, 400)
	elif nodeName == "COMBAT":
		$mapNodeSprites.region_rect = Rect2(0, 0, 400, 400)
	elif nodeName == "SHOP":
		$mapNodeSprites.region_rect = Rect2(410, 0, 400, 400)

func setNodeId(argId : int):
	nodeId = argId

func setNodeType(argNodeType : nodeTypes):
	curNodeType = argNodeType

func setNodeName(argName : String):
	nodeName = str(argName)

func setNodePos(argX : float, argY : float):
	nodePos = Vector2(argX, argY)


func getNodeName():
	return nodeName

func getNodeId():
	return nodeId

func getNodeType():
	return curNodeType

func getNodePos():
	return nodePos

func getLevelInfo():
	return ("Name: %s\nLevel %s\n" % [str(nodeName), str(nodeId)])
