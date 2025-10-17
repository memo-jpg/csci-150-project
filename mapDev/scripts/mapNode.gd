extends Node2D

class_name mapNode

@export var data : int
@export var nodeId : int
@export var nodeName : String
@export var isActive : bool

func _init(argData: int = 0, argId: int = 0, argName: String = "noName"):
	data = argData
	nodeId = argId
	
	nodeName = argName
	isActive = false

func setNextID(argID : int):
	nodeId = argID

func getLevelInfo():
	return ("Name: %s\nLevel %s\n" % [str(nodeName), str(nodeId)])

func getId():
	return nodeId;
