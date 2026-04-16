extends Node2D
const MAP_NODE = preload("res://files/map/scenes/mapNode.tscn")
const PLAYER = preload("res://files/player/scenes/player.tscn")


var spacing: int = 100
var start_x_pos: int = 50 + 115 # 115 is old spacing
var start_y_pos: int = 600

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
		
		var loadedDict = saver_loader.loadGame(%_Map) # takes array here and appens the map nodes to it
		
		var playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		if(playerRestored):
			print("_MapScene.gd playerRestored:")
			print(playerRestored)
			
			playerRestored.scale *= 0.5
			playerRestored.z_index = 99
			
		else:
			print("Player is null is _MapScene.gd")
			
		
		
		for node in placedNodes:
			
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
		
		saver_loader.saveMapNodes()
		#saver_loader.saveGame()
		
		
	else: # New game case
		print("Save file does NOT exist")
		#Global.curNodeId = 0
		generate_map_1d()
		#generate_map_2d()
		
		generate_player()
		
		# Generates the player but doesn't scale it down nor position it correctly if i remove the save vvv
		saver_loader.saveGame()
		#saver_loader.loadGame()
		
	
	

func generate_map_2d():

	for row_num in range(row_of_nodes):
		for col_num in range(col_of_nodes):
			print("node[",row_num,"][",col_num,"]")
			
			var newNode = MAP_NODE.instantiate()
			var xPos = start_x_pos + (col_num * spacing)
			var yPos = start_y_pos + (row_num + col_spacing)
			
			newNode.setNodePos(xPos, yPos)
			newNode.position = newNode.getNodePos()
			
			var nodeId = col_num
			newNode.setNodeId(nodeId)
			
			if col_num == 0:
				newNode.isActive = true
				#var nodeName = "Node " + str(i)
			
			newNode.isCompleted = false
			
			if(col_num == shop_index): 
				newNode.setNodeName("SHOP")
			else:
				newNode.setNodeName("COMBAT")
				
			
			
			newNode.updateSprite()
			#tempMapArr.append(newNode)
			add_child(newNode)
		
		
	

func generate_player():
	
	# Creating player and setting position and curNodeId
	var newPlayer = PLAYER.instantiate()
	newPlayer.position = Vector2(60, 300)
	newPlayer.scale *= 0.5
	#newPlayer.curNodeId = 0
	add_child(newPlayer)
	

@warning_ignore("integer_division")
var shop_index = randi_range(num_of_nodes / 2 + 1, num_of_nodes - 2)

func generate_map_1d():
	var tempMapArr : Array
	
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
		
		if(i == shop_index): 
			newNode.setNodeName("SHOP")
		else:
			newNode.setNodeName("COMBAT")
			
		
		
		newNode.updateSprite()
		tempMapArr.append(newNode)
		add_child(newNode)
		
		
	
	draw_lines(tempMapArr)
	
	



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
