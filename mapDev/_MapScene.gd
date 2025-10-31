extends Node2D
const MAP_NODE = preload("res://mapDev/mapNode.tscn")



var spacing: int = 100
var start_x_pos: int = 50
var start_y_pos: int = 300

var num_of_nodes: int = 10

func _ready():
	place_nodes()
	




func place_nodes():
	for i in range(num_of_nodes):
		
		var newNode = MAP_NODE.instantiate()
		
		
		var xPos = start_x_pos + (i * spacing)
		var yPos = randi_range(250, 400)
		print("start x:", start_x_pos)
		print("spacing: ", spacing)
		print("y pos:", yPos)
		# yPos + xPos
		
		
		var nodeId = i
		var nodeName = "Node " + str(i)
		
		
		MapData.mapInfo[nodeId] = {
			'nodeName': nodeName,
			'isActive': true,
			'data': i * 10,
			'instance': newNode
		}
		
		newNode.position = Vector2(xPos, yPos)
		newNode.setNodeId(nodeId);
		newNode.setNodeName(nodeName)
		#if(i == 0):
		newNode.isActive = true
		
		add_child(newNode)
		
