extends Node

var gold: int = 0
var permanent_upgrades: Dictionary = {
	"swift_boots": 0,
	"magnet_charm": 0,
	"iron_heart": 0,
	"battle_focus": 0,
	"power_core": 0,
}

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

func add_gold(amount: int) -> void:
	gold += amount
	save_data()

func save_data() -> void:
	var data: Dictionary = {
		"gold": gold,
		"permanent_upgrades": permanent_upgrades.duplicate(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

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
