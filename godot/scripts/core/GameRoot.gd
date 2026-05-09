extends Node2D

const XP_GEM_SCENE := preload("res://scenes/pickups/XPGem.tscn")
const GOLD_COIN_SCENE := preload("res://scenes/pickups/GoldCoin.tscn")

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var wave_manager: WaveManager = $WaveManager
@onready var level_up_ui: LevelUpUI = $LevelUpUI
@onready var result_panel: CanvasLayer = $ResultPanel
@onready var result_title: Label = $ResultPanel/Panel/VBox/Title
@onready var result_stats: Label = $ResultPanel/Panel/VBox/Stats
@onready var btn_restart: Button = $ResultPanel/Panel/VBox/BtnRestart
@onready var btn_menu: Button = $ResultPanel/Panel/VBox/BtnMenu

var _survival_time: float = 0.0
var _total_time: float = 600.0
var _is_game_over: bool = false
var _is_victory: bool = false

var _run_damage_taken_at_lv5: bool = false
var _run_lv5_locked: bool = false
var _run_evolved: bool = false
var _run_boss_killed: bool = false
var _last_seen_hp: int = -1
var _newly_unlocked_achievements: Array = []

func _ready() -> void:
	randomize()
	enemy_spawner.setup(player)
	wave_manager.setup(enemy_spawner, GameData.selected_stage)
	_total_time = wave_manager.get_total_time()

	player.hp_changed.connect(hud.set_hp)
	player.hp_changed.connect(_on_hp_changed_track)
	player.xp_changed.connect(_on_player_xp_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	player.gold_changed.connect(hud.set_gold)
	player.kill_count_changed.connect(hud.set_kills)
	player.died.connect(_on_player_died)

	enemy_spawner.enemy_killed.connect(_on_enemy_killed)
	level_up_ui.upgrade_chosen.connect(_on_upgrade_chosen)

	btn_restart.pressed.connect(_on_restart_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)

	result_panel.visible = false

	hud.set_hp(player.current_hp, player.max_hp)
	hud.set_time(_total_time)
	hud.set_level(1)
	hud.set_kills(0)
	hud.set_gold(0)

func _process(delta: float) -> void:
	if _is_game_over or _is_victory:
		return
	_survival_time += delta
	wave_manager.update(delta)
	hud.set_time(_total_time - _survival_time)
	if _survival_time >= _total_time:
		_on_victory()

func _on_player_xp_changed(current: int, needed: int) -> void:
	hud.set_xp(current, needed)

func _on_player_leveled_up(level: int) -> void:
	hud.set_level(level)
	level_up_ui.show_for_player(player)
	AudioManager.play("level_up", -4.0)
	if level == 5 and not _run_damage_taken_at_lv5:
		_run_lv5_locked = true
		_try_unlock("untouchable")
	elif level == 5:
		_run_lv5_locked = true
	if level == 10 and _survival_time < 180.0:
		_try_unlock("speed_runner")
	if level >= 20:
		_try_unlock("completionist")

func _on_hp_changed_track(current: int, _max_val: int) -> void:
	if _last_seen_hp >= 0 and current < _last_seen_hp and not _run_lv5_locked:
		_run_damage_taken_at_lv5 = true
	_last_seen_hp = current

func _try_unlock(key: String) -> void:
	if GameData.try_unlock_achievement(key):
		_newly_unlocked_achievements.append(key)

func _on_enemy_killed(xp: int, gold: int, pos: Vector2) -> void:
	player.add_kill()
	if xp >= 100:
		_run_boss_killed = true
		_try_unlock("boss_slayer")
	var gem := XP_GEM_SCENE.instantiate() as XPGem
	gem.xp_value = xp
	gem.global_position = pos
	add_child(gem)
	if gold > 0:
		var coin := GOLD_COIN_SCENE.instantiate() as GoldCoin
		coin.gold_value = gold
		coin.global_position = pos + Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		add_child(coin)

func _on_player_died() -> void:
	_is_game_over = true
	await get_tree().create_timer(0.5).timeout
	_show_result(false)

func _on_victory() -> void:
	_is_victory = true
	_show_result(true)

func _show_result(victory: bool) -> void:
	get_tree().paused = true
	if victory:
		_try_unlock("first_survivor")
		if GameData.difficulty != "normal":
			_try_unlock("hard_mode_clear")
	if player.kill_count >= 200:
		_try_unlock("killer_instinct")
	if player.session_gold >= 500:
		_try_unlock("wealthy")
	if player.weapon_manager.weapons.size() >= 4:
		_try_unlock("combo_master")
	GameData.add_gold(player.session_gold)
	LeaderboardManager.submit_run(
		GameData.selected_stage,
		player.kill_count,
		player.session_gold,
		int(_survival_time),
		GameData.difficulty,
	)
	result_panel.visible = true
	if victory:
		result_title.text = Localization.tr_key("result_victory")
		result_title.modulate = Color(0.95, 0.9, 0.2)
		AudioManager.play("victory", 0.0)
	else:
		result_title.text = Localization.tr_key("result_gameover")
		result_title.modulate = Color(1.0, 0.3, 0.3)
		AudioManager.play("defeat", 0.0)
	var tm := int(_survival_time)
	var lines: Array = [
		Localization.tr_key("result_survived_fmt") % [tm / 60, tm % 60],
		Localization.tr_key("result_kills_fmt") % player.kill_count,
		Localization.tr_key("result_gold_fmt") % player.session_gold,
	]
	if not _newly_unlocked_achievements.is_empty():
		lines.append("")
		lines.append(Localization.tr_key("result_new_ach"))
		for key in _newly_unlocked_achievements:
			var ach_name: String = Achievements.display_name(key)
			var ach_gold: int = int(Achievements.DATA[key]["gold"])
			lines.append(Localization.tr_key("result_ach_line") % [ach_name, ach_gold])
	result_stats.text = "\n".join(lines)
	btn_restart.text = Localization.tr_key("btn_play_again") if victory else Localization.tr_key("btn_retry")
	btn_menu.text = Localization.tr_key("btn_main_menu")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_upgrade_chosen(upgrade_id: String) -> void:
	if upgrade_id.begins_with("new:"):
		_add_weapon(upgrade_id.substr(4))
	elif upgrade_id.begins_with("up:"):
		player.weapon_manager.upgrade_weapon(upgrade_id.substr(3))
	elif upgrade_id.begins_with("passive:"):
		player.weapon_manager.apply_passive(upgrade_id.substr(8))
	elif upgrade_id.begins_with("evolve:"):
		player.weapon_manager.evolve_weapon(upgrade_id.substr(7))
		_run_evolved = true
		_try_unlock("evolver")
		AudioManager.play("evolve", 0.0)

func _add_weapon(wname: String) -> void:
	var w: WeaponBase = null
	match wname:
		"Spirit Orb":  w = SpiritOrb.new()
		"Fire Wisp":   w = FireWisp.new()
		"Thorn Ring":  w = ThornRing.new()
		"Star Needle": w = StarNeedle.new()
	if w:
		player.weapon_manager.add_weapon(w)
