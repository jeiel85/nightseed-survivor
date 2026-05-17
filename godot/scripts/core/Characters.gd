class_name Characters
extends RefCounted

const DEFAULT_KEY: String = "vagrant"
const ORDER: Array = ["vagrant", "spirit_sister", "hunter", "berserker", "pyromancer"]

const DATA: Dictionary = {
	"vagrant": {
		"name": "Vagrant",
		"desc": "Balanced loner with a moonlit blade.",
		"starting_weapon": "Moon Dagger",
		"max_hp": 100,
		"move_speed": 160.0,
		"cooldown_mult": 1.0,
		"damage_mult": 1.0,
		"xp_radius": 80.0,
		"color": Color(0.2, 0.5, 1.0),
		"sprite": "res://assets/sprites/char_vagrant.png",
		"unlock_cost": 0,
		"name_key": "char_vagrant_name",
		"desc_key": "char_vagrant_desc",
		"passive_id": "blade_dance",
		"passive_name_key": "char_passive_blade_dance_name",
		"passive_desc_key": "char_passive_blade_dance_desc",
	},
	"spirit_sister": {
		"name": "Spirit Sister",
		"desc": "Channels orbiting souls. Frail but magnetic.",
		"starting_weapon": "Spirit Orb",
		"max_hp": 80,
		"move_speed": 150.0,
		"cooldown_mult": 0.95,
		"damage_mult": 1.0,
		"xp_radius": 110.0,
		"color": Color(0.4, 0.95, 0.95),
		"sprite": "res://assets/sprites/char_spirit_sister.png",
		"unlock_cost": 200,
		"name_key": "char_spirit_sister_name",
		"desc_key": "char_spirit_sister_desc",
		"passive_id": "soul_echo",
		"passive_name_key": "char_passive_soul_echo_name",
		"passive_desc_key": "char_passive_soul_echo_desc",
	},
	"hunter": {
		"name": "Hunter",
		"desc": "Swift archer. High mobility, low defense.",
		"starting_weapon": "Star Needle",
		"max_hp": 75,
		"move_speed": 180.0,
		"cooldown_mult": 0.9,
		"damage_mult": 1.0,
		"xp_radius": 80.0,
		"color": Color(0.95, 0.85, 0.4),
		"sprite": "res://assets/sprites/char_hunter.png",
		"unlock_cost": 500,
		"name_key": "char_hunter_name",
		"desc_key": "char_hunter_desc",
		"passive_id": "flee_reload",
		"passive_name_key": "char_passive_flee_reload_name",
		"passive_desc_key": "char_passive_flee_reload_desc",
	},
	"berserker": {
		"name": "Berserker",
		"desc": "Reckless force. High HP and damage, slow.",
		"starting_weapon": "Thorn Ring",
		"max_hp": 140,
		"move_speed": 140.0,
		"cooldown_mult": 1.05,
		"damage_mult": 1.25,
		"xp_radius": 70.0,
		"color": Color(0.5, 0.95, 0.4),
		"sprite": "res://assets/sprites/char_berserker.png",
		"unlock_cost": 1000,
		"name_key": "char_berserker_name",
		"desc_key": "char_berserker_desc",
		"passive_id": "reckless_fury",
		"passive_name_key": "char_passive_reckless_fury_name",
		"passive_desc_key": "char_passive_reckless_fury_desc",
	},
	"pyromancer": {
		"name": "Pyromancer",
		"desc": "Fire-bound caster. Wisp-charged from start.",
		"starting_weapon": "Fire Wisp",
		"max_hp": 90,
		"move_speed": 155.0,
		"cooldown_mult": 0.85,
		"damage_mult": 1.1,
		"xp_radius": 90.0,
		"color": Color(1.0, 0.55, 0.2),
		"sprite": "res://assets/sprites/char_pyromancer.png",
		"unlock_cost": 1500,
		"name_key": "char_pyromancer_name",
		"desc_key": "char_pyromancer_desc",
		"passive_id": "ember_renewal",
		"passive_name_key": "char_passive_ember_renewal_name",
		"passive_desc_key": "char_passive_ember_renewal_desc",
	},
}

static func get_data(key: String) -> Dictionary:
	return DATA.get(key, DATA[DEFAULT_KEY])

static func display_name(key: String) -> String:
	var d := get_data(key)
	if d.has("name_key") and Localization:
		return Localization.tr_key(String(d["name_key"]), String(d.get("name", "?")))
	return String(d.get("name", "?"))

static func display_desc(key: String) -> String:
	var d := get_data(key)
	if d.has("desc_key") and Localization:
		return Localization.tr_key(String(d["desc_key"]), String(d.get("desc", "")))
	return String(d.get("desc", ""))

static func stat_summary(key: String) -> String:
	var d := get_data(key)
	return "HP %d  ·  SPD %d  ·  CD x%.2f  ·  Magnet %d" % [
		int(d["max_hp"]), int(d["move_speed"]), float(d["cooldown_mult"]), int(d["xp_radius"])
	]

static func display_passive_name(key: String) -> String:
	var d := get_data(key)
	if d.has("passive_name_key") and Localization:
		return Localization.tr_key(String(d["passive_name_key"]), "")
	return ""

static func display_passive_desc(key: String) -> String:
	var d := get_data(key)
	if d.has("passive_desc_key") and Localization:
		return Localization.tr_key(String(d["passive_desc_key"]), "")
	return ""
