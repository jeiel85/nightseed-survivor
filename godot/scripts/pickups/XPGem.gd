extends Node2D
class_name XPGem

@export var xp_value: int = 2

var _target_pos: Vector2 = Vector2.ZERO
var _attracted: bool = false
var _attract_speed: float = 240.0

func _ready() -> void:
	add_to_group("xp_gems")
	_draw_gem()

func _draw_gem() -> void:
	var vis := Polygon2D.new()
	vis.color = Color(0.2, 0.95, 0.4)
	vis.polygon = PackedVector2Array([
		Vector2(0, -7), Vector2(5, 0), Vector2(0, 7), Vector2(-5, 0)
	])
	add_child(vis)

func attract(toward: Vector2) -> void:
	_attracted = true
	_target_pos = toward

func collect(p: Node) -> void:
	if p.has_method("add_xp"):
		p.add_xp(xp_value)
	AudioManager.play("pickup_xp", -8.0)
	queue_free()

func _process(delta: float) -> void:
	if _attracted:
		global_position = global_position.move_toward(_target_pos, _attract_speed * delta)
