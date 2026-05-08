extends Node2D

const TOTAL_TIME: float = 600.0

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
var _is_game_over: bool = false
var _is_victory: bool = false

func _ready() -> void:
	randomize()
	enemy_spawner.setup(player)
	wave_manager.setup(enemy_spawner)

	player.hp_changed.connect(hud.set_hp)
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
	hud.set_time(TOTAL_TIME)
	hud.set_level(1)
	hud.set_kills(0)
	hud.set_gold(0)

func _process(delta: float) -> void:
	if _is_game_over or _is_victory:
		return
	_survival_time += delta
	wave_manager.update(delta)
	hud.set_time(TOTAL_TIME - _survival_time)
	if _survival_time >= TOTAL_TIME:
		_on_victory()

func _on_player_xp_changed(current: int, needed: int) -> void:
	hud.set_xp(current, needed)

func _on_player_leveled_up(level: int) -> void:
	hud.set_level(level)
	level_up_ui.show_for_player(player)

func _on_enemy_killed(xp: int, gold: int, pos: Vector2) -> void:
	player.add_kill()
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
	result_panel.visible = true
	if victory:
		result_title.text = "VICTORY!"
		result_title.modulate = Color(0.95, 0.9, 0.2)
	else:
		result_title.text = "GAME OVER"
		result_title.modulate = Color(1.0, 0.3, 0.3)
	var tm := int(_survival_time)
	result_stats.text = "Survived:  %d:%02d\nKills:  %d\nGold earned:  %d" % [
		tm / 60, tm % 60, player.kill_count, player.session_gold
	]
	btn_restart.text = "Play Again" if victory else "Retry"
	GameData.add_gold(player.session_gold)

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

func _add_weapon(wname: String) -> void:
	var w: WeaponBase = null
	match wname:
		"Spirit Orb":  w = SpiritOrb.new()
		"Fire Wisp":   w = FireWisp.new()
		"Thorn Ring":  w = ThornRing.new()
		"Star Needle": w = StarNeedle.new()
	if w:
		player.weapon_manager.add_weapon(w)
