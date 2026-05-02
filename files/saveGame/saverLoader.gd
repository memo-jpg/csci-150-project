class_name saverLoader
extends Node

########################################
# Extended part of this @ 48:15 === https://youtu.be/43BZsLZheA4?t=2895
########################################

func saveGame():
	var saved_game:savedGame = savedGame.new()
	
	var saved_data:Array[savedData] = []
	
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	#print("saved_game.saved_data: ", saved_game.saved_data, " in saveGame()!")
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	

func savePlayer():
	var saved_game: savedGame = load("user://savegame.tres") as savedGame
	var saved_data: Array[savedData] = []
	
	# keep mapNode data from the file
	for item in saved_game.saved_data:
		if item.scene_path == "res://files/map/scenes/mapNode.tscn":
			saved_data.append(item)
	
	# save player
	get_tree().call_group("game_events", "on_save_game", saved_data)
	
	saved_game.saved_data = saved_data
	#print("saved_data: ", saved_data, " in savePlayer()")
	ResourceSaver.save(saved_game, "user://savegame.tres")



func saveMapNodes():
	var saved_game: savedGame = load("user://savegame.tres") as savedGame
	var saved_data: Array[savedData] = []
	
	# keep mapNode data from the file
	for item in saved_game.saved_data:
		if item.scene_path == "res://files/player/scenes/player.tscn":
			saved_data.append(item)
	
	var mapNodeMembers = get_tree().get_nodes_in_group("game_events")
	for node in mapNodeMembers:
		if node is mapNode:
			node.on_save_game(saved_data)
			print("saving nodeId: ", node.nodeId," | isActive: ", node.isActive, " | isCompleted: ", node.isCompleted, " | in saveMapNodes() !")
	
	saved_game.saved_data = saved_data
	ResourceSaver.save(saved_game, "user://savegame.tres")



func loadPlayer() -> Player:
	if not FileAccess.file_exists("user://savegame.tres"):
		print("Save file 'savegame.tres' does not exist !")
		return null
		
	var saved_game:savedGame = load("user://savegame.tres") as savedGame # loads saved_game var as a savedGame object
	
	# iterates until player is found
	for item in saved_game.saved_data:
		if(item.scene_path == "res://files/player/scenes/player.tscn"):
			var scene = load(item.scene_path) as PackedScene
			var playerRestored = scene.instantiate()
			playerRestored.on_load_game(item)
			return playerRestored
			
	
	return null
	


# Passing 'map_GD_node' if a node in godot's node tree is passed
func loadGame(map_GD_node: Node2D = null):
	# local dictionary, mapNodeArr and playerRstored object 
	var allNodes = {}
	var mapNodeArr : Array = []
	var playerRestored : Player = null
	
	# file doesn't exist
	if not FileAccess.file_exists("user://savegame.tres"):
		allNodes["player"] = playerRestored
		allNodes["mapNodes"] = mapNodeArr
		return allNodes
	
	var saved_game:savedGame = load("user://savegame.tres") as savedGame
	#print("saved_game.saved_data: ", saved_game.saved_data, " in loadGame()!")
	get_tree().call_group("game_events", "on_before_load_game")
	
	# for each object in file
	for item in saved_game.saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		# handles mapNodes
		if(item.scene_path == "res://files/map/scenes/mapNode.tscn"):
			mapNodeArr.append(restored_node)
			if(map_GD_node):
				map_GD_node.add_child(restored_node)
			else:
				restored_node.queue_free()
			
		# handles playerRestore
		elif(item.scene_path == "res://files/player/scenes/player.tscn"):
			print("Scene path:", item.scene_path)
			print("Restored type:", restored_node.get_class())
			playerRestored = restored_node
			if(map_GD_node):
				map_GD_node.add_child(playerRestored)
			else: # TODO have loadGame only return data, have a function that operates the scenes(?)
				restored_node.queue_free() # temp fix for oprhans in unit testing
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
	
	# returns a dictionary
	allNodes["player"] = playerRestored
	allNodes["mapNodes"] = mapNodeArr
	return allNodes
	
