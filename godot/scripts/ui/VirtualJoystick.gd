extends Control
class_name VirtualJoystick

@export var max_radius: float = 130.0
@export var handle_radius: float = 52.0
@export var dead_zone: float = 14.0
@export var ring_color: Color = Color(1, 1, 1, 0.18)
@export var ring_outline: Color = Color(1, 1, 1, 0.55)
@export var handle_color: Color = Color(1, 1, 1, 0.45)
@export var handle_outline: Color = Color(1, 1, 1, 0.85)

var _active_touch_id: int = -1
var _origin: Vector2 = Vector2.ZERO
var _handle_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _input(event: InputEvent) -> void:
	var paused := get_tree().paused
	if event is InputEventScreenTouch:
		_handle_touch(event, paused)
	elif event is InputEventScreenDrag:
		_handle_drag(event, paused)
	elif event is InputEventMouseButton and OS.has_feature("editor"):
		_handle_mouse_button(event, paused)
	elif event is InputEventMouseMotion and _active_touch_id == -2:
		_update_drag(event.position)

func _handle_touch(event: InputEventScreenTouch, paused: bool) -> void:
	if event.pressed:
		if paused or _active_touch_id != -1:
			return
		_active_touch_id = event.index
		_begin_drag(event.position)
	elif event.index == _active_touch_id:
		_end_drag()

func _handle_drag(event: InputEventScreenDrag, paused: bool) -> void:
	if paused or event.index != _active_touch_id:
		return
	_update_drag(event.position)

func _handle_mouse_button(event: InputEventMouseButton, paused: bool) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		if paused or _active_touch_id != -1:
			return
		_active_touch_id = -2
		_begin_drag(event.position)
	elif _active_touch_id == -2:
		_end_drag()

func _begin_drag(pos: Vector2) -> void:
	_origin = pos
	_handle_pos = pos
	TouchInput.move_vector = Vector2.ZERO
	queue_redraw()

func _update_drag(pos: Vector2) -> void:
	var delta := pos - _origin
	var dist := delta.length()
	if dist < dead_zone:
		TouchInput.move_vector = Vector2.ZERO
		_handle_pos = _origin
	else:
		var clamped_dist := minf(dist, max_radius)
		var dir := delta / dist
		_handle_pos = _origin + dir * clamped_dist
		TouchInput.move_vector = dir * (clamped_dist / max_radius)
	queue_redraw()

func _end_drag() -> void:
	_active_touch_id = -1
	TouchInput.move_vector = Vector2.ZERO
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_VISIBILITY_CHANGED:
		if _active_touch_id != -1:
			_end_drag()

func _draw() -> void:
	if _active_touch_id == -1:
		return
	draw_circle(_origin, max_radius, ring_color)
	draw_arc(_origin, max_radius, 0.0, TAU, 64, ring_outline, 3.0, true)
	draw_circle(_handle_pos, handle_radius, handle_color)
	draw_arc(_handle_pos, handle_radius, 0.0, TAU, 32, handle_outline, 2.0, true)
