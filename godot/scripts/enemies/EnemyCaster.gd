extends EnemyBase
class_name EnemyCaster

## Stays at a preferred distance, shoots projectiles at the player.

const PROJ_SCENE := preload("res://scenes/enemies/EnemyProjectile.tscn")

@export var min_distance: float = 220.0
@export var max_distance: float = 320.0
@export var fire_interval: float = 2.2
@export var projectile_damage: int = 9
@export var projectile_speed: float = 260.0

var _fire_timer: float = 0.0

func _ready() -> void:
	super()
	_fire_timer = randf_range(0.6, fire_interval)

func _update_velocity(delta: float) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = to_target.length()
	var dir: Vector2 = to_target.normalized() if dist > 0.001 else Vector2.RIGHT
	if dist < min_distance:
		# Too close — back away
		velocity = -dir * move_speed
	elif dist > max_distance:
		# Too far — close in
		velocity = dir * move_speed
	else:
		# In range — strafe slowly perpendicular to keep moving target hard to hit player
		var perp := dir.rotated(PI / 2.0)
		velocity = perp * move_speed * 0.5
	_fire_timer -= delta
	if _fire_timer <= 0.0 and dist <= max_distance * 1.4:
		_fire_timer = fire_interval
		_fire_at_player()

func _fire_at_player() -> void:
	if not is_instance_valid(target):
		return
	var proj := PROJ_SCENE.instantiate() as EnemyProjectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.launch(global_position.direction_to(target.global_position), projectile_damage, projectile_speed)
