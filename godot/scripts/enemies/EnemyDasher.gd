extends EnemyBase
class_name EnemyDasher

## Telegraphs then dashes. Forces player to dodge or break line of sight.
## During telegraph we (a) tint the sprite and (b) draw a charge line from
## the dasher toward the player so the dodge cue is readable even when the
## sprite tint is washed out by other VFX.

enum State { TRACK, TELEGRAPH, DASH, RECOVER }

@export var dash_interval: float = 4.0
@export var telegraph_time: float = 0.55
@export var dash_time: float = 0.35
@export var recover_time: float = 0.9
@export var dash_speed_mult: float = 3.5
@export var telegraph_color: Color = Color(2.5, 1.6, 0.5)
@export var telegraph_line_color: Color = Color(1.0, 0.55, 0.25, 0.85)
@export var telegraph_line_length: float = 220.0

var _state: int = State.TRACK
var _state_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO
var _base_speed: float = 0.0
var _telegraph_line: Line2D = null

func _ready() -> void:
	super()
	_base_speed = move_speed
	_state_timer = randf_range(1.5, dash_interval)
	_make_telegraph_line()

func _make_telegraph_line() -> void:
	var visual: Node = $Visual
	if visual == null:
		return
	var line := Line2D.new()
	line.width = 4.0
	line.default_color = telegraph_line_color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
	line.visible = false
	line.z_index = -1
	visual.add_child(line)
	_telegraph_line = line

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
				_show_charge_line()
		State.TELEGRAPH:
			velocity = velocity.lerp(Vector2.ZERO, 0.3)
			_update_charge_line()
			if _state_timer <= 0.0:
				_state = State.DASH
				_state_timer = dash_time
				_dash_dir = global_position.direction_to(target.global_position)
				if is_instance_valid(visual_sprite):
					visual_sprite.modulate = Color.WHITE
				_hide_charge_line()
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

func _show_charge_line() -> void:
	if not is_instance_valid(_telegraph_line):
		return
	_telegraph_line.visible = true
	_telegraph_line.modulate.a = 0.0
	var tw := _telegraph_line.create_tween()
	tw.tween_property(_telegraph_line, "modulate:a", 1.0, 0.12)

func _hide_charge_line() -> void:
	if is_instance_valid(_telegraph_line):
		_telegraph_line.visible = false

func _update_charge_line() -> void:
	if not is_instance_valid(_telegraph_line) or not is_instance_valid(target):
		return
	# Line lives in Visual's local space. Length pulses outward as we near
	# the dash so the player reads "release imminent" without watching the timer.
	var to_target_world: Vector2 = target.global_position - global_position
	var dir_local := to_target_world.normalized()
	var charge_t: float = clampf(1.0 - (_state_timer / telegraph_time), 0.0, 1.0)
	var len: float = telegraph_line_length * (0.55 + 0.45 * charge_t)
	_telegraph_line.points = PackedVector2Array([Vector2.ZERO, dir_local * len])

func _die() -> void:
	if is_instance_valid(_telegraph_line):
		_telegraph_line.visible = false
	super()

func _update_flash(delta: float) -> void:
	# Avoid the base flash from clobbering our telegraph color
	if _state == State.TELEGRAPH:
		_flash_timer = 0.0
		return
	super(delta)
