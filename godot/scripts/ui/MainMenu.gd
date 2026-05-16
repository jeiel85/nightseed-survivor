extends Control

# Asset paths for the Phase UI-3 rework. Each may be missing on a freshly cloned
# checkout (the .import pass hasn't run yet), so every loader below falls back
# gracefully — the menu still renders, just without the new artwork.
# Hero-lineup BG (BG-04) takes precedence; falls back to the empty night sky
# (BG-01) when the lineup asset isn't present yet, and finally to the procedural
# MenuBackdrop. When the hero lineup is shown, the per-character showcase is
# hidden because the same five heroes already live inside the artwork.
const BG_MENU_HERO_LINEUP_PATH := "res://assets/sprites/ui/bg/bg_menu_hero_lineup.png"
const BG_MENU_NIGHT_SKY_PATH   := "res://assets/sprites/ui/bg/bg_menu_night_sky.png"
const ICON_GOLD_PATH           := "res://assets/sprites/ui/icon_top/icon_gold_coin.png"
const TITLE_KO_PATH            := "res://assets/logo/title_ko.png"
const TITLE_EN_PATH            := "res://assets/logo/title_en.png"
const NAV_ICON_PATHS := {
	"heroes":      "res://assets/sprites/ui/icon_nav/icon_nav_heroes.png",
	"stages":      "res://assets/sprites/ui/icon_nav/icon_nav_stages.png",
	"difficulty":  "res://assets/sprites/ui/icon_nav/icon_nav_difficulty.png",
	"shop":        "res://assets/sprites/ui/icon_nav/icon_nav_shop.png",
	"story":       "res://assets/sprites/ui/icon_nav/icon_nav_story.png",
	"leaderboard": "res://assets/sprites/ui/icon_nav/icon_nav_leaderboard.png",
}

@onready var background_image: TextureRect = $BackgroundImage
@onready var menu_backdrop: Control = $MenuBackdrop
@onready var title_image: TextureRect = $VBox/TitleImage
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var status_card: PanelContainer = $VBox/StatusCard
@onready var gold_coin_icon: TextureRect = $VBox/StatusCard/StatusVBox/GoldRow/GoldCoinIcon
@onready var gold_label: Label = $VBox/StatusCard/StatusVBox/GoldRow/GoldLabel
@onready var next_goal_label: Label = $VBox/StatusCard/StatusVBox/GoldRow/NextGoalLabel
@onready var status_label: Label = $VBox/StatusCard/StatusVBox/StatusLabel
@onready var btn_play: Button = $VBox/BtnPlay
@onready var btn_character: Button = $VBox/PrimaryRow/BtnCharacter
@onready var btn_stage: Button = $VBox/PrimaryRow/BtnStage
@onready var btn_difficulty: Button = $VBox/SecondaryRow/BtnDifficulty
@onready var btn_shop: Button = $VBox/SecondaryRow/BtnShop
@onready var btn_codex: Button = $VBox/TertiaryRow/BtnCodex
@onready var btn_leaderboard: Button = $VBox/TertiaryRow/BtnLeaderboard
@onready var btn_language: Button = $TopRightRow/BtnLanguage
@onready var btn_credits: Button = $TopRightRow/BtnCredits
@onready var character_showcase: CharacterShowcase = $CharacterShowcase

func _ready() -> void:
	AudioManager.play_bgm("menu")
	_apply_background()
	_apply_title_styles()
	_apply_button_styles()
	_apply_button_icons()
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
	# Title is now a TextureRect (pixel-art logo image, language-aware in
	# _refresh_title_texture). Subtitle keeps the system-font outline so it
	# stays readable over the BG-04 hero-lineup art.
	subtitle_label.add_theme_color_override("font_color", Color(0.76, 0.84, 1.0, 1.0))
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.043, 0.078, 0.149, 0.85))
	subtitle_label.add_theme_constant_override("outline_size", 3)

func _refresh_title_texture() -> void:
	# Pick KO logo for Korean, EN logo for everything else (en + future langs).
	var lang := "en"
	if Localization and "current_lang" in Localization:
		lang = String(Localization.current_lang)
	var path := TITLE_KO_PATH if lang == "ko" else TITLE_EN_PATH
	if ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			title_image.texture = tex
			title_image.visible = true
			return
	# Fallback: keep TitleImage hidden if textures missing — Subtitle alone
	# still labels the screen well enough for early dev.
	title_image.visible = false

func _apply_background() -> void:
	# Prefer the hero-lineup background when present; the five heroes already
	# appear in the art so the per-character showcase is hidden alongside.
	if ResourceLoader.exists(BG_MENU_HERO_LINEUP_PATH):
		var tex_lineup: Texture2D = load(BG_MENU_HERO_LINEUP_PATH)
		if tex_lineup != null:
			background_image.texture = tex_lineup
			menu_backdrop.visible = false
			if character_showcase:
				character_showcase.visible = false
			return
	if ResourceLoader.exists(BG_MENU_NIGHT_SKY_PATH):
		var tex: Texture2D = load(BG_MENU_NIGHT_SKY_PATH)
		if tex != null:
			background_image.texture = tex
			menu_backdrop.visible = false
			return
	background_image.visible = false
	menu_backdrop.visible = true

func _apply_button_styles() -> void:
	# Phase UI-3 — Texture-based Moon/Stone styles using the new 9-slice panels.
	# ButtonStyles automatically falls back to the flat StyleBox helpers when
	# the panel textures are missing, so this call site stays the single source
	# of truth for which button gets which tier.
	ButtonStyles.apply_amber_texture(btn_play)
	ButtonStyles.apply_stone_texture(btn_character,    ButtonStyles.CHARACTER)
	ButtonStyles.apply_stone_texture(btn_stage,        ButtonStyles.STAGE)
	ButtonStyles.apply_stone_texture(btn_difficulty,   ButtonStyles.DIFFICULTY)
	ButtonStyles.apply_stone_texture(btn_shop,         ButtonStyles.SHOP)
	ButtonStyles.apply_stone_texture(btn_codex,        ButtonStyles.CODEX)
	ButtonStyles.apply_stone_texture(btn_leaderboard,  ButtonStyles.LEADERBOARD)
	# Corner secondaries stay quiet — flat secondary stone, not the new texture.
	ButtonStyles.apply_stone_secondary(btn_language, ButtonStyles.LANGUAGE)
	ButtonStyles.apply_stone_secondary(btn_credits,  ButtonStyles.CREDITS)

func _apply_button_icons() -> void:
	# Phase UI-3: navigation icons sit left of each menu button label. The
	# helper silently no-ops on any missing texture so we can ship the rework
	# even if a single asset is held back.
	_set_button_icon(btn_character,   String(NAV_ICON_PATHS["heroes"]))
	_set_button_icon(btn_stage,       String(NAV_ICON_PATHS["stages"]))
	_set_button_icon(btn_difficulty,  String(NAV_ICON_PATHS["difficulty"]))
	_set_button_icon(btn_shop,        String(NAV_ICON_PATHS["shop"]))
	_set_button_icon(btn_codex,       String(NAV_ICON_PATHS["story"]))
	_set_button_icon(btn_leaderboard, String(NAV_ICON_PATHS["leaderboard"]))
	# Gold coin icon next to the gold counter — pixel-art accent in the status
	# strip so the gold number doesn't sit on a bare text label.
	if ResourceLoader.exists(ICON_GOLD_PATH):
		var coin := load(ICON_GOLD_PATH)
		if coin is Texture2D:
			gold_coin_icon.texture = coin
			gold_coin_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		else:
			gold_coin_icon.visible = false
	else:
		gold_coin_icon.visible = false

func _set_button_icon(button: Button, path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var tex := load(path)
	if not (tex is Texture2D):
		return
	button.icon = tex
	# Keep icon at its native pixel size so the icon+text group can be visually
	# centered together. expand_icon=true forces the icon to fill the button
	# height and pins it to the left edge — looks unbalanced on wide buttons.
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Modest cap so cropped icons (some came in slightly larger after auto-fit)
	# stay readable next to a 32pt label.
	button.add_theme_constant_override("icon_max_width", 44)
	button.add_theme_constant_override("h_separation", 12)
	# Lift dark silhouettes (heroes hood, watchtower, skull) so they read
	# against the dark stone texture. Mild lift only — we don't want to wash
	# out warmer icons (gold trophy, parchment).
	var lift := Color(1.18, 1.20, 1.25, 1.0)
	button.add_theme_color_override("icon_normal_color", lift)
	button.add_theme_color_override("icon_hover_color", lift)
	button.add_theme_color_override("icon_pressed_color", lift)
	button.add_theme_color_override("icon_focus_color", lift)
	button.add_theme_color_override("icon_disabled_color", Color(0.7, 0.7, 0.78, 0.85))

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
	_refresh_title_texture()
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
