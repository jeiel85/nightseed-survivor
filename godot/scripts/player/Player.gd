extends CharacterBody2D
class_name Player

signal hp_changed(current_hp: int, max_hp: int)
signal died

@export var move_speed: float = 160.0
@export var max_hp: int = 100
@export var invincible_duration: float = 0.5

var current_hp: int
var invincible_timer: float = 0.0

func _ready() -> void:
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	if invincible_timer > 0.0:
		invincible_timer = max(invincible_timer - delta, 0.0)

func apply_damage(amount: int) -> void:
	if invincible_timer > 0.0 or current_hp <= 0:
		return

	current_hp = max(current_hp - amount, 0)
	invincible_timer = invincible_duration
	hp_changed.emit(current_hp, max_hp)

	if current_hp == 0:
		died.emit()
