extends Node2D
class_name Starfield

@export var star_count: int = 80
@export var area_size: float = 2400.0
@export var follow_target: NodePath

var _stars: Array = []
var _target: Node2D

func _ready() -> void:
	z_index = -10
	if not follow_target.is_empty():
		_target = get_node_or_null(follow_target)
	for _i in range(star_count):
		var star := Polygon2D.new()
		var s: float = randf_range(1.0, 2.5)
		star.polygon = PackedVector2Array([
			Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)
		])
		var brightness := randf_range(0.3, 0.85)
		star.color = Color(brightness, brightness, brightness * 1.1, randf_range(0.4, 0.8))
		star.position = Vector2(randf_range(-area_size, area_size), randf_range(-area_size, area_size))
		add_child(star)
		_stars.append({
			"node": star,
			"phase": randf() * TAU,
			"speed": randf_range(0.5, 1.5),
			"parallax": randf_range(0.2, 0.6),
			"home": star.position,
		})

func _process(delta: float) -> void:
	var time: float = float(Time.get_ticks_msec()) / 1000.0
	var follow_pos: Vector2 = global_position
	if is_instance_valid(_target):
		follow_pos = _target.global_position
	for entry in _stars:
		var star: Polygon2D = entry["node"]
		var phase: float = entry["phase"] + time * entry["speed"]
		var alpha := 0.4 + 0.4 * sin(phase)
		var c: Color = star.color
		c.a = alpha
		star.color = c
		# Parallax: drift opposite to follow target
		star.position = entry["home"] - follow_pos * float(entry["parallax"]) * 0.4
		# Wrap around
		while star.position.x - entry["home"].x < -area_size:
			entry["home"] += Vector2(area_size * 2.0, 0)
		while star.position.x - entry["home"].x > area_size:
			entry["home"] -= Vector2(area_size * 2.0, 0)
		while star.position.y - entry["home"].y < -area_size:
			entry["home"] += Vector2(0, area_size * 2.0)
		while star.position.y - entry["home"].y > area_size:
			entry["home"] -= Vector2(0, area_size * 2.0)
