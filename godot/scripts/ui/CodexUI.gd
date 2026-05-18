extends Control

## Codex / glossary screen. Lists Nightseed story terms loaded from
## `data/story_terms.json` and shows the description of the selected term.

@onready var title_label: Label = $VBox/Title
@onready var hint_label: Label = $VBox/Hint
@onready var term_list: VBoxContainer = $VBox/ListScroll/TermList
@onready var detail_name: Label = $VBox/DetailScroll/Detail/DetailName
@onready var detail_short: Label = $VBox/DetailScroll/Detail/DetailShort
@onready var detail_long: Label = $VBox/DetailScroll/Detail/DetailLong
@onready var detail_safe_header: Label = $VBox/DetailScroll/Detail/SafeHeader
@onready var detail_safe: Label = $VBox/DetailScroll/Detail/DetailSafe
@onready var btn_back: Button = $VBox/BtnBack

var _terms: Array = []
var _selected_id: String = ""

func _ready() -> void:
	AudioManager.play_bgm("menu")
	btn_back.pressed.connect(_on_back_pressed)
	if Localization:
		Localization.language_changed.connect(_on_language_changed)
	_terms = Story.get_terms() if Story else []
	_refresh()
	_select_first()

func _refresh() -> void:
	title_label.text = Localization.tr_key("codex_title")
	hint_label.text = Localization.tr_key("codex_hint")
	detail_safe_header.text = Localization.tr_key("codex_safe_label")
	btn_back.text = Localization.tr_key("btn_back")
	_rebuild_list()
	if not _selected_id.is_empty():
		_show_detail(_selected_id)

func _rebuild_list() -> void:
	for child in term_list.get_children():
		child.queue_free()
	for t in _terms:
		if not (t is Dictionary):
			continue
		var id: String = String(t.get("id", ""))
		var name_str: String = _term_name(t)
		var btn := Button.new()
		btn.text = name_str
		btn.custom_minimum_size = Vector2(0, 64)
		btn.add_theme_font_size_override("font_size", 22)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_term_pressed.bind(id))
		term_list.add_child(btn)

func _select_first() -> void:
	if _terms.is_empty():
		return
	var first: Dictionary = _terms[0]
	_show_detail(String(first.get("id", "")))

func _on_term_pressed(id: String) -> void:
	_show_detail(id)

func _show_detail(id: String) -> void:
	_selected_id = id
	var t: Dictionary = Story.get_term(id) if Story else {}
	if t.is_empty():
		detail_name.text = ""
		detail_short.text = ""
		detail_long.text = ""
		detail_safe.text = ""
		return
	detail_name.text = _term_name(t)
	var short_text: String = _localized(t, "short")
	detail_short.text = short_text
	detail_short.visible = not short_text.is_empty()
	var long_text: String = _localized(t, "long")
	detail_long.text = long_text
	detail_long.visible = not long_text.is_empty()
	var safe: Array = t.get("safe_usage", [])
	if safe is Array and not safe.is_empty():
		detail_safe_header.visible = true
		detail_safe.visible = true
		var lines: Array = []
		for s in safe:
			lines.append("• " + String(s))
		detail_safe.text = "\n".join(lines)
	else:
		detail_safe_header.visible = false
		detail_safe.visible = false
		detail_safe.text = ""

func _term_name(t: Dictionary) -> String:
	var lang: String = Localization.current_lang if Localization else "en"
	var key := "name_%s" % lang
	if t.has(key):
		return String(t[key])
	if t.has("name_en"):
		return String(t["name_en"])
	return String(t.get("id", "?"))

func _localized(t: Dictionary, kind: String) -> String:
	var lang: String = Localization.current_lang if Localization else "en"
	var k_lang := "%s_%s" % [kind, lang]
	var k_en := "%s_en" % kind
	var k_ko := "%s_ko" % kind
	if t.has(k_lang):
		return String(t[k_lang])
	if t.has(k_en):
		return String(t[k_en])
	if t.has(k_ko):
		return String(t[k_ko])
	return ""

func _on_language_changed(_lang: String) -> void:
	_refresh()

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()
