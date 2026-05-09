extends CanvasLayer
class_name LevelUpUI

signal upgrade_chosen(upgrade_id: String)

const WEAPON_DATA: Dictionary = {
	"Moon Dagger":  {"name_key": "weapon_moon_dagger", "desc_key": "weapon_desc_moon_dagger", "color": Color(0.5, 0.8, 1.0),  "icon": "res://assets/sprites/icon_moon_dagger.png"},
	"Spirit Orb":   {"name_key": "weapon_spirit_orb",  "desc_key": "weapon_desc_spirit_orb",  "color": Color(0.3, 0.9, 1.0),  "icon": "res://assets/sprites/icon_spirit_orb.png"},
	"Fire Wisp":    {"name_key": "weapon_fire_wisp",   "desc_key": "weapon_desc_fire_wisp",   "color": Color(1.0, 0.5, 0.15), "icon": "res://assets/sprites/icon_fire_wisp.png"},
	"Thorn Ring":   {"name_key": "weapon_thorn_ring",  "desc_key": "weapon_desc_thorn_ring",  "color": Color(0.3, 0.9, 0.3),  "icon": "res://assets/sprites/icon_thorn_ring.png"},
	"Star Needle":  {"name_key": "weapon_star_needle", "desc_key": "weapon_desc_star_needle", "color": Color(0.95, 0.9, 0.2), "icon": "res://assets/sprites/icon_star_needle.png"},
}

const PASSIVE_DATA: Dictionary = {
	"swift_boots":  {"name_key": "passive_swift_boots_name",  "desc_key": "passive_swift_boots_desc",  "color": Color(0.5, 0.85, 0.5)},
	"magnet_charm": {"name_key": "passive_magnet_charm_name", "desc_key": "passive_magnet_charm_desc", "color": Color(0.75, 0.5, 0.95)},
	"iron_heart":   {"name_key": "passive_iron_heart_name",   "desc_key": "passive_iron_heart_desc",   "color": Color(1.0, 0.35, 0.35)},
	"battle_focus": {"name_key": "passive_battle_focus_name", "desc_key": "passive_battle_focus_desc", "color": Color(0.9, 0.7, 0.2)},
	"power_core":   {"name_key": "passive_power_core_name",   "desc_key": "passive_power_core_desc",   "color": Color(1.0, 0.3, 0.65)},
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
			priority.append({
				"id": "evolve:" + w.weapon_name,
				"title": "★ EVOLVE: " + String(rule["evolved_name"]),
				"desc": String(rule["desc"]),
				"color": rule["color"],
			})

	for wname in WEAPON_DATA:
		if not wm.has_weapon(wname):
			var wd: Dictionary = WEAPON_DATA[wname]
			pool.append({
				"id": "new:" + wname,
				"title": Localization.tr_key(String(wd["name_key"]), wname),
				"desc": Localization.tr_key(String(wd["desc_key"]), ""),
				"color": wd["color"],
				"icon": wd.get("icon", ""),
			})

	for w in wm.weapons:
		if w.evolved:
			continue
		var wname: String = w.weapon_name
		if WEAPON_DATA.has(wname):
			var wd2: Dictionary = WEAPON_DATA[wname]
			pool.append({
				"id": "up:" + wname,
				"title": Localization.tr_key(String(wd2["name_key"]), wname) + "  Lv." + str(w.level + 1),
				"desc": Localization.tr_key("upgrade_desc_default", "DMG +25% / CD -12%"),
				"color": wd2["color"].lightened(0.2),
				"icon": wd2.get("icon", ""),
			})

	for pkey in PASSIVE_DATA:
		if wm.get_passive_level(pkey) < 5:
			var pd: Dictionary = PASSIVE_DATA[pkey]
			pool.append({
				"id": "passive:" + pkey,
				"title": Localization.tr_key(String(pd["name_key"]), pkey),
				"desc": Localization.tr_key(String(pd["desc_key"]), ""),
				"color": pd["color"],
			})

	pool.shuffle()
	_options = priority + pool
	_options = _options.slice(0, 3)

	var fallback := {"id": "passive:iron_heart", "title": "Iron Heart", "desc": "Max HP +20", "color": Color(1.0, 0.35, 0.35)}
	while _options.size() < 3:
		_options.append(fallback)

func _update_cards() -> void:
	for i in range(3):
		if i >= _options.size() or i >= _cards.size():
			break
		_setup_card(_cards[i], _options[i], i)

func _setup_card(card: PanelContainer, opt: Dictionary, idx: int) -> void:
	var header: ColorRect = card.get_node_or_null("VBox/Header")
	var icon_rect: TextureRect = card.get_node_or_null("VBox/Icon")
	var title_lbl: Label = card.get_node_or_null("VBox/Title")
	var desc_lbl: Label = card.get_node_or_null("VBox/Desc")
	var btn: Button = card.get_node_or_null("VBox/SelectBtn")

	if header:
		header.color = opt["color"]
	if icon_rect:
		var icon_path: String = String(opt.get("icon", ""))
		if icon_path != "":
			icon_rect.texture = load(icon_path)
			icon_rect.visible = true
		else:
			icon_rect.texture = null
			icon_rect.visible = false
	if title_lbl:
		title_lbl.text = opt["title"]
	if desc_lbl:
		desc_lbl.text = opt["desc"]
	if btn:
		btn.text = Localization.tr_key("btn_select")
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection["callable"])
		var captured_idx := idx
		btn.pressed.connect(func(): _on_card_selected(captured_idx))

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
