extends GutTest
# https://www.youtube.com/watch?v=h5HmdD0cAps
# var
# var map: Map
var map_node = preload("res://unit_testing/map_node.gd")
var node: map_node



func before_each() -> void: # before each unit test
	# hero = Hero.new()
	node = map_node.new()
	# add_child(hero)
	add_child(node)
	# await get_tree().process_frame
	await get_tree().process_frame
	pass

func after_each() -> void:
	#hero.queue_free()
	node.queue_free()
	pass
	


#func test_isActive
func test_isActive() -> void:
	#assert_eq(hero.health, hero.max_health, "Hero should start with full health.")
	assert_eq(node.isActive, false, "Expected init node to be false")
	
