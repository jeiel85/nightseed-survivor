extends Node2D
class_name EnemySpawner

signal enemy_killed(xp: int, gold: int, pos: Vector2)

@export var max_enemies: int = 200
@export var spawn_radius: float = 750.0

var player: Node2D
var _enemy_pool: Array = []
var _spawn_count: int = 2

@onready var _timer: Timer = $SpawnTimer

func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = 1.5
	_timer.start()

func setup(p: Node2D) -> void:
	player = p

func set_wave(pool: Array, interval: float, count: int) -> void:
	_enemy_pool = pool
	_spawn_count = count
	if abs(_timer.wait_time - interval) > 0.05:
		_timer.stop()
		_timer.wait_time = interval
		_timer.start()

func spawn_specific(scene: PackedScene) -> void:
	if scene == null or not is_instance_valid(player):
		return
	_do_spawn(scene)

func _on_timer_timeout() -> void:
	if _enemy_pool.is_empty() or not is_instance_valid(player):
		return
	var current := get_tree().get_nodes_in_group("enemies").size()
	if current >= max_enemies:
		return
	var available := max_enemies - current
	var count := mini(_spawn_count, available)
	for _i in range(count):
		var scene: PackedScene = _enemy_pool[randi() % _enemy_pool.size()]
		_do_spawn(scene)

func _do_spawn(scene: PackedScene) -> void:
	var enemy := scene.instantiate()
	var angle := randf_range(0.0, TAU)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_radius
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	if enemy.has_signal("died"):
		enemy.died.connect(func(xp: int, gold: int, pos: Vector2):
			enemy_killed.emit(xp, gold, pos)
		)
	get_parent().add_child(enemy)
