extends Node2D
const MAP_NODE = preload("res://mapDev/mapNode.tscn")

var spacing: int = 100
var start_x_pos: int = 50
var start_y_pos: int = 300

var num_of_nodes: int = 10

var placedNodes : Array = []


func _ready():
	print("_Map Node2D running")
	place_nodes()
	# draw_lines() # cur no need, but save/load work


func draw_lines():
	if(placedNodes.size() > 0):
		for i in range(len(placedNodes) - 1):
			var nodeA = placedNodes[i]
			var nodeB = placedNodes[i + 1]
		
			var line = Line2D.new()  # Create a new Line2D
			line.add_point(nodeA.position)  # Add the position of node A
			line.add_point(nodeB.position)  # Add the position of node B
			line.width = 2  # Line width
			line.default_color = Color(0, 0, 0)  # White color for the line
			
			# Add the line to the scene to visually connect the nodes
			add_child(line)



func place_nodes():

	for i in range(num_of_nodes):
		var newNode = MAP_NODE.instantiate()
		
		var xPos = start_x_pos + (i * spacing)
		var yPos = randi_range(250, 400)
		#print("start x:", start_x_pos)
		#print("spacing: ", spacing)
		#print("y pos:", yPos)
		
		newNode.setNodePos(xPos,yPos);
		newNode.position = newNode.getNodePos()
		var nodeId = i
		newNode.setNodeId(nodeId);
		var nodeName = "Node " + str(i)
		newNode.setNodeName(nodeName)
		
		if(i == 0):
			newNode.isActive = true
		
		
		add_child(newNode)
		placedNodes.append(newNode)
		# could pass a sceneChange("COMBAT_SCENE", newNode.data)
		# newNode.data could hold an array of enemies that appear
		
