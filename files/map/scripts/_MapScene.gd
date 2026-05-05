extends Node2D
const MAP_NODE = preload("res://files/map/scenes/mapNode.tscn")
const PLAYER   = preload("res://files/player/scenes/player.tscn")

var spacing:     int = 100
var start_x_pos: int = 50 + 100
var start_y_pos: int = 250

var num_of_nodes: int = 10

var col_spacing:  int = 100
var row_spacing:  int = 70
var col_of_nodes: int = 10
var row_of_nodes: int = 3

var node_grid    = []
var playerRestored = null
var event_panel: Control = null
var treasure_panel: Control = null

@onready var scene_transition = $SceneTransition/AnimationPlayer
@onready var saver_loader: saverLoader = %SaverLoader

@warning_ignore("integer_division")
var shop_index = randi_range(num_of_nodes / 2 + 1, num_of_nodes - 2)
var optional_boss_cols: Array[int] = [3, 5, 7]


# =========================================================
# READY
# =========================================================
func _ready():
	print("_MapScene _ready running")
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	await get_tree().create_timer(0.25).timeout
	scene_transition.play("fade_out")
	handleScene()


# =========================================================
# HANDLE SCENE — load or generate
# =========================================================
func handleScene():
	print("handleScene() called in _MapScene.gd")
	row_of_nodes = clamp(Global.map_rows, 3, 5)
	start_y_pos = 300 - int(float(row_of_nodes - 1) * row_spacing / 2.0)

	if FileAccess.file_exists("user://savegame.tres"):
		print("Save file exists")

		var loadedDict    = saver_loader.loadGame(%_Map)
		playerRestored    = loadedDict.get("player", null)
		var placedNodes   = loadedDict.get("mapNodes", [])

		if playerRestored:
			playerRestored.scale  *= 0.5
			playerRestored.z_index = 99
		else:
			print("Player is null in _MapScene.gd")

		# Rebuild grid reference
		node_grid.clear()
		node_grid.resize(row_of_nodes)
		for row in range(row_of_nodes):
			node_grid[row] = []
			node_grid[row].resize(col_of_nodes)
			for col in range(col_of_nodes):
				node_grid[row][col] = null

		for node in placedNodes:
			var row = node.nodeId / col_of_nodes
			var col = node.nodeId % col_of_nodes
			node_grid[row][col] = node
			node.node_selected.connect(_on_node_selected)
			if node.nodeId == playerRestored.curNodeId:
				playerRestored.global_position   = node.global_position
				playerRestored.global_position.y -= 55
				node.isActive    = false
				node.isCompleted = true
				node.updateSprite()
			else:
				node.updateSprite()

			# Visibility by path state
			if not node.isPathNode:
				node.modulate.a = 0.0
			elif node.isCompleted:
				node.modulate.a = 1.0
			else:
				node.modulate.a = 0.5

		var player_col = -1
		if playerRestored.curNodeId != -1:
			player_col = playerRestored.curNodeId % col_of_nodes

		draw_lines_2d()
		for col in range(player_col + 1):
			if line_nodes.has(col):
				for line in line_nodes[col]:
					line.visible = true

		activate_column(player_col + 1)
		saver_loader.saveMapNodes()

	else:
		# ── NEW GAME ──────────────────────────────────────────────────────
		print("Save file does NOT exist — new game")
		Global.boss_id = randi() % 2   # pick boss for this run; Darkness is disabled for now
		generate_map_2d()
		generate_player()
		saver_loader.saveGame()


# =========================================================
# MAP GENERATION
# =========================================================
var active_nodes = {}
var path_edges = {}

func generate_paths():
	active_nodes.clear()
	path_edges.clear()

	var active_rows_by_col: Dictionary = {}
	for col in range(col_of_nodes):
		var active_count = randi_range(2, row_of_nodes) if row_of_nodes > 3 else randi_range(1, row_of_nodes - 1)
		var rows = Array(range(row_of_nodes))
		rows.shuffle()
		var active_rows = rows.slice(0, active_count)
		if col == col_of_nodes - 1:
			active_rows = [row_of_nodes / 2]
		active_rows_by_col[col] = active_rows
		for row in range(row_of_nodes):
			var nodeId = row * col_of_nodes + col
			active_nodes[nodeId] = row in active_rows

	for col in range(col_of_nodes - 1):
		var next_incoming: Dictionary = {}
		for next_row in active_rows_by_col[col + 1]:
			next_incoming[next_row] = false

		for row in active_rows_by_col[col]:
			var from_id = row * col_of_nodes + col
			var candidates: Array = []
			for next_row in active_rows_by_col[col + 1]:
				if abs(int(next_row) - int(row)) <= 2:
					candidates.append(next_row)
			if candidates.is_empty():
				candidates = active_rows_by_col[col + 1].duplicate()
			candidates.shuffle()

			var edge_count = min(candidates.size(), randi_range(1, 2))
			path_edges[from_id] = []
			for i in range(edge_count):
				var to_row: int = candidates[i]
				var to_id: int = to_row * col_of_nodes + col + 1
				path_edges[from_id].append(to_id)
				next_incoming[to_row] = true

		for next_row in next_incoming.keys():
			if next_incoming[next_row]:
				continue
			var best_prev: int = active_rows_by_col[col][0]
			for prev_row in active_rows_by_col[col]:
				if abs(int(prev_row) - int(next_row)) < abs(best_prev - int(next_row)):
					best_prev = prev_row
			var from_id: int = best_prev * col_of_nodes + col
			var to_id: int = int(next_row) * col_of_nodes + col + 1
			if not path_edges.has(from_id):
				path_edges[from_id] = []
			if not path_edges[from_id].has(to_id):
				path_edges[from_id].append(to_id)


func generate_map_2d():
	generate_paths()
	var optional_boss_rows: Dictionary = {}
	for col in optional_boss_cols:
		optional_boss_rows[col] = randi_range(0, row_of_nodes - 1)
		active_nodes[optional_boss_rows[col] * col_of_nodes + col] = true

	for row_num in range(row_of_nodes):
		var cur_row = []
		for col_num in range(col_of_nodes):
			var newNode = MAP_NODE.instantiate()
			var xPos    = start_x_pos + (col_num * col_spacing)
			var yPos    = start_y_pos + (row_num * row_spacing)
			newNode.setNodePos(xPos, yPos)
			newNode.position = newNode.getNodePos()

			var nodeId = row_num * col_of_nodes + col_num
			newNode.setNodeId(nodeId)
			newNode.nodeData = path_edges.get(nodeId, [])

			newNode.isPathNode = active_nodes.get(nodeId, false)
			newNode.modulate.a = 0.0 if not newNode.isPathNode else 0.5
			newNode.isCompleted = false

			if col_num == 0:
				newNode.isActive = true

			# ── Node type assignment ───────────────────────────────────────
			if col_num == col_of_nodes - 1:
				newNode.setNodeName("BOSS")
			elif col_num == shop_index:
				newNode.setNodeName("SHOP")
			elif optional_boss_cols.has(col_num) and row_num == optional_boss_rows.get(col_num, -1):
				newNode.setNodeName("OPTIONAL_BOSS")
			elif col_num > 1 and col_num < col_of_nodes - 2 and randf() < 0.14:
				newNode.setNodeName("EVENT")
			elif col_num > 1 and col_num < col_of_nodes - 2 and randf() < 0.18:
				newNode.setNodeName("TREASURE")
			else:
				newNode.setNodeName("COMBAT")
			# ─────────────────────────────────────────────────────────────

			newNode.updateSprite()
			newNode.node_selected.connect(_on_node_selected)
			cur_row.append(newNode)
			add_child(newNode)

		node_grid.append(cur_row)

	activate_column(0)
	draw_lines_2d()


func generate_player():
	var newPlayer         = PLAYER.instantiate()
	newPlayer.position    = Vector2(60, 300)
	newPlayer.z_index     = 99
	newPlayer.scale      *= 0.5
	newPlayer.curNodeId   = -1
	playerRestored        = newPlayer
	add_child(newPlayer)


# =========================================================
# NODE SELECTED — handles COMBAT / SHOP / BOSS / ELITE
# =========================================================
func _on_node_selected(nodeId: int):
	print("nodeId Selected: ", nodeId, " | in _MapScene.gd")
	if playerRestored == null:
		return

	var clicked_col = nodeId % col_of_nodes
	var clicked_row = nodeId / col_of_nodes
	var player_col  = -1
	if playerRestored.curNodeId != -1:
		player_col = playerRestored.curNodeId % col_of_nodes

	# Must be exactly one column ahead
	if clicked_col != player_col + 1:
		return

	var target_node = node_grid[clicked_row][clicked_col]
	if target_node == null:
		return

	# Mark previous node completed
	if playerRestored.curNodeId != -1:
		var prev_row  = playerRestored.curNodeId / col_of_nodes
		var prev_col  = playerRestored.curNodeId % col_of_nodes
		var prev_node = node_grid[prev_row][prev_col]
		if prev_node:
			prev_node.isActive    = false
			prev_node.isCompleted = true
			prev_node.updateSprite()

	# Move player
	playerRestored.curNodeId           = nodeId
	playerRestored.global_position     = target_node.global_position
	playerRestored.global_position.y  -= 55

	activate_column(clicked_col + 1)
	saver_loader.saveGame()

	# Store where to return after combat
	Global.prev_scene_path = get_tree().current_scene.scene_file_path

	# Populate encounter data based on node type
	match target_node.nodeName:
		"COMBAT":
			_build_combat_encounter()
		"ELITE":
			_build_elite_encounter()
		"BOSS":
			_build_boss_encounter()
		"OPTIONAL_BOSS":
			_build_optional_boss_encounter()
		"EVENT":
			_show_event_panel()
			return
		"TREASURE":
			_show_treasure_panel()
			return
		"SHOP":
			# Shop goes directly — no encounter data needed
			pass

	# Transition then change scene
	scene_transition.play("fade_in")
	await get_tree().create_timer(0.5).timeout

	match target_node.nodeName:
		"COMBAT", "ELITE", "BOSS", "OPTIONAL_BOSS":
			get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn")
		"SHOP":
			get_tree().change_scene_to_file("res://files/combat/scenes/shop.tscn")
		_:
			get_tree().change_scene_to_file("res://files/combat/scenes/combat.tscn")


# =========================================================
# ENCOUNTER BUILDERS (ported from your mapNode.gd)
# =========================================================
func _scramble_future_map(start_col: int) -> void:
	for col in range(max(start_col, 1), col_of_nodes - 1):
		var active_count := randi_range(1, row_of_nodes - 1)
		var rows := Array(range(row_of_nodes))
		rows.shuffle()
		var active_rows := rows.slice(0, active_count)
		var optional_boss_row := randi_range(0, row_of_nodes - 1)
		if optional_boss_cols.has(col) and not active_rows.has(optional_boss_row):
			active_rows.append(optional_boss_row)
		for row in range(row_of_nodes):
			var node = node_grid[row][col]
			if node == null or node.isCompleted:
				continue
			node.isPathNode = row in active_rows
			node.isActive = false
			node.modulate.a = 0.0 if not node.isPathNode else 0.5
			if col == shop_index:
				node.setNodeName("SHOP")
			elif optional_boss_cols.has(col) and row == optional_boss_row:
				node.setNodeName("OPTIONAL_BOSS")
			elif col > 1 and col < col_of_nodes - 2 and randf() < 0.25:
				node.setNodeName("EVENT")
			else:
				node.setNodeName("COMBAT")
			node.updateSprite()
	_redraw_map_lines()


func _build_combat_encounter() -> void:
	var count    = randi_range(1, 3)
	var movesets = [
		[1, 3, 1, 3],
		[1, 1, 3, 1],
		[3, 1, 3, 3],
		[1, 3, 3, 1],
	]
	var enemies = []
	for _i in range(count):
		enemies.append({
			"type":    "normal",
			"hp":      randi_range(20, 45),
			"moveset": movesets[randi() % movesets.size()]
		})
	Global.encounter_data = enemies
	print("Built combat encounter — %d enemies" % count)


func _build_elite_encounter() -> void:
	Global.encounter_data = [
		{"type": "elite", "hp": 60, "moveset": [1, 11, 3, 1]},
		{"type": "elite", "hp": 50, "moveset": [1, 3, 11, 3]}
	]
	print("Built elite encounter.")


func _build_boss_encounter() -> void:
	match Global.boss_id:
		0:  Global.encounter_data = _boss_chronofiend()
		1:  Global.encounter_data = _boss_warden()
		_:  Global.encounter_data = _boss_warden()
	Global.pending_artifact_reward = false
	print("Built boss encounter — boss_id = %d" % Global.boss_id)


func _build_optional_boss_encounter() -> void:
	match randi() % 2:
		0:  Global.encounter_data = _boss_chronofiend()
		_:  Global.encounter_data = _boss_warden()
	Global.pending_artifact_reward = true
	print("Built optional artifact boss encounter.")


func _show_event_panel() -> void:
	if event_panel:
		event_panel.queue_free()
	event_panel = ColorRect.new()
	event_panel.color = Color(0, 0, 0, 0.78)
	event_panel.size = get_viewport().get_visible_rect().size
	event_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	event_panel.z_index = 250
	add_child(event_panel)

	var events := _event_pool()
	events.shuffle()
	var story: Dictionary = events[0]
	event_panel.set_meta("event_data", story)

	var title := Label.new()
	title.text = story["title"]
	title.position = Vector2(260, 90)
	title.size = Vector2(620, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	event_panel.add_child(title)

	var body := Label.new()
	body.text = story["body"]
	body.position = Vector2(260, 150)
	body.size = Vector2(620, 130)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 18)
	event_panel.add_child(body)

	var options: Array = story["options"]
	var start_x := 300.0
	for i in range(options.size()):
		var option: Dictionary = options[i]
		var choice := Button.new()
		choice.text = option["label"]
		choice.position = Vector2(start_x + i * 190.0, 330)
		choice.size = Vector2(170, 52)
		choice.pressed.connect(_resolve_event.bind(body, option))
		event_panel.add_child(choice)

	var leave := Button.new()
	leave.text = "Leave"
	leave.position = Vector2(785, 330)
	leave.size = Vector2(150, 48)
	leave.pressed.connect(_close_event_panel)
	event_panel.add_child(leave)


func _event_pool() -> Array[Dictionary]:
	return [
		{
			"title": "The Lantern Surgeon",
			"body": "A surgeon with a lantern-mask offers to cut a glowing splinter from your ribs. The light inside it beats like a second heart.",
			"options": [
				{"label": "Hold Still", "effect": "hp_for_artifact", "hp": 30, "text": "The cut is clean and cold. You lose %d HP, but the splinter hardens into an artifact."},
				{"label": "Offer Gold", "effect": "gold_for_heal", "gold": 40, "heal": 35, "text": "The surgeon pockets the gold and stitches warmth through your chest. You heal %d HP."}
			]
		},
		{
			"title": "The Ink-Bound Duelist",
			"body": "A duelist draws a card in black ink and presses it against your palm. The ink will not dry unless it drinks something first.",
			"options": [
				{"label": "Bleed for Ink", "effect": "hp_for_card", "hp": 20, "text": "The card drinks from your palm. You lose %d HP and gain a new card."},
				{"label": "Pay the Ante", "effect": "gold_for_card", "gold": 35, "text": "The duelist bows. Your gold vanishes; a card remains."}
			]
		},
		{
			"title": "The Brass Orchard",
			"body": "Metal fruit hangs from a tree that ticks instead of rustles. Each fruit promises power, but the branch bends toward your throat.",
			"options": [
				{"label": "Bite the Fruit", "effect": "hp_for_gold", "hp": 18, "gold": 75, "text": "The fruit tastes like lightning and coins. You lose %d HP and gain %d gold."},
				{"label": "Crack the Seed", "effect": "hp_for_artifact", "hp": 25, "text": "The seed splits in your hand. You lose %d HP and uncover an artifact."}
			]
		},
		{
			"title": "The Three Silent Bells",
			"body": "Three bells hang without clappers. One sounds only for the living, one for the lost, and one for those who listen too closely.",
			"options": [
				{"label": "Left Bell", "effect": "gain_card", "text": "The bell rings inside your deck. A card appears."},
				{"label": "Middle Bell", "effect": "take_damage", "hp": 22, "text": "The bell answers too loudly. You lose %d HP."},
				{"label": "Right Bell", "effect": "gain_gold", "gold": 60, "text": "The bell rings like a dropped coin. You gain %d gold."}
			]
		},
		{
			"title": "The Door With No Hinges",
			"body": "A painted door stands on bare stone. Three keys lie beneath it, each warm as if recently held.",
			"options": [
				{"label": "Bone Key", "effect": "take_damage", "hp": 18, "text": "The door opens onto your own shadow. You lose %d HP."},
				{"label": "Glass Key", "effect": "gain_artifact", "text": "The door opens onto a small, impossible room. An artifact waits inside."},
				{"label": "Iron Key", "effect": "heal", "heal": 30, "text": "The door opens onto clean air. You heal %d HP."}
			]
		}
	]


func _resolve_event(body: Label, option: Dictionary) -> void:
	if event_panel and event_panel.get_meta("resolved", false):
		return
	if event_panel:
		event_panel.set_meta("resolved", true)

	match option["effect"]:
		"hp_for_artifact":
			var loss: int = option["hp"]
			playerRestored.currentHP = max(1, playerRestored.currentHP - loss)
			var artifact := Global.award_random_artifact()
			body.text = option["text"] % loss
			if not artifact.is_empty():
				body.text += "\nArtifact gained: %s." % artifact["name"]
		"hp_for_card":
			var loss: int = option["hp"]
			playerRestored.currentHP = max(1, playerRestored.currentHP - loss)
			var card_name := _award_random_card()
			body.text = option["text"] % loss
			body.text += "\nCard gained: %s." % card_name
		"gold_for_heal":
			var cost: int = min(playerRestored.gold, int(option["gold"]))
			playerRestored.gold -= cost
			var healed: int = min(int(option["heal"]), playerRestored.maxHP - playerRestored.currentHP)
			playerRestored.currentHP += healed
			body.text = option["text"] % healed
		"gold_for_card":
			var cost: int = min(playerRestored.gold, int(option["gold"]))
			playerRestored.gold -= cost
			var card_name := _award_random_card()
			body.text = option["text"] + "\nCard gained: %s." % card_name
		"hp_for_gold":
			var loss: int = option["hp"]
			var gained: int = option["gold"]
			playerRestored.currentHP = max(1, playerRestored.currentHP - loss)
			playerRestored.gold += gained
			body.text = option["text"] % [loss, gained]
		"gain_card":
			var card_name := _award_random_card()
			body.text = option["text"] + "\nCard gained: %s." % card_name
		"gain_gold":
			var gained: int = option["gold"]
			playerRestored.gold += gained
			body.text = option["text"] % gained
		"gain_artifact":
			var artifact := Global.award_random_artifact()
			body.text = option["text"]
			if not artifact.is_empty():
				body.text += "\nArtifact gained: %s." % artifact["name"]
		"heal":
			var healed: int = min(int(option["heal"]), playerRestored.maxHP - playerRestored.currentHP)
			playerRestored.currentHP += healed
			body.text = option["text"] % healed
		"take_damage":
			var loss: int = option["hp"]
			playerRestored.currentHP = max(1, playerRestored.currentHP - loss)
			body.text = option["text"] % loss
	saver_loader.savePlayer()
	if event_panel:
		_disable_event_engage_buttons(event_panel)


func _disable_event_engage_buttons(root: Node) -> void:
	for child in root.get_children():
		if child is Button and child.text == "Engage":
			child.disabled = true
		_disable_event_engage_buttons(child)


func _award_random_card() -> String:
	var db := CardDatabase.new()
	add_child(db)
	db.load_cards("res://_assets/cards.json")
	var cards := db.cards.keys()
	var chosen := ""
	if not cards.is_empty():
		chosen = cards[randi() % cards.size()]
		Global.player_deck.append(chosen)
	db.queue_free()
	return chosen


func _remove_random_card() -> void:
	if Global.player_deck.size() <= 1:
		return
	Global.player_deck.remove_at(randi() % Global.player_deck.size())


func _close_event_panel() -> void:
	if event_panel:
		event_panel.queue_free()
		event_panel = null
	saver_loader.saveGame()


func _show_treasure_panel() -> void:
	if treasure_panel:
		treasure_panel.queue_free()

	treasure_panel = ColorRect.new()
	treasure_panel.color = Color(0, 0, 0, 0.78)
	treasure_panel.size = get_viewport().get_visible_rect().size
	treasure_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	treasure_panel.z_index = 260
	add_child(treasure_panel)

	var gold := randi_range(45, 90)
	playerRestored.gold += gold
	var artifact := Global.award_random_artifact()
	saver_loader.savePlayer()

	var title := Label.new()
	title.text = "Treasure Chest"
	title.position = Vector2(260, 78)
	title.size = Vector2(620, 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	treasure_panel.add_child(title)

	var body := Label.new()
	body.text = "The chest opens with a satisfied click. You gain %d gold%s. Choose one card from the velvet tray." % [
		gold,
		" and %s" % artifact.get("name", "an artifact") if not artifact.is_empty() else ""
	]
	body.position = Vector2(250, 135)
	body.size = Vector2(650, 80)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 17)
	treasure_panel.add_child(body)

	var cards := _roll_treasure_cards()
	var start_x := 300.0
	for i in range(cards.size()):
		var card: String = cards[i]
		var btn := Button.new()
		btn.text = card
		btn.position = Vector2(start_x + i * 190.0, 260)
		btn.size = Vector2(170, 72)
		btn.pressed.connect(_on_treasure_card_chosen.bind(card))
		treasure_panel.add_child(btn)


func _roll_treasure_cards() -> Array[String]:
	var db := CardDatabase.new()
	add_child(db)
	db.load_cards("res://_assets/cards.json")
	var names: Array[String] = []
	for name in db.cards.keys():
		names.append(name)
	names.shuffle()
	var offered: Array[String] = []
	for i in range(min(3, names.size())):
		offered.append(names[i])
	db.queue_free()
	return offered


func _on_treasure_card_chosen(card_name: String) -> void:
	Global.player_deck.append(card_name)
	saver_loader.savePlayer()
	if treasure_panel:
		treasure_panel.queue_free()
		treasure_panel = null
	saver_loader.saveGame()


# ── Boss 0: Chronofiend ────────────────────────────────────────────────────
func _boss_chronofiend() -> Array:
	return [{
		"type":             "boss",
		"hp":               180,
		"sprite":           "res://_assets/bosses/chronofiend.png",
		"bg_color":         Color(0.05, 0.0, 0.15),
		"phase_thresholds": [0.33],
		"phase_movesets":   [
			[6, 7, 8, 5],
			[6, 9, 8, 9]
		]
	}]


# ── Boss 1: The Warden ─────────────────────────────────────────────────────
func _boss_warden() -> Array:
	return [{
		"type":             "boss",
		"hp":               150,
		"sprite":           "res://_assets/bosses/warden.png",
		"bg_color":         Color(0.1, 0.05, 0.0),
		"phase_thresholds": [0.33],
		"phase_movesets":   [
			[1, 2, 3, 1],
			[1, 4, 5, 3]
		]
	}]


# ── Boss 2: Darkness ───────────────────────────────────────────────────────
func _boss_darkness() -> Array:
	# Disabled for now: this incomplete boss starts in the dangerous phase and
	# repeatedly uses Darkness Grasp for 100 damage.
	# return [{
	# 	"type": "boss",
	# 	"hp": 200,
	# 	"sprite": "res://_assets/bosses/darkness.png",
	# 	"bg_color": Color(0.0, 0.0, 0.0),
	# 	"phase_thresholds": [0.33],
	# 	"phase_movesets": [
	# 		[10, 10, 10, 10, 10],
	# 		[10, 10, 10, 10, 10]
	# 	]
	# }]
	return []


# =========================================================
# COLUMN ACTIVATION
# =========================================================
func activate_column(col: int):
	if col >= col_of_nodes:
		return
	var reachable: Array = []
	if col > 0 and playerRestored != null and playerRestored.curNodeId != -1:
		var prev_row = playerRestored.curNodeId / col_of_nodes
		var prev_col = playerRestored.curNodeId % col_of_nodes
		if prev_col == col - 1:
			var prev_node = node_grid[prev_row][prev_col]
			if prev_node != null:
				reachable = prev_node.nodeData

	for row in range(row_of_nodes):
		var node = node_grid[row][col]
		if node != null and node.isPathNode:
			var can_reach := col == 0 or reachable.has(node.nodeId)
			node.isActive = can_reach
			node.modulate.a = 1.0 if can_reach else 0.5
			node.updateSprite()
	if line_nodes.has(col - 1):
		for line in line_nodes[col - 1]:
			line.visible = true


# =========================================================
# LINE DRAWING
# =========================================================
var line_nodes = {}


func _redraw_map_lines() -> void:
	for lines in line_nodes.values():
		for line in lines:
			if is_instance_valid(line):
				line.queue_free()
	line_nodes.clear()
	draw_lines_2d()

func draw_lines_2d():
	line_nodes.clear()
	for row in range(row_of_nodes):
		for col in range(col_of_nodes - 1):
			var nodeA = node_grid[row][col]
			if nodeA == null or not nodeA.isPathNode:
				continue
			for to_id in nodeA.nodeData:
				var next_row = int(to_id) / col_of_nodes
				var next_col = int(to_id) % col_of_nodes
				if next_col != col + 1 or next_row < 0 or next_row >= row_of_nodes:
					continue
				var nodeB = node_grid[next_row][next_col]
				if nodeB == null or not nodeB.isPathNode:
					continue
				var line               = Line2D.new()
				line.add_point(nodeA.position)
				line.add_point(nodeB.position)
				line.width             = 3
				line.default_color     = Color(0, 0, 0)
				line.z_index           = -55
				line.visible           = false
				add_child(line)
				if not line_nodes.has(col):
					line_nodes[col] = []
				line_nodes[col].append(line)
