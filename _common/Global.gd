extends Node

# ── Scene routing ──────────────────────────────────────────────────────────
var prev_scene_path: String = ""

# ── Map progress ───────────────────────────────────────────────────────────
var curNodeId:  int = -1   # -1 = new game, no node visited yet
var totShops:   int = 0
var num_nodes:  int = 10

# ── Combat handoff ─────────────────────────────────────────────────────────
# Populated by _MapScene before scene change; read by combat_manager in _ready.
var encounter_data: Array = []

# Stores the player's deck across scene changes as card-name strings.
# Empty means the next combat should seed the starter deck.
var player_deck: Array[String] = []
var artifacts: Array[String] = []
var pending_artifact_reward: bool = false
var optional_boss_defeated: bool = false
var starter_deck_mode: String = "normal"
var map_rows: int = 3

const ARTIFACT_POOL: Array[Dictionary] = [
	{"id": "healing_sprout", "name": "Healing Sprout", "description": "Restore 5 HP after every combat."},
	{"id": "protection_charm", "name": "Protection Charm", "description": "Reduce all incoming damage by 5."},
	{"id": "protein_bar", "name": "Protein Bar", "description": "Gain +2 max energy during combat."},
	{"id": "handy_shield", "name": "Handy Shield", "description": "Start every player turn with 4 shield."},
	{"id": "gold_totem", "name": "Gold Totem", "description": "Defeated enemies award improved gold."},
	{"id": "ember_core", "name": "Ember Core", "description": "Elemental cards deal 3 bonus damage."}
]

# ── Boss selection ─────────────────────────────────────────────────────────
# Set once when a new run's map is generated; stays fixed for the whole run.
#   0 = Chronofiend   1 = The Warden   2 = Darkness
var boss_id: int = 0

func new_run() -> void:
	curNodeId  = -1
	totShops   = 0
	boss_id    = randi() % 2
	encounter_data.clear()
	player_deck.clear()
	artifacts.clear()
	ensure_starting_artifact()
	pending_artifact_reward = false
	optional_boss_defeated = false

func ensure_starting_artifact() -> void:
	if not artifacts.has("healing_sprout"):
		artifacts.append("healing_sprout")

func has_artifact(id: String) -> bool:
	return artifacts.has(id)

func award_random_artifact() -> Dictionary:
	var available: Array[Dictionary] = []
	for artifact in ARTIFACT_POOL:
		if not artifacts.has(artifact["id"]):
			available.append(artifact)
	if available.is_empty():
		return {}
	available.shuffle()
	var chosen := available[0]
	artifacts.append(chosen["id"])
	return chosen
