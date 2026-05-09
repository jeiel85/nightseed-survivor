extends Node2D
class_name DeathBurst

@export var burst_color: Color = Color(1, 1, 1, 1)
@export var particle_count: int = 10
@export var spread: float = 50.0
@export var lifetime: float = 0.45

var _particles: Array = []
var _elapsed: float = 0.0

func _ready() -> void:
	z_index = 5
	for _i in range(particle_count):
		var p := Polygon2D.new()
		var size: float = randf_range(2.0, 4.5)
		p.polygon = PackedVector2Array([
			Vector2(-size, -size),
			Vector2(size, -size),
			Vector2(size, size),
			Vector2(-size, size),
		])
		p.color = burst_color
		add_child(p)
		var dir := Vector2.RIGHT.rotated(randf() * TAU)
		var speed := randf_range(spread * 0.6, spread * 1.4)
		_particles.append({"node": p, "vel": dir * speed, "spin": randf_range(-8.0, 8.0)})

func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = _elapsed / lifetime
	if t >= 1.0:
		queue_free()
		return
	var alpha := 1.0 - t
	for entry in _particles:
		var node: Polygon2D = entry["node"]
		if not is_instance_valid(node):
			continue
		node.position += entry["vel"] * delta
		node.rotation += entry["spin"] * delta
		var c: Color = burst_color
		c.a = alpha
		node.color = c
		entry["vel"] *= (1.0 - delta * 1.5)
