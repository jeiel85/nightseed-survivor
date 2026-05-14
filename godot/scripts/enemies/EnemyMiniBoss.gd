extends EnemyDasher
class_name EnemyMiniBoss

## Mid-run mini-boss. Inherits the Dasher's telegraph→dash threat, plus:
##   - Glowing aura (visual identity)
##   - Periodic shockwave pulse — a ring expands out from the mini-boss,
##     and if the player is inside the ring's leading edge when it passes
##     them they take damage. The expansion is slow enough to be readable
##     and the inner zone is safe, so the patterned answer is "step out
##     before the ring sweeps past."
## Drops bonus gold on death (handled in WaveManager-side spawn config).

@export var aura_color: Color = Color(0.95, 0.4, 1.0, 0.18)
@export var aura_radius: float = 60.0
@export var pulse_interval: float = 6.5
@export var pulse_max_radius: float = 360.0
@export var pulse_duration: float = 1.4
@export var pulse_damage: int = 12
@export var pulse_band_width: float = 36.0
@export var pulse_color: Color = Color(1.0, 0.55, 1.0, 0.55)

var _aura_node: Polygon2D = null
var _pulse_timer: float = 0.0
var _active_pulse: Dictionary = {}

func _ready() -> void:
	super()
	_add_aura()
	# Stagger the first pulse so two mini-bosses in the same window don't
	# fire in sync.
	_pulse_timer = randf_range(pulse_interval * 0.5, pulse_interval)

func _add_aura() -> void:
	var visual: Node = $Visual
	if visual == null:
		return
	var aura := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var a := float(i) * TAU / 16.0
		pts.append(Vector2(cos(a), sin(a)) * aura_radius)
	aura.polygon = pts
	aura.color = aura_color
	visual.add_child(aura)
	visual.move_child(aura, 0)
	_aura_node = aura

func _physics_process(delta: float) -> void:
	super(delta)
	if _aura_node:
		_aura_node.rotation += delta * 1.2
	_tick_shockwave(delta)

func _tick_shockwave(delta: float) -> void:
	_pulse_timer -= delta
	if _pulse_timer <= 0.0:
		_start_shockwave()
		_pulse_timer = pulse_interval
	if _active_pulse.is_empty():
		return
	_active_pulse["elapsed"] += delta
	var t: float = float(_active_pulse["elapsed"]) / pulse_duration
	if t >= 1.0:
		_end_shockwave()
		return
	var r: float = pulse_max_radius * t
	var ring: Line2D = _active_pulse.get("ring", null)
	if is_instance_valid(ring):
		_redraw_ring(ring, r)
		ring.modulate.a = 1.0 - t
	# Damage the player once, when the expanding band first sweeps past them.
	if not _active_pulse.get("hit", false) and is_instance_valid(target):
		var dist: float = global_position.distance_to(target.global_position)
		if dist >= r - pulse_band_width and dist <= r + pulse_band_width:
			_active_pulse["hit"] = true
			if target.has_method("apply_damage"):
				target.apply_damage(pulse_damage)

func _start_shockwave() -> void:
	_end_shockwave()
	var visual: Node = $Visual
	var ring := Line2D.new()
	ring.width = 5.0
	ring.default_color = pulse_color
	ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	ring.closed = true
	ring.z_index = -1
	if visual:
		visual.add_child(ring)
	else:
		add_child(ring)
	_redraw_ring(ring, 4.0)
	_active_pulse = {"elapsed": 0.0, "ring": ring, "hit": false}
	AudioManager.play("boss_appear", -12.0)

func _redraw_ring(ring: Line2D, radius: float) -> void:
	var pts := PackedVector2Array()
	var steps: int = 36
	for i in range(steps + 1):
		var a := float(i) * TAU / float(steps)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	ring.points = pts

func _end_shockwave() -> void:
	if _active_pulse.is_empty():
		return
	var ring: Line2D = _active_pulse.get("ring", null)
	if is_instance_valid(ring):
		ring.queue_free()
	_active_pulse = {}

func _die() -> void:
	_end_shockwave()
	super()
