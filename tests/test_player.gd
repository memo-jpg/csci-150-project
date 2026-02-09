extends GutTest

# tests player health
var Player = preload("res://player.gd")
var playerTest: Player

func before_each() -> void: # before each unit test
	playerTest = Player.new()
	add_child(playerTest)
	await get_tree().process_frame
	pass

func after_each() -> void:
	playerTest.queue_free()
	pass
	


#func test_isActive
func test_player_init_health() -> void:
	# assert_eq(node.isActive, false, "Map node at initialization expected to be false")
	assert_eq(playerTest.currentHP, 100, "Health initialization expected to be <= 100")
	pass
	
func test_player_init_location() -> void:
	
	assert_eq(playerTest.curNodeId, Global.curNodeId, "Player's node location is not the same as the Global variable, 0")
	pass
