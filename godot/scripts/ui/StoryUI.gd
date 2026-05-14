extends Control

## Story replay screen. Lists every stage with its unlocked dialogue lines
## (intro / boss intro / clear). Locked stages show a "coming soon" placeholder
## so players see what's still to come without spoiling the dialogue itself.

@onready var title_label: Label = $VBox/HeaderRow/Title
@onready var hint_label: Label = $VBox/Hint
@onready var stage_list: VBoxContainer = $VBox/ScrollContainer/StageList
@onready var btn_codex: Button = $VBox/HeaderRow/BtnCodex
@onready var btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	AudioManager.play_bgm("menu")
	_apply_button_styles()
	btn_back.pressed.connect(_on_back_pressed)
	btn_codex.pressed.connect(_on_codex_pressed)
	if Localization:
		Localization.language_changed.connect(_on_language_changed)
	_refresh()

func _apply_button_styles() -> void:
	ButtonStyles.apply(btn_back, ButtonStyles.NEUTRAL)
	ButtonStyles.apply(btn_codex, ButtonStyles.CODEX)

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
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = Stages.display_name(stage_id) if Stages.has_method("display_name") else stage_id
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vbox.add_child(name_label)

	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	if not unlocked:
		var locked := Label.new()
		locked.text = "🔒  " + Localization.tr_key("story_locked_long")
		locked.add_theme_font_size_override("font_size", 19)
		locked.add_theme_color_override("font_color", Color(0.70, 0.74, 0.86, 0.85))
		locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(locked)
		return panel

	_append_section(vbox, stage_id, "intro", "story_section_intro")
	_append_section(vbox, stage_id, "boss_intro", "story_section_boss")
	_append_section(vbox, stage_id, "clear", "story_section_clear")
	return panel

func _append_section(vbox: VBoxContainer, stage_id: String, slot: String, header_key: String) -> void:
	var lines: Array = Story.get_stage_lines(stage_id, slot) if Story else []
	if lines.is_empty():
		return
	var header := Label.new()
	header.text = Localization.tr_key(header_key)
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(0.95, 0.85, 0.45, 1))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	for entry in lines:
		if not (entry is Dictionary):
			continue
		var line := Label.new()
		var speaker: String = String(entry.get("speaker", ""))
		var text: String = String(entry.get("text", ""))
		line.text = ("%s — %s" % [speaker, text]) if speaker != "" else text
		line.add_theme_font_size_override("font_size", 19)
		line.add_theme_color_override("font_color", Color(0.92, 0.94, 1, 1))
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(line)

func _entry_style(stage_id: String) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var unlocked: bool = (GameData != null and GameData.is_stage_unlocked(stage_id))
	if unlocked:
		sb.bg_color = Color(0.10, 0.12, 0.18, 0.95)
		sb.border_color = Color(0.32, 0.36, 0.52, 1.0)
	else:
		sb.bg_color = Color(0.08, 0.08, 0.11, 0.85)
		sb.border_color = Color(0.22, 0.22, 0.28, 0.85)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 14
	return sb

func _on_language_changed(_lang: String) -> void:
	_refresh()

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _on_codex_pressed() -> void:
	Transition.change_scene("res://scenes/ui/CodexUI.tscn")
