extends Node2D

class_name mapNode


@export var nodeId : int
@export var nodeName : String
@export var nodeData : int
@export var isActive : bool


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


func getNodeName():
	return nodeName

func getId():
	return nodeId;
	
	
