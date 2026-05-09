class_name Difficulty
extends RefCounted

const DATA: Dictionary = {
	"normal": {
		"name": "Normal",
		"name_key": "difficulty_normal",
		"hp_mult": 1.0,
		"dmg_mult": 1.0,
		"reward_mult": 1.0,
		"color": Color(0.6, 0.85, 0.6),
	},
	"hard": {
		"name": "Hard",
		"name_key": "difficulty_hard",
		"hp_mult": 1.5,
		"dmg_mult": 1.3,
		"reward_mult": 1.3,
		"color": Color(1.0, 0.7, 0.3),
	},
	"nightmare": {
		"name": "Nightmare",
		"name_key": "difficulty_nightmare",
		"hp_mult": 2.5,
		"dmg_mult": 1.7,
		"reward_mult": 1.7,
		"color": Color(1.0, 0.3, 0.4),
	},
}

const ORDER: Array = ["normal", "hard", "nightmare"]

static func get_data(key: String) -> Dictionary:
	return DATA.get(key, DATA["normal"])

static func display_name(key: String) -> String:
	var d := get_data(key)
	if d.has("name_key") and Localization:
		return Localization.tr_key(String(d["name_key"]), String(d.get("name", "?")))
	return String(d.get("name", "?"))

static func next_key(key: String) -> String:
	var idx: int = ORDER.find(key)
	if idx == -1:
		return ORDER[0]
	return ORDER[(idx + 1) % ORDER.size()]
