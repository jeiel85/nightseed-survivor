extends Control

const VERSION: String = "0.5.0"

@onready var btn_back: Button = $VBox/BtnBack
@onready var version_label: Label = $VBox/VersionLabel

func _ready() -> void:
	AudioManager.play_bgm("menu")
	btn_back.pressed.connect(_on_back_pressed)
	if version_label:
		version_label.text = "v" + VERSION

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()
