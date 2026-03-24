extends Node2D
const MAP_NODE = preload("res://files/map/scenes/mapNode.tscn")
const PLAYER = preload("res://files/player/scenes/player.tscn")


var spacing: int = 100
var start_x_pos: int = 50 + 115 # 115 is old spacing
var start_y_pos: int = 300

var num_of_nodes: int = 10


var row_spacing: int = 115
var col_spacing: int = 20
var row_of_nodes: int = 10
var col_of_nodes: int = 3
# nodeArr[10][3], 10 rows of nodes
# if nodeArr[X][0] 

#var placedNodes : Array = []
#var playerRestored : PlayerTwo

# create a var for player than can be sent to the loader and saved in the main scene so that position can be handled

@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var saver_loader: saverLoader = %SaverLoader
# @onready var player: Player = %Player

func _ready():
	print("_MainScene _ready running")
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")
	
	#generate_map_2d()
	
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
			print("player.curNodeId: ", playerRestored.curNodeId)
			print("player.name: ", playerRestored.name)
			print("player.position: ", playerRestored.position)
			#Global.curNodeId = playerRestored.curNodeId
			
			playerRestored.scale *= 0.5
			playerRestored.z_index = 99
			
		else:
			print("Player is null")
			
		for node in placedNodes:
			print("nodeId: ", node.nodeId, " | isActive: ", node.isActive, " | isCompleted: ", node.isCompleted, " | nodeName: ", node.nodeName)
			if node.nodeId == playerRestored.curNodeId - 1:
				playerRestored.global_position = node.global_position
				playerRestored.global_position.y -= 55
				node.isActive = false
				node.isCompleted = true
				node.updateSprite()
				
			elif node.nodeId == playerRestored.curNodeId:
				node.isActive = true
				node.isCompleted = false
				node.updateSprite()
				
			else:
				node.updateSprite()
				
		
		
		draw_lines(placedNodes)
		
		saver_loader.saveGame()
		
		
	else: # New game case
		print("Save file does NOT exist")
		#Global.curNodeId = 0
		generate_map_1d()
		
		generate_player()
		
		# Generates the player but doesn't scale it down nor position it correctly if i remove the save vvv
		saver_loader.saveGame()
		
	
	

func generate_map_2d():
	
	for rows in range(row_of_nodes):
		for cols in range(col_of_nodes):
			print("node[",rows,"][",cols,"]")
			#var newNode = MAP_NODE.instantiate()
			var xPos = start_x_pos + (rows * spacing)
			var yPos = (cols + col_spacing)
			

func generate_player():
	
	# Creating player and setting position and curNodeId
	var newPlayer = PLAYER.instantiate()
	newPlayer.position = Vector2(60, 300)
	newPlayer.scale *= 0.5
	newPlayer.curNodeId = -1
	add_child(newPlayer)
	

func generate_map_1d():
	
	for i in range(num_of_nodes):
		var newNode = MAP_NODE.instantiate()
		var xPos = start_x_pos + (i * spacing)
		var yPos = randi_range(250, 400)
		
		newNode.setNodePos(xPos,yPos);
		newNode.position = newNode.getNodePos()
		
		var nodeId = i
		newNode.setNodeId(nodeId)
		if i == 0:
			newNode.isActive = true
			#var nodeName = "Node " + str(i)
		
		newNode.isCompleted = false
		
		@warning_ignore("integer_division")
		if(Global.totShops < 1 && (i > num_of_nodes / 2 && i < num_of_nodes - 1) && randf() < 0.5): 
			Global.totShops += 1
			newNode.setNodeName("SHOP")
		else:
			newNode.setNodeName("COMBAT")
			
		
		# newNode.setCurNodeType("COMBAT")
		# make it so COMBAT has more weight to be selected, maybe have shop in the middle for now ?
		#newNode.setNodeType(COMBAT)
		newNode.updateSprite()
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
			# add a z_index (?)
			
			
			# Add the line to the scene to visually connect the nodes
			add_child(line)
