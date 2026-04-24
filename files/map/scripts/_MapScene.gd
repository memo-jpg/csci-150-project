extends Node2D
const MAP_NODE = preload("res://files/map/scenes/mapNode.tscn")
const PLAYER = preload("res://files/player/scenes/player.tscn")


var spacing: int = 100
var start_x_pos: int = 50 + 100 # 115 is old spacing
var start_y_pos: int = 250

var num_of_nodes: int = 10


var col_spacing: int = 100
var row_spacing: int = 70
var col_of_nodes: int = 10
var row_of_nodes: int = 3
# nodeArr[10][3], 10 rows of nodes
# if nodeArr[X][0] 

var node_grid = []
var playerRestored = null

# create a var for player than can be sent to the loader and saved in the main scene so that position can be handled

@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var saver_loader: saverLoader = %SaverLoader
# @onready var player: Player = %Player

func _ready():
	print("_MainScene _ready running")
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")
	
	
	handleScene()
	



func handleScene():
	if(FileAccess.file_exists("user://savegame.tres")):
		print("Save file exists")
		
		var loadedDict = saver_loader.loadGame(%_Map) # takes array here and appens the map nodes to it
		
		playerRestored = loadedDict.get("player", null)
		var placedNodes = loadedDict.get("mapNodes", [])
		
		if(playerRestored):
			print("_MapScene.gd playerRestored:")
			print(playerRestored)
			
			playerRestored.scale *= 0.5
			playerRestored.z_index = 99
			
		else:
			print("Player is null is _MapScene.gd")
			
		
		
		for node in placedNodes:
			if node.nodeId == playerRestored.curNodeId:
				playerRestored.global_position = node.global_position
				playerRestored.global_position.y -= 55
				node.isActive = false
				node.isCompleted = true
				node.updateSprite()
				
			else:
				node.updateSprite()
			
			
		
		node_grid.clear()
		node_grid.resize(row_of_nodes)
		for row in range(row_of_nodes):
			node_grid[row] = []
			node_grid[row].resize(col_of_nodes)
			for col in range(col_of_nodes):
				node_grid[row][col] = null
				
		for node in placedNodes:
			var row = node.nodeId / col_of_nodes
			var col = node.nodeId % col_of_nodes
			node_grid[row][col] = node
			node.node_selected.connect(_on_node_selected)
		
		var player_col = playerRestored.curNodeId % col_of_nodes
		activate_column(player_col + 1)
		draw_lines(placedNodes)
		
		saver_loader.saveMapNodes()
		#saver_loader.saveGame()
		
		
	else: # New game case
		print("Save file does NOT exist")
		generate_map_2d()
		generate_player()
		
		# Generates the player but doesn't scale it down nor position it correctly if i remove the save vvv
		saver_loader.saveGame()
		
	



func generate_map_2d():
	for row_num in range(row_of_nodes):
		var cur_row = []
		
		for col_num in range(col_of_nodes):
			print("")
			
			
			var newNode = MAP_NODE.instantiate()
			var xPos = start_x_pos + (col_num * col_spacing)
			var yPos = start_y_pos + (row_num * row_spacing)
			
			print("node[",row_num,"][",col_num,"]: pos[",xPos,"][",yPos,"]")
			
			
			newNode.setNodePos(xPos, yPos)
			newNode.position = newNode.getNodePos()
			
			var nodeId = row_num * col_of_nodes + col_num
			print("nodeId: ", nodeId, " | IN _MapScene.gd")
			# maybe make the nodeID the "row_num" + "col_num" as string id so [row][col] [2][1] would be id 21
			#var nodeId = col_num
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
			newNode.node_selected.connect(_on_node_selected)
			cur_row.append(newNode)
			add_child(newNode)
		
		node_grid.append(cur_row)
		
		
	
	activate_column(1)
	

func _on_node_selected(nodeId: int):
	
	print("nodeId Selected: ", nodeId, " | in _MapScene.gd")
	if playerRestored == null: 
		return
	
	var clicked_col = nodeId % col_of_nodes
	var clicked_row = nodeId / col_of_nodes
	var player_col
	
	if playerRestored.curNodeId == -1:
		player_col = -1
	else:
		player_col = playerRestored.curNodeId % col_of_nodes
	
	# one column ahead
	if clicked_col != player_col + 1:
		return
	
	var target_node = node_grid[clicked_row][clicked_col]
	if target_node == null:
		return
		
	
	var prev_row = playerRestored.curNodeId / col_of_nodes
	var prev_col = playerRestored.curNodeId % col_of_nodes
	var prev_node = node_grid[prev_row][prev_col]
	if prev_node:
		prev_node.isActive = false
		prev_node.isCompleted = true
		prev_node.updateSprite()
		
	playerRestored.curNodeId = nodeId
	playerRestored.global_position = target_node.global_position
	playerRestored.global_position.y -= 55
	
	activate_column(clicked_col + 1)
	
	saver_loader.saveGame()
	
		# Current scene becomes previous globally
	Global.prev_scene_path = get_tree().current_scene.scene_file_path
	
	#use target_node
	
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
	print("node_grid: ", nodeId, " | in _MapScene.gd")
	
	if(target_node.nodeName == "COMBAT"):
		print("Combat Node is clicked") 
		get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn") #Change to combat
		
	elif(target_node.nodeName == "SHOP"):
		print("Shop Node is clicked") 
		get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn") #Change to shop
		
		

func activate_column(col: int):
	if col >= col_of_nodes:
		return
	for row in range(row_of_nodes):
		var node = node_grid[row][col]
		if node != null:
			node.isActive = true
			node.updateSprite()
		

func generate_player():
	
	# Creating player and setting position and curNodeId
	var newPlayer = PLAYER.instantiate()
	newPlayer.position = Vector2(60, 300)
	newPlayer.scale *= 0.5
	newPlayer.curNodeId = -1
	playerRestored = newPlayer
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
