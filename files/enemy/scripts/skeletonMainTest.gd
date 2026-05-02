extends Node

@onready var skeleton: SkeletonEnemy = SkeletonEnemy.new()

func _ready():
	print("=== Skeleton Enemy Test ===")
	add_child(skeleton)

	skeleton.take_turn()
	skeleton.take_damage(15)
	skeleton.take_damage(20)
	skeleton.take_damage(30)
	print("=== End of Test ===")
