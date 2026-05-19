extends Node

## Story dialogue + glossary registry.
##
## Loads the curated stage intro / boss intro / clear lines defined in
## `data/story_dialogues.json` and the glossary entries in
## `data/story_terms.json`. UI scripts ask Story for *already-localized* lines
## so callers do not need to know about the on-disk schema.

const DIALOGUES_PATH := "res://data/story_dialogues.json"
const TERMS_PATH := "res://data/story_terms.json"
const CHAPTERS_PATH := "res://data/story_chapters.json"

var _dialogues: Dictionary = {}
var _terms: Array = []
var _chapters: Dictionary = {}

func _ready() -> void:
	_load_dialogues()
	_load_terms()
	_load_chapters()

func _load_dialogues() -> void:
	if not FileAccess.file_exists(DIALOGUES_PATH):
		push_error("Story: dialogues file missing at %s" % DIALOGUES_PATH)
		return
	var f := FileAccess.open(DIALOGUES_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		_dialogues = parsed
	else:
		push_error("Story: dialogues JSON invalid")

func _load_terms() -> void:
	if not FileAccess.file_exists(TERMS_PATH):
		return
	var f := FileAccess.open(TERMS_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		var list = parsed.get("terms", [])
		if list is Array:
			_terms = list

func _load_chapters() -> void:
	if not FileAccess.file_exists(CHAPTERS_PATH):
		return
	var f := FileAccess.open(CHAPTERS_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		_chapters = parsed
	else:
		push_error("Story: chapters JSON invalid")

## Returns an Array of {speaker: String, text: String} dictionaries for the
## given stage and slot ("intro", "boss_intro", "clear"). Speaker name and
## line text are already resolved to the current Localization language.
func get_stage_lines(stage_id: String, slot: String) -> Array:
	var stages: Dictionary = _dialogues.get("stages", {})
	var stage_block: Dictionary = stages.get(stage_id, {})
	var raw_lines = stage_block.get(slot, [])
	if not (raw_lines is Array):
		return []
	var out: Array = []
	for entry in raw_lines:
		if not (entry is Dictionary):
			continue
		out.append({
			"speaker": _speaker_name(String(entry.get("speaker", ""))),
			"text": _localized_text(entry),
		})
	return out

func has_stage_lines(stage_id: String, slot: String) -> bool:
	return not get_stage_lines(stage_id, slot).is_empty()

func get_repeat_hint() -> String:
	var hints = _dialogues.get("repeat_hints", [])
	if not (hints is Array) or hints.is_empty():
		return ""
	var entry = hints[randi() % hints.size()]
	if entry is Dictionary:
		return _localized_text(entry)
	return ""

func get_terms() -> Array:
	return _terms

func get_term(id: String) -> Dictionary:
	for t in _terms:
		if t is Dictionary and String(t.get("id", "")) == id:
			return t
	return {}

func get_stage_chapter(stage_id: String) -> Dictionary:
	var chapters: Dictionary = _chapters.get("chapters", {})
	var raw: Dictionary = chapters.get(stage_id, {})
	if raw.is_empty():
		return {}
	var out: Dictionary = {
		"title": _localized_text(raw.get("title", {})),
		"summary": _localized_text(raw.get("summary", {})),
		"revealed_terms": raw.get("revealed_terms", []),
	}
	return out

func has_stage_chapter(stage_id: String) -> bool:
	var chapters: Dictionary = _chapters.get("chapters", {})
	return chapters.has(stage_id)

## Returns localized chapter body sections for a stage.
## Each entry includes {unlock, unlocked, heading, text}. Locked entries keep
## their heading so StoryUI can hint at post-clear material without revealing it.
func get_chapter_sections(stage_id: String) -> Array:
	var chapters: Dictionary = _chapters.get("chapters", {})
	var raw: Dictionary = chapters.get(stage_id, {})
	var body = raw.get("body", [])
	if not (body is Array):
		return []
	var out: Array = []
	for entry in body:
		if not (entry is Dictionary):
			continue
		var unlock := String(entry.get("unlock", "stage_unlocked"))
		out.append({
			"unlock": unlock,
			"unlocked": _is_unlock_condition_met(stage_id, unlock),
			"heading": _localized_text(entry.get("heading", {})),
			"text": _localized_text(entry.get("text", {})),
		})
	return out

# --- internal helpers ---

func _speaker_name(key: String) -> String:
	if key.is_empty():
		return ""
	var speakers: Dictionary = _dialogues.get("speakers", {})
	var entry = speakers.get(key, null)
	if entry is Dictionary:
		return _localized_text(entry)
	return key

func _localized_text(entry: Dictionary) -> String:
	var lang: String = Localization.current_lang if Localization else "en"
	if entry.has(lang):
		return String(entry[lang])
	if entry.has("en"):
		return String(entry["en"])
	if entry.has("ko"):
		return String(entry["ko"])
	return ""

func _is_unlock_condition_met(stage_id: String, unlock: String) -> bool:
	match unlock:
		"stage_unlocked":
			return GameData == null or GameData.is_stage_unlocked(stage_id)
		"stage_cleared":
			return GameData != null and GameData.is_stage_cleared(stage_id)
		"campaign_cleared":
			return _is_campaign_cleared()
		_:
			return false

func _is_campaign_cleared() -> bool:
	if GameData == null or Stages == null:
		return false
	for stage in Stages.stages:
		if not (stage is Dictionary):
			continue
		var stage_id := String(stage.get("id", ""))
		if stage_id != "" and Stages.has_method("is_last_stage") and Stages.is_last_stage(stage_id):
			return GameData.is_stage_cleared(stage_id)
	return false
