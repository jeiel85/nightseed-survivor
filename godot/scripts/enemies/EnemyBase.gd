extends CharacterBody2D
class_name EnemyBase

@export var move_speed: float = 70.0
@export var contact_damage: int = 8

var target: Node2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	hit_area.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(target.global_position)
	velocity = direction * move_speed
	move_and_slide()

func set_target(target_node: Node2D) -> void:
	target = target_node

func _on_hit_area_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(contact_damage)
