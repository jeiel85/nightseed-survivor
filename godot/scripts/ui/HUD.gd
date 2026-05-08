extends CanvasLayer
class_name HUD

@onready var hp_bar: ProgressBar = $Left/VBox/HPBar
@onready var hp_label: Label = $Left/VBox/HPLabel
@onready var xp_bar: ProgressBar = $Left/VBox/XPBar
@onready var level_label: Label = $Left/VBox/LevelLabel
@onready var kill_label: Label = $Left/VBox/KillLabel
@onready var gold_label: Label = $Left/VBox/GoldLabel
@onready var time_label: Label = $TimeLabel

func set_hp(current: int, max_val: int) -> void:
	if not is_instance_valid(hp_bar):
		return
	hp_bar.max_value = max_val
	hp_bar.value = current
	hp_label.text = "HP  %d / %d" % [current, max_val]

func set_xp(current: int, needed: int) -> void:
	if not is_instance_valid(xp_bar):
		return
	xp_bar.max_value = needed
	xp_bar.value = current

func set_level(level: int) -> void:
	if is_instance_valid(level_label):
		level_label.text = "Level  %d" % level

func set_time(seconds_remaining: float) -> void:
	if not is_instance_valid(time_label):
		return
	var total := maxi(int(seconds_remaining), 0)
	var m := total / 60
	var s := total % 60
	time_label.text = "%d:%02d" % [m, s]

func set_kills(count: int) -> void:
	if is_instance_valid(kill_label):
		kill_label.text = "Kills  %d" % count

func set_gold(amount: int) -> void:
	if is_instance_valid(gold_label):
		gold_label.text = "Gold  %d" % amount
