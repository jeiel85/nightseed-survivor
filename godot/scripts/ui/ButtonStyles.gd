extends RefCounted
class_name ButtonStyles

# Menu/result button color palette — applied at runtime via add_theme_stylebox_override.
# Tuned for the dark game background; each entry is the "normal" tone, hover lightens, pressed darkens.
const PLAY        := Color(0.86, 0.55, 0.20)   # warm amber — legacy CTA tone (kept for back-compat)
const CHARACTER   := Color(0.20, 0.55, 0.72)   # teal
const STAGE       := Color(0.58, 0.40, 0.22)   # earth/brass
const SHOP        := Color(0.22, 0.62, 0.36)   # green
const DIFFICULTY  := Color(0.52, 0.30, 0.72)   # violet
const LEADERBOARD := Color(0.78, 0.62, 0.20)   # gold (★)
const CODEX       := Color(0.30, 0.36, 0.72)   # indigo
const LANGUAGE    := Color(0.34, 0.42, 0.52)   # slate
const CREDITS     := Color(0.26, 0.26, 0.34)   # graphite
const VICTORY     := Color(0.86, 0.55, 0.20)   # amber (=PLAY)
const DEFEAT      := Color(0.82, 0.32, 0.32)   # red
const NEUTRAL     := Color(0.34, 0.42, 0.52)   # slate (back-to-menu, secondary)
const REWARD_AD   := Color(0.48, 0.30, 0.72)   # violet — rewarded-ad CTA

# Nightseed UI art direction (docs/UI_ART_DIRECTION_ROADMAP.md §2):
# - Moon CTA: 창백한 달빛 배경 + 짙은 남색 텍스트 (PLAY 전용, 가장 강한 액션)
# - Stone primary: 어두운 청회색 패널 + 강조색 테두리 (캐릭터/스테이지/상점 등 주요 메뉴)
# - Stone secondary: 더 어두운 패널 + 얇은 테두리 (스토리/리더보드/언어/크레딧)
const MOON_PRIMARY      := Color(0.867, 0.922, 1.000)  # #DDEBFF 창백한 달빛
const MOON_TEXT         := Color(0.043, 0.078, 0.149)  # #0B1426 짙은 남색 텍스트
const MOON_BORDER       := Color(0.560, 0.660, 0.800)  # #8EA8CC 달빛 테두리
const STONE_PRIMARY     := Color(0.078, 0.094, 0.137)  # #141823 어두운 청회색
const STONE_SECONDARY   := Color(0.055, 0.066, 0.094)  # #0E1018 더 어두운 청회색
const STONE_TEXT        := Color(0.910, 0.940, 1.000)  # 거의 흰색 (살짝 푸른 기운)
const STONE_BORDER      := Color(0.380, 0.450, 0.580)  # 흐린 달빛 테두리

static func apply(button: Button, base: Color) -> void:
	button.add_theme_stylebox_override("normal",   _box(base, 0.0))
	button.add_theme_stylebox_override("hover",    _box(base, 0.16))
	button.add_theme_stylebox_override("pressed",  _box(base, -0.20))
	button.add_theme_stylebox_override("focus",    _focus_box(base))
	button.add_theme_stylebox_override("disabled", _box(base.darkened(0.45), 0.0))
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.95))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))

# Moon CTA — pale moonlight fill, dark navy text. Single strongest action on a screen.
static func apply_moon(button: Button) -> void:
	button.add_theme_stylebox_override("normal",   _moon_box(0.0))
	button.add_theme_stylebox_override("hover",    _moon_box(0.07))
	button.add_theme_stylebox_override("pressed",  _moon_box(-0.10))
	button.add_theme_stylebox_override("focus",    _moon_focus_box())
	button.add_theme_stylebox_override("disabled", _moon_disabled_box())
	button.add_theme_color_override("font_color", MOON_TEXT)
	button.add_theme_color_override("font_hover_color", MOON_TEXT)
	button.add_theme_color_override("font_pressed_color", MOON_TEXT.lightened(0.18))
	button.add_theme_color_override("font_focus_color", MOON_TEXT)

# Stone primary — dark stone fill with an accent border (uses the legacy CHARACTER/STAGE/… hue).
# `accent` is the per-button hue used for the border and a subtle hover tint.
static func apply_stone(button: Button, accent: Color) -> void:
	button.add_theme_stylebox_override("normal",   _stone_box(STONE_PRIMARY, accent, 0.0, true))
	button.add_theme_stylebox_override("hover",    _stone_box(STONE_PRIMARY, accent, 0.10, true))
	button.add_theme_stylebox_override("pressed",  _stone_box(STONE_PRIMARY, accent, -0.10, true))
	button.add_theme_stylebox_override("focus",    _stone_focus_box(accent, true))
	button.add_theme_stylebox_override("disabled", _stone_box(STONE_PRIMARY.darkened(0.30), accent.darkened(0.45), 0.0, true))
	button.add_theme_color_override("font_color", STONE_TEXT)
	button.add_theme_color_override("font_hover_color", STONE_TEXT)
	button.add_theme_color_override("font_pressed_color", STONE_TEXT.darkened(0.10))
	button.add_theme_color_override("font_focus_color", STONE_TEXT)

# Stone secondary — quieter recessed panel for story/leaderboard/language/credits.
static func apply_stone_secondary(button: Button, accent: Color = STONE_BORDER) -> void:
	button.add_theme_stylebox_override("normal",   _stone_box(STONE_SECONDARY, accent, 0.0, false))
	button.add_theme_stylebox_override("hover",    _stone_box(STONE_SECONDARY, accent, 0.08, false))
	button.add_theme_stylebox_override("pressed",  _stone_box(STONE_SECONDARY, accent, -0.10, false))
	button.add_theme_stylebox_override("focus",    _stone_focus_box(accent, false))
	button.add_theme_stylebox_override("disabled", _stone_box(STONE_SECONDARY.darkened(0.30), accent.darkened(0.45), 0.0, false))
	button.add_theme_color_override("font_color", STONE_TEXT.darkened(0.05))
	button.add_theme_color_override("font_hover_color", STONE_TEXT)
	button.add_theme_color_override("font_pressed_color", STONE_TEXT.darkened(0.15))
	button.add_theme_color_override("font_focus_color", STONE_TEXT)

static func _box(base: Color, shift: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var c := base
	if shift > 0.0:
		c = c.lightened(shift)
	elif shift < 0.0:
		c = c.darkened(-shift)
	sb.bg_color = c
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	sb.border_color = base.lightened(0.35)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

static func _focus_box(base: Color) -> StyleBoxFlat:
	var sb := _box(base, 0.0)
	sb.border_color = Color(1, 1, 1, 0.85)
	sb.set_border_width_all(3)
	return sb

static func _moon_box(shift: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var c := MOON_PRIMARY
	if shift > 0.0:
		c = c.lightened(shift)
	elif shift < 0.0:
		c = c.darkened(-shift)
	sb.bg_color = c
	sb.set_corner_radius_all(6)
	sb.set_border_width_all(3)
	sb.border_color = MOON_BORDER
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	# Soft outer moon glow (visible against the dark menu backdrop)
	sb.shadow_color = Color(MOON_PRIMARY.r, MOON_PRIMARY.g, MOON_PRIMARY.b, 0.18)
	sb.shadow_size = 8
	return sb

static func _moon_focus_box() -> StyleBoxFlat:
	var sb := _moon_box(0.0)
	sb.border_color = Color(1, 1, 1, 0.95)
	sb.set_border_width_all(4)
	return sb

static func _moon_disabled_box() -> StyleBoxFlat:
	var sb := _moon_box(0.0)
	sb.bg_color = MOON_PRIMARY.darkened(0.45)
	sb.border_color = MOON_BORDER.darkened(0.40)
	sb.shadow_color = Color(0, 0, 0, 0)
	return sb

# Stone box — primary uses an emphasized top border ("rune line"), secondary uses a thin frame.
static func _stone_box(base: Color, accent: Color, shift: float, primary: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	var c := base
	if shift > 0.0:
		c = c.lightened(shift)
		# Bleed a hint of the accent hue on hover.
		c = c.lerp(accent, 0.08)
	elif shift < 0.0:
		c = c.darkened(-shift)
	sb.bg_color = c
	sb.set_corner_radius_all(5 if primary else 4)
	if primary:
		sb.border_width_top = 3
		sb.border_width_bottom = 2
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_color = accent.lightened(0.10)
	else:
		sb.set_border_width_all(2)
		sb.border_color = accent.darkened(0.10)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 8 if primary else 6
	sb.content_margin_bottom = 8 if primary else 6
	return sb

static func _stone_focus_box(accent: Color, primary: bool) -> StyleBoxFlat:
	var sb := _stone_box(STONE_PRIMARY if primary else STONE_SECONDARY, accent, 0.0, primary)
	sb.border_color = Color(1, 1, 1, 0.85)
	sb.set_border_width_all(3)
	return sb

# ------------------------------------------------------------
# Texture-based styles (Phase UI-3) — uses the AI-generated 9-slice panels
# in res://assets/sprites/ui/panel/. Falls back to the flat StyleBox helpers
# above when the texture is missing so the menu still renders during asset
# bring-up. docs/UI_REDESIGN_SPEC.md §3.3 has the 9-slice margin spec.
# ------------------------------------------------------------

const PANEL_STONE_BLUE_PATH := "res://assets/sprites/ui/panel/panel_stone_blue.9.png"
const PANEL_CTA_AMBER_PATH  := "res://assets/sprites/ui/panel/panel_cta_amber.9.png"

# 9-slice margins are in TEXTURE pixels, not source-render pixels. Our PNGs are
# downsampled to native button sizes (stone 96×96, amber 192×64), so margins
# must leave a non-zero center region to stretch.
const STONE_NINE_MARGIN := 16   # 96×96 texture, 16px corner → 64×64 center stretches
const AMBER_NINE_L_R    := 24   # 192×64 texture, 24px caps → 144×40 center stretches
const AMBER_NINE_T_B    := 12

# CTA text uses the same dark navy as the Moon button — high contrast on amber.
const CTA_MOON_TEXT_COLOR := Color(0.043, 0.078, 0.149)

# Texture-backed stone primary button. Same hover/pressed/focus contract as
# apply_stone(): we tint the texture via modulate to convey state without
# swapping textures, and keep the per-button accent color on the focus ring.
static func apply_stone_texture(button: Button, accent: Color = MOON_BORDER) -> void:
	var tex := _try_load_texture(PANEL_STONE_BLUE_PATH)
	if tex == null:
		apply_stone(button, accent)
		return
	button.add_theme_stylebox_override("normal",   _stone_tex_box(tex, Color(1, 1, 1, 1)))
	button.add_theme_stylebox_override("hover",    _stone_tex_box(tex, Color(1.10, 1.10, 1.12, 1)))
	button.add_theme_stylebox_override("pressed",  _stone_tex_box(tex, Color(0.82, 0.84, 0.92, 1)))
	button.add_theme_stylebox_override("focus",    _stone_tex_focus(tex, accent))
	button.add_theme_stylebox_override("disabled", _stone_tex_box(tex, Color(0.55, 0.58, 0.65, 0.85)))
	button.add_theme_color_override("font_color", STONE_TEXT)
	button.add_theme_color_override("font_hover_color", STONE_TEXT)
	button.add_theme_color_override("font_pressed_color", STONE_TEXT.darkened(0.10))
	button.add_theme_color_override("font_focus_color", STONE_TEXT)

# Texture-backed amber CTA button. PLAY-tier action only (one per screen).
static func apply_amber_texture(button: Button) -> void:
	var tex := _try_load_texture(PANEL_CTA_AMBER_PATH)
	if tex == null:
		apply(button, PLAY)
		return
	button.add_theme_stylebox_override("normal",   _amber_tex_box(tex, Color(1, 1, 1, 1)))
	button.add_theme_stylebox_override("hover",    _amber_tex_box(tex, Color(1.10, 1.08, 1.02, 1)))
	button.add_theme_stylebox_override("pressed",  _amber_tex_box(tex, Color(0.86, 0.78, 0.62, 1)))
	button.add_theme_stylebox_override("focus",    _amber_tex_focus(tex))
	button.add_theme_stylebox_override("disabled", _amber_tex_box(tex, Color(0.55, 0.50, 0.42, 0.85)))
	button.add_theme_color_override("font_color", CTA_MOON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", CTA_MOON_TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", CTA_MOON_TEXT_COLOR.lightened(0.10))
	button.add_theme_color_override("font_focus_color", CTA_MOON_TEXT_COLOR)

static func _try_load_texture(path: String) -> Texture2D:
	# ResourceLoader.exists() lets us bring up assets gradually without scene
	# loads failing on machines that haven't run the editor import pass yet.
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is Texture2D:
		return res
	return null

static func _stone_tex_box(tex: Texture2D, modulate: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.modulate_color = modulate
	sb.texture_margin_left = STONE_NINE_MARGIN
	sb.texture_margin_right = STONE_NINE_MARGIN
	sb.texture_margin_top = STONE_NINE_MARGIN
	sb.texture_margin_bottom = STONE_NINE_MARGIN
	# Tight horizontal content margins so localized labels (HEROES, ★ RANK)
	# fit inside the narrow primary/secondary row buttons.
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

static func _stone_tex_focus(tex: Texture2D, accent: Color) -> StyleBoxTexture:
	# Focus state keeps the texture but lifts modulate toward the accent hue
	# so keyboard/controller focus is visible without breaking the stone look.
	var sb := _stone_tex_box(tex, Color(1, 1, 1, 1).lerp(accent, 0.25))
	return sb

static func _amber_tex_box(tex: Texture2D, modulate: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.modulate_color = modulate
	sb.texture_margin_left = AMBER_NINE_L_R
	sb.texture_margin_right = AMBER_NINE_L_R
	sb.texture_margin_top = AMBER_NINE_T_B
	sb.texture_margin_bottom = AMBER_NINE_T_B
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	return sb

static func _amber_tex_focus(tex: Texture2D) -> StyleBoxTexture:
	return _amber_tex_box(tex, Color(1.06, 1.04, 0.96, 1))
