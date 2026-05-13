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
@onready var visual_body: Polygon2D = $Visual.get_node_or_null("Body")
@onready var visual_sprite: Sprite2D = $Visual.get_node_or_null("Sprite")

func _ready() -> void:
	var d: Dictionary = Difficulty.get_data(GameData.difficulty)
	# Time-based escalation: enemies grow stronger as the run progresses.
	# Compressed for the 5-min stage length so the 5-min mark hits the
	# same intensity the old 7-min runs reached at their finale.
	# At 3 min: ~1.84x HP, 1.17x speed, 1.42x damage, 1.42x XP reward.
	# At 5 min: ~2.40x HP, 1.28x speed, 1.70x damage, 1.70x XP reward.
	var minutes: float = max(GameData.run_elapsed, 0.0) / 60.0
	var hp_t: float = 1.0 + minutes * 0.28
	var spd_t: float = 1.0 + minutes * 0.055
	var dmg_t: float = 1.0 + minutes * 0.14
	var xp_t: float = 1.0 + minutes * 0.14
	max_hp = int(max_hp * float(d["hp_mult"]) * hp_t)
	contact_damage = int(contact_damage * float(d["dmg_mult"]) * dmg_t)
	xp_reward = int(xp_reward * float(d["reward_mult"]) * xp_t)
	move_speed = move_speed * spd_t
	current_hp = max_hp
	add_to_group("enemies")
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	_update_visual()

func _update_visual() -> void:
	if is_instance_valid(visual_sprite):
		var s: float = body_size / 7.0
		visual_sprite.scale = Vector2(s, s)
		return
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
	_update_velocity(delta)
	move_and_slide()
	_update_flash(delta)

# Override in subclasses for custom behavior (dash, kite, etc.).
# Default: walk straight at the player.
func _update_velocity(_delta: float) -> void:
	var dir := global_position.direction_to(target.global_position)
	velocity = dir * move_speed

func _update_flash(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			if is_instance_valid(visual_sprite):
				visual_sprite.modulate = Color.WHITE
			elif is_instance_valid(visual_body):
				visual_body.color = body_color

func set_target(t: Node2D) -> void:
	target = t

func take_damage(amount: int) -> void:
	current_hp -= amount
	_flash_timer = 0.12
	if is_instance_valid(visual_sprite):
		visual_sprite.modulate = Color(3.0, 3.0, 3.0)
	elif is_instance_valid(visual_body):
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
