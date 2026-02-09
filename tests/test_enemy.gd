extends GutTest


var Enemy = preload("res://enemy.gd")
var enemyTest : Enemy


func before_each() -> void: # before each unit test
	# hero = Hero.new()
	enemyTest = Enemy.new()
	# add_child(hero)
	add_child(enemyTest)
	# await get_tree().process_frame
	await get_tree().process_frame
	pass

func after_each() -> void:
	#hero.queue_free()
	enemyTest.queue_free()
	pass
	

func test_has_name() -> void:
	assert_eq(enemyTest.name, "Enemy", "Name needs to be a string")
	pass
	
