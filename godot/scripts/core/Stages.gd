extends Node

const STAGES_PATH := "res://data/stages.json"

var stages: Array = []
var by_id: Dictionary = {}

func _ready() -> void:
	_load_stages()

func _load_stages() -> void:
	if not FileAccess.file_exists(STAGES_PATH):
		push_error("Stages: stages.json not found at %s" % STAGES_PATH)
		return
	var f := FileAccess.open(STAGES_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Stages: invalid JSON")
		return
	var stage_list = parsed.get("stages", [])
	if not stage_list is Array:
		return
	stages = stage_list
	by_id.clear()
	for s in stages:
		if s is Dictionary:
			by_id[String(s.get("id", ""))] = s

func get_stage(id: String) -> Dictionary:
	if by_id.has(id):
		return by_id[id]
	if not stages.is_empty():
		return stages[0]
	return {}

func get_default_id() -> String:
	if stages.is_empty():
		return ""
	return String(stages[0].get("id", ""))

func display_name(id: String) -> String:
	var s := get_stage(id)
	if s.has("name_key") and Localization:
		return Localization.tr_key(String(s["name_key"]), String(s.get("name", "?")))
	return String(s.get("name", "?"))

func display_desc(id: String) -> String:
	var s := get_stage(id)
	if s.has("desc_key") and Localization:
		return Localization.tr_key(String(s["desc_key"]), String(s.get("desc", "")))
	return String(s.get("desc", ""))
