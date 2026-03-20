class_name saverLoader
extends Node

@onready var _map: Node2D = %_Map
# @onready var _map: Node2D = $"../../_GameManager/_Map"
# @onready var _game_manager: Node = %_GameManager

########################################
# Extended part of this @ 48:15 === https://youtu.be/43BZsLZheA4?t=2895
########################################
func saveGame():
	var saved_game:savedGame = savedGame.new()
	
	var saved_data:Array[savedData] = []
	
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	print("saved_game.saved_data: ", saved_game.saved_data, " in saveGame()!")
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	

func updateSaveGame(_dict):
	var saved_game:savedGame = savedGame.new()
	var saved_data:Array[savedData] = []
	
	var allNodes = {}
	var mapNodeArr : Array = []
	var playerRestored : Player = null
	
	# Create a saved_game object
	# create array of saved data
	# get node, get gree of game_events objects that have the on_save_game data array
	# saved_game's saved_data object array = the saved_data array created locally
	# Resource saver to saved game
	
	# Create a saved_game object
	# create array of saved data
	# get node, get gree of game_events objects that have the on_save_game data array
	# saved_game's saved_data object array = the saved_data array created locally
	# Resource saver to saved game
	
	if(_dict):		
		print("Dictionary: ", _dict, " exists")
		
	else:
		print("Dictionary does not exits")
		
	
	print("updatedSaveGame from saverLoader.gd called")
	pass
	

func loadGame():
	var allNodes = {}
	var mapNodeArr : Array = []
	var playerRestored : Player = null
	
	if not FileAccess.file_exists("user://savegame.tres"):
		allNodes["player"] = playerRestored
		allNodes["mapNodes"] = mapNodeArr
		return allNodes
	
	var saved_game:savedGame = load("user://savegame.tres") as savedGame
	print("saved_game.saved_data: ", saved_game.saved_data, " in loadGame()!")
	get_tree().call_group("game_events", "on_before_load_game")
	
	for item in saved_game.saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		
		# handles mapNodes
		if(item.scene_path == "res://files/map/scenes/mapNode.tscn"):
			mapNodeArr.append(restored_node)
			if(_map):
				_map.add_child(restored_node)
			else: # TODO have loadGame only return data, have a function that operates the scenes(?)
					restored_node.queue_free()
			
		# handles playerRestore
		elif(item.scene_path == "res://files/player/scenes/player.tscn"):
			playerRestored = restored_node
			if(_map):
				_map.add_child(playerRestored)
			else: # TODO have loadGame only return data, have a function that operates the scenes(?)
				restored_node.queue_free() # temp fix for oprhans in unit testing
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
			
	
	allNodes["player"] = playerRestored
	allNodes["mapNodes"] = mapNodeArr
	return allNodes
