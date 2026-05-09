extends Control

const UPGRADE_KEYS: Array = ["swift_boots", "magnet_charm", "iron_heart", "battle_focus", "power_core"]

const UPGRADE_NAME_KEYS: Dictionary = {
	"swift_boots":  "passive_swift_boots_name",
	"magnet_charm": "passive_magnet_charm_name",
	"iron_heart":   "passive_iron_heart_name",
	"battle_focus": "passive_battle_focus_name",
	"power_core":   "passive_power_core_name",
}

const UPGRADE_DESC_KEYS: Dictionary = {
	"swift_boots":  "shop_swift_boots_desc",
	"magnet_charm": "shop_magnet_charm_desc",
	"iron_heart":   "shop_iron_heart_desc",
	"battle_focus": "shop_battle_focus_desc",
	"power_core":   "shop_power_core_desc",
}

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

@onready var title_label: Label = $VBox/Title

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	if title_label:
		title_label.text = Localization.tr_key("shop_title")
	btn_back.text = Localization.tr_key("btn_back")
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
	name_lbl.text = Localization.tr_key(UPGRADE_NAME_KEYS[key])
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 26)
	header.add_child(name_lbl)

	var level_lbl := Label.new()
	level_lbl.name = "LevelLbl"
	level_lbl.text = Localization.tr_key("label_lv_fmt") % GameData.permanent_upgrades.get(key, 0)
	level_lbl.add_theme_font_size_override("font_size", 24)
	header.add_child(level_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = Localization.tr_key(UPGRADE_DESC_KEYS[key])
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(desc_lbl)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	vbox.add_child(footer)

	var cost := GameData.get_upgrade_cost(key)
	var cost_lbl := Label.new()
	cost_lbl.name = "CostLbl"
	cost_lbl.text = (Localization.tr_key("label_cost_fmt") % cost) if cost > 0 else Localization.tr_key("btn_max")
	cost_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 22)
	footer.add_child(cost_lbl)

	var btn := Button.new()
	btn.name = "BuyBtn"
	btn.text = Localization.tr_key("btn_buy")
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
			level_lbl.text = Localization.tr_key("label_lv_fmt") % GameData.permanent_upgrades.get(key, 0)
		if cost_lbl:
			cost_lbl.text = (Localization.tr_key("label_cost_fmt") % cost) if cost > 0 else Localization.tr_key("btn_max")
		if btn:
			btn.disabled = cost <= 0 or GameData.gold < cost

func _refresh_gold() -> void:
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
