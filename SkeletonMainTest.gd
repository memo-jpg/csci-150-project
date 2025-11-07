extends Node

@onready var skeleton: SkeletonEnemy = SkeletonEnemy.new()

func _ready():
	print("=== Skeleton Enemy Test ===")

	add_child(skeleton) 
	skeleton.take_turn()
	skeleton.setHp(20)  
	print("Skeleton current HP:", skeleton.currentHp)

	skeleton.take_damage(15)  
	print("Skeleton HP after taking damage:", skeleton.currentHp)

	print("=== End of Test ===")
