class_name CardRewardManager
extends Node

# =============================================================================
# CardRewardManager
# =============================================================================
# Offers 3 cards after combat victory, weighted by encounter type.
# Usage:
#   var reward = CardRewardManager.new()
#   add_child(reward)
#   reward.show_reward(player_node, card_database, encounter_type)
#   reward.reward_closed.connect(_on_reward_closed)
# =============================================================================

signal reward_closed

const RARITY_WEIGHTS: Dictionary = {
	"normal": { "common": 45, "uncommon": 40, "rare": 13, "legendary": 2 },
	"elite":  { "common": 20, "uncommon": 45, "rare": 25, "legendary": 10 },
	"boss":   { "common":  0, "uncommon": 25, "rare": 45, "legendary": 30 }
}

const RARITY_FALLBACK_ORDER: Array = ["rare", "uncommon", "common"]
const OFFER_COUNT: int = 3

var _player:   Node         = null
var _db:       CardDatabase = null
var _panel:    Control      = null
var _enc_type: String       = "normal"
var _rerolled: bool         = false


# =============================================================================
# Public entry point
# =============================================================================
func show_reward(player: Node, db: CardDatabase, encounter_type: String = "normal") -> void:
	_player   = player
	_db       = db
	_enc_type = encounter_type.to_lower()

	var offered := _roll_offer()

	if offered.is_empty():
		reward_closed.emit()
		return

	_build_ui(offered)


func _roll_offer() -> Array[CardData]:
	var offered: Array[CardData] = []
	var used_names: Array[String] = []
	for _i in range(OFFER_COUNT):
		var rolled_rarity := _roll_rarity(_enc_type)
		var card := _pick_one_card(rolled_rarity, used_names)
		if card != null:
			offered.append(card)
			used_names.append(card.name)
	return offered


# =============================================================================
# Rarity rolling
# =============================================================================
func _roll_rarity(enc_type: String) -> String:
	var weights: Dictionary = RARITY_WEIGHTS.get(enc_type, RARITY_WEIGHTS["normal"])
	var total := 0
	for w in weights.values():
		total += w
	if total <= 0:
		return "common"
	var roll := randi() % total
	var cumulative := 0
	for rarity in weights.keys():
		cumulative += weights[rarity]
		if roll < cumulative:
			return rarity
	return "common"


# =============================================================================
# Card picking
# =============================================================================
func _pick_one_card(rarity: String, exclude_names: Array[String]) -> CardData:
	var pool := _cards_of_rarity(rarity)
	pool = pool.filter(func(c): return not exclude_names.has(c.name))

	if pool.is_empty():
		for fallback in RARITY_FALLBACK_ORDER:
			if fallback == rarity:
				continue
			pool = _cards_of_rarity(fallback)
			pool = pool.filter(func(c): return not exclude_names.has(c.name))
			if not pool.is_empty():
				break

	if pool.is_empty():
		return null
	pool.shuffle()
	return pool[0]


func _cards_of_rarity(rarity: String) -> Array[CardData]:
	var result: Array[CardData] = []
	for card in _db.cards.values():
		if card.rarity == rarity:
			result.append(card)
	return result


# =============================================================================
# UI
# =============================================================================
func _build_ui(offered: Array[CardData]) -> void:
	_panel             = ColorRect.new()
	_panel.color       = Color(0, 0, 0, 0.75)
	_panel.size        = get_viewport().get_visible_rect().size
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.z_index     = 200
	add_child(_panel)

	var title := Label.new()
	title.text = "Choose a Card"
	title.add_theme_font_size_override("font_size", 28)
	title.position = Vector2(get_viewport().get_visible_rect().size.x / 2.0 - 200, 80)
	title.size = Vector2(400, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	var vp_w    := get_viewport().get_visible_rect().size.x
	var btn_w   := 160.0
	var btn_h   := 220.0
	var gap     := 40.0
	var total_w := offered.size() * btn_w + (offered.size() - 1) * gap
	var start_x := (vp_w - total_w) / 2.0
	var btn_y   := 160.0

	for i in range(offered.size()):
		var card: CardData = offered[i]
		var btn := _make_card_button(card, btn_w, btn_h)
		btn.position = Vector2(start_x + i * (btn_w + gap), btn_y)
		_panel.add_child(btn)
		btn.pressed.connect(_on_card_chosen.bind(card))

	var skip := Button.new()
	skip.text     = "Skip"
	skip.size     = Vector2(120, 40)
	skip.position = Vector2(vp_w / 2.0 + 10, btn_y + btn_h + 30)
	skip.add_theme_font_size_override("font_size", 16)
	_panel.add_child(skip)
	skip.pressed.connect(_on_skip)

	var reroll := Button.new()
	reroll.text = "Reroll"
	reroll.size = Vector2(120, 40)
	reroll.position = Vector2(vp_w / 2.0 - 130, btn_y + btn_h + 30)
	reroll.add_theme_font_size_override("font_size", 16)
	reroll.disabled = _rerolled
	_panel.add_child(reroll)
	reroll.pressed.connect(_on_reroll)


func _make_card_button(card: CardData, w: float, h: float) -> Button:
	var btn           := Button.new()
	btn.size          = Vector2(w, h)
	btn.clip_contents = true

	var lbl := Label.new()
	lbl.size          = Vector2(w - 10, h - 10)
	lbl.position      = Vector2(5, 5)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 11)

	var lines: Array = [
		"[%s]" % card.rarity.to_upper(),
		card.name,
		"",
		"Cost: %d" % card.energy,
	]
	if card.damage > 0: lines.append("DMG: %d" % card.damage)
	if card.shield > 0: lines.append("DEF: %d" % card.shield)
	lbl.text = "\n".join(lines)
	btn.add_child(lbl)

	match card.rarity:
		"common":    btn.modulate = Color(1.0, 1.0, 1.0)
		"uncommon":  btn.modulate = Color(0.4, 1.0, 0.4)
		"rare":      btn.modulate = Color(0.4, 0.6, 1.0)
		"legendary": btn.modulate = Color(1.0, 0.8, 0.2)

	return btn


# =============================================================================
# Callbacks
# =============================================================================
func _on_card_chosen(card: CardData) -> void:
	print("CardRewardManager: player chose '%s'" % card.name)
	if _player and _player.deckManager:
		_player.deckManager.add_card_to_deck(card.duplicate_instance())
	Global.player_deck.append(card.name)
	_close()


func _on_skip() -> void:
	print("CardRewardManager: player skipped reward")
	_close()


func _on_reroll() -> void:
	if _rerolled:
		return
	_rerolled = true
	if _panel:
		_panel.queue_free()
		_panel = null
	var offered := _roll_offer()
	if offered.is_empty():
		reward_closed.emit()
	else:
		_build_ui(offered)


func _close() -> void:
	if _panel:
		_panel.queue_free()
		_panel = null
	reward_closed.emit()
