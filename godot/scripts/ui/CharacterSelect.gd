extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

@onready var title_label: Label = $VBox/Title

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	if title_label:
		title_label.text = Localization.tr_key("choose_character")
	btn_back.text = Localization.tr_key("btn_back")
	_build_cards()
	_refresh_gold()

func _build_cards() -> void:
	for child in items_container.get_children():
		child.queue_free()
	for key in Characters.ORDER:
		items_container.add_child(_make_card(key))

func _make_card(key: String) -> PanelContainer:
	var data: Dictionary = Characters.DATA[key]
	var card := PanelContainer.new()
	card.name = "Card_" + key
	card.custom_minimum_size = Vector2(0, 220)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	card.add_child(hbox)

	var color_block := ColorRect.new()
	color_block.custom_minimum_size = Vector2(70, 0)
	color_block.color = data["color"]
	hbox.add_child(color_block)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = Characters.display_name(key)
	name_lbl.add_theme_font_size_override("font_size", 28)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = Characters.display_desc(key)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 18)
	info.add_child(desc_lbl)

	var stats_lbl := Label.new()
	stats_lbl.text = Localization.tr_key("label_start_fmt") % data["starting_weapon"]
	stats_lbl.add_theme_font_size_override("font_size", 18)
	stats_lbl.add_theme_color_override("font_color", data["color"])
	info.add_child(stats_lbl)

	var stat_summary := Label.new()
	stat_summary.text = Characters.stat_summary(key)
	stat_summary.add_theme_font_size_override("font_size", 16)
	info.add_child(stat_summary)

	var btn := Button.new()
	btn.name = "ActionBtn"
	btn.custom_minimum_size = Vector2(0, 70)
	btn.add_theme_font_size_override("font_size", 22)
	_setup_button(btn, key, data)
	info.add_child(btn)

	return card

func _setup_button(btn: Button, key: String, data: Dictionary) -> void:
	for c in btn.pressed.get_connections():
		btn.pressed.disconnect(c["callable"])
	if not GameData.is_character_unlocked(key):
		var cost: int = int(data["unlock_cost"])
		btn.text = Localization.tr_key("btn_unlock_fmt") % cost
		btn.disabled = GameData.gold < cost
		btn.pressed.connect(func(): _on_unlock_pressed(key, cost))
	elif GameData.selected_character == key:
		btn.text = Localization.tr_key("btn_selected")
		btn.disabled = true
	else:
		btn.text = Localization.tr_key("btn_select")
		btn.disabled = false
		btn.pressed.connect(func(): _on_select_pressed(key))

func _on_unlock_pressed(key: String, cost: int) -> void:
	if GameData.try_unlock_character(key, cost):
		GameData.select_character(key)
		_refresh_all()

func _on_select_pressed(key: String) -> void:
	if GameData.select_character(key):
		_refresh_all()

func _refresh_all() -> void:
	_refresh_gold()
	for key in Characters.ORDER:
		var card := items_container.get_node_or_null("Card_" + key)
		if card == null:
			continue
		var btn: Button = card.find_child("ActionBtn", true, false)
		if btn:
			_setup_button(btn, key, Characters.DATA[key])

func _refresh_gold() -> void:
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
