class_name map_node extends Area2D

# dont need this file/folder, in test_map_node 

@export var nodeId : int
@export var nodeName : String
@export var nodeData : Array # rand array of ints to test
@export var isActive : bool

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
	
	print(curNodeType)
	

# figure out where to draw lines later
func change_sprite():
	pass


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
