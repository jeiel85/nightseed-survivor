extends Node2D
class_name EnemySpawner

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_count: int = 2
@export var max_enemies: int = 150
@export var spawn_radius: float = 700.0

var player: Node2D
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func setup(player_node: Node2D) -> void:
	player = player_node

func _on_spawn_timer_timeout() -> void:
	if not is_instance_valid(player) or enemy_scene == null:
		return

	var current_enemies := get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		return

	var available := max_enemies - current_enemies
	var count := mini(spawn_count, available)
	for _i in range(count):
		spawn_enemy()

func spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	if enemy == null:
		return

	var angle := randf_range(0.0, TAU)
	var offset := Vector2.RIGHT.rotated(angle) * spawn_radius
	enemy.global_position = player.global_position + offset
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	get_parent().add_child(enemy)
