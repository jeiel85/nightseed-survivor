extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

@onready var title_label: Label = $VBox/Title

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	if title_label:
		title_label.text = Localization.tr_key("choose_stage")
	btn_back.text = Localization.tr_key("btn_back")
	_build_cards()
	_refresh_gold()

func _build_cards() -> void:
	for child in items_container.get_children():
		child.queue_free()
	for stage in Stages.stages:
		if stage is Dictionary:
			items_container.add_child(_make_card(stage))

func _make_card(stage: Dictionary) -> PanelContainer:
	var stage_id := String(stage.get("id", ""))
	var card := PanelContainer.new()
	card.name = "Card_" + stage_id
	card.custom_minimum_size = Vector2(0, 200)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	card.add_child(hbox)

	var color_block := ColorRect.new()
	color_block.custom_minimum_size = Vector2(70, 0)
	color_block.color = Color.html(String(stage.get("color", "#888888")))
	hbox.add_child(color_block)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = Stages.display_name(stage_id)
	name_lbl.add_theme_font_size_override("font_size", 28)
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = Stages.display_desc(stage_id)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 18)
	info.add_child(desc_lbl)

	var time_lbl := Label.new()
	var tt: int = int(stage.get("total_time", 600))
	time_lbl.text = Localization.tr_key("stage_duration_fmt") % [tt / 60, tt % 60, int((stage.get("waves", []) as Array).size())]
	time_lbl.add_theme_font_size_override("font_size", 18)
	info.add_child(time_lbl)

	var btn := Button.new()
	btn.name = "ActionBtn"
	btn.custom_minimum_size = Vector2(0, 70)
	btn.add_theme_font_size_override("font_size", 22)
	_setup_button(btn, stage_id, stage)
	info.add_child(btn)

	return card

func _setup_button(btn: Button, stage_id: String, stage: Dictionary) -> void:
	for c in btn.pressed.get_connections():
		btn.pressed.disconnect(c["callable"])
	if not GameData.is_stage_unlocked(stage_id):
		var cost: int = int(stage.get("unlock_cost", 0))
		btn.text = Localization.tr_key("btn_unlock_fmt") % cost
		btn.disabled = GameData.gold < cost
		btn.pressed.connect(func(): _on_unlock_pressed(stage_id, cost))
	elif GameData.selected_stage == stage_id:
		btn.text = Localization.tr_key("btn_selected")
		btn.disabled = true
	else:
		btn.text = Localization.tr_key("btn_select")
		btn.disabled = false
		btn.pressed.connect(func(): _on_select_pressed(stage_id))

func _on_unlock_pressed(stage_id: String, cost: int) -> void:
	if GameData.try_unlock_stage(stage_id, cost):
		GameData.select_stage(stage_id)
		_refresh_all()

func _on_select_pressed(stage_id: String) -> void:
	if GameData.select_stage(stage_id):
		_refresh_all()

func _refresh_all() -> void:
	_refresh_gold()
	for stage in Stages.stages:
		if not stage is Dictionary:
			continue
		var stage_id := String(stage.get("id", ""))
		var card := items_container.get_node_or_null("Card_" + stage_id)
		if card == null:
			continue
		var btn: Button = card.find_child("ActionBtn", true, false)
		if btn:
			_setup_button(btn, stage_id, stage)

func _refresh_gold() -> void:
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
