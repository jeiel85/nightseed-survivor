extends Node2D

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var game_over_label: Label = $UIRoot/GameOverLabel
@onready var game_over_button: Button = $UIRoot/RestartButton

var survival_time: float = 0.0
var is_game_over: bool = false

func _ready() -> void:
	randomize()
	enemy_spawner.setup(player)
	player.hp_changed.connect(_on_player_hp_changed)
	player.died.connect(_on_player_died)
	game_over_button.pressed.connect(_on_restart_pressed)
	game_over_label.visible = false
	game_over_button.visible = false
	_on_player_hp_changed(player.current_hp, player.max_hp)

func _process(delta: float) -> void:
	if is_game_over:
		return

	survival_time += delta
	hud.set_survival_time(survival_time)

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	hud.set_hp(current_hp, max_hp)

func _on_player_died() -> void:
	is_game_over = true
	get_tree().paused = true
	game_over_label.visible = true
	game_over_button.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
