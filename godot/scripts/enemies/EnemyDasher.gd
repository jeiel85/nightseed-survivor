extends EnemyBase
class_name EnemyDasher

## Telegraphs then dashes. Forces player to dodge or break line of sight.

enum State { TRACK, TELEGRAPH, DASH, RECOVER }

@export var dash_interval: float = 4.0
@export var telegraph_time: float = 0.55
@export var dash_time: float = 0.35
@export var recover_time: float = 0.9
@export var dash_speed_mult: float = 3.5
@export var telegraph_color: Color = Color(2.5, 1.6, 0.5)

var _state: int = State.TRACK
var _state_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO
var _base_speed: float = 0.0

func _ready() -> void:
	super()
	_base_speed = move_speed
	_state_timer = randf_range(1.5, dash_interval)

func _update_velocity(delta: float) -> void:
	_state_timer -= delta
	match _state:
		State.TRACK:
			move_speed = _base_speed
			var dir := global_position.direction_to(target.global_position)
			velocity = dir * move_speed
			if _state_timer <= 0.0:
				_state = State.TELEGRAPH
				_state_timer = telegraph_time
				if is_instance_valid(visual_sprite):
					visual_sprite.modulate = telegraph_color
		State.TELEGRAPH:
			velocity = velocity.lerp(Vector2.ZERO, 0.3)
			if _state_timer <= 0.0:
				_state = State.DASH
				_state_timer = dash_time
				_dash_dir = global_position.direction_to(target.global_position)
				if is_instance_valid(visual_sprite):
					visual_sprite.modulate = Color.WHITE
		State.DASH:
			velocity = _dash_dir * (_base_speed * dash_speed_mult)
			if _state_timer <= 0.0:
				_state = State.RECOVER
				_state_timer = recover_time
		State.RECOVER:
			velocity = velocity.lerp(Vector2.ZERO, 0.2)
			if _state_timer <= 0.0:
				_state = State.TRACK
				_state_timer = dash_interval

func _update_flash(delta: float) -> void:
	# Avoid the base flash from clobbering our telegraph color
	if _state == State.TELEGRAPH:
		_flash_timer = 0.0
		return
	super(delta)
