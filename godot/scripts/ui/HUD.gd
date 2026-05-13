extends CanvasLayer
class_name HUD

@onready var top_bar: Control = $TopBar
@onready var hp_bar: ProgressBar = $TopBar/HPBar
@onready var hp_label: Label = $TopBar/HPLabel
@onready var xp_bar: ProgressBar = $TopBar/XPBar
@onready var time_label: Label = $TopBar/StatsRow/TimeLabel
@onready var level_label: Label = $TopBar/StatsRow/LevelLabel
@onready var kill_label: Label = $TopBar/StatsRow/KillLabel
@onready var gold_label: Label = $TopBar/StatsRow/GoldLabel

var _last_hp: int = 0
var _last_max: int = 0
var _last_level: int = 1
var _last_kills: int = 0
var _last_gold: int = 0

func _ready() -> void:
	if Localization:
		Localization.language_changed.connect(_on_language_changed)
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

# Push HUD away from display cutouts (notch / punch-hole) so the in-game
# time/HP do not collide with the system clock. On devices without a cutout
# the safe area equals the window, so the offsets resolve to zero.
func _apply_safe_area() -> void:
	if not is_instance_valid(top_bar):
		return
	var win: Vector2i = DisplayServer.window_get_size()
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	# Some desktop platforms return a screen-space rect; clamp to the window
	# so the offsets never go negative or larger than the viewport.
	var top_inset: float = clamp(float(safe.position.y), 0.0, float(win.y) * 0.25)
	var left_inset: float = clamp(float(safe.position.x), 0.0, float(win.x) * 0.25)
	var right_inset: float = clamp(float(win.x) - float(safe.position.x + safe.size.x), 0.0, float(win.x) * 0.25)
	top_bar.offset_top = top_inset
	top_bar.offset_bottom = 168.0 + top_inset
	top_bar.offset_left = left_inset
	top_bar.offset_right = -right_inset

func _on_language_changed(_lang: String) -> void:
	set_hp(_last_hp, _last_max)
	set_level(_last_level)
	set_kills(_last_kills)
	set_gold(_last_gold)

var _hp_tween: Tween
var _xp_tween: Tween

func set_hp(current: int, max_val: int) -> void:
	_last_hp = current
	_last_max = max_val
	if not is_instance_valid(hp_bar):
		return
	hp_bar.max_value = max_val
	if _hp_tween and _hp_tween.is_valid():
		_hp_tween.kill()
	_hp_tween = create_tween()
	_hp_tween.tween_property(hp_bar, "value", float(current), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hp_label.text = Localization.tr_key("hud_hp_fmt") % [current, max_val]

func set_xp(current: int, needed: int) -> void:
	if not is_instance_valid(xp_bar):
		return
	xp_bar.max_value = needed
	if _xp_tween and _xp_tween.is_valid():
		_xp_tween.kill()
	_xp_tween = create_tween()
	_xp_tween.tween_property(xp_bar, "value", float(current), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func set_level(level: int) -> void:
	_last_level = level
	if is_instance_valid(level_label):
		level_label.text = Localization.tr_key("hud_level_fmt") % level

func set_time(seconds_remaining: float) -> void:
	if not is_instance_valid(time_label):
		return
	var total := maxi(int(seconds_remaining), 0)
	var m := total / 60
	var s := total % 60
	time_label.text = "%d:%02d" % [m, s]

func set_kills(count: int) -> void:
	_last_kills = count
	if is_instance_valid(kill_label):
		kill_label.text = Localization.tr_key("hud_kills_fmt") % count

func set_gold(amount: int) -> void:
	_last_gold = amount
	if is_instance_valid(gold_label):
		gold_label.text = Localization.tr_key("hud_gold_fmt") % amount
