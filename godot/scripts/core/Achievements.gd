class_name Achievements
extends RefCounted

const DATA: Dictionary = {
	"first_survivor":  {"name": "First Survivor",  "desc": "Survive the full duration",            "gold": 200, "name_key": "ach_first_survivor_name",  "desc_key": "ach_first_survivor_desc"},
	"speed_runner":    {"name": "Speed Runner",    "desc": "Reach Level 10 in under 3 minutes",     "gold": 150, "name_key": "ach_speed_runner_name",    "desc_key": "ach_speed_runner_desc"},
	"killer_instinct": {"name": "Killer Instinct", "desc": "Kill 200 enemies in one run",           "gold": 100, "name_key": "ach_killer_instinct_name", "desc_key": "ach_killer_instinct_desc"},
	"untouchable":     {"name": "Untouchable",     "desc": "Reach Level 5 without taking damage",   "gold": 200, "name_key": "ach_untouchable_name",     "desc_key": "ach_untouchable_desc"},
	"evolver":         {"name": "Evolver",         "desc": "Evolve a weapon",                       "gold": 250, "name_key": "ach_evolver_name",         "desc_key": "ach_evolver_desc"},
	"boss_slayer":     {"name": "Boss Slayer",     "desc": "Defeat the final boss",                 "gold": 300, "name_key": "ach_boss_slayer_name",     "desc_key": "ach_boss_slayer_desc"},
	"wealthy":         {"name": "Wealthy",         "desc": "Earn 500 gold in one run",              "gold": 200, "name_key": "ach_wealthy_name",         "desc_key": "ach_wealthy_desc"},
	"combo_master":    {"name": "Combo Master",    "desc": "Carry 4 different weapons at once",     "gold": 250, "name_key": "ach_combo_master_name",    "desc_key": "ach_combo_master_desc"},
	"hard_mode_clear": {"name": "Trial by Fire",   "desc": "Win on Hard or Nightmare difficulty",   "gold": 400, "name_key": "ach_hard_mode_clear_name", "desc_key": "ach_hard_mode_clear_desc"},
	"completionist":   {"name": "Completionist",   "desc": "Reach Level 20 in one run",             "gold": 350, "name_key": "ach_completionist_name",   "desc_key": "ach_completionist_desc"},
}

static func display_name(key: String) -> String:
	var d: Dictionary = DATA.get(key, {})
	if d.has("name_key") and Localization:
		return Localization.tr_key(String(d["name_key"]), String(d.get("name", "?")))
	return String(d.get("name", "?"))

static func display_desc(key: String) -> String:
	var d: Dictionary = DATA.get(key, {})
	if d.has("desc_key") and Localization:
		return Localization.tr_key(String(d["desc_key"]), String(d.get("desc", "")))
	return String(d.get("desc", ""))

const ORDER: Array = [
	"first_survivor", "speed_runner", "killer_instinct",
	"untouchable", "evolver", "boss_slayer",
	"wealthy", "combo_master", "hard_mode_clear", "completionist",
]
