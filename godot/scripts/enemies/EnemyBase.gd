extends CharacterBody2D
class_name EnemyBase

signal died(xp: int, gold: int, pos: Vector2)

@export var move_speed: float = 70.0
@export var contact_damage: int = 8
@export var max_hp: int = 12
@export var xp_reward: int = 2
@export var gold_drop_chance: float = 0.05
@export var gold_drop_amount: int = 1
@export var body_color: Color = Color(0.9, 0.2, 0.2, 1.0)
@export var body_size: float = 12.0

var current_hp: int
var target: Node2D
var _flash_timer: float = 0.0

@onready var hit_area: Area2D = $HitArea
@onready var visual_body: Polygon2D = $Visual/Body

func _ready() -> void:
	var d: Dictionary = Difficulty.get_data(GameData.difficulty)
	max_hp = int(max_hp * float(d["hp_mult"]))
	contact_damage = int(contact_damage * float(d["dmg_mult"]))
	xp_reward = int(xp_reward * float(d["reward_mult"]))
	current_hp = max_hp
	add_to_group("enemies")
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	_update_visual()

func _update_visual() -> void:
	if not is_instance_valid(visual_body):
		return
	visual_body.color = body_color
	var pts := PackedVector2Array()
	for i in range(8):
		var a := float(i) * TAU / 8.0
		pts.append(Vector2(cos(a) * body_size, sin(a) * body_size))
	visual_body.polygon = pts

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	var dir := global_position.direction_to(target.global_position)
	velocity = dir * move_speed
	move_and_slide()

	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			if is_instance_valid(visual_body):
				visual_body.color = body_color

func set_target(t: Node2D) -> void:
	target = t

func take_damage(amount: int) -> void:
	current_hp -= amount
	_flash_timer = 0.12
	if is_instance_valid(visual_body):
		visual_body.color = Color.WHITE
	if current_hp <= 0:
		_die()

func _die() -> void:
	var gold_drop: int = gold_drop_amount if randf() < gold_drop_chance else 0
	_spawn_death_burst()
	AudioManager.play("kill", -14.0)
	died.emit(xp_reward, gold_drop, global_position)
	queue_free()

func _spawn_death_burst() -> void:
	var burst := DeathBurst.new()
	burst.global_position = global_position
	burst.burst_color = body_color
	burst.particle_count = int(8 + body_size * 0.3)
	burst.spread = body_size * 6.0
	burst.lifetime = 0.45
	get_tree().current_scene.add_child(burst)

func _on_hit_area_body_entered(body: Node) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(contact_damage)
