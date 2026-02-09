extends GutTest

# tests player health
var saverLoader = preload("res://mapDev/scripts/saveGame/saverLoader.gd")
var saveLoadTest: saverLoader

func before_each() -> void: # before each unit test
	saveLoadTest = saverLoader.new()
	add_child_autofree(saveLoadTest)
	await get_tree().process_frame
	pass

func after_each() -> void:
	saveLoadTest.queue_free()
	pass
	

func test_ten_nodes_exist() -> void:
	var loadedDict = saveLoadTest.loadGame()
	var placedNodes = loadedDict.get("mapNodes", [])
	

	assert_eq(placedNodes.size(), 10, "Only 10 nodes are supposed to exist")
	pass
	
