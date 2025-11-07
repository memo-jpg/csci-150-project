extends "res://enemy.gd"
class_name SkeletonEnemy

func _ready():
	name = "Skeleton"
	maxHp = 50
	currentHp = maxHp
	print(name, " rises from the grave with ", maxHp, " HP!")

func attack():
	print(name, " swings its rusty sword!")

func defend():
	print(name, " raises its bone shield!")

func take_turn():
	var choice = randi_range(0, 1)
	if choice == 0:
		attack()
	else:
		defend()
func take_damage(amount: int):
	currentHp -= amount
	if currentHp < 0:
		currentHp = 0
	print(name, " takes ", amount, " damage! (", currentHp, "/", maxHp, " HP left)")

	if currentHp == 0:
		die()

func die():
	print(name, " collapses into a pile of bones...")
	queue_free()
