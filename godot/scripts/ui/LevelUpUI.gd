extends CanvasLayer
class_name LevelUpUI

signal upgrade_chosen(upgrade_id: String)

const WEAPON_DATA: Dictionary = {
	"Moon Dagger":  {"name_key": "weapon_moon_dagger", "desc_key": "weapon_desc_moon_dagger", "color": Color(0.5, 0.8, 1.0),  "icon": "res://assets/sprites/icon_moon_dagger.png",  "roles": ["tag_seek", "tag_power"]},
	"Spirit Orb":   {"name_key": "weapon_spirit_orb",  "desc_key": "weapon_desc_spirit_orb",  "color": Color(0.3, 0.9, 1.0),  "icon": "res://assets/sprites/icon_spirit_orb.png",   "roles": ["tag_melee", "tag_defense"]},
	"Fire Wisp":    {"name_key": "weapon_fire_wisp",   "desc_key": "weapon_desc_fire_wisp",   "color": Color(1.0, 0.5, 0.15), "icon": "res://assets/sprites/icon_fire_wisp.png",    "roles": ["tag_aoe", "tag_power"]},
	"Thorn Ring":   {"name_key": "weapon_thorn_ring",  "desc_key": "weapon_desc_thorn_ring",  "color": Color(0.3, 0.9, 0.3),  "icon": "res://assets/sprites/icon_thorn_ring.png",   "roles": ["tag_melee", "tag_aoe"]},
	"Star Needle":  {"name_key": "weapon_star_needle", "desc_key": "weapon_desc_star_needle", "color": Color(0.95, 0.9, 0.2), "icon": "res://assets/sprites/icon_star_needle.png",  "roles": ["tag_ranged", "tag_aoe"]},
}

const PASSIVE_DATA: Dictionary = {
	"swift_boots":  {"name_key": "passive_swift_boots_name",  "desc_key": "passive_swift_boots_desc",  "color": Color(0.5, 0.85, 0.5),  "icon": "res://assets/sprites/shop_swift.png",  "roles": ["tag_mobility"],   "per_level": "+20 SPD"},
	"magnet_charm": {"name_key": "passive_magnet_charm_name", "desc_key": "passive_magnet_charm_desc", "color": Color(0.75, 0.5, 0.95), "icon": "res://assets/sprites/shop_magnet.png", "roles": ["tag_pickup"],     "per_level": "+40 XP radius"},
	"iron_heart":   {"name_key": "passive_iron_heart_name",   "desc_key": "passive_iron_heart_desc",   "color": Color(1.0, 0.35, 0.35), "icon": "res://assets/sprites/shop_heart.png",  "roles": ["tag_survive"],    "per_level": "+20 Max HP"},
	"battle_focus": {"name_key": "passive_battle_focus_name", "desc_key": "passive_battle_focus_desc", "color": Color(0.9, 0.7, 0.2),   "icon": "res://assets/sprites/shop_focus.png",  "roles": ["tag_utility"],    "per_level": "-8% CD"},
	"power_core":   {"name_key": "passive_power_core_name",   "desc_key": "passive_power_core_desc",   "color": Color(1.0, 0.3, 0.65),  "icon": "res://assets/sprites/shop_power.png",  "roles": ["tag_power"],      "per_level": "+15% DMG"},
}

const TAG_NEW_COLOR := Color(0.4, 0.85, 1.0, 1.0)
const TAG_UP_COLOR := Color(1.0, 0.85, 0.45, 1.0)
const TAG_EVOLVE_COLOR := Color(1.0, 0.6, 0.95, 1.0)

# Phase UI-4 — AI pixel-art card assets.
# panel_card_dark is the base stone tablet (any card kind).
# glow frames overlay on top to convey rarity at a glance.
const PANEL_CARD_DARK_PATH := "res://assets/sprites/ui/panel/panel_card_dark.9.png"
const GLOW_BY_KIND := {
	"new":         "res://assets/sprites/ui/panel/frame_card_glow_blue.9.png",
	"up":          "res://assets/sprites/ui/panel/frame_card_glow_gold.9.png",
	"evolve":      "res://assets/sprites/ui/panel/frame_card_glow_purple.9.png",
	"passive_new": "res://assets/sprites/ui/panel/frame_card_glow_green.9.png",
	"passive_up":  "res://assets/sprites/ui/panel/frame_card_glow_gold.9.png",
}

var _options: Array = []
var _player: Player
var _cards: Array = []
var _pending_count: int = 0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cards = [
		$Background/VBox/Card1,
		$Background/VBox/Card2,
		$Background/VBox/Card3,
	]

func show_for_player(p: Player) -> void:
	_player = p
	_pending_count += 1
	if visible:
		return
	_show_next()

func _show_next() -> void:
	_generate_options()
	_update_cards()
	var title_lbl: Label = $Background/Title
	if title_lbl:
		title_lbl.text = Localization.tr_key("levelup_title")
	visible = true
	get_tree().paused = true
	_animate_cards_in()

func _animate_cards_in() -> void:
	# Staggered pop-in (scale + fade). We can't tween `position` because cards
	# live inside a VBoxContainer that overrides positions every layout pass —
	# tweening position causes all three to collapse to the same y. Scale and
	# modulate are visual transforms that don't fight the container.
	for i in range(_cards.size()):
		var card: PanelContainer = _cards[i]
		card.pivot_offset = card.size * 0.5
		card.modulate.a = 0.0
		card.scale = Vector2(0.85, 0.85)
		var delay := float(i) * 0.08
		var tw_fade := create_tween()
		tw_fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw_fade.tween_interval(delay)
		tw_fade.tween_property(card, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var tw_scale := create_tween()
		tw_scale.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw_scale.tween_interval(delay)
		tw_scale.tween_property(card, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _generate_options() -> void:
	var pool: Array = []
	var priority: Array = []
	var wm := _player.weapon_manager

	# Evolution opportunities (priority - shown first when available)
	for w in wm.weapons:
		if w.evolved:
			continue
		if Evolutions.can_evolve(w.weapon_name, w.level, Callable(wm, "get_passive_level")):
			var rule: Dictionary = Evolutions.RULES[w.weapon_name]
			var base_icon: String = ""
			var roles: Array = ["tag_evolve"]
			if WEAPON_DATA.has(w.weapon_name):
				base_icon = String(WEAPON_DATA[w.weapon_name].get("icon", ""))
				roles = (WEAPON_DATA[w.weapon_name].get("roles", []) as Array).duplicate()
				roles.push_front("tag_evolve")
			priority.append({
				"id": "evolve:" + w.weapon_name,
				"kind": "evolve",
				"title": String(rule["evolved_name"]),
				"desc": String(rule["desc"]),
				"color": rule["color"],
				"icon": base_icon,
				"level_line": Localization.tr_key("levelup_evolve_base_fmt") % Localization.tr_key(String(WEAPON_DATA[w.weapon_name]["name_key"]), w.weapon_name),
				"stats": Localization.tr_key("levelup_evolve_stats"),
				"roles": roles,
				"tag_text": Localization.tr_key("levelup_tag_evolve"),
				"tag_color": TAG_EVOLVE_COLOR,
			})

	for wname in WEAPON_DATA:
		if not wm.has_weapon(wname):
			var wd: Dictionary = WEAPON_DATA[wname]
			var sample := _sample_weapon_stats(wname)
			pool.append({
				"id": "new:" + wname,
				"kind": "new",
				"title": Localization.tr_key(String(wd["name_key"]), wname),
				"desc": Localization.tr_key(String(wd["desc_key"]), ""),
				"color": wd["color"],
				"icon": wd.get("icon", ""),
				"level_line": Localization.tr_key("levelup_new_weapon"),
				"stats": Localization.tr_key("levelup_stats_start_fmt") % [sample["dmg"], sample["cd"]],
				"roles": (wd.get("roles", []) as Array).duplicate(),
				"tag_text": Localization.tr_key("levelup_tag_new"),
				"tag_color": TAG_NEW_COLOR,
			})

	for w in wm.weapons:
		if w.evolved:
			continue
		var wname: String = w.weapon_name
		if WEAPON_DATA.has(wname):
			var wd2: Dictionary = WEAPON_DATA[wname]
			var current_dmg: int = w.get_damage()
			var next_dmg: int = int(int(w.base_damage * 1.25) * w.damage_multiplier)
			var current_cd: float = maxf(w.base_cooldown * w.cooldown_multiplier, 0.15)
			var next_cd: float = maxf(maxf(w.base_cooldown * 0.88, 0.2) * w.cooldown_multiplier, 0.15)
			pool.append({
				"id": "up:" + wname,
				"kind": "up",
				"title": Localization.tr_key(String(wd2["name_key"]), wname),
				"desc": Localization.tr_key(String(wd2["desc_key"]), ""),
				"color": wd2["color"].lightened(0.18),
				"icon": wd2.get("icon", ""),
				"level_line": Localization.tr_key("levelup_lv_change_fmt") % [w.level, w.level + 1],
				"stats": Localization.tr_key("levelup_stats_up_fmt") % [current_dmg, next_dmg, current_cd, next_cd],
				"roles": (wd2.get("roles", []) as Array).duplicate(),
				"tag_text": Localization.tr_key("levelup_tag_up_fmt") % (w.level + 1),
				"tag_color": TAG_UP_COLOR,
			})

	for pkey in PASSIVE_DATA:
		var p_level: int = wm.get_passive_level(pkey)
		if p_level < 5:
			var pd: Dictionary = PASSIVE_DATA[pkey]
			var is_new: bool = p_level == 0
			pool.append({
				"id": "passive:" + pkey,
				"kind": "passive_new" if is_new else "passive_up",
				"title": Localization.tr_key(String(pd["name_key"]), pkey),
				"desc": Localization.tr_key(String(pd["desc_key"]), ""),
				"color": pd["color"],
				"icon": pd.get("icon", ""),
				"level_line": (Localization.tr_key("levelup_new_passive") if is_new else (Localization.tr_key("levelup_passive_level_fmt") % [p_level, p_level + 1])),
				"stats": String(pd.get("per_level", "")),
				"roles": (pd.get("roles", []) as Array).duplicate(),
				"tag_text": (Localization.tr_key("levelup_tag_new") if is_new else (Localization.tr_key("levelup_tag_up_fmt") % (p_level + 1))),
				"tag_color": TAG_NEW_COLOR if is_new else TAG_UP_COLOR,
			})

	pool.shuffle()
	_options = priority + pool
	_options = _options.slice(0, 3)

	var fallback := {
		"id": "passive:iron_heart",
		"kind": "passive_new",
		"title": Localization.tr_key("passive_iron_heart_name", "Iron Heart"),
		"desc": Localization.tr_key("passive_iron_heart_desc", "Max HP +20"),
		"color": Color(1.0, 0.35, 0.35),
		"icon": "res://assets/sprites/shop_heart.png",
		"level_line": Localization.tr_key("levelup_new_passive"),
		"stats": "+20 Max HP",
		"roles": ["tag_survive"],
		"tag_text": Localization.tr_key("levelup_tag_new"),
		"tag_color": TAG_NEW_COLOR,
	}
	while _options.size() < 3:
		_options.append(fallback)

# Returns the "starting" damage and cooldown shown when offering a brand-new
# weapon. Pulls per-weapon base stats from a small lookup so the player sees
# concrete numbers before committing.
func _sample_weapon_stats(wname: String) -> Dictionary:
	var passive_dmg_mult: float = 1.0 + _player.weapon_manager.get_passive_level("power_core") * 0.15
	var passive_cd_mult: float = maxf(1.0 - _player.weapon_manager.get_passive_level("battle_focus") * 0.08, 0.3)
	var base := {
		"Moon Dagger": {"dmg": 12, "cd": 1.2},
		"Spirit Orb":  {"dmg": 8,  "cd": 0.35},
		"Fire Wisp":   {"dmg": 22, "cd": 2.8},
		"Thorn Ring":  {"dmg": 10, "cd": 3.5},
		"Star Needle": {"dmg": 8,  "cd": 0.75},
	}
	var b: Dictionary = base.get(wname, {"dmg": 10, "cd": 1.0})
	return {
		"dmg": int(b["dmg"] * passive_dmg_mult),
		"cd": maxf(b["cd"] * passive_cd_mult, 0.15),
	}

func _update_cards() -> void:
	for i in range(3):
		if i >= _options.size() or i >= _cards.size():
			break
		_setup_card(_cards[i], _options[i], i)

func _setup_card(card: PanelContainer, opt: Dictionary, idx: int) -> void:
	var header: ColorRect = card.get_node_or_null("VBox/Header")
	var tag_lbl: Label = card.get_node_or_null("VBox/Header/Tag")
	var icon_rect: TextureRect = card.get_node_or_null("VBox/HBox/Icon")
	var title_lbl: Label = card.get_node_or_null("VBox/HBox/TitleBox/Title")
	var level_lbl: Label = card.get_node_or_null("VBox/HBox/TitleBox/LevelLine")
	var stats_lbl: Label = card.get_node_or_null("VBox/Stats")
	var desc_lbl: Label = card.get_node_or_null("VBox/Desc")
	var tags_lbl: Label = card.get_node_or_null("VBox/Tags")
	var btn: Button = card.get_node_or_null("VBox/SelectBtn")
	var color: Color = opt["color"]
	var kind: String = String(opt.get("kind", ""))
	var captured_idx := idx

	# Card panel — prefer the AI pixel-art stone tablet (panel_card_dark.9), fall
	# back to the procedural StyleBoxFlat when the texture isn't imported yet.
	card.add_theme_stylebox_override("panel", _make_card_panel_style(color))
	# Rarity glow overlay (separate node so it doesn't fight PanelContainer
	# layout). NinePatchRect stretches the pixel-art glow to any card size.
	_apply_card_glow(card, kind)

	# Whole card is the tap target — players can tap the icon, title, desc, or button.
	# Inner children must not stop the event from reaching the panel's gui_input.
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var inner_vbox: VBoxContainer = card.get_node_or_null("VBox")
	if inner_vbox:
		inner_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_propagate_mouse_ignore(inner_vbox)
	for connection in card.gui_input.get_connections():
		card.gui_input.disconnect(connection["callable"])
	card.gui_input.connect(func(event): _on_card_gui_input(event, captured_idx))

	if header:
		header.color = color
	if tag_lbl:
		tag_lbl.text = String(opt.get("tag_text", ""))
		var tc: Color = opt.get("tag_color", Color.WHITE)
		tag_lbl.add_theme_color_override("font_color", tc.lightened(0.25))
	if icon_rect:
		var icon_path: String = String(opt.get("icon", ""))
		if icon_path != "":
			icon_rect.texture = load(icon_path)
			icon_rect.visible = true
			# Brighten + tint with weapon color so weapon icons are clearly
			# distinct from raw XP pickup icons (Kenney tile reuse — base
			# sprites are all small potions, differentiated only by hue).
			icon_rect.self_modulate = color.lightened(0.25)
		else:
			icon_rect.texture = null
			icon_rect.visible = false
	if title_lbl:
		title_lbl.text = String(opt.get("title", ""))
		title_lbl.add_theme_color_override("font_color", color.lightened(0.35))
	if level_lbl:
		var line: String = String(opt.get("level_line", ""))
		level_lbl.text = line
		level_lbl.visible = line != ""
	if stats_lbl:
		var st: String = String(opt.get("stats", ""))
		stats_lbl.text = st
		stats_lbl.visible = st != ""
	if desc_lbl:
		desc_lbl.text = String(opt.get("desc", ""))
	if tags_lbl:
		tags_lbl.text = _format_role_tags(opt.get("roles", []))
		tags_lbl.visible = tags_lbl.text != ""
	if btn:
		btn.text = "▶  " + Localization.tr_key("btn_select")
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection["callable"])
		btn.pressed.connect(func(): _on_card_selected(captured_idx))
		var btn_normal := StyleBoxFlat.new()
		btn_normal.bg_color = color
		btn_normal.set_corner_radius_all(10)
		btn_normal.set_content_margin_all(8)
		var btn_hover := StyleBoxFlat.new()
		btn_hover.bg_color = color.lightened(0.18)
		btn_hover.set_corner_radius_all(10)
		btn_hover.set_content_margin_all(8)
		var btn_press := StyleBoxFlat.new()
		btn_press.bg_color = color.darkened(0.25)
		btn_press.set_corner_radius_all(10)
		btn_press.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_press)
		btn.add_theme_stylebox_override("focus", btn_hover)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_focus_color", Color.WHITE)
		# Heavy navy outline so the white label reads against any card hue
		# (bright green / orange / pink backgrounds all happen).
		var outline_color := Color(0.05, 0.07, 0.12, 0.95)
		btn.add_theme_color_override("font_outline_color", outline_color)
		btn.add_theme_constant_override("outline_size", 6)

func _make_card_panel_style(tint: Color) -> StyleBox:
	# Texture-backed stone tablet when the asset is present.
	if ResourceLoader.exists(PANEL_CARD_DARK_PATH):
		var tex := load(PANEL_CARD_DARK_PATH)
		if tex is Texture2D:
			var sb := StyleBoxTexture.new()
			sb.texture = tex
			# 128×160 source asset; 14 px corner keeps the tablet's rounded
			# corner detail crisp at any card size.
			sb.texture_margin_left = 14
			sb.texture_margin_right = 14
			sb.texture_margin_top = 14
			sb.texture_margin_bottom = 14
			sb.content_margin_left = 12
			sb.content_margin_right = 12
			sb.content_margin_top = 12
			sb.content_margin_bottom = 12
			# Subtle rarity-color modulate so the dark stone reads slightly
			# warmer/cooler per card without overpowering the texture.
			sb.modulate_color = Color(1, 1, 1, 1).lerp(tint, 0.12)
			return sb
	# Fallback: original procedural flat panel.
	var sb_flat := StyleBoxFlat.new()
	sb_flat.bg_color = Color(tint.r * 0.16, tint.g * 0.16, tint.b * 0.20, 0.95)
	sb_flat.border_color = tint
	sb_flat.set_border_width_all(4)
	sb_flat.set_corner_radius_all(16)
	sb_flat.set_content_margin_all(10)
	sb_flat.shadow_color = Color(tint.r, tint.g, tint.b, 0.40)
	sb_flat.shadow_size = 8
	return sb_flat

func _apply_card_glow(card: PanelContainer, kind: String) -> void:
	var glow_path: String = String(GLOW_BY_KIND.get(kind, ""))
	var glow: NinePatchRect = card.get_node_or_null("CardGlow") as NinePatchRect
	if glow_path == "" or not ResourceLoader.exists(glow_path):
		if glow:
			glow.visible = false
		return
	if glow == null:
		glow = NinePatchRect.new()
		glow.name = "CardGlow"
		glow.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		# Skip the center stretch region entirely — only the corners + edges
		# of the glow get drawn. Without this the (still partially opaque)
		# asset center would overlay the card content as a solid sheet.
		glow.draw_center = false
		# 144×176 source asset; 24 px corner gives the rounded glow halo
		# room to stretch without distorting the corner curve.
		glow.set_patch_margin_all(24)
		# PanelContainer expects a single layout child; the glow as an extra
		# child with anchors=FULL_RECT just paints over the panel rect and
		# does not affect VBox layout. Z-order: drawn after the stylebox.
		card.add_child(glow)
		card.move_child(glow, card.get_child_count() - 1)
	glow.texture = load(glow_path)
	# Force WHITE so PanelContainer.modulate (alpha 0→1 fade-in) doesn't tint
	# the glow, and so it always shows the asset's native pixel color.
	glow.self_modulate = Color.WHITE
	glow.visible = true

func _propagate_mouse_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			continue
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if child.get_child_count() > 0:
			_propagate_mouse_ignore(child)

func _format_role_tags(roles: Array) -> String:
	if roles.is_empty():
		return ""
	var parts: Array = []
	for r in roles:
		var key: String = String(r)
		if key == "":
			continue
		parts.append(Localization.tr_key(key, key))
	if parts.is_empty():
		return ""
	return "· " + " · ".join(parts) + " ·"

func _on_card_gui_input(event: InputEvent, idx: int) -> void:
	# Fire on release so a stray drag-out doesn't lock in a choice. On press
	# we play a tiny scale-down so the card visibly responds to touch — the
	# whole card is the tap target, but without feedback it felt dead.
	if event is InputEventScreenTouch:
		if event.pressed:
			_animate_card_press(idx, true)
		else:
			_animate_card_press(idx, false)
			_on_card_selected(idx)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_animate_card_press(idx, true)
		else:
			_animate_card_press(idx, false)
			_on_card_selected(idx)

func _animate_card_press(idx: int, pressed: bool) -> void:
	if idx >= _cards.size():
		return
	var card: PanelContainer = _cards[idx]
	if not is_instance_valid(card):
		return
	var target: Vector2 = Vector2(0.96, 0.96) if pressed else Vector2.ONE
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(card, "scale", target, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_card_selected(idx: int) -> void:
	if idx >= _options.size():
		return
	var opt: Dictionary = _options[idx]
	upgrade_chosen.emit(opt["id"])
	_pending_count -= 1
	if _pending_count > 0:
		call_deferred("_show_next")
	else:
		visible = false
		get_tree().paused = false
