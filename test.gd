extends Node

@export var testMobScene: PackedScene
var  testEnemy: Node2D


func _process(delta): 
	if(Input.is_action_pressed('spawnTest')):
		testEnemy = testMobScene.instantiate()
		testEnemy.position = Vector2(0,0) 
		print('child added')
		add_child(testEnemy)
	if(Input.is_action_pressed('damageTest')):
		testEnemy.setHp(50)
	
