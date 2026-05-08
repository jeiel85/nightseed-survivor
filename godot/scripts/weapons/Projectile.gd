extends Area2D
class_name Projectile

@export var speed: float = 350.0
@export var damage: int = 15
@export var max_lifetime: float = 2.0
@export var pierce_count: int = 1

var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 0.0
var hit_enemies: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func launch(dir: Vector2, dmg: int, spd: float = 350.0, lifetime_max: float = 2.0, pierce: int = 1) -> void:
	direction = dir.normalized()
	damage = dmg
	speed = spd
	max_lifetime = lifetime_max
	pierce_count = pierce
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in hit_enemies:
		return
	hit_enemies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	if hit_enemies.size() >= pierce_count:
		queue_free()
