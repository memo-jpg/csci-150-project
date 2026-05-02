extends Area2D
class_name mapNode

@export var nodeId:      int    = -1
@export var nodeName:    String = "noName"
@export var nodeData:    Array  = [0, 1, 2, 3]
@export var isActive:    bool   = false
@export var isCompleted: bool   = false
@export var isPathNode:  bool   = true
@export var curNodeType: int    = 0
@export var nodePos:     Vector2

signal node_selected(nodeId)

@onready var scene_transition = get_node_or_null("SceneTransition/AnimationPlayer")


func _ready():
	pass


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("mouseClick") and isActive:
		emit_signal("node_selected", nodeId)
		print("_input_event fired, isActive: ", isActive, " nodeId: ", nodeId)


# =========================================================
# SAVE / LOAD
# =========================================================
func on_save_game(saved_data: Array[savedData]):
	var my_data          = SavedMapData.new()
	my_data.scene_path   = scene_file_path
	my_data.position     = global_position
	my_data.nodeId       = nodeId
	my_data.nodeName     = nodeName
	my_data.isActive     = isActive
	my_data.nodeData     = nodeData
	my_data.nodePos      = global_position
	my_data.isCompleted  = isCompleted
	my_data.isPathNode   = isPathNode
	saved_data.append(my_data)


func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()


func on_load_game(saved_data: savedData):
	var my_data: SavedMapData = saved_data as SavedMapData
	global_position = my_data.position
	nodeId          = my_data.nodeId
	nodeName        = my_data.nodeName
	isActive        = my_data.isActive
	isCompleted     = my_data.isCompleted
	nodeData        = my_data.nodeData
	isPathNode      = my_data.isPathNode


# =========================================================
# SPRITE UPDATE
# Sprite sheet regions (mapNodeSprites.png, each frame 400px wide):
#   COMBAT:    x=0
#   SHOP:      x=410
#   COMPLETED: x=820
#   BOSS:      x=1230  (if you add a 4th frame; otherwise falls back to COMBAT)
# =========================================================
func updateSprite():
	z_index = 1
	$mapNodeSprites.modulate = Color(1, 1, 1)
	if isCompleted:
		$mapNodeSprites.region_rect = Rect2(820, 0, 400, 400)
	elif nodeName == "BOSS":
		$mapNodeSprites.region_rect = Rect2(0, 0, 400, 400)
		$mapNodeSprites.modulate = Color(0.25, 0.65, 1.0)
	elif nodeName == "OPTIONAL_BOSS":
		$mapNodeSprites.region_rect = Rect2(0, 0, 400, 400)
		$mapNodeSprites.modulate = Color(1.0, 0.25, 0.95)
	elif nodeName == "EVENT":
		$mapNodeSprites.region_rect = Rect2(410, 0, 400, 400)
		$mapNodeSprites.modulate = Color(1.0, 0.9, 0.25)
	elif nodeName == "TREASURE":
		$mapNodeSprites.region_rect = Rect2(410, 0, 400, 400)
		$mapNodeSprites.modulate = Color(1.0, 0.72, 0.1)
	elif nodeName == "SHOP":
		$mapNodeSprites.region_rect = Rect2(410, 0, 400, 400)
	elif nodeName == "ELITE":
		$mapNodeSprites.region_rect = Rect2(410, 0, 400, 400)  # re-use SHOP frame until elite frame added
	else:
		# COMBAT (default)
		$mapNodeSprites.region_rect = Rect2(0, 0, 400, 400)


# =========================================================
# SETTERS / GETTERS
# =========================================================
func setNodeId(argId: int):
	nodeId = argId

func setNodeName(argName: String):
	nodeName = str(argName)

func setNodePos(argX: float, argY: float):
	nodePos = Vector2(argX, argY)

func getNodeName(): return nodeName
func getNodeId():   return nodeId
func getNodeType(): return curNodeType
func getNodePos():  return nodePos

func getLevelInfo():
	return ("Name: %s\nLevel %s\n" % [str(nodeName), str(nodeId)])
