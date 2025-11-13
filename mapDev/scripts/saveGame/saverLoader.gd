class_name saverLoader
extends Node

@onready var _map: Node2D = %_Map
# @onready var _map: Node2D = $"../../_GameManager/_Map"
@onready var _game_manager: Node = %_GameManager

########################################
# Extended part of this @ 48:15 === https://youtu.be/43BZsLZheA4?t=2895
########################################
func saveGame():
	var saved_game:savedGame = savedGame.new()
	
	var saved_data:Array[savedData] = []
	get_tree().call_group("game_events", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	


func loadGame(mapNodeArr : Array):
	var saved_game:savedGame = load("user://savegame.tres") as savedGame
	
	get_tree().call_group("game_events", "on_before_load_game")
	
	for item in saved_game.saved_data:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		# print(_map)
		_map.add_child(restored_node)
		# currently appends all items, even player character since its part of the .tres file, works but need to distinguish between player object and node 
		if(item.scene_path == "res://mapDev/mapNode.tscn"):
			mapNodeArr.append(restored_node)
			# Appends to an array if it is a mapNode
		
		#print(item.scene_path)
		
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
		
		
