extends Control

@export var player_cards: playerCards
@export var player: Player

var shop_inventory: Array = []        # names of cards in shop
var card_prices: Dictionary = {}      # card_name -> gold price
var steal_chances: Dictionary = {}    # card_name -> 0-100 chance

var selected_card := ""

# --- UI references ---
@onready var slots_container = $Panel/CardSlots
@onready var zoom_panel = $ZoomPanel
@onready var buy_button = $ZoomPanel/BuyButton
@onready var close_button = $ZoomPanel/CloseButton

func hide_zoom_panel() -> void:
	zoom_panel.visible = false
	selected_card = ""

func _ready():
	hide_zoom_panel()
	populate_shop()
	update_slots()

	# Connect Buy + Close
	if not buy_button.pressed.is_connected(_on_buy_pressed):
		buy_button.pressed.connect(_on_buy_pressed)
	if not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)

# --- Populate shop from card registry ---
func populate_shop() -> void:
	shop_inventory.clear()
	card_prices.clear()
	steal_chances.clear()

	for card in player_cards.card_list:
		shop_inventory.append(card.name)
		card_prices[card.name] = randi_range(50, 100)
		steal_chances[card.name] = randi_range(0, 100)

# --- Update 4 slots ---
func update_slots() -> void:
	for i in range(slots_container.get_child_count()):
		var slot = slots_container.get_child(i)
		if i < shop_inventory.size():
			var card_name = shop_inventory[i]
			slot.disabled = false
			slot.text = "%s - %dG" % [card_name, card_prices[card_name]]
			# Connect click to zoom panel
			if not slot.pressed.is_connected(_on_slot_pressed):
				slot.pressed.connect(_on_slot_pressed.bind(i))
		else:
			slot.text = "Empty"
			slot.disabled = true

# --- Open zoom panel ---
func _on_slot_pressed(index: int) -> void:
	selected_card = shop_inventory[index]
	zoom_panel.visible = true
	# Placeholder: your friend can draw card here
	zoom_panel.get_node("CardZoomContainer").get_child(0).text = selected_card

# --- Buy ---
func _on_buy_pressed() -> void:
	if selected_card == "":
		return
	var price = card_prices[selected_card]
	if player.gold < price:
		print("Not enough gold!")
		return
	var success = player_cards.try_get_card(selected_card, price, -1, player.gold)
	if success:
		player.gold -= price
		print("Purchased:", selected_card)
		hide_zoom_panel()
	else:
		print("Purchase failed.")

# --- Close ---
func _on_close_pressed() -> void:
	hide_zoom_panel()
	selected_card = ""
