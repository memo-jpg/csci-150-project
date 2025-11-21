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
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	


func loadGame():
	var allNodes = {}
	
	
	var saved_game:savedGame = load("user://savegame.tres") as savedGame
	
	get_tree().call_group("game_events", "on_before_load_game")
	
	var mapNodeArr : Array = []
	var playerRestored : Player = null
	
	
	
	for item in saved_game.saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		
		# handles mapNodes
		if(item.scene_path == "res://mapDev/mapNode.tscn"):
			
			mapNodeArr.append(restored_node)
			_map.add_child(restored_node)
			
		
		# handles playerRestore
		elif(item.scene_path == "res://player.tscn"):
			playerRestored = restored_node
			_map.add_child(playerRestored)
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
		
		allNodes["player"] = playerRestored
		allNodes["mapNodes"] = mapNodeArr
		
	
	
	return allNodes
