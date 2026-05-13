extends Node2D
class_name GoldCoin

@export var gold_value: int = 1

var _target_pos: Vector2 = Vector2.ZERO
var _attracted: bool = false
var _attract_speed: float = 200.0

const SPRITE := preload("res://assets/sprites/pickup_gold.png")
const GLOW_COLOR := Color(1.0, 0.85, 0.25, 0.7)
const GLOW_RADIUS := 14.0

var _vis: Sprite2D
var _glow: Node2D

func _ready() -> void:
	add_to_group("gold_coins")
	_build_visual()
	_start_idle_motion()

func _build_visual() -> void:
	_glow = _GlowDraw.new()
	(_glow as _GlowDraw).color = GLOW_COLOR
	(_glow as _GlowDraw).radius = GLOW_RADIUS
	add_child(_glow)
	_vis = Sprite2D.new()
	_vis.texture = SPRITE
	_vis.scale = Vector2(1.6, 1.6)
	add_child(_vis)

func _start_idle_motion() -> void:
	# Coins spin instead of bouncing, so the player can tell XP from gold
	# at a glance without reading the icon.
	var t := create_tween()
	t.set_loops()
	t.tween_property(_vis, "scale:x", -1.6, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(_vis, "scale:x", 1.6, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var g := create_tween()
	g.set_loops()
	g.tween_property(_glow, "modulate:a", 0.5, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	g.tween_property(_glow, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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

class _GlowDraw extends Node2D:
	var color: Color = Color.WHITE
	var radius: float = 12.0
	func _draw() -> void:
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, color.a * 0.35))
		draw_circle(Vector2.ZERO, radius * 0.65, Color(color.r, color.g, color.b, color.a * 0.55))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Color(color.r, color.g, color.b, 0.9), 1.5, true)
