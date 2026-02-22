class_name CardData
extends RefCounted

var id: int
var type: String
var name: String
var damage: int
var shield: int
var energy: int
var exhaust: bool
var sprite: String


func _init(
	_id: int,
	_type: String,
	_name: String,
	_damage: int,
	_shield: int,
	_energy: int,
	_sprite: String,
	_exhaust: bool = false
) -> void:
	id = _id
	type = _type.to_lower()
	name = _name
	damage = _damage
	shield = _shield
	energy = _energy
	sprite = _sprite
	exhaust = _exhaust


func duplicate_instance() -> CardData:
	return CardData.new(
		id,
		type,
		name,
		damage,
		shield,
		energy,
		sprite,
		exhaust
	)
