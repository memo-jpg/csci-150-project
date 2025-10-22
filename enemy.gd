class_name Enemy extends Node2D
var currentHp: int
@export var maxHp: int
var pos: int
var statusEffect

func setHp(newHp):
	if(newHp<maxHp): {
	currentHp=newHp
	} 
	else: {
		currentHP=maxHp
	}
