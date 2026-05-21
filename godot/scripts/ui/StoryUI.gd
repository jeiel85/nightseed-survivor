extends Control

## Story reading screen. Lists every stage with its detailed chronicle chapter.
## Runtime battle subtitles stay in story_dialogues.json and are shown only as
## a compact "battle records" section after the chapter body.
##
## v0.32 ancient-grimoire reskin: hand-drawn chamber background, gold-framed
## header with story-book icon, per-stage wax seals, and chain-wrapped locked
## cards. Wooden plaques replace the stone secondary buttons in the footer.

const COLOR_PARCHMENT := Color(0.949, 0.922, 0.863, 1.0)
const COLOR_PARCHMENT_EDGE := Color(0.753, 0.647, 0.420, 1.0)
const COLOR_INK := Color(0.173, 0.141, 0.122, 1.0)
const COLOR_INK_FADED := Color(0.173, 0.141, 0.122, 0.68)
const COLOR_GOLD := Color(0.831, 0.686, 0.216, 1.0)
const COLOR_LOCKED_SURFACE := Color(0.165, 0.176, 0.208, 0.95)
const COLOR_LOCKED_TEXT := Color(0.66, 0.61, 0.50, 0.92)
const CARD_WIDTH := 656.0

const STORY_PARCHMENT_PATH := "res://assets/sprites/ui/story/panel_story_parchment.9.png"
const STORY_LOCKED_PATH := "res://assets/sprites/ui/story/panel_story_locked.9.png"
const STORY_DIVIDER_PATH := "res://assets/sprites/ui/story/divider_story_diamond.png"
const STORY_LOCK_ICON_PATH := "res://assets/sprites/ui/story/icon_story_lock.png"
const STORY_BOOK_ICON_PATH := "res://assets/sprites/ui/story/icon_story_book.png"
const STORY_BTN_WOOD_PATH := "res://assets/sprites/ui/story/btn_story_wood.png"
const STORY_CHAIN_PATH := "res://assets/sprites/ui/story/chain_story_locked.png"
# frame_story_gold.png is a portrait asset — stretching it to fit a landscape
# header collapses the inner gold rim into doubled lines. Kept in the assets
# folder for later use (chapter intro overlay, locked-card outer frame).

const STORY_PANEL_MARGIN := 24
# btn_story_wood.png was downscaled from 2172×724 to 543×181 so the 9-slice
# margins stay smaller than the 280×72 footer buttons (Godot skips drawing the
# texture entirely when the slice margins exceed the container).
const WOOD_BTN_MARGIN_LR := 32
const WOOD_BTN_MARGIN_TB := 27

const STAGE_SEALS := {
	"forest": "res://assets/sprites/ui/story/seal_forest.png",
	"frozen_wastes": "res://assets/sprites/ui/story/seal_frozen_wastes.png",
	"twilight_sanctum": "res://assets/sprites/ui/story/seal_twilight_sanctum.png",
	"inferno_chasm": "res://assets/sprites/ui/story/seal_inferno_chasm.png",
	"cursed_tomb": "res://assets/sprites/ui/story/seal_cursed_tomb.png",
}

@onready var header_panel: PanelContainer = $VBox/HeaderPanel
@onready var book_icon: TextureRect = $VBox/HeaderPanel/HeaderInner/TitleRow/BookIcon
@onready var title_label: Label = $VBox/HeaderPanel/HeaderInner/TitleRow/Title
@onready var hint_label: Label = $VBox/HeaderPanel/HeaderInner/Hint
@onready var stage_list: VBoxContainer = $VBox/ScrollContainer/StageList
@onready var btn_back: Button = $VBox/FooterRow/BtnBack
@onready var btn_codex: Button = $VBox/FooterRow/BtnCodex

func _ready() -> void:
	AudioManager.play_bgm("menu")
	_apply_header_panel_style()
	_apply_book_icon()
	_apply_wood_button(btn_back)
	_apply_wood_button(btn_codex)
	btn_back.pressed.connect(_on_back_pressed)
	btn_codex.pressed.connect(_on_codex_pressed)
	if Localization:
		Localization.language_changed.connect(_on_language_changed)
	_refresh()

func _apply_header_panel_style() -> void:
	# Simple darkened plaque with a gold underline at the bottom. The portrait
	# frame asset doesn't 9-slice cleanly across the landscape header, so we
	# keep the header understated and let the background lamp/vignette carry
	# the grimoire mood instead.
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.045, 0.038, 0.028, 0.60)
	sb.set_corner_radius_all(6)
	sb.border_width_bottom = 3
	sb.border_color = COLOR_GOLD.lightened(0.05)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 14
	header_panel.add_theme_stylebox_override("panel", sb)

func _apply_book_icon() -> void:
	var tex := _try_load_texture(STORY_BOOK_ICON_PATH)
	if tex == null:
		book_icon.visible = false
		return
	book_icon.texture = tex

func _apply_wood_button(button: Button) -> void:
	var tex := _try_load_texture(STORY_BTN_WOOD_PATH)
	if tex == null:
		ButtonStyles.apply_stone_secondary(button, Color(0.55, 0.36, 0.20, 1.0))
		return
	button.add_theme_stylebox_override("normal",   _wood_box(tex, Color(1, 1, 1, 1)))
	button.add_theme_stylebox_override("hover",    _wood_box(tex, Color(1.10, 1.06, 0.98, 1)))
	button.add_theme_stylebox_override("pressed",  _wood_box(tex, Color(0.78, 0.72, 0.62, 1)))
	button.add_theme_stylebox_override("focus",    _wood_box(tex, Color(1.18, 1.10, 0.92, 1)))
	button.add_theme_stylebox_override("disabled", _wood_box(tex, Color(0.55, 0.50, 0.42, 0.85)))
	button.add_theme_color_override("font_color", Color(0.97, 0.88, 0.62, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 0.93, 0.70, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.85, 0.74, 0.50, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 0.93, 0.70, 1))
	button.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.95))
	button.add_theme_constant_override("outline_size", 4)

func _wood_box(tex: Texture2D, modulate: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.modulate_color = modulate
	sb.texture_margin_left = WOOD_BTN_MARGIN_LR
	sb.texture_margin_right = WOOD_BTN_MARGIN_LR
	sb.texture_margin_top = WOOD_BTN_MARGIN_TB
	sb.texture_margin_bottom = WOOD_BTN_MARGIN_TB
	sb.content_margin_left = 26
	sb.content_margin_right = 26
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	return sb

func _refresh() -> void:
	title_label.text = Localization.tr_key("story_title")
	hint_label.text = Localization.tr_key("story_hint")
	btn_codex.text = Localization.tr_key("btn_to_codex")
	btn_back.text = Localization.tr_key("btn_back_to_menu")
	_rebuild_list()

func _rebuild_list() -> void:
	for child in stage_list.get_children():
		child.queue_free()
	if Stages == null:
		return
	for stage in Stages.stages:
		if not (stage is Dictionary):
			continue
		var stage_id: String = String(stage.get("id", ""))
		if stage_id.is_empty():
			continue
		stage_list.add_child(_build_stage_entry(stage_id))

func _build_stage_entry(stage_id: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _entry_style(stage_id))
	panel.custom_minimum_size.x = CARD_WIDTH
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	_add_card_header(vbox, stage_id, unlocked)
	if not unlocked:
		_add_locked_body(vbox, stage_id)
		return panel

	_append_chapter_summary(vbox, stage_id)
	_append_chapter_sections(vbox, stage_id)
	_append_battle_records(vbox, stage_id)
	return panel

func _add_card_header(vbox: VBoxContainer, stage_id: String, unlocked: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	vbox.add_child(row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_box.add_theme_constant_override("separation", 2)
	row.add_child(title_box)

	var chapter := Label.new()
	chapter.text = _chapter_label(stage_id)
	chapter.add_theme_font_size_override("font_size", 13)
	chapter.add_theme_color_override("font_color", COLOR_INK_FADED if unlocked else COLOR_LOCKED_TEXT)
	chapter.add_theme_constant_override("outline_size", 0)
	title_box.add_child(chapter)

	var name_label := Label.new()
	name_label.text = Stages.display_name(stage_id) if Stages.has_method("display_name") else stage_id
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", COLOR_INK if unlocked else Color(0.50, 0.52, 0.58, 1.0))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_box.add_child(name_label)

	row.add_child(_build_seal(stage_id, unlocked))

	_add_rule(vbox, _stage_accent(stage_id) if unlocked else Color(0.33, 0.34, 0.40, 1.0))

func _build_seal(stage_id: String, unlocked: bool) -> Control:
	var tex_path: String = String(STAGE_SEALS.get(stage_id, ""))
	var tex := _try_load_texture(tex_path) if tex_path != "" else null
	if tex != null:
		var rect := TextureRect.new()
		rect.texture = tex
		rect.custom_minimum_size = Vector2(76, 76)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if not unlocked:
			# Desaturate + dim so the locked seal still hints at the chapter
			# without competing with the chain band visually.
			rect.modulate = Color(0.45, 0.45, 0.50, 0.65)
		return rect
	# Fallback: text glyph (old style).
	var label := Label.new()
	label.custom_minimum_size = Vector2(44, 44)
	label.text = _stage_icon_glyph(stage_id)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", _stage_accent(stage_id).lightened(0.12) if unlocked else Color(0.34, 0.35, 0.40, 1.0))
	return label

func _add_locked_body(vbox: VBoxContainer, stage_id: String) -> void:
	var chain_tex := _try_load_texture(STORY_CHAIN_PATH)
	if chain_tex != null:
		vbox.add_child(_make_chain_band(chain_tex))

	var lock_texture := _try_load_texture(STORY_LOCK_ICON_PATH)
	if lock_texture != null:
		var icon := TextureRect.new()
		icon.texture = lock_texture
		icon.custom_minimum_size = Vector2(80, 80)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(icon)

	var lock_label := Label.new()
	lock_label.text = "LOCKED"
	lock_label.custom_minimum_size = Vector2(0, 36 if lock_texture != null else 58)
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_label.add_theme_font_size_override("font_size", 30)
	lock_label.add_theme_color_override("font_color", Color(0.78, 0.66, 0.42, 0.95))
	lock_label.add_theme_constant_override("outline_size", 4)
	lock_label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.07, 0.95))
	vbox.add_child(lock_label)

	var locked := Label.new()
	locked.text = _locked_card_hint(stage_id)
	locked.add_theme_font_size_override("font_size", 20)
	locked.add_theme_color_override("font_color", COLOR_LOCKED_TEXT)
	locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(locked)

	if chain_tex != null:
		vbox.add_child(_make_chain_band(chain_tex))

func _locked_card_hint(stage_id: String) -> String:
	var prev_id := _previous_stage_id(stage_id)
	if prev_id == "" or Stages == null or not Stages.has_method("display_name"):
		return Localization.tr_key("story_locked_long")
	var prev_name: String = Stages.display_name(prev_id)
	return Localization.tr_key("story_locked_prev_stage_fmt") % prev_name

func _previous_stage_id(stage_id: String) -> String:
	var stage_source: Array = Stages.stages if Stages else []
	var prev_id := ""
	for stage in stage_source:
		if not (stage is Dictionary):
			continue
		var sid := String(stage.get("id", ""))
		if sid == stage_id:
			return prev_id
		prev_id = sid
	return ""

func _make_chain_band(tex: Texture2D) -> TextureRect:
	var chain := TextureRect.new()
	chain.texture = tex
	chain.custom_minimum_size = Vector2(0, 34)
	chain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chain.stretch_mode = TextureRect.STRETCH_SCALE
	chain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return chain

func _append_section(vbox: VBoxContainer, stage_id: String, slot: String, header_key: String) -> void:
	var lines: Array = Story.get_stage_lines(stage_id, slot) if Story else []
	if lines.is_empty():
		return
	var header := Label.new()
	header.text = _section_label(header_key)
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", _stage_accent(stage_id).darkened(0.22))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	for entry in lines:
		if not (entry is Dictionary):
			continue
		var line := Label.new()
		var speaker: String = String(entry.get("speaker", ""))
		var text: String = String(entry.get("text", ""))
		line.text = ("%s - %s" % [speaker, text]) if speaker != "" else text
		line.add_theme_font_size_override("font_size", 21)
		line.add_theme_color_override("font_color", COLOR_INK)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(line)
	_add_rule(vbox, _stage_accent(stage_id))

func _append_chapter_summary(vbox: VBoxContainer, stage_id: String) -> void:
	var chapter := Story.get_stage_chapter(stage_id) if Story else {}
	var summary := String(chapter.get("summary", ""))
	if summary.is_empty():
		return
	var header := Label.new()
	header.text = _section_label("story_section_summary")
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", _stage_accent(stage_id).darkened(0.22))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	var label := Label.new()
	label.text = summary
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", COLOR_INK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(label)
	_add_rule(vbox, _stage_accent(stage_id))

func _append_chapter_sections(vbox: VBoxContainer, stage_id: String) -> void:
	var sections: Array = Story.get_chapter_sections(stage_id) if Story else []
	if sections.is_empty():
		return
	var detail_header := Label.new()
	detail_header.text = _section_label("story_section_detail")
	detail_header.add_theme_font_size_override("font_size", 14)
	detail_header.add_theme_color_override("font_color", _stage_accent(stage_id).darkened(0.22))
	detail_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(detail_header)

	for section in sections:
		if not (section is Dictionary):
			continue
		var is_unlocked := bool(section.get("unlocked", false))
		var heading := Label.new()
		heading.text = String(section.get("heading", "")) if is_unlocked else "???"
		heading.add_theme_font_size_override("font_size", 23)
		heading.add_theme_color_override("font_color", COLOR_INK if is_unlocked else COLOR_INK_FADED)
		heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(heading)

		var body := Label.new()
		if is_unlocked:
			body.text = String(section.get("text", ""))
			body.add_theme_color_override("font_color", COLOR_INK)
		else:
			body.text = _locked_section_text(String(section.get("unlock", "")))
			body.add_theme_color_override("font_color", COLOR_INK_FADED)
		body.add_theme_font_size_override("font_size", 22)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(body)
	_add_rule(vbox, _stage_accent(stage_id))

func _append_battle_records(vbox: VBoxContainer, stage_id: String) -> void:
	var slots := ["intro", "boss_intro", "clear"]
	var added_header := false
	for slot in slots:
		var lines: Array = Story.get_stage_lines(stage_id, slot) if Story else []
		if lines.is_empty():
			continue
		if not added_header:
			var header := Label.new()
			header.text = _section_label("story_section_battle_quotes")
			header.add_theme_font_size_override("font_size", 14)
			header.add_theme_color_override("font_color", _stage_accent(stage_id).darkened(0.22))
			header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(header)
			added_header = true
		var slot_label := Label.new()
		slot_label.text = _section_label(_battle_slot_key(slot))
		slot_label.add_theme_font_size_override("font_size", 13)
		slot_label.add_theme_color_override("font_color", COLOR_INK_FADED)
		vbox.add_child(slot_label)
		for entry in lines:
			if not (entry is Dictionary):
				continue
			var line := Label.new()
			var speaker: String = String(entry.get("speaker", ""))
			var text: String = String(entry.get("text", ""))
			line.text = ("%s - %s" % [speaker, text]) if speaker != "" else text
			line.add_theme_font_size_override("font_size", 18)
			line.add_theme_color_override("font_color", COLOR_INK_FADED)
			line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(line)
	if added_header:
		_add_rule(vbox, _stage_accent(stage_id))

func _battle_slot_key(slot: String) -> String:
	match slot:
		"intro":
			return "story_section_intro"
		"boss_intro":
			return "story_section_boss"
		"clear":
			return "story_section_clear"
		_:
			return "story_section_battle_quotes"

func _locked_section_text(unlock: String) -> String:
	match unlock:
		"stage_cleared":
			return Localization.tr_key("story_locked_clear_required")
		"campaign_cleared":
			return Localization.tr_key("story_locked_campaign_required")
		_:
			return Localization.tr_key("story_locked_long")

func _entry_style(stage_id: String) -> StyleBox:
	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	var texture_path := STORY_PARCHMENT_PATH if unlocked else STORY_LOCKED_PATH
	var texture := _try_load_texture(texture_path)
	if texture != null:
		return _entry_texture_style(texture)

	var sb := StyleBoxFlat.new()
	if unlocked:
		sb.bg_color = COLOR_PARCHMENT
		sb.border_color = COLOR_GOLD
	else:
		sb.bg_color = COLOR_LOCKED_SURFACE
		sb.border_color = Color(0.29, 0.30, 0.36, 0.92)
	sb.set_border_width_all(3 if unlocked else 2)
	sb.border_width_top = 5 if unlocked else 2
	sb.border_width_bottom = 5 if unlocked else 2
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 20
	sb.shadow_color = Color(0, 0, 0, 0.42)
	sb.shadow_size = 10
	return sb

func _entry_texture_style(texture: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = texture
	sb.texture_margin_left = STORY_PANEL_MARGIN
	sb.texture_margin_right = STORY_PANEL_MARGIN
	sb.texture_margin_top = STORY_PANEL_MARGIN
	sb.texture_margin_bottom = STORY_PANEL_MARGIN
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 24
	sb.content_margin_bottom = 26
	return sb

func _add_rule(vbox: VBoxContainer, accent: Color) -> void:
	var divider_texture := _try_load_texture(STORY_DIVIDER_PATH)
	if divider_texture != null:
		var divider := TextureRect.new()
		divider.texture = divider_texture
		divider.custom_minimum_size = Vector2(0, 24)
		divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		divider.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(divider)
		return

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 18)
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)

	var left := ColorRect.new()
	left.color = Color(accent.r, accent.g, accent.b, 0.30)
	left.custom_minimum_size.y = 1
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(left)

	var node := Label.new()
	node.text = "◆"
	node.add_theme_font_size_override("font_size", 13)
	node.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.72))
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(node)

	var right := ColorRect.new()
	right.color = Color(accent.r, accent.g, accent.b, 0.30)
	right.custom_minimum_size.y = 1
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(right)

func _chapter_label(stage_id: String) -> String:
	var ids := []
	var stage_source: Array = Stages.stages if Stages else []
	for stage in stage_source:
		if stage is Dictionary:
			ids.append(String(stage.get("id", "")))
	var index := ids.find(stage_id)
	if index < 0:
		index = 0
	return "CHAPTER %02d" % (index + 1)

func _section_label(header_key: String) -> String:
	return Localization.tr_key(header_key).replace("—", "").strip_edges().to_upper()

func _stage_accent(stage_id: String) -> Color:
	var stage := Stages.get_stage(stage_id) if Stages else {}
	var color_text := String(stage.get("color", ""))
	if color_text.begins_with("#") and color_text.length() == 7:
		return Color.html(color_text)
	match stage_id:
		"forest":
			return Color(0.176, 0.353, 0.153, 1.0)
		"frozen_wastes":
			return Color(0.455, 0.667, 0.800, 1.0)
		"twilight_sanctum":
			return Color(0.667, 0.467, 1.000, 1.0)
		"inferno_chasm":
			return Color(0.769, 0.302, 0.169, 1.0)
		"cursed_tomb":
			return Color(0.867, 0.267, 0.533, 1.0)
		_:
			return COLOR_GOLD

func _stage_icon_glyph(stage_id: String) -> String:
	match stage_id:
		"forest":
			return "♣"
		"frozen_wastes":
			return "*"
		"twilight_sanctum":
			return "✦"
		"inferno_chasm":
			return "▲"
		"cursed_tomb":
			return "✧"
		_:
			return "◇"

func _try_load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is Texture2D:
		return res
	return null

func _on_language_changed(_lang: String) -> void:
	_refresh()

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _on_codex_pressed() -> void:
	Transition.change_scene("res://scenes/ui/CodexUI.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()
