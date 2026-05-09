extends Node2D
class_name GoldCoin

@export var gold_value: int = 1

var _target_pos: Vector2 = Vector2.ZERO
var _attracted: bool = false
var _attract_speed: float = 200.0

const SPRITE := preload("res://assets/sprites/pickup_gold.png")

func _ready() -> void:
	add_to_group("gold_coins")
	_draw_coin()

func _draw_coin() -> void:
	var vis := Sprite2D.new()
	vis.texture = SPRITE
	vis.scale = Vector2(1.4, 1.4)
	add_child(vis)

func attract(toward: Vector2) -> void:
	_attracted = true
	_target_pos = toward

func collect(p: Node) -> void:
	if p.has_method("add_gold"):
		p.add_gold(gold_value)
	AudioManager.play("pickup_gold", -6.0)
	queue_free()

func _process(delta: float) -> void:
	if _attracted:
		global_position = global_position.move_toward(_target_pos, _attract_speed * delta)
