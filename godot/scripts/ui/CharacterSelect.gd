extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var items_container: VBoxContainer = $VBox/Scroll/Items
@onready var btn_back: Button = $VBox/BtnBack

@onready var title_label: Label = $VBox/Title

func _ready() -> void:
	AudioManager.play_bgm("menu")
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
	var unlocked: bool = GameData.is_character_unlocked(key)
	var selected: bool = GameData.selected_character == key
	var card := PanelContainer.new()
	card.name = "Card_" + key
	card.custom_minimum_size = Vector2(0, 240)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	card.add_child(hbox)

	# Portrait
	var portrait := _make_portrait(data, unlocked, selected)
	hbox.add_child(portrait)

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

	# Signature passive — single line: name + condensed effect. Color matches
	# the character so the trait reads as part of their identity.
	var passive_name: String = Characters.display_passive_name(key)
	if passive_name != "":
		var signature_lbl := Label.new()
		signature_lbl.text = Localization.tr_key("label_signature_fmt") % passive_name
		signature_lbl.add_theme_font_size_override("font_size", 16)
		var sig_c: Color = data["color"]
		signature_lbl.add_theme_color_override("font_color", sig_c.lightened(0.15))
		info.add_child(signature_lbl)
		var passive_desc: String = Characters.display_passive_desc(key)
		if passive_desc != "":
			var sig_desc := Label.new()
			sig_desc.text = passive_desc
			sig_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			sig_desc.add_theme_font_size_override("font_size", 14)
			sig_desc.add_theme_color_override("font_color", Color(0.78, 0.82, 0.88))
			info.add_child(sig_desc)

	var btn := Button.new()
	btn.name = "ActionBtn"
	btn.custom_minimum_size = Vector2(0, 70)
	btn.add_theme_font_size_override("font_size", 22)
	_setup_button(btn, key, data)
	info.add_child(btn)

	return card

func _make_portrait(data: Dictionary, unlocked: bool, selected: bool) -> Control:
	var portrait := Control.new()
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(140, 0)

	# Tinted background panel
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bgc: Color = data["color"]
	bgc.a = 0.30 if selected else 0.18
	bg.color = bgc
	portrait.add_child(bg)

	# Selected glow border (subtle inner stroke via 4 thin ColorRects)
	if selected:
		var border_c: Color = data["color"]
		border_c.a = 0.85
		_add_border(portrait, border_c, 3.0)

	# Centered character sprite
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_top = 4
	center.offset_bottom = -28
	portrait.add_child(center)

	var sprite := TextureRect.new()
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	sprite.custom_minimum_size = Vector2(96, 96)
	if data.has("sprite"):
		sprite.texture = load(String(data["sprite"]))
	if not unlocked:
		# Dark silhouette for locked characters
		sprite.modulate = Color(0.10, 0.10, 0.15, 1.0)
	center.add_child(sprite)

	# Weapon icon thumb (bottom-right)
	var wname: String = String(data.get("starting_weapon", ""))
	if wname != "":
		var icon_path: String = "res://assets/sprites/icon_" + wname.to_lower().replace(" ", "_") + ".png"
		if ResourceLoader.exists(icon_path):
			var weapon_icon := TextureRect.new()
			weapon_icon.texture = load(icon_path)
			weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			weapon_icon.custom_minimum_size = Vector2(34, 34)
			weapon_icon.anchor_left = 1.0
			weapon_icon.anchor_top = 1.0
			weapon_icon.anchor_right = 1.0
			weapon_icon.anchor_bottom = 1.0
			weapon_icon.offset_left = -40
			weapon_icon.offset_top = -40
			weapon_icon.offset_right = -6
			weapon_icon.offset_bottom = -6
			if not unlocked:
				weapon_icon.modulate = Color(0.5, 0.5, 0.5, 0.6)
			portrait.add_child(weapon_icon)

	# Lock indicator
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
	# Rebuild all cards so portrait (border, lock icon, silhouette) reflects new state
	_build_cards()

func _refresh_gold() -> void:
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()
