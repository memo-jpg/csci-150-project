extends Node
class_name StatusEffectManager

# =========================
# Status definition
# =========================
class Status:
	var type:       String
	var name:       String
	var duration:   int    # for decay: current stack count; for others: turns remaining
	var sprite:     String
	var is_expired: bool = false
	var owner:      Node

	func _init(
		_type:     String,
		_name:     String,
		_duration: int,
		_owner:    Node,
		_sprite:   String = ""
	) -> void:
		type     = _type
		name     = _name
		duration = _duration
		owner    = _owner
		sprite   = _sprite

	func tick() -> void:
		if is_expired:
			return
		duration -= 1
		if duration <= 0:
			is_expired = true
			print("%s has worn off." % name)

# =========================
# Status lists
# =========================
var positive_statuses: Array[Status] = []
var negative_statuses: Array[Status] = []

# Reference to CombatManager so Decay can route damage through it.
# Set by combat_manager after creating the StatusEffectManager.
var combat_manager: Node = null

# =========================
# Apply effect
# =========================
func apply_effect(
	_type:       String,
	_name:       String,
	_duration:   int,
	is_negative: bool,
	_owner:      Node,
	_sprite:     String = ""
) -> void:
	var list: Array[Status] = negative_statuses if is_negative else positive_statuses

	# Stack refresh — add stacks for decay, refresh duration for others
	for s in list:
		if s.type == _type and not s.is_expired:
			s.duration += _duration
			print("%s stacked to %d." % [_name, s.duration])
			return

	var new_status := Status.new(_type, _name, _duration, _owner, _sprite)
	list.append(new_status)
	print("%s applied for %d stacks/turns." % [_name, _duration])

# =========================
# Turn tick — called at the start of the owner's turn
# =========================
func on_turn_start() -> void:

	# ── Negative effects ────────────────────────────────────────────────
	for s in negative_statuses:
		if not is_instance_valid(s.owner):
			s.is_expired = true
			continue

		match s.type:

			"poison":
				# Ignores shield — raw HP damage
				if s.owner.has_method("take_raw_damage"):
					s.owner.take_raw_damage(s.duration)
				else:
					s.owner.currentHP -= s.duration
				s.tick()

			"burn":
				# Respects shield
				if s.owner.has_method("apply_damage"):
					s.owner.apply_damage(s.duration)
				else:
					s.owner.currentHP -= s.duration
				s.tick()

			"decay":
				# Deals `duration` damage respecting shield, then stack decreases by 1.
				var dmg = s.duration
				print("Decay ticks %d damage (shield first)." % dmg)
				if combat_manager != null and combat_manager.has_method("apply_damage_to_player"):
					combat_manager.apply_damage_to_player(dmg)
				elif s.owner.has_method("apply_damage"):
					s.owner.apply_damage(dmg)
				else:
					s.owner.currentHP -= dmg
				s.tick()

			"element_fire", "element_water", "element_wind", "element_earth":
				pass

			_:
				s.tick()

	# ── Positive effects ────────────────────────────────────────────────
	for s in positive_statuses:
		s.tick()

	_cleanup()

# =========================
# Queries
# =========================
func has_status(_type: String) -> bool:
	for s in positive_statuses:
		if s.type == _type and not s.is_expired:
			return true
	return false

func get_status_stacks(_type: String) -> int:
	for s in positive_statuses:
		if s.type == _type and not s.is_expired:
			return s.duration
	return 0

func get_negative_stacks(_type: String) -> int:
	for s in negative_statuses:
		if s.type == _type and not s.is_expired:
			return s.duration
	return 0

func consume_negative_stack(_type: String, amount: int = 1) -> int:
	for s in negative_statuses:
		if s.type == _type and not s.is_expired:
			var consumed = min(amount, s.duration)
			s.duration -= consumed
			if s.duration <= 0:
				s.is_expired = true
			_cleanup()
			return consumed
	return 0

func remove_negative_status(_type: String) -> int:
	var removed := 0
	for s in negative_statuses:
		if s.type == _type and not s.is_expired:
			removed += s.duration
			s.is_expired = true
	_cleanup()
	return removed

# =========================
# Cleanup
# =========================
func _cleanup() -> void:
	positive_statuses = positive_statuses.filter(func(s): return not s.is_expired)
	negative_statuses = negative_statuses.filter(func(s): return not s.is_expired)
