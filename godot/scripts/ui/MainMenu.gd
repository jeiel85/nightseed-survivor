extends Control

@onready var gold_label: Label = $VBox/GoldLabel
@onready var status_label: Label = $VBox/StatusLabel
@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_character: Button = $VBox/BtnCharacter
@onready var btn_stage: Button = $VBox/BtnStage
@onready var btn_shop: Button = $VBox/BtnShop
@onready var btn_difficulty: Button = $VBox/BtnDifficulty
@onready var btn_credits: Button = $VBox/BtnCredits

func _ready() -> void:
	_refresh()
	btn_play.pressed.connect(_on_play_pressed)
	btn_character.pressed.connect(_on_character_pressed)
	btn_stage.pressed.connect(_on_stage_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)
	btn_difficulty.pressed.connect(_on_difficulty_pressed)
	btn_credits.pressed.connect(_on_credits_pressed)

func _refresh() -> void:
	gold_label.text = "Gold: %d" % GameData.gold
	var ch: Dictionary = Characters.get_data(GameData.selected_character)
	var st: Dictionary = Stages.get_stage(GameData.selected_stage)
	var df: Dictionary = Difficulty.get_data(GameData.difficulty)
	status_label.text = "%s  ·  %s  ·  %s" % [
		String(ch["name"]), String(st.get("name", "?")), String(df["name"])
	]
	status_label.add_theme_color_override("font_color", df["color"])
	btn_difficulty.text = "DIFFICULTY:  %s" % String(df["name"])
	btn_difficulty.add_theme_color_override("font_color", df["color"])

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameRoot.tscn")

func _on_character_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/CharacterSelect.tscn")

func _on_stage_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/StageSelect.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/ShopUI.tscn")

func _on_difficulty_pressed() -> void:
	GameData.cycle_difficulty()
	_refresh()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/CreditsUI.tscn")
