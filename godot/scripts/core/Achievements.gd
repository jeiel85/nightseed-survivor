class_name Achievements
extends RefCounted

const DATA: Dictionary = {
	"first_survivor": {
		"name": "First Survivor",
		"desc": "Survive the full duration",
		"gold": 200,
	},
	"speed_runner": {
		"name": "Speed Runner",
		"desc": "Reach Level 10 in under 3 minutes",
		"gold": 150,
	},
	"killer_instinct": {
		"name": "Killer Instinct",
		"desc": "Kill 200 enemies in one run",
		"gold": 100,
	},
	"untouchable": {
		"name": "Untouchable",
		"desc": "Reach Level 5 without taking damage",
		"gold": 200,
	},
	"evolver": {
		"name": "Evolver",
		"desc": "Evolve a weapon",
		"gold": 250,
	},
	"boss_slayer": {
		"name": "Boss Slayer",
		"desc": "Defeat the final boss",
		"gold": 300,
	},
	"wealthy": {
		"name": "Wealthy",
		"desc": "Earn 500 gold in one run",
		"gold": 200,
	},
	"combo_master": {
		"name": "Combo Master",
		"desc": "Carry 4 different weapons at once",
		"gold": 250,
	},
	"hard_mode_clear": {
		"name": "Trial by Fire",
		"desc": "Win on Hard or Nightmare difficulty",
		"gold": 400,
	},
	"completionist": {
		"name": "Completionist",
		"desc": "Reach Level 20 in one run",
		"gold": 350,
	},
}

const ORDER: Array = [
	"first_survivor", "speed_runner", "killer_instinct",
	"untouchable", "evolver", "boss_slayer",
	"wealthy", "combo_master", "hard_mode_clear", "completionist",
]
