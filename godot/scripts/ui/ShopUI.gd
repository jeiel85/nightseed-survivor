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

func _make_row(key: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Row_" + key
	card.custom_minimum_size = Vector2(0, 150)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var name_lbl := Label.new()
	name_lbl.text = UPGRADE_NAMES[key]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 26)
	header.add_child(name_lbl)

	var level_lbl := Label.new()
	level_lbl.name = "LevelLbl"
	level_lbl.text = "Lv %d" % GameData.permanent_upgrades.get(key, 0)
	level_lbl.add_theme_font_size_override("font_size", 24)
	header.add_child(level_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = UPGRADE_DESCS[key]
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(desc_lbl)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	vbox.add_child(footer)

	var cost := GameData.get_upgrade_cost(key)
	var cost_lbl := Label.new()
	cost_lbl.name = "CostLbl"
	cost_lbl.text = ("Cost: %d" % cost) if cost > 0 else "MAX"
	cost_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 22)
	footer.add_child(cost_lbl)

	var btn := Button.new()
	btn.name = "BuyBtn"
	btn.text = "BUY"
	btn.custom_minimum_size = Vector2(160, 70)
	btn.disabled = cost <= 0 or GameData.gold < cost
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(func(): _on_buy(key))
	footer.add_child(btn)

	return card

func _on_buy(key: String) -> void:
	if GameData.try_upgrade(key):
		_refresh_all_rows()
		_refresh_gold()

func _refresh_all_rows() -> void:
	for key in UPGRADE_KEYS:
		var row := items_container.get_node_or_null("Row_" + key)
		if row == null:
			continue
		var level_lbl: Label = row.find_child("LevelLbl", true, false)
		var cost_lbl: Label = row.find_child("CostLbl", true, false)
		var btn: Button = row.find_child("BuyBtn", true, false)
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
