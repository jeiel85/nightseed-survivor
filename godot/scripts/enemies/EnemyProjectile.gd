extends Area2D
class_name EnemyProjectile

## Projectile fired by enemies (e.g., Caster). Damages the player on contact.

const PROJ_TEX := preload("res://assets/sprites/proj_orb.png")

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
	# Halo glow
	var halo := Polygon2D.new()
	var hpts := PackedVector2Array()
	for i in range(12):
		var a := float(i) * TAU / 12.0
		hpts.append(Vector2(cos(a), sin(a)) * (radius * 2.2))
	halo.polygon = hpts
	var halo_color: Color = color
	halo_color.a = 0.30
	halo.color = halo_color
	add_child(halo)
	# Sprite (tinted)
	var sprite := Sprite2D.new()
	sprite.texture = PROJ_TEX
	sprite.scale = Vector2(1.4, 1.4)
	sprite.modulate = color
	add_child(sprite)
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
