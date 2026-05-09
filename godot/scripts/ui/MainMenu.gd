extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var gold_label: Label = $VBox/GoldLabel
@onready var status_label: Label = $VBox/StatusLabel
@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_character: Button = $VBox/BtnCharacter
@onready var btn_stage: Button = $VBox/BtnStage
@onready var btn_shop: Button = $VBox/BtnShop
@onready var btn_difficulty: Button = $VBox/BtnDifficulty
@onready var btn_leaderboard: Button = $VBox/BtnLeaderboard
@onready var btn_language: Button = $VBox/BtnLanguage
@onready var btn_credits: Button = $VBox/BtnCredits

func _ready() -> void:
	_refresh()
	btn_play.pressed.connect(_on_play_pressed)
	btn_character.pressed.connect(_on_character_pressed)
	btn_stage.pressed.connect(_on_stage_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)
	btn_difficulty.pressed.connect(_on_difficulty_pressed)
	btn_leaderboard.pressed.connect(_on_leaderboard_pressed)
	btn_language.pressed.connect(_on_language_pressed)
	btn_credits.pressed.connect(_on_credits_pressed)
	btn_leaderboard.visible = LeaderboardManager.is_supported() or OS.get_name() == "Android"
	if Localization:
		Localization.language_changed.connect(_on_language_changed)

func _refresh() -> void:
	title_label.text = Localization.tr_key("app_title")
	subtitle_label.text = Localization.tr_key("app_subtitle")
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold
	var ch_name: String = Characters.display_name(GameData.selected_character)
	var st_name: String = Stages.display_name(GameData.selected_stage)
	var df_name: String = Difficulty.display_name(GameData.difficulty)
	status_label.text = Localization.tr_key("label_status") % [ch_name, st_name, df_name]
	var df: Dictionary = Difficulty.get_data(GameData.difficulty)
	status_label.add_theme_color_override("font_color", df["color"])
	btn_play.text = Localization.tr_key("btn_play")
	btn_character.text = Localization.tr_key("btn_characters")
	btn_stage.text = Localization.tr_key("btn_stages")
	btn_shop.text = Localization.tr_key("btn_shop")
	btn_difficulty.text = Localization.tr_key("btn_difficulty_fmt") % df_name
	btn_difficulty.add_theme_color_override("font_color", df["color"])
	btn_leaderboard.text = Localization.tr_key("btn_leaderboard")
	btn_language.text = Localization.tr_key("btn_language_fmt") % Localization.current_label()
	btn_credits.text = Localization.tr_key("btn_credits")

func _on_language_changed(_lang: String) -> void:
	_refresh()

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

func _on_leaderboard_pressed() -> void:
	if not LeaderboardManager.is_signed_in():
		LeaderboardManager.sign_in()
		return
	LeaderboardManager.show_all_leaderboards()

func _on_language_pressed() -> void:
	Localization.cycle_language()
