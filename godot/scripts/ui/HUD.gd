extends CanvasLayer
class_name HUD

@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

func set_hp(current_hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d / %d" % [current_hp, max_hp]

func set_survival_time(seconds: float) -> void:
	time_label.text = "Time: %.1fs" % seconds
