extends Node
class_name StatusEffectManager

# =========================
# Status definition
# =========================
class Status:
	var type: String
	var name: String
	var duration: int # duration == stacks
	var sprite: String
	var is_expired: bool = false
	var owner: Node #if this works then this will be either player or enemy

	func _init(
		_type: String,
		_name: String,
		_duration: int,
		_owner: Node,
		_sprite: String = ""
	) -> void:
		type = _type
		name = _name
		duration = _duration
		owner = _owner
		sprite = _sprite

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

# =========================
# Apply effect
# =========================
func apply_effect(
	_type: String,
	_name: String,
	_duration: int,
	is_negative: bool,
	_owner: Node,
	_sprite: String = ""
) -> void:

	var list: Array[Status]
	if is_negative:
		list = negative_statuses
	else:
		list = positive_statuses

	# Stack refresh
	for s in list:
		if s.type == _type and not s.is_expired:
			s.duration += _duration
			print("%s stacked to %d." % [_name, s.duration])
			return

	var new_status := Status.new(_type, _name, _duration, _owner, _sprite)
	list.append(new_status)

	print("%s applied for %d turns." % [_name, _duration])

# =========================
# Turn tick
# =========================
func on_turn_start() -> void:

	# --- Negative effects ---
	for s in negative_statuses:
		if not is_instance_valid(s.owner):
			s.is_expired = true
			continue

		match s.type:
			"poison":
				# ignores shield
				if s.owner.has_method("take_raw_damage"):
					s.owner.take_raw_damage(s.duration)
				else:
					s.owner.currentHP -= s.duration

			"burn":
				# respects shield
				if s.owner.has_method("apply_damage"):
					s.owner.apply_damage(s.duration)
				else:
					s.owner.currentHP -= s.duration

		s.tick()

	# --- Positive effects ---
	for s in positive_statuses:
		s.tick()

	_cleanup()

# =========================
# Queries for CombatManager
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

# =========================
# Cleanup
# =========================
func _cleanup() -> void:
	positive_statuses = positive_statuses.filter(func(s): return not s.is_expired)
	negative_statuses = negative_statuses.filter(func(s): return not s.is_expired)
