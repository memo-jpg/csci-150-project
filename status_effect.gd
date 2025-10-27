class_name StatusEffect
extends RefCounted

var name: String
var duration: int
var is_expired: bool = false

func _init(name: String, duration: int) -> void:
	self.name = name
	self.duration = duration

func on_apply() -> void:
	print("%s has been applied." % name)

func on_turn_start(target_hp: int) -> int:
	duration -= 1
	if duration <= 0:
		is_expired = true
		on_expire()
	return target_hp

func on_expire() -> void:
	print("%s has worn off." % name)
