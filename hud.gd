class_name HUD
extends CanvasLayer

@onready var hp_label       = $TopBar/HBoxContainer/HPLabel
@onready var energy_label   = $TopBar/HBoxContainer/EnergyLabel
@onready var shield_label   = $TopBar/HBoxContainer/ShieldLabel
@onready var gold_label     = $TopBar/HBoxContainer/GoldLabel
@onready var name_label     = $TopBar/HBoxContainer/NameLabel

func update_all(player):
	update_hp(player.currentHP, player.maxHP)
	update_energy(player.currentEnergy, player.maxEnergy)
	update_shield(player.shield)
	update_gold(player.gold)
	update_name(player.characterName)

func update_hp(current_hp:int, max_hp:int):
	hp_label.text = "HP: %d / %d" % [current_hp, max_hp]

func update_energy(current_energy:int, max_energy:int):
	energy_label.text = "Energy: %d / %d" % [current_energy, max_energy]

func update_shield(shld:int):
	shield_label.text = "Shield: %d" % shld

func update_gold(g:int):
	gold_label.text = "Gold: %d" % g

func update_name(n:String):
	name_label.text = n
