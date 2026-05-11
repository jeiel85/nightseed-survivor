extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

@onready var title_label: Label = $VBox/Title

func _ready() -> void:
	AudioManager.play_bgm("menu")
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

const STAGE_PREVIEW: Dictionary = {
	"forest":           ["res://assets/sprites/enemy_slime.png", "res://assets/sprites/enemy_bat.png"],
	"frozen_wastes":    ["res://assets/sprites/enemy_bat.png",   "res://assets/sprites/enemy_hound.png"],
	"twilight_sanctum": ["res://assets/sprites/enemy_knight.png", "res://assets/sprites/enemy_caster.png"],
	"inferno_chasm":    ["res://assets/sprites/enemy_hound.png", "res://assets/sprites/enemy_dasher.png"],
	"cursed_tomb":      ["res://assets/sprites/enemy_boss.png",  "res://assets/sprites/enemy_miniboss.png"],
}

func _make_card(stage: Dictionary) -> PanelContainer:
	var stage_id := String(stage.get("id", ""))
	var unlocked: bool = GameData.is_stage_unlocked(stage_id)
	var selected: bool = GameData.selected_stage == stage_id
	var stage_color := Color.html(String(stage.get("color", "#888888")))
	var card := PanelContainer.new()
	card.name = "Card_" + stage_id
	card.custom_minimum_size = Vector2(0, 220)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	card.add_child(hbox)

	# Portrait (tinted bg + 2 enemy icons + lock/selected state)
	var portrait := _make_stage_portrait(stage_id, stage_color, unlocked, selected)
	hbox.add_child(portrait)

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

func _make_stage_portrait(stage_id: String, stage_color: Color, unlocked: bool, selected: bool) -> Control:
	var portrait := Control.new()
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(140, 0)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bgc := stage_color
	bgc.a = 0.30 if selected else 0.18
	bg.color = bgc
	portrait.add_child(bg)

	if selected:
		var border_c: Color = stage_color
		border_c.a = 0.85
		_add_border(portrait, border_c, 3.0)

	# Two enemy sprites diagonally arranged
	var sprites: Array = STAGE_PREVIEW.get(stage_id, [])
	if sprites.size() >= 1:
		var s1 := TextureRect.new()
		var p1: String = String(sprites[0])
		if ResourceLoader.exists(p1):
			s1.texture = load(p1)
		s1.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		s1.custom_minimum_size = Vector2(72, 72)
		s1.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		s1.offset_left = 12
		s1.offset_top = -56
		s1.offset_right = 84
		s1.offset_bottom = 16
		if not unlocked:
			s1.modulate = Color(0.10, 0.10, 0.15, 1.0)
		portrait.add_child(s1)

	if sprites.size() >= 2:
		var s2 := TextureRect.new()
		var p2: String = String(sprites[1])
		if ResourceLoader.exists(p2):
			s2.texture = load(p2)
		s2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		s2.custom_minimum_size = Vector2(60, 60)
		s2.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		s2.offset_left = -68
		s2.offset_top = 0
		s2.offset_right = -8
		s2.offset_bottom = 60
		if not unlocked:
			s2.modulate = Color(0.10, 0.10, 0.15, 1.0)
		portrait.add_child(s2)

	if not unlocked:
		var lock_lbl := Label.new()
		lock_lbl.text = "🔒"
		lock_lbl.add_theme_font_size_override("font_size", 36)
		lock_lbl.set_anchors_preset(Control.PRESET_CENTER)
		lock_lbl.offset_left = -20
		lock_lbl.offset_top = -24
		lock_lbl.offset_right = 20
		lock_lbl.offset_bottom = 24
		portrait.add_child(lock_lbl)

	return portrait

func _add_border(parent: Control, color: Color, thickness: float) -> void:
	var top := ColorRect.new()
	top.anchor_right = 1.0
	top.offset_bottom = thickness
	top.color = color
	parent.add_child(top)
	var bottom := ColorRect.new()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_top = -thickness
	bottom.color = color
	parent.add_child(bottom)
	var left := ColorRect.new()
	left.anchor_bottom = 1.0
	left.offset_right = thickness
	left.color = color
	parent.add_child(left)
	var right := ColorRect.new()
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.anchor_bottom = 1.0
	right.offset_left = -thickness
	right.color = color
	parent.add_child(right)

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
	_build_cards()

func _refresh_gold() -> void:
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")
