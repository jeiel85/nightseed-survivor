extends Node

var gold: int = 0
var permanent_upgrades: Dictionary = {
	"swift_boots": 0,
	"magnet_charm": 0,
	"iron_heart": 0,
	"battle_focus": 0,
	"power_core": 0,
}
var selected_character: String = "vagrant"
var unlocked_characters: Array = ["vagrant"]
var achievements_unlocked: Array = []
var selected_stage: String = "forest"
var unlocked_stages: Array = ["forest"]
var difficulty: String = "normal"
var language: String = "auto"

# Transient (not saved): current run elapsed seconds, set by GameRoot each frame.
# EnemyBase reads this to apply time-based scaling (HP/speed/damage grow over time).
var run_elapsed: float = 0.0

const UPGRADE_COSTS: Array = [100, 200, 350, 550, 800, 1100, 1500, 2000, 2600, 3300]
const UPGRADE_MAX_LEVEL: int = 10
const SAVE_PATH: String = "user://save_data.json"

func _ready() -> void:
	load_data()

func get_upgrade_cost(key: String) -> int:
	var level: int = permanent_upgrades.get(key, 0)
	if level >= UPGRADE_MAX_LEVEL:
		return -1
	return UPGRADE_COSTS[level]

func try_upgrade(key: String) -> bool:
	var cost: int = get_upgrade_cost(key)
	if cost < 0 or gold < cost:
		return false
	gold -= cost
	permanent_upgrades[key] += 1
	save_data()
	return true

func is_character_unlocked(key: String) -> bool:
	return unlocked_characters.has(key)

func try_unlock_character(key: String, cost: int) -> bool:
	if is_character_unlocked(key) or gold < cost:
		return false
	gold -= cost
	unlocked_characters.append(key)
	save_data()
	return true

func select_character(key: String) -> bool:
	if not is_character_unlocked(key):
		return false
	selected_character = key
	save_data()
	return true

func add_gold(amount: int) -> void:
	gold += amount
	save_data()

func is_stage_unlocked(id: String) -> bool:
	return unlocked_stages.has(id)

func try_unlock_stage(id: String, cost: int) -> bool:
	if is_stage_unlocked(id) or gold < cost:
		return false
	gold -= cost
	unlocked_stages.append(id)
	save_data()
	return true

func select_stage(id: String) -> bool:
	if not is_stage_unlocked(id):
		return false
	selected_stage = id
	save_data()
	return true

func has_achievement(key: String) -> bool:
	return achievements_unlocked.has(key)

func try_unlock_achievement(key: String) -> bool:
	if has_achievement(key) or not Achievements.DATA.has(key):
		return false
	achievements_unlocked.append(key)
	gold += int(Achievements.DATA[key]["gold"])
	save_data()
	return true

func save_data() -> void:
	var data: Dictionary = {
		"gold": gold,
		"permanent_upgrades": permanent_upgrades.duplicate(),
		"selected_character": selected_character,
		"unlocked_characters": unlocked_characters.duplicate(),
		"achievements_unlocked": achievements_unlocked.duplicate(),
		"selected_stage": selected_stage,
		"unlocked_stages": unlocked_stages.duplicate(),
		"difficulty": difficulty,
		"language": language,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	# Mark cloud-dirty so PGS Snapshots flushes our meta progress within the
	# throttle window. No-op on non-Android or when not signed in.
	var cs := get_node_or_null("/root/CloudSave")
	if cs and cs.has_method("mark_dirty"):
		cs.mark_dirty()

# Merge a payload coming from PGS cloud into local state, then persist.
# Policy: gold takes the max; arrays (unlocks/achievements) take the union;
# permanent_upgrades takes the max per key. Selected character/stage prefer
# the cloud value only if it's still unlocked locally after the merge.
func apply_cloud_payload(payload: Dictionary) -> void:
	if payload.is_empty():
		return
	gold = maxi(gold, int(payload.get("gold", 0)))
	var saved_up: Dictionary = payload.get("permanent_upgrades", {})
	for key in permanent_upgrades:
		permanent_upgrades[key] = maxi(permanent_upgrades.get(key, 0), int(saved_up.get(key, 0)))
	var cloud_chars = payload.get("unlocked_characters", [])
	if cloud_chars is Array:
		for c in cloud_chars:
			if not unlocked_characters.has(c):
				unlocked_characters.append(c)
	var cloud_stages = payload.get("unlocked_stages", [])
	if cloud_stages is Array:
		for s in cloud_stages:
			if not unlocked_stages.has(s):
				unlocked_stages.append(s)
	var cloud_achs = payload.get("achievements_unlocked", [])
	if cloud_achs is Array:
		for a in cloud_achs:
			if not achievements_unlocked.has(a):
				achievements_unlocked.append(a)
	var cs_char: String = String(payload.get("selected_character", ""))
	if cs_char != "" and unlocked_characters.has(cs_char):
		selected_character = cs_char
	var cs_stage: String = String(payload.get("selected_stage", ""))
	if cs_stage != "" and unlocked_stages.has(cs_stage):
		selected_stage = cs_stage
	var cs_diff: String = String(payload.get("difficulty", ""))
	if cs_diff != "" and Difficulty.DATA.has(cs_diff):
		difficulty = cs_diff
	save_data()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	if result == null or not result is Dictionary:
		return
	gold = result.get("gold", 0)
	var saved: Dictionary = result.get("permanent_upgrades", {})
	for key in permanent_upgrades:
		permanent_upgrades[key] = saved.get(key, 0)
	selected_character = result.get("selected_character", "vagrant")
	var saved_chars = result.get("unlocked_characters", ["vagrant"])
	if saved_chars is Array:
		unlocked_characters = saved_chars.duplicate()
	if not unlocked_characters.has("vagrant"):
		unlocked_characters.append("vagrant")
	if not unlocked_characters.has(selected_character):
		selected_character = "vagrant"
	var saved_achs = result.get("achievements_unlocked", [])
	if saved_achs is Array:
		achievements_unlocked = saved_achs.duplicate()
	selected_stage = result.get("selected_stage", "forest")
	var saved_stages = result.get("unlocked_stages", ["forest"])
	if saved_stages is Array:
		unlocked_stages = saved_stages.duplicate()
	if not unlocked_stages.has("forest"):
		unlocked_stages.append("forest")
	if not unlocked_stages.has(selected_stage):
		selected_stage = "forest"
	difficulty = result.get("difficulty", "normal")
	if not Difficulty.DATA.has(difficulty):
		difficulty = "normal"
	language = result.get("language", "auto")

func cycle_difficulty() -> String:
	difficulty = Difficulty.next_key(difficulty)
	save_data()
	return difficulty

func get_speed_bonus() -> float:
	return permanent_upgrades.get("swift_boots", 0) * 12.0

func get_magnet_bonus() -> float:
	return permanent_upgrades.get("magnet_charm", 0) * 20.0

func get_hp_bonus() -> int:
	return permanent_upgrades.get("iron_heart", 0) * 10

func get_cooldown_multiplier() -> float:
	return maxf(1.0 - permanent_upgrades.get("battle_focus", 0) * 0.04, 0.3)

func get_damage_multiplier() -> float:
	return 1.0 + permanent_upgrades.get("power_core", 0) * 0.05
