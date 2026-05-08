extends Control

const UPGRADE_KEYS: Array = ["swift_boots", "magnet_charm", "iron_heart", "battle_focus", "power_core"]

const UPGRADE_NAMES: Dictionary = {
	"swift_boots":  "Swift Boots",
	"magnet_charm": "Magnet Charm",
	"iron_heart":   "Iron Heart",
	"battle_focus": "Battle Focus",
	"power_core":   "Power Core",
}

const UPGRADE_DESCS: Dictionary = {
	"swift_boots":  "Move Speed +12 per level",
	"magnet_charm": "XP Radius +20 per level",
	"iron_heart":   "Max HP +10 per level",
	"battle_focus": "Cooldowns -4% per level",
	"power_core":   "All Damage +5% per level",
}

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	_build_rows()
	_refresh_gold()

func _build_rows() -> void:
	for key in UPGRADE_KEYS:
		var row := _make_row(key)
		items_container.add_child(row)

func _make_row(key: String) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.name = "Row_" + key

	var name_lbl := Label.new()
	name_lbl.text = UPGRADE_NAMES[key]
	name_lbl.custom_minimum_size.x = 160
	hbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = UPGRADE_DESCS[key]
	desc_lbl.custom_minimum_size.x = 200
	hbox.add_child(desc_lbl)

	var level_lbl := Label.new()
	level_lbl.name = "LevelLbl"
	level_lbl.text = "Lv %d" % GameData.permanent_upgrades.get(key, 0)
	level_lbl.custom_minimum_size.x = 60
	hbox.add_child(level_lbl)

	var cost := GameData.get_upgrade_cost(key)
	var cost_lbl := Label.new()
	cost_lbl.name = "CostLbl"
	cost_lbl.text = ("Cost: %d" % cost) if cost > 0 else "MAX"
	cost_lbl.custom_minimum_size.x = 100
	hbox.add_child(cost_lbl)

	var btn := Button.new()
	btn.name = "BuyBtn"
	btn.text = "Buy"
	btn.disabled = cost <= 0 or GameData.gold < cost
	btn.pressed.connect(func(): _on_buy(key))
	hbox.add_child(btn)

	return hbox

func _on_buy(key: String) -> void:
	if GameData.try_upgrade(key):
		_refresh_all_rows()
		_refresh_gold()

func _refresh_all_rows() -> void:
	for key in UPGRADE_KEYS:
		var row := items_container.get_node_or_null("Row_" + key)
		if row == null:
			continue
		var level_lbl: Label = row.get_node_or_null("LevelLbl")
		var cost_lbl: Label = row.get_node_or_null("CostLbl")
		var btn: Button = row.get_node_or_null("BuyBtn")
		var cost := GameData.get_upgrade_cost(key)
		if level_lbl:
			level_lbl.text = "Lv %d" % GameData.permanent_upgrades.get(key, 0)
		if cost_lbl:
			cost_lbl.text = ("Cost: %d" % cost) if cost > 0 else "MAX"
		if btn:
			btn.disabled = cost <= 0 or GameData.gold < cost

func _refresh_gold() -> void:
	gold_label.text = "Gold: %d" % GameData.gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
