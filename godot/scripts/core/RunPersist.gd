extends Node

## Run-in-progress persistence (v0.29.0).
##
## Lets the player back out of a run (Android Back, app paused, app killed) and
## resume later from the main menu. Stores the minimum state needed to rebuild
## a coherent battle: player stats, weapons + passives, wave-manager elapsed
## time, and GameRoot run flags. Enemies / projectiles / pickups are NOT saved
## — on resume the wave manager re-spawns from `_elapsed` so combat continues
## naturally without state-restore complexity.
##
## Save lifecycle:
##   - capture_*() takes a snapshot into `_pending` (no I/O yet)
##   - commit() writes _pending to disk (cheap; called on pause/quit-to-menu)
##   - clear() removes the file (called on run end or explicit "give up")
##   - has_save() lets MainMenu show the "이어하기" CTA
##   - load_save() reads the file for GameRoot to apply during _ready()

const SAVE_PATH := "user://run_save.json"
const SCHEMA_VERSION := 1

var _pending: Dictionary = {}
var _has_disk_save: bool = false

func _ready() -> void:
	_has_disk_save = FileAccess.file_exists(SAVE_PATH)

# --- Public API ---

func has_save() -> bool:
	return _has_disk_save

func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return {}
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if not (parsed is Dictionary):
		return {}
	if int(parsed.get("schema", 0)) != SCHEMA_VERSION:
		# Future migration point. For now, treat older saves as invalid.
		return {}
	return parsed

func capture_from(root: Node2D) -> void:
	# Snapshots the live run into _pending. Call from GameRoot before the
	# pause menu shows or when the app is about to background. The actual
	# disk write happens in commit() so we don't pay I/O on every back press
	# that the user might immediately reverse with "Resume".
	if not is_instance_valid(root):
		return
	var player = root.get("player")
	var wave_manager = root.get("wave_manager")
	if player == null or wave_manager == null:
		return
	_pending = {
		"schema": SCHEMA_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"stage": GameData.selected_stage,
		"character": GameData.selected_character,
		"difficulty": GameData.difficulty,
		"player": _capture_player(player),
		"weapons": _capture_weapons(player.weapon_manager),
		"passives": (player.weapon_manager.passives as Dictionary).duplicate(),
		"weapon_manager": {
			"init_damage_mult": float(player.weapon_manager._init_damage_mult),
			"init_cooldown_mult": float(player.weapon_manager._init_cooldown_mult),
			"passive_damage_mult": float(player.weapon_manager.passive_damage_mult),
			"passive_cooldown_mult": float(player.weapon_manager.passive_cooldown_mult),
		},
		"wave_elapsed": float(wave_manager._elapsed),
		"survival_time": float(root._survival_time),
		"run_flags": {
			"damage_taken_at_lv5": bool(root._run_damage_taken_at_lv5),
			"lv5_locked":          bool(root._run_lv5_locked),
			"evolved":             bool(root._run_evolved),
			"boss_killed":         bool(root._run_boss_killed),
			"revive_used":         bool(root._revive_used),
			"double_gold_used":    bool(root._double_gold_used),
			"newly_unlocked":      (root._newly_unlocked_achievements as Array).duplicate(),
		},
	}

func commit() -> bool:
	if _pending.is_empty():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not f:
		return false
	f.store_string(JSON.stringify(_pending))
	f.close()
	_has_disk_save = true
	return true

func clear() -> void:
	_pending.clear()
	_has_disk_save = false
	if FileAccess.file_exists(SAVE_PATH):
		var d := DirAccess.open("user://")
		if d:
			d.remove("run_save.json")

# --- Capture helpers ---

func _capture_player(player) -> Dictionary:
	return {
		"pos_x": player.global_position.x,
		"pos_y": player.global_position.y,
		"current_hp": int(player.current_hp),
		"max_hp": int(player.max_hp),
		"move_speed": float(player.move_speed),
		"xp_radius": float(player.xp_radius),
		"current_xp": int(player.current_xp),
		"current_level": int(player.current_level),
		"kill_count": int(player.kill_count),
		"session_gold": int(player.session_gold),
	}

func _capture_weapons(wm) -> Array:
	var arr: Array = []
	for w in wm.weapons:
		if not is_instance_valid(w):
			continue
		arr.append({
			"name": String(w.weapon_name),
			"level": int(w.level),
			"base_damage": int(w.base_damage),
			"base_cooldown": float(w.base_cooldown),
			"damage_multiplier": float(w.damage_multiplier),
			"cooldown_multiplier": float(w.cooldown_multiplier),
			"evolved": bool(w.evolved),
		})
	return arr

# --- Helpers for MainMenu CTA ---

func get_save_summary() -> Dictionary:
	# Returns the loaded save trimmed to what MainMenu needs to show:
	# stage_id, level, elapsed seconds. Empty dict if no save.
	var save := load_save()
	if save.is_empty():
		return {}
	var player: Dictionary = save.get("player", {})
	return {
		"stage": String(save.get("stage", "")),
		"level": int(player.get("current_level", 1)),
		"elapsed": int(save.get("survival_time", 0.0)),
	}
