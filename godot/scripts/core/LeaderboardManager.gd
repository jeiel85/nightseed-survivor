extends Node

## Bridge between gameplay and Google Play Games Services leaderboards.
##
## v3.x of godot-play-game-services exposes clients as Nodes (not autoloads).
## We instantiate them as children of this manager after the main plugin
## autoload (GodotPlayGameServices) is initialized.
##
## On non-Android platforms (PC dev, headless), all calls are no-ops.

const SignInClientScript = preload("res://addons/GodotPlayGameServices/scripts/sign_in/sign_in_client.gd")
const LeaderboardsClientScript = preload("res://addons/GodotPlayGameServices/scripts/leaderboards/leaderboards_client.gd")

# Map our internal stage IDs (data/stages.json) → Play Console leaderboard IDs.
# Filled in once Play Console PGS setup is complete (see docs/PLAY_GAMES_SERVICES_SETUP.md).
const LEADERBOARD_IDS: Dictionary = {
	"forest":            "CgkI4dHfiPAMEAIQAQ",
	"frozen_wastes":     "CgkI4dHfiPAMEAIQAg",
	"twilight_sanctum":  "CgkI4dHfiPAMEAIQAw",
	"inferno_chasm":     "CgkI4dHfiPAMEAIQBA",
	"cursed_tomb":       "CgkI4dHfiPAMEAIQBQ",
	"total_kills":       "CgkI4dHfiPAMEAIQBg",
}

signal sign_in_changed(signed_in: bool)

var _plugin_ready: bool = false
var _signed_in: bool = false
var _sign_in_client: Node = null
var _leaderboards_client: Node = null

func _ready() -> void:
	if OS.get_name() != "Android":
		return
	call_deferred("_init_plugin")

func _init_plugin() -> void:
	if not ProjectSettings.has_setting("autoload/GodotPlayGameServices"):
		return
	var pgs = GodotPlayGameServices
	if pgs == null:
		return
	var err = pgs.initialize()
	if err != 0:
		push_warning("PGS plugin init failed: %s" % err)
		return
	_plugin_ready = true
	_sign_in_client = SignInClientScript.new()
	_sign_in_client.name = "SignInClient"
	add_child(_sign_in_client)
	_leaderboards_client = LeaderboardsClientScript.new()
	_leaderboards_client.name = "LeaderboardsClient"
	add_child(_leaderboards_client)
	if _sign_in_client.has_signal("user_authenticated"):
		_sign_in_client.user_authenticated.connect(_on_user_authenticated)
	if _sign_in_client.has_method("is_authenticated"):
		_sign_in_client.is_authenticated()

func _on_user_authenticated(authenticated: bool, _msg: String = "") -> void:
	_signed_in = authenticated
	sign_in_changed.emit(authenticated)

func is_supported() -> bool:
	return _plugin_ready

func is_signed_in() -> bool:
	return _signed_in

func sign_in() -> void:
	if not _plugin_ready or _sign_in_client == null:
		return
	_sign_in_client.sign_in()

func compute_score(kills: int, gold: int, survival_time: int, difficulty: String) -> int:
	var base: float = float(kills * 10 + gold * 5 + survival_time)
	var mult: float = 1.0
	match difficulty:
		"hard":      mult = 1.5
		"nightmare": mult = 2.5
	return int(floor(base * mult))

func submit_run(stage_id: String, kills: int, gold: int, survival_time: int, difficulty: String) -> void:
	if not _plugin_ready or not _signed_in or _leaderboards_client == null:
		return
	var score := compute_score(kills, gold, survival_time, difficulty)
	var stage_lb := _resolve_id(stage_id)
	if stage_lb != "":
		_leaderboards_client.submit_score(stage_lb, score)
	var kills_lb := _resolve_id("total_kills")
	if kills_lb != "" and kills > 0:
		_leaderboards_client.submit_score(kills_lb, kills)

func show_leaderboard_for_stage(stage_id: String) -> void:
	if not _plugin_ready or not _signed_in or _leaderboards_client == null:
		return
	var lb_id := _resolve_id(stage_id)
	if lb_id != "":
		_leaderboards_client.show_leaderboard(lb_id)

func show_all_leaderboards() -> void:
	if not _plugin_ready or not _signed_in or _leaderboards_client == null:
		return
	_leaderboards_client.show_all_leaderboards()

func _resolve_id(key: String) -> String:
	var raw := String(LEADERBOARD_IDS.get(key, ""))
	if raw.is_empty() or raw.begins_with("REPLACE_ME"):
		return ""
	return raw
