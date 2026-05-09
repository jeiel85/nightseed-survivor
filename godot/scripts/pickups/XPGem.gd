extends Node2D
class_name XPGem

@export var xp_value: int = 2

var _target_pos: Vector2 = Vector2.ZERO
var _attracted: bool = false
var _attract_speed: float = 240.0

const SPRITE := preload("res://assets/sprites/pickup_xp.png")

func _ready() -> void:
	add_to_group("xp_gems")
	_draw_gem()

func _draw_gem() -> void:
	var vis := Sprite2D.new()
	vis.texture = SPRITE
	vis.scale = Vector2(1.4, 1.4)
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
