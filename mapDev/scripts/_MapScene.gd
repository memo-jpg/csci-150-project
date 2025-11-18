extends Node2D
const MAP_NODE = preload("res://mapDev/mapNode.tscn")
const PLAYER = preload("res://mapDev/_testPlayer.tscn")


var spacing: int = 100
var start_x_pos: int = 50
var start_y_pos: int = 300

var num_of_nodes: int = 10

#var placedNodes : Array = []
#var playerRestored : PlayerTwo

# create a var for player than can be sent to the loader and saved in the main scene so that position can be handled

@onready var saver_loader: saverLoader = %SaverLoader
# @onready var player: Player = %Player

func _ready():
	print("_Map Node2D running")
	
	#print(playChar.getCurrentHP())
	#playChar.setCurrentHP(20)
	#print(playChar.getCurrentHP())
	
	if(FileAccess.file_exists("user://savegame.tres")):
		print("Save file exists")
		
		var loadedDict = saver_loader.loadGame() # takes array here and appens the map nodes to it
		

		
		var playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		
		if(playerRestored):
			print(playerRestored)
			print("player.curNodeId: ", playerRestored.curNodeId)
			print("player.name: ", playerRestored.name)
			print("player.position: ", playerRestored.position)
		else:
			print("Player is null")
			
		for node in placedNodes:
			print("Node pos: ", node.global_position)
			if(node.nodeId == playerRestored.curNodeId):
				playerRestored.position = node.position
				#node.isActive = false
				#playerRestored.curNodeId = node.nodeId + 1
				
			#if(node.isActive):
				
		
		draw_lines(placedNodes)
		# placingPlayer()
		# loadGame // from SaverLoader
		
	else: # if new game
		print("Save file does NOT exist")
		generate_map()
		
		var newPlayer = PLAYER.instantiate()
		newPlayer.setCurrentHP(20)
		newPlayer.position = Vector2(60, 60)
		
		newPlayer.curNodeId = 0
		
		add_child(newPlayer)
		print(newPlayer.getCurrentHP())
		
		
		
		saver_loader.saveGame()
		var loadedDict = saver_loader.loadGame()
		
		var playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		
		if(playerRestored):
			print(playerRestored)
		else:
			print("Player is null")
			
		for node in placedNodes:
			print("Node pos: ", node.global_position)
			if(node.nodeId == playerRestored.curNodeId):
				playerRestored.position = node.position
				#node.isActive = false
				#playerRestored.curNodeId = node.nodeId + 1
				
		
		draw_lines(placedNodes)
		
		# placingPlayer()
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
		#placedNodes.append(newNode)
		# could pass a sceneChange("COMBAT_SCENE", newNode.data)
		# newNode.data could hold an array of enemies that appear
		
		



func draw_lines(arrArg : Array):
	if(arrArg.size() > 0):
		for i in range(len(arrArg) - 1):
			var nodeA = arrArg[i]
			var nodeB = arrArg[i + 1]
			
			var line = Line2D.new()  # Create a new Line2D
			line.add_point(nodeA.position)  # Add the position of node A
			line.add_point(nodeB.position)  # Add the position of node B
			line.width = 2  # Line width
			line.default_color = Color(0, 0, 0)  # White color for the line
			
			# Add the line to the scene to visually connect the nodes
			add_child(line)
