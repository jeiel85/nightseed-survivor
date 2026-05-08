extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_shop: Button = $VBox/BtnShop

func _ready() -> void:
	gold_label.text = "Gold: %d" % GameData.gold
	btn_play.pressed.connect(_on_play_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameRoot.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/ShopUI.tscn")
