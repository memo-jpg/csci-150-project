class_name DeckManager
extends Node

# =========================
# Core Containers
# =========================
var deck: Array[CardData] = []
var combat_deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard: Array[CardData] = []
var exhaust: Array[CardData] = []

var draw_limit: int = 5


# =========================
# Setup
# =========================
func build_combat_deck() -> void:
	combat_deck.clear()
	for card in deck:
		combat_deck.append(card.duplicate_instance())

	shuffle_combat_deck()


func shuffle_combat_deck() -> void:
	combat_deck.shuffle()


func reset_combat() -> void:
	hand.clear()
	discard.clear()
	exhaust.clear()
	combat_deck.clear()


# =========================
# Drawing
# =========================
func draw_cards(amount: int) -> void:
	for i in range(amount):
		if combat_deck.is_empty():
			reshuffle_discard_into_combat()

		if combat_deck.is_empty():
			break

		hand.append(combat_deck.pop_back())


func reshuffle_discard_into_combat() -> void:
	if discard.is_empty():
		return

	combat_deck += discard
	discard.clear()
	shuffle_combat_deck()


# =========================
# Playing Cards
# =========================
func play_card(index: int) -> CardData:
	if index < 0 or index >= hand.size():
		return null

	var card := hand[index]
	hand.remove_at(index)

	if card.exhaust:
		exhaust.append(card)
	else:
		discard.append(card)

	return card


func discard_hand() -> void:
	discard += hand
	hand.clear()


# =========================
# Deck Building
# =========================
func add_card_to_deck(card: CardData) -> void:
	deck.append(card)


func remove_card_from_deck(index: int) -> void:
	if index >= 0 and index < deck.size():
		deck.remove_at(index)


# =========================
# Accessors (read-only usage)
# =========================
func get_hand() -> Array[CardData]:
	return hand

func get_deck_size() -> int:
	return combat_deck.size()

func get_draw_limit() -> int:
	return draw_limit

func set_draw_limit(value: int) -> void:
	draw_limit = value
