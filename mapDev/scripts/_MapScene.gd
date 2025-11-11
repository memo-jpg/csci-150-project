extends Node2D
const MAP_NODE = preload("res://mapDev/mapNode.tscn")

var spacing: int = 100
var start_x_pos: int = 50
var start_y_pos: int = 300

var num_of_nodes: int = 10

var placedNodes : Array = []

@onready var saver_loader: saverLoader = %SaverLoader
@onready var player: Player = %Player

func placingPlayer():
	if(placedNodes.size() > 0):
		for i in range(placedNodes.size()):
			if(placedNodes[i].isActive):
				player.global_position = placedNodes[i].position 
	
	


func _ready():
	print("_Map Node2D running")
	# if (NEW_GAME): { place nodes, saveGame }, else{ loadGame }
	# place_nodes()
	# draw_lines() # cur no need, but save/load work
	print(player.getCharacterName())
	
	print(player.getCurrentHP())
	player.setCurrentHP(20)
	print(player.getCurrentHP())
	
	if(FileAccess.file_exists("user://savegame.tres")):
		print("Save file exists")
		saver_loader.loadGame(placedNodes)
		draw_lines()
		placingPlayer()
		# loadGame // from SaverLoader

		
	else: # if new game
		print("Save file does NOT exist")
		generate_map()
		saver_loader.saveGame()
		saver_loader.loadGame(placedNodes)
		draw_lines()
		placingPlayer()
		# saveGame() # save the nodes
		
	# _play_char.position = placedNodes[0].position


func generate_map():
	
	
	
	
	
	
	
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
		else:
			newNode.isActive = false
		# newNode.isActive = true;
		
		add_child(newNode)
		# placedNodes.append(newNode)
		# could pass a sceneChange("COMBAT_SCENE", newNode.data)
		# newNode.data could hold an array of enemies that appear
		



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
