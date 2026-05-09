extends Control

const VERSION: String = "0.5.0"

@onready var btn_back: Button = $VBox/BtnBack
@onready var version_label: Label = $VBox/VersionLabel

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	if version_label:
		version_label.text = "v" + VERSION

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
