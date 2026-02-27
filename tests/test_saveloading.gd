extends GutTest

# tests player health
var saverLoader = preload("res://files/saveGame/saverLoader.gd")
var saveLoadTest: saverLoader

func before_each() -> void: # before each unit test
	saveLoadTest = saverLoader.new()
	add_child_autofree(saveLoadTest)
	await get_tree().process_frame
	pass

func after_each() -> void:
	saveLoadTest.queue_free()
	pass
	

func test_one_shop_exists() -> void:
	var loadedDict = saveLoadTest.loadGame()
	var placedNodes = loadedDict.get("mapNodes", [])
	
	var shopCtr = 0
	for node in placedNodes:
		if(node.nodeName == "SHOP"):
			shopCtr += 1
			
	assert_eq(shopCtr, 1, "There is only to exist one shop")
	pass

func test_different_node_positions() -> void:
	var loadedDict = saveLoadTest.loadGame()
	var placedNodes = loadedDict.get("mapNodes", [])
	
	var overlappingNodes = false
	
	var prevNodeX = 0.0
	var prevNodeY = 0.0
	for node in placedNodes:
		
		if(node.position.x > prevNodeX + 100):
			overlappingNodes = false
		else:
			overlappingNodes = true
		
		#print("x: %d, y: %d\n", prevNodeX, prevNodeY)
		
	assert_eq(overlappingNodes, false, "Map nodes are overlapping")
	

func test_ten_nodes_exist() -> void:
	var loadedDict = saveLoadTest.loadGame()
	var placedNodes = loadedDict.get("mapNodes", [])
	

	assert_eq(placedNodes.size(), 10, "Only 10 nodes are supposed to exist")
	pass
	
