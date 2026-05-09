extends Area2D
class_name EnemyProjectile

## Projectile fired by enemies (e.g., Caster). Damages the player on contact.

@export var damage: int = 8
@export var speed: float = 240.0
@export var lifetime: float = 4.5
@export var radius: float = 6.0
@export var color: Color = Color(1.0, 0.4, 0.95, 1.0)

var _direction: Vector2 = Vector2.RIGHT
var _alive: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1  # Player layer
	body_entered.connect(_on_body_entered)
	# Visual
	var node := Node2D.new()
	add_child(node)
	# Use a Polygon2D for the visible orb
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(8):
		var a := float(i) * TAU / 8.0
		pts.append(Vector2(cos(a), sin(a)) * radius)
	poly.polygon = pts
	poly.color = color
	add_child(poly)
	# Halo
	var halo := Polygon2D.new()
	var hpts := PackedVector2Array()
	for i in range(8):
		var a := float(i) * TAU / 8.0
		hpts.append(Vector2(cos(a), sin(a)) * (radius * 1.8))
	halo.polygon = hpts
	var halo_color: Color = color
	halo_color.a = 0.25
	halo.color = halo_color
	add_child(halo)
	move_child(halo, 0)
	# Collision
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)

func launch(dir: Vector2, dmg: int, spd: float) -> void:
	_direction = dir.normalized()
	damage = dmg
	speed = spd

func _physics_process(delta: float) -> void:
	_alive += delta
	if _alive >= lifetime:
		queue_free()
		return
	global_position += _direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()
