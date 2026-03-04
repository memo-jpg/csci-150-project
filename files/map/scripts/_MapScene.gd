extends Node2D
const MAP_NODE = preload("res://files/map/scenes/mapNode.tscn")
const PLAYER = preload("res://files/player/scenes/player.tscn")


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
	print("_MainScene _ready running")
	
	handleScene()
	


func handleScene():
	if(FileAccess.file_exists("user://savegame.tres")):
		print("Save file exists")
		
		var loadedDict = saver_loader.loadGame() # takes array here and appens the map nodes to it
		
		var playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		if(playerRestored):
			print("_MapScene:")
			print(playerRestored)
			print("Global.curNodeId: ", Global.curNodeId)
			print("player.name: ", playerRestored.name)
			print("player.position: ", playerRestored.position)
			#Global.curNodeId = playerRestored.curNodeId
			print("player.curNodeId: ", playerRestored.curNodeId)
		else:
			print("Player is null")
			
		for node in placedNodes:
			print("Node pos: ", node.global_position)
			if(node.nodeId == Global.curNodeId && Global.curNodeId <= placedNodes.size()):
				playerRestored.global_position = node.global_position # somethings wrong with player restored
				playerRestored.global_position.y -= 55
				playerRestored.scale *= 0.5
				# playerRestored.z_index = 99
				node.isActive = true
				
			else: #(node.nodeId != Global.curNodeId):
				node.isActive = false
					
					
		
				
				
		draw_lines(placedNodes)
		
		saver_loader.saveGame()
		
	else: # New game case
		print("Save file does NOT exist")
		Global.curNodeId = 0
		generate_map()
		
		# Creating player and setting position and curNodeId
		var newPlayer = PLAYER.instantiate()
		newPlayer.position = Vector2(60, 60)
		newPlayer.curNodeId = Global.curNodeId
		add_child(newPlayer)
		
		saver_loader.saveGame()
		var loadedDict = saver_loader.loadGame()
		
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
			if(node.nodeId == Global.curNodeId && Global.curNodeId <= placedNodes.size()):
				playerRestored.global_position = node.global_position
				playerRestored.global_position.y -= 55
				node.isActive = true
				
			else: #(node.nodeId != Global.curNodeId):
				node.isActive = false
				
		
		
		draw_lines(placedNodes)
		
		
		saver_loader.saveGame()
				#node.isActive = false
				#playerRestored.curNodeId = node.nodeId + 1
				
		
	

func generate_map():
	
	for i in range(num_of_nodes):
		var newNode = MAP_NODE.instantiate()
		
		var xPos = start_x_pos + (i * spacing)
		var yPos = randi_range(250, 400)
		
		newNode.setNodePos(xPos,yPos);
		newNode.position = newNode.getNodePos()
		
		var nodeId = i
		newNode.setNodeId(nodeId)
		
		#var nodeName = "Node " + str(i)
		newNode.setNodeName("COMBAT")
		
		if randf() < 0.5:
			pass
			
		
		@warning_ignore("integer_division")
		if(Global.totShops < 1 && (i > num_of_nodes / 2 && i < num_of_nodes - 1) && randf() < 0.5): 
			Global.totShops += 1
			newNode.setNodeName("SHOP")
		else:
			pass
		
		# newNode.setCurNodeType("COMBAT")
		# make it so COMBAT has more weight to be selected, maybe have shop in the middle for now ?
		#newNode.setNodeType(COMBAT)
		
		add_child(newNode)
		
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
