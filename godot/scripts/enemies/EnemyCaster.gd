extends EnemyBase
class_name EnemyCaster

## Stays at a preferred distance, telegraphs, then shoots a projectile at
## the player. The 0.45s aim phase shows a magenta line from the caster
## toward the player's *current* position when the windup started, so a
## moving target can sidestep the shot if they read the cue.

const PROJ_SCENE := preload("res://scenes/enemies/EnemyProjectile.tscn")

enum State { IDLE, AIM, FIRE_RECOVER }

@export var min_distance: float = 220.0
@export var max_distance: float = 320.0
@export var fire_interval: float = 2.2
@export var aim_time: float = 0.45
@export var projectile_damage: int = 9
@export var projectile_speed: float = 260.0
@export var aim_color: Color = Color(1.0, 0.45, 1.0, 0.75)
@export var aim_telegraph_tint: Color = Color(1.8, 0.7, 1.8)

var _state: int = State.IDLE
var _fire_timer: float = 0.0
var _aim_timer: float = 0.0
var _aim_dir: Vector2 = Vector2.RIGHT
var _aim_line: Line2D = null

func _ready() -> void:
	super()
	_fire_timer = randf_range(0.6, fire_interval)
	_make_aim_line()

func _make_aim_line() -> void:
	var visual: Node = $Visual
	if visual == null:
		return
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = aim_color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
	line.visible = false
	line.z_index = -1
	visual.add_child(line)
	_aim_line = line

func _update_velocity(delta: float) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = to_target.length()
	var dir: Vector2 = to_target.normalized() if dist > 0.001 else Vector2.RIGHT
	match _state:
		State.IDLE:
			_update_kite_velocity(dir, dist)
			_fire_timer -= delta
			if _fire_timer <= 0.0 and dist <= max_distance * 1.4:
				_enter_aim(dir)
		State.AIM:
			# Slow drift while aiming, but keep some momentum so the kiting
			# feel doesn't snap to zero.
			velocity = velocity.lerp(Vector2.ZERO, 0.2)
			_aim_timer -= delta
			_update_aim_line()
			if _aim_timer <= 0.0:
				_fire_at(_aim_dir)
				_state = State.FIRE_RECOVER
				_fire_timer = fire_interval
				_hide_aim_line()
				if is_instance_valid(visual_sprite):
					visual_sprite.modulate = Color.WHITE
		State.FIRE_RECOVER:
			_update_kite_velocity(dir, dist)
			_fire_timer -= delta
			if _fire_timer <= 0.0:
				_state = State.IDLE
				_fire_timer = randf_range(fire_interval * 0.6, fire_interval)

func _update_kite_velocity(dir: Vector2, dist: float) -> void:
	if dist < min_distance:
		velocity = -dir * move_speed
	elif dist > max_distance:
		velocity = dir * move_speed
	else:
		var perp := dir.rotated(PI / 2.0)
		velocity = perp * move_speed * 0.5

func _enter_aim(initial_dir: Vector2) -> void:
	_state = State.AIM
	_aim_timer = aim_time
	_aim_dir = initial_dir
	if is_instance_valid(visual_sprite):
		visual_sprite.modulate = aim_telegraph_tint
	_show_aim_line()

func _show_aim_line() -> void:
	if not is_instance_valid(_aim_line):
		return
	_aim_line.visible = true
	_aim_line.modulate.a = 0.0
	var tw := _aim_line.create_tween()
	tw.tween_property(_aim_line, "modulate:a", 1.0, 0.10)

func _hide_aim_line() -> void:
	if is_instance_valid(_aim_line):
		_aim_line.visible = false

func _update_aim_line() -> void:
	if not is_instance_valid(_aim_line) or not is_instance_valid(target):
		return
	# Refresh the lock direction so player movement during the windup is
	# visible — but we sample the latest direction so the actual shot still
	# resolves from where the target ends up at fire time.
	_aim_dir = global_position.direction_to(target.global_position)
	var pulse: float = 0.6 + 0.4 * (1.0 - (_aim_timer / aim_time))
	_aim_line.points = PackedVector2Array([Vector2.ZERO, _aim_dir * (320.0 * pulse)])

func _fire_at(dir: Vector2) -> void:
	if not is_instance_valid(target):
		return
	var proj := PROJ_SCENE.instantiate() as EnemyProjectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.launch(dir, projectile_damage, projectile_speed)

func _die() -> void:
	_hide_aim_line()
	super()

func _update_flash(delta: float) -> void:
	# Don't let damage flash overwrite the aim tint.
	if _state == State.AIM:
		_flash_timer = 0.0
		return
	super(delta)
