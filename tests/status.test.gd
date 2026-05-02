extends Node

const StatusEffectManager = preload("res://files/combat/scripts/status_effect.gd")

var status_manager: StatusEffectManager


class DummyActor extends Node:
	var currentHP: int = 100
	var shield: int = 10

	func apply_damage(amount: int) -> void:
		var remaining := amount
		if shield > 0:
			var absorbed = min(shield, remaining)
			shield -= absorbed
			remaining -= absorbed
		currentHP -= remaining

	func take_raw_damage(amount: int) -> void:
		currentHP -= amount


func _ready() -> void:
	print("\n=== STATUS EFFECT MANAGER TEST ===")

	status_manager = StatusEffectManager.new()
	add_child(status_manager)

	var actor: DummyActor = DummyActor.new()
	add_child(actor)

	print("\n--- Test 1: Poison stacking ---")
	status_manager.apply_effect("poison", "Poison", 2, true, actor)
	status_manager.apply_effect("poison", "Poison", 1, true, actor)
	print("Expected poison stacks: 3")

	for turn in range(1, 5):
		print("\nTurn", turn)
		status_manager.on_turn_start()
		print("HP after turn:", actor.currentHP)

	print("\n--- Test 3: Poison ignores shield ---")
	actor.currentHP = 50
	actor.shield = 999
	status_manager.apply_effect("poison", "Poison", 2, true, actor)
	status_manager.on_turn_start()
	print("Expected HP: 48")
	print("Actual HP:", actor.currentHP, "Shield:", actor.shield)

	print("\n--- Test 4: Burn respects shield ---")
	actor.currentHP = 50
	actor.shield = 5
	status_manager.apply_effect("burn", "Burn", 3, true, actor)
	status_manager.on_turn_start()
	print("Expected HP: 50 | Shield: 2")
	print("Actual HP:", actor.currentHP, "Shield:", actor.shield)

	print("\n=== TEST COMPLETE ===")
