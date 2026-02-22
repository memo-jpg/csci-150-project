class_name Player
extends Node2D

# =========================
# References
# =========================
var hud: HUD
var status_manager

# =========================
# Core stats
# =========================
var characterName: String = "Elliot"

var maxHP: int = 87
var currentHP: int = maxHP
var shield: int = 0

var maxEnergy: int = 3
var currentEnergy: int = maxEnergy

var maxHandSize: int = 5

var gold: int = 0

# =========================
# Deck System
# =========================
var deck_manager: DeckManager


# =========================
# Lifecycle
# =========================
func _ready() -> void:
	currentHP = maxHP
	currentEnergy = maxEnergy

	deck_manager = DeckManager.new()
	add_child(deck_manager)

	hud = get_tree().get_root().get_node_or_null("CombatScene/HUD")

	if has_node("StatusEffectManager"):
		status_manager = get_node("StatusEffectManager")

	update_hud()


# =========================
# DAMAGE / HEALING API
# =========================
func apply_damage(amount: int) -> void:
	if amount <= 0:
		return

	var remaining := amount

	# Apply to shield first
	if shield > 0:
		if remaining <= shield:
			shield -= remaining
			remaining = 0
		else:
			remaining -= shield
			shield = 0

	# Apply leftover to HP
	if remaining > 0:
		currentHP -= remaining

	check_death()
	update_hud()


func take_raw_damage(amount: int) -> void:
	if amount <= 0:
		return

	currentHP -= amount
	check_death()
	update_hud()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	currentHP = min(currentHP + amount, maxHP)
	update_hud()


func add_shield(amount: int) -> void:
	if amount <= 0:
		return

	shield += amount
	update_hud()


# =========================
# Energy
# =========================
func setCurrentEnergy(value: int):
	currentEnergy = clamp(value, 0, maxEnergy)
	update_hud()

func getCurrentEnergy() -> int:
	return currentEnergy

func getMaxEnergy() -> int:
	return maxEnergy


# =========================
# HP
# =========================
func getCurrentHP() -> int:
	return currentHP

func getMaxHP() -> int:
	return maxHP

func setMaxHP(value: int):
	maxHP = value

func setCurrentHP(value: int):
	currentHP = value


# =========================
# Death Handling
# =========================
func check_death() -> void:
	if currentHP > 0:
		return

	currentHP = 0
	print("Player has died")


# =========================
# HUD
# =========================
func update_hud() -> void:
	if hud:
		hud.update_all(self)


# =========================
# Deck Wrappers
# =========================
func build_combat_deck():
	deck_manager.build_combat_deck()

func draw_cards():
	deck_manager.draw_cards(deck_manager.get_draw_limit())

func get_hand() -> Array[CardData]:
	return deck_manager.get_hand()

func play_card(index: int) -> CardData:
	return deck_manager.play_card(index)

func discard_hand():
	deck_manager.discard_hand()

func add_card_to_deck(card: CardData):
	deck_manager.add_card_to_deck(card)
