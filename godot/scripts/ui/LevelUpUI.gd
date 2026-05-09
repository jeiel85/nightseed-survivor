extends CanvasLayer
class_name LevelUpUI

signal upgrade_chosen(upgrade_id: String)

const WEAPON_DATA: Dictionary = {
	"Moon Dagger":  {"desc": "Auto-fires at nearest enemy", "color": Color(0.5, 0.8, 1.0),  "icon": "res://assets/sprites/icon_moon_dagger.png"},
	"Spirit Orb":   {"desc": "Orbiting damage orbs",        "color": Color(0.3, 0.9, 1.0),  "icon": "res://assets/sprites/icon_spirit_orb.png"},
	"Fire Wisp":    {"desc": "Random area explosions",      "color": Color(1.0, 0.5, 0.15), "icon": "res://assets/sprites/icon_fire_wisp.png"},
	"Thorn Ring":   {"desc": "Burst of radial spikes",      "color": Color(0.3, 0.9, 0.3),  "icon": "res://assets/sprites/icon_thorn_ring.png"},
	"Star Needle":  {"desc": "Spread needle volley",        "color": Color(0.95, 0.9, 0.2), "icon": "res://assets/sprites/icon_star_needle.png"},
}

const PASSIVE_DATA: Dictionary = {
	"swift_boots":  {"name": "Swift Boots",  "desc": "Move speed +20",      "color": Color(0.5, 0.85, 0.5)},
	"magnet_charm": {"name": "Magnet Charm", "desc": "XP pickup range +40", "color": Color(0.75, 0.5, 0.95)},
	"iron_heart":   {"name": "Iron Heart",   "desc": "Max HP +20",          "color": Color(1.0, 0.35, 0.35)},
	"battle_focus": {"name": "Battle Focus", "desc": "All cooldowns -8%",   "color": Color(0.9, 0.7, 0.2)},
	"power_core":   {"name": "Power Core",   "desc": "All damage +15%",     "color": Color(1.0, 0.3, 0.65)},
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
			pool.append({
				"id": "new:" + wname,
				"title": wname,
				"desc": WEAPON_DATA[wname]["desc"],
				"color": WEAPON_DATA[wname]["color"],
				"icon": WEAPON_DATA[wname].get("icon", ""),
			})

	for w in wm.weapons:
		if w.evolved:
			continue
		var wname: String = w.weapon_name
		if WEAPON_DATA.has(wname):
			pool.append({
				"id": "up:" + wname,
				"title": wname + "  Lv." + str(w.level + 1),
				"desc": "DMG +25% / CD -12%",
				"color": WEAPON_DATA[wname]["color"].lightened(0.2),
				"icon": WEAPON_DATA[wname].get("icon", ""),
			})

	for pkey in PASSIVE_DATA:
		if wm.get_passive_level(pkey) < 5:
			var pd: Dictionary = PASSIVE_DATA[pkey]
			pool.append({
				"id": "passive:" + pkey,
				"title": pd["name"],
				"desc": pd["desc"],
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
