extends Node2D

const RARITY_BASE_PRICE: Dictionary = {
	"common": 40,
	"uncommon": 75,
	"rare": 120,
	"legendary": 200
}
const PRICE_VARIANCE: int = 15
const SHOP_SLOTS: int = 4
const REMOVE_CARD_COST: int = 50
const REROLL_STOCK_COST: int = 25

var _db: CardDatabase
var _player: Node
var _stock: Array[CardData] = []
var _prices: Array[int] = []
var _sold: Array[bool] = []
var _selected_idx: int = -1

var _slot_panels: Array = []
var _gold_label: Label
var _status_label: Label
var _buy_button: Button
var _reroll_button: Button
var _leave_button: Button
var _detail_panel: ColorRect
var _detail_name: Label
var _detail_cost: Label
var _detail_desc: Label
var _detail_price: Label
var _remove_list: VBoxContainer
var _saver_loader: saverLoader


func _ready() -> void:
	print("ShopScene _ready() started")

	_saver_loader = saverLoader.new()
	add_child(_saver_loader)

	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0]
	if _player == null:
		_player = _saver_loader.loadPlayer()
		if _player != null:
			_player.visible = false
			add_child(_player)
	if _player == null:
		push_error("ShopScene: Could not find Player node!")

	_db = CardDatabase.new()
	add_child(_db)
	_db.load_cards("res://_assets/cards.json")

	_roll_stock()
	_build_ui()
	_refresh_ui()
	print("ShopScene _ready() complete")


func _roll_stock() -> void:
	_stock.clear()
	_prices.clear()
	_sold.clear()

	var weights := {"common": 45, "uncommon": 35, "rare": 15, "legendary": 5}
	var pool: Array[CardData] = []
	for card in _db.cards.values():
		pool.append(card)
	pool.shuffle()

	var used: Array[String] = []
	for _i in range(SHOP_SLOTS):
		var rarity := _weighted_pick(weights)
		var card := _pick_card(rarity, used, pool)
		if card == null:
			for c in pool:
				if not used.has(c.name):
					card = c
					break
		if card == null:
			continue
		_stock.append(card)
		used.append(card.name)
		var price: int = RARITY_BASE_PRICE.get(card.rarity, 50) + randi_range(-PRICE_VARIANCE, PRICE_VARIANCE)
		_prices.append(price)
		_sold.append(false)


func _weighted_pick(weights: Dictionary) -> String:
	var total := 0
	for w in weights.values():
		total += w
	var roll := randi() % total
	var cumul := 0
	for rarity in weights.keys():
		cumul += weights[rarity]
		if roll < cumul:
			return rarity
	return "common"


func _pick_card(rarity: String, exclude: Array[String], pool: Array[CardData]) -> CardData:
	var candidates: Array[CardData] = []
	for c in pool:
		if c.rarity == rarity and not exclude.has(c.name):
			candidates.append(c)
	if candidates.is_empty():
		for fallback in ["uncommon", "common"]:
			if fallback == rarity:
				continue
			for c in pool:
				if c.rarity == fallback and not exclude.has(c.name):
					candidates.append(c)
			if not candidates.is_empty():
				break
	if candidates.is_empty():
		return null
	candidates.shuffle()
	return candidates[0]


func _build_ui() -> void:
	var vp := get_viewport().get_visible_rect().size

	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.07, 0.04)
	bg.size = vp
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.z_index = -10
	add_child(bg)

	var title := Label.new()
	title.text = "Shop"
	title.position = Vector2(vp.x / 2.0 - 100, 22)
	title.size = Vector2(200, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	add_child(title)

	_gold_label = Label.new()
	_gold_label.position = Vector2(20, 20)
	_gold_label.size = Vector2(220, 30)
	_gold_label.add_theme_font_size_override("font_size", 18)
	add_child(_gold_label)

	_status_label = Label.new()
	_status_label.position = Vector2(vp.x / 2.0 - 200, vp.y - 110)
	_status_label.size = Vector2(400, 30)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.modulate = Color(1, 0.9, 0.3)
	add_child(_status_label)

	_build_remove_panel(vp)

	var card_w := 160.0
	var card_h := 240.0
	var gap := 30.0
	var total_w := _stock.size() * card_w + (_stock.size() - 1) * gap
	var origin_x := (vp.x - total_w) / 2.0
	var card_y := 90.0

	for i in range(_stock.size()):
		var btn := _make_slot_button(i, card_w, card_h)
		btn.position = Vector2(origin_x + i * (card_w + gap), card_y)
		add_child(btn)
		_slot_panels.append(btn)

	var dp_y := card_y + card_h + 20.0
	_detail_panel = ColorRect.new()
	_detail_panel.color = Color(0.15, 0.10, 0.06, 0.95)
	_detail_panel.size = Vector2(300, 170)
	_detail_panel.position = Vector2(vp.x / 2.0 - 150, dp_y)
	_detail_panel.visible = false
	add_child(_detail_panel)

	_detail_name = _lbl(Vector2(10, 8), Vector2(280, 28), 16)
	_detail_panel.add_child(_detail_name)
	_detail_cost = _lbl(Vector2(10, 40), Vector2(280, 22), 12)
	_detail_cost.modulate = Color(0.6, 1.0, 0.6)
	_detail_panel.add_child(_detail_cost)
	_detail_desc = _lbl(Vector2(10, 68), Vector2(280, 55), 12)
	_detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_panel.add_child(_detail_desc)
	_detail_price = _lbl(Vector2(10, 130), Vector2(280, 24), 14)
	_detail_price.modulate = Color(1.0, 0.85, 0.2)
	_detail_panel.add_child(_detail_price)

	_buy_button = Button.new()
	_buy_button.text = "Buy"
	_buy_button.size = Vector2(130, 42)
	_buy_button.position = Vector2(vp.x / 2.0 - 65, dp_y + 180)
	_buy_button.visible = false
	_buy_button.pressed.connect(_on_buy_pressed)
	add_child(_buy_button)

	_reroll_button = Button.new()
	_reroll_button.text = "Reroll Shop - %d gold" % REROLL_STOCK_COST
	_reroll_button.size = Vector2(170, 42)
	_reroll_button.position = Vector2(vp.x / 2.0 - 85, dp_y + 230)
	_reroll_button.pressed.connect(_on_reroll_shop_pressed)
	add_child(_reroll_button)

	_leave_button = Button.new()
	_leave_button.text = "Leave Shop"
	_leave_button.size = Vector2(150, 44)
	_leave_button.position = Vector2(vp.x - 170, vp.y - 64)
	_leave_button.pressed.connect(_on_leave_pressed)
	add_child(_leave_button)


func _build_remove_panel(vp: Vector2) -> void:
	var panel := ColorRect.new()
	panel.color = Color(0.12, 0.08, 0.05, 0.96)
	panel.size = Vector2(250, 330)
	panel.position = Vector2(max(20.0, vp.x - 280.0), 78)
	add_child(panel)

	var heading := Label.new()
	heading.text = "Remove a Card - %d gold" % REMOVE_CARD_COST
	heading.position = Vector2(10, 10)
	heading.size = Vector2(230, 26)
	heading.add_theme_font_size_override("font_size", 15)
	panel.add_child(heading)

	var hint := Label.new()
	hint.text = "Choose one card from your deck."
	hint.position = Vector2(10, 38)
	hint.size = Vector2(230, 34)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 11)
	hint.modulate = Color(0.85, 0.78, 0.66)
	panel.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 76)
	scroll.size = Vector2(230, 244)
	panel.add_child(scroll)

	_remove_list = VBoxContainer.new()
	_remove_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_remove_list)


func _make_slot_button(idx: int, w: float, h: float) -> Button:
	var btn := Button.new()
	btn.size = Vector2(w, h)
	btn.clip_contents = true
	var lbl := Label.new()
	lbl.size = Vector2(w - 10, h - 10)
	lbl.position = Vector2(5, 5)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 11)
	btn.add_child(lbl)
	_update_slot_button(btn, idx)
	btn.pressed.connect(_on_slot_pressed.bind(idx))
	return btn


func _update_slot_button(btn: Button, idx: int) -> void:
	var lbl := btn.get_child(0) as Label
	btn.disabled = false
	if idx < _stock.size() and idx < _prices.size():
		var card := _stock[idx]
		lbl.text = "[%s]\n%s\n\nEnergy: %d\n%s\n\n%d gold" % [
			card.rarity.to_upper(), card.name,
			card.energy, _stat_text(card), _prices[idx]
		]
		_apply_tint(btn, card.rarity)
	else:
		lbl.text = "-"
		btn.disabled = true


func _stat_text(card: CardData) -> String:
	var p: Array[String] = []
	if card.damage > 0:
		p.append("DMG %d" % card.damage)
	if card.shield > 0:
		p.append("DEF %d" % card.shield)
	return "  ".join(p) if not p.is_empty() else card.type


func _lbl(pos: Vector2, sz: Vector2, fs: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.add_theme_font_size_override("font_size", fs)
	return l


func _apply_tint(node: CanvasItem, rarity: String) -> void:
	match rarity:
		"common":
			node.modulate = Color(1.0, 1.0, 1.0)
		"uncommon":
			node.modulate = Color(0.5, 1.0, 0.5)
		"rare":
			node.modulate = Color(0.5, 0.7, 1.0)
		"legendary":
			node.modulate = Color(1.0, 0.85, 0.2)


func _refresh_ui() -> void:
	if _gold_label and _player:
		_gold_label.text = "Gold: %d" % _player.gold
	if _reroll_button and _player:
		_reroll_button.disabled = _player.gold < REROLL_STOCK_COST

	for i in range(_slot_panels.size()):
		if i >= _sold.size():
			break
		var btn := _slot_panels[i] as Button
		if _sold[i]:
			btn.modulate = Color(0.4, 0.4, 0.4)
			btn.disabled = true
		elif i == _selected_idx:
			btn.modulate = Color(1.3, 1.3, 0.7)
		elif i < _stock.size():
			_apply_tint(btn, _stock[i].rarity)

	var has_sel := _selected_idx != -1 and _selected_idx < _stock.size()
	_detail_panel.visible = has_sel
	_buy_button.visible = has_sel and not _sold[_selected_idx]
	if has_sel:
		var card := _stock[_selected_idx]
		var price: int = _prices[_selected_idx]
		_detail_name.text = card.name
		_detail_cost.text = "Energy: %d   Rarity: %s" % [card.energy, card.rarity]
		_detail_desc.text = _stat_text(card)
		_detail_price.text = "%d gold%s" % [price, "  (SOLD)" if _sold[_selected_idx] else ""]

	_refresh_remove_ui()


func _refresh_remove_ui() -> void:
	if _remove_list == null:
		return
	for child in _remove_list.get_children():
		child.queue_free()

	if Global.player_deck.is_empty():
		var empty := Label.new()
		empty.text = "No removable cards."
		empty.modulate = Color(0.8, 0.75, 0.68)
		_remove_list.add_child(empty)
		return

	for i in range(Global.player_deck.size()):
		var card_name: String = Global.player_deck[i]
		var btn := Button.new()
		btn.text = card_name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.disabled = _player == null or _player.gold < REMOVE_CARD_COST or Global.player_deck.size() <= 1
		btn.pressed.connect(_on_remove_card_pressed.bind(i))
		_remove_list.add_child(btn)


func _on_slot_pressed(idx: int) -> void:
	if idx >= _sold.size() or _sold[idx]:
		return
	_selected_idx = -1 if _selected_idx == idx else idx
	_status_label.text = ""
	_refresh_ui()


func _on_buy_pressed() -> void:
	if _selected_idx == -1 or _player == null:
		return
	var price: int = _prices[_selected_idx]
	if _player.gold < price:
		_status_label.text = "Not enough gold! (need %d, have %d)" % [price, _player.gold]
		return
	_player.gold -= price
	var card := _stock[_selected_idx]
	_player.deckManager.add_card_to_deck(card.duplicate_instance())
	Global.player_deck.append(card.name)
	_saver_loader.savePlayer()
	print("ShopScene: bought '%s' for %dg" % [card.name, price])
	_sold[_selected_idx] = true
	_selected_idx = -1
	_status_label.text = "Purchased: %s!" % card.name
	_refresh_ui()


func _on_reroll_shop_pressed() -> void:
	if _player == null:
		return
	if _player.gold < REROLL_STOCK_COST:
		_status_label.text = "Shop reroll costs %d gold." % REROLL_STOCK_COST
		return
	_player.gold -= REROLL_STOCK_COST
	_selected_idx = -1
	_roll_stock()
	for i in range(_slot_panels.size()):
		_update_slot_button(_slot_panels[i] as Button, i)
	_saver_loader.savePlayer()
	_status_label.text = "Shop stock rerolled."
	_refresh_ui()


func _on_remove_card_pressed(index: int) -> void:
	if _player == null:
		return
	if Global.player_deck.size() <= 1:
		_status_label.text = "You must keep at least one card."
		return
	if _player.gold < REMOVE_CARD_COST:
		_status_label.text = "Card removal costs %d gold." % REMOVE_CARD_COST
		return
	if index < 0 or index >= Global.player_deck.size():
		return

	var removed_name: String = Global.player_deck[index]
	Global.player_deck.remove_at(index)
	_player.gold -= REMOVE_CARD_COST
	if _player.deckManager != null:
		_player.deckManager.remove_card_from_deck(index)
	_saver_loader.savePlayer()
	_status_label.text = "Removed: %s." % removed_name
	_refresh_ui()


func _on_leave_pressed() -> void:
	if _player != null:
		_saver_loader.savePlayer()
	var target := Global.prev_scene_path
	if target == "":
		target = "res://files/map/scenes/mapScene.tscn"
	get_tree().change_scene_to_file(target)
