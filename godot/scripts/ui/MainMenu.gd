extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var status_card: PanelContainer = $VBox/StatusCard
@onready var gold_label: Label = $VBox/StatusCard/StatusVBox/GoldRow/GoldLabel
@onready var next_goal_label: Label = $VBox/StatusCard/StatusVBox/GoldRow/NextGoalLabel
@onready var status_label: Label = $VBox/StatusCard/StatusVBox/StatusLabel
@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_character: Button = $VBox/PrimaryRow/BtnCharacter
@onready var btn_stage: Button = $VBox/PrimaryRow/BtnStage
@onready var btn_difficulty: Button = $VBox/PrimaryRow/BtnDifficulty
@onready var btn_shop: Button = $VBox/SecondaryRow/BtnShop
@onready var btn_codex: Button = $VBox/SecondaryRow/BtnCodex
@onready var btn_leaderboard: Button = $VBox/SecondaryRow/BtnLeaderboard
@onready var btn_language: Button = $TopRightRow/BtnLanguage
@onready var btn_credits: Button = $TopRightRow/BtnCredits
@onready var character_showcase: CharacterShowcase = $CharacterShowcase

func _ready() -> void:
	AudioManager.play_bgm("menu")
	_apply_title_styles()
	_apply_button_styles()
	_apply_status_card_style()
	_refresh()
	btn_play.pressed.connect(_on_play_pressed)
	btn_character.pressed.connect(_on_character_pressed)
	btn_stage.pressed.connect(_on_stage_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)
	btn_difficulty.pressed.connect(_on_difficulty_pressed)
	btn_leaderboard.pressed.connect(_on_leaderboard_pressed)
	btn_codex.pressed.connect(_on_codex_pressed)
	btn_language.pressed.connect(_on_language_pressed)
	btn_credits.pressed.connect(_on_credits_pressed)
	btn_leaderboard.visible = LeaderboardManager.is_supported() or OS.get_name() == "Android"
	if Localization:
		Localization.language_changed.connect(_on_language_changed)

func _apply_title_styles() -> void:
	# Nightseed 톤 — 창백한 달빛 제목 + 살짝 푸른 부제. 배경(MenuBackdrop)의
	# 어두운 남색 위에서 충분히 떠 보이도록 외곽선/그림자 보정.
	title_label.add_theme_color_override("font_color", Color(0.93, 0.96, 1.0, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.043, 0.078, 0.149, 0.95))
	title_label.add_theme_constant_override("outline_size", 6)
	subtitle_label.add_theme_color_override("font_color", Color(0.76, 0.84, 1.0, 1.0))
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.043, 0.078, 0.149, 0.85))
	subtitle_label.add_theme_constant_override("outline_size", 3)

func _apply_button_styles() -> void:
	# Phase UI-1 — Moon/Stone 위계 적용.
	# PLAY 만 달빛 CTA, 1차 행은 강조색 테두리의 석판 스타일,
	# 2차 행과 코너 보조 버튼은 더 조용한 석판 스타일.
	ButtonStyles.apply_moon(btn_play)
	ButtonStyles.apply_stone(btn_character, ButtonStyles.CHARACTER)
	ButtonStyles.apply_stone(btn_stage, ButtonStyles.STAGE)
	ButtonStyles.apply_stone(btn_difficulty, ButtonStyles.DIFFICULTY)
	ButtonStyles.apply_stone_secondary(btn_shop, ButtonStyles.SHOP)
	ButtonStyles.apply_stone_secondary(btn_codex, ButtonStyles.CODEX)
	ButtonStyles.apply_stone_secondary(btn_leaderboard, ButtonStyles.LEADERBOARD)
	ButtonStyles.apply_stone_secondary(btn_language, ButtonStyles.LANGUAGE)
	ButtonStyles.apply_stone_secondary(btn_credits, ButtonStyles.CREDITS)

func _apply_status_card_style() -> void:
	# 상태 카드는 메뉴 위에 떠 있어야 하므로 톤을 살짝 더 어둡게 + 모서리는 작게(6 이하).
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.078, 0.094, 0.137, 0.88)
	sb.border_color = Color(0.38, 0.45, 0.58, 0.95)
	sb.border_width_top = 3
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	status_card.add_theme_stylebox_override("panel", sb)

func _refresh() -> void:
	title_label.text = Localization.tr_key("app_title")
	subtitle_label.text = Localization.tr_key("app_subtitle")
	gold_label.text = Localization.tr_key("label_gold") % GameData.gold
	next_goal_label.text = _next_goal_text()
	var ch_name: String = Characters.display_name(GameData.selected_character)
	var st_name: String = Stages.display_name(GameData.selected_stage)
	var df_name: String = Difficulty.display_name(GameData.difficulty)
	status_label.text = Localization.tr_key("label_status") % [ch_name, st_name, df_name]
	var df: Dictionary = Difficulty.get_data(GameData.difficulty)
	status_label.add_theme_color_override("font_color", df["color"])
	if character_showcase:
		character_showcase.character_key = String(GameData.selected_character)
		character_showcase.refresh()
	btn_play.text = Localization.tr_key("btn_play")
	btn_character.text = Localization.tr_key("btn_characters")
	btn_stage.text = Localization.tr_key("btn_stages")
	btn_shop.text = Localization.tr_key("btn_shop")
	btn_difficulty.text = Localization.tr_key("btn_difficulty_short_fmt") % df_name
	btn_difficulty.add_theme_color_override("font_color", df["color"])
	btn_leaderboard.text = Localization.tr_key("btn_leaderboard_short")
	btn_codex.text = Localization.tr_key("btn_story")
	btn_language.text = Localization.current_label()
	btn_credits.text = Localization.tr_key("btn_credits_short")

# Show "next upgrade ready" if any shop upgrade is affordable now, otherwise
# "X gold to next upgrade" using the cheapest upgrade still below max. Falls
# back to "all maxed" once every upgrade is at 10. Keeps menu motivation in
# view without adding new data sources.
func _next_goal_text() -> String:
	var cheapest: int = -1
	for key in GameData.permanent_upgrades.keys():
		var cost: int = GameData.get_upgrade_cost(key)
		if cost <= 0:
			continue
		if cheapest < 0 or cost < cheapest:
			cheapest = cost
	if cheapest < 0:
		return Localization.tr_key("menu_next_goal_maxed")
	if GameData.gold >= cheapest:
		next_goal_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35, 1.0))
		return Localization.tr_key("menu_next_goal_ready")
	next_goal_label.add_theme_color_override("font_color", Color(0.78, 0.84, 1, 1))
	return Localization.tr_key("menu_next_goal_fmt") % (cheapest - GameData.gold)

func _on_language_changed(_lang: String) -> void:
	_refresh()

func _on_play_pressed() -> void:
	Transition.change_scene("res://scenes/main/GameRoot.tscn")

func _on_character_pressed() -> void:
	Transition.change_scene("res://scenes/ui/CharacterSelect.tscn")

func _on_stage_pressed() -> void:
	Transition.change_scene("res://scenes/ui/StageSelect.tscn")

func _on_shop_pressed() -> void:
	Transition.change_scene("res://scenes/ui/ShopUI.tscn")

func _on_difficulty_pressed() -> void:
	GameData.cycle_difficulty()
	_refresh()

func _on_credits_pressed() -> void:
	Transition.change_scene("res://scenes/ui/CreditsUI.tscn")

func _on_codex_pressed() -> void:
	# Button keeps the codex variable name for layout stability, but the
	# main-menu route now opens StoryUI (which hosts a "용어집 →" link to
	# CodexUI inside it). User-facing label is "스토리".
	Transition.change_scene("res://scenes/ui/StoryUI.tscn")

func _on_leaderboard_pressed() -> void:
	if not LeaderboardManager.is_signed_in():
		LeaderboardManager.sign_in()
		return
	LeaderboardManager.show_all_leaderboards()

func _on_language_pressed() -> void:
	Localization.cycle_language()
