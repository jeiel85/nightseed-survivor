extends Node

## Cloud backup for meta progress via Play Games Services Snapshots (v0.29.0).
##
## Wraps PlayGamesSnapshotsClient so the rest of the code never imports the PGS
## addon directly. On non-Android platforms or when PGS isn't signed in, every
## operation is a silent no-op — the local user://save_data.json file remains
## the source of truth.
##
## Conflict policy (kept intentionally dumb):
##   - On meta save: write the *current* local meta to the cloud, blindly.
##     Cloud snapshot is meant for restore-on-reinstall, not multi-device sync.
##   - On cloud load: surface the snapshot data; MainMenu decides whether to
##     replace local (user prompt) or merge (gold = max, unlocks = union).
##
## We do NOT cloud-save the run-in-progress save (RunPersist) — that's
## device-local by nature and changes too often to be worth the PGS quota.

signal cloud_loaded(meta: Dictionary)
signal cloud_saved(success: bool)

const SnapshotsClientScript = preload("res://addons/GodotPlayGameServices/scripts/snapshots/snapshots_client.gd")
const SNAPSHOT_NAME := "nightseed_meta"
const SNAPSHOT_DESC := "Nightseed Survivor — meta progress"

var _client: Node = null
var _supported: bool = false
# Debounce: avoid hitting PGS on every coin pickup. We coalesce writes to one
# every ~10s, and flush immediately when the app backgrounds (NOTIFICATION_
# APPLICATION_PAUSED in MainMenu).
var _dirty: bool = false
var _last_save_ts: float = 0.0
const SAVE_THROTTLE_SECONDS := 10.0

func _ready() -> void:
	if OS.get_name() != "Android":
		return
	# LeaderboardManager initializes the PGS plugin first. We piggy-back on
	# its is_supported() once it's ready by polling on the next idle frame.
	call_deferred("_init_client")
	# Auto-save throttled writes.
	var t := Timer.new()
	t.wait_time = 1.0
	t.autostart = true
	t.timeout.connect(_on_tick)
	add_child(t)

func _init_client() -> void:
	# LeaderboardManager owns the plugin handle. Wait for it to be ready.
	if not is_instance_valid(LeaderboardManager) or not LeaderboardManager.is_supported():
		# Try again next frame — the autoload order isn't strictly guaranteed
		# and PGS init is deferred. After ~3s give up silently.
		if _retry_count < 30:
			_retry_count += 1
			call_deferred("_init_client")
		return
	_client = SnapshotsClientScript.new()
	_client.name = "SnapshotsClient"
	add_child(_client)
	_client.game_saved.connect(_on_game_saved)
	_client.game_loaded.connect(_on_game_loaded)
	_supported = true

var _retry_count: int = 0

# --- Public API ---

func is_supported() -> bool:
	return _supported and LeaderboardManager.is_signed_in()

func request_load() -> void:
	# Asks the cloud for the latest meta snapshot. Result comes back via
	# cloud_loaded(meta) — an empty dict means "no snapshot or load failed".
	if not is_supported() or _client == null:
		cloud_loaded.emit({})
		return
	_client.load_game(SNAPSHOT_NAME, false)

func mark_dirty() -> void:
	_dirty = true

func flush() -> void:
	# Immediate write — call when the app is about to background and we can't
	# afford to wait for the next throttle tick.
	if not is_supported() or _client == null or not _dirty:
		return
	_save_now()

# --- Internals ---

func _on_tick() -> void:
	if not _dirty:
		return
	var now := Time.get_unix_time_from_system()
	if now - _last_save_ts < SAVE_THROTTLE_SECONDS:
		return
	_save_now()

func _save_now() -> void:
	if _client == null:
		return
	var payload := _build_payload()
	var bytes := payload.to_utf8_buffer()
	_last_save_ts = Time.get_unix_time_from_system()
	_dirty = false
	_client.save_game(SNAPSHOT_NAME, SNAPSHOT_DESC, bytes, 0, GameData.gold)

func _build_payload() -> String:
	return JSON.stringify({
		"schema": 1,
		"saved_at": Time.get_unix_time_from_system(),
		"gold": GameData.gold,
		"permanent_upgrades": GameData.permanent_upgrades.duplicate(),
		"unlocked_characters": GameData.unlocked_characters.duplicate(),
		"unlocked_stages": GameData.unlocked_stages.duplicate(),
		"achievements_unlocked": GameData.achievements_unlocked.duplicate(),
		"selected_character": GameData.selected_character,
		"selected_stage": GameData.selected_stage,
		"difficulty": GameData.difficulty,
	})

func _on_game_saved(success: bool, _name: String, _desc: String) -> void:
	cloud_saved.emit(success)

func _on_game_loaded(snapshot) -> void:
	if snapshot == null:
		cloud_loaded.emit({})
		return
	var content: PackedByteArray = snapshot.content
	if content.is_empty():
		cloud_loaded.emit({})
		return
	var text: String = content.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		cloud_loaded.emit({})
		return
	cloud_loaded.emit(parsed)
