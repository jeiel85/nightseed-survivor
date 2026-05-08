extends CharacterBody2D
class_name Player

signal hp_changed(current: int, max_val: int)
signal died
signal xp_changed(current: int, needed: int)
signal leveled_up(level: int)
signal gold_changed(total: int)
signal kill_count_changed(count: int)

@export var move_speed: float = 160.0
@export var max_hp: int = 100
@export var invincible_duration: float = 0.5

var current_hp: int
var xp_radius: float = 80.0
var current_xp: int = 0
var current_level: int = 1
var kill_count: int = 0
var session_gold: int = 0
var _invincible_timer: float = 0.0

@onready var weapon_manager: WeaponManager = $WeaponManager

func _ready() -> void:
	max_hp += GameData.get_hp_bonus()
	move_speed += GameData.get_speed_bonus()
	xp_radius += GameData.get_magnet_bonus()
	weapon_manager._init_damage_mult = GameData.get_damage_multiplier()
	weapon_manager._init_cooldown_mult = GameData.get_cooldown_multiplier()
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	xp_changed.emit(0, get_xp_needed())
	var dagger := MoonDagger.new()
	weapon_manager.add_weapon(dagger)

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * move_speed
	move_and_slide()
	if _invincible_timer > 0.0:
		_invincible_timer = maxf(_invincible_timer - delta, 0.0)
	_handle_pickups()

func _handle_pickups() -> void:
	for gem in get_tree().get_nodes_in_group("xp_gems"):
		if not is_instance_valid(gem):
			continue
		var dist := global_position.distance_to(gem.global_position)
		if dist <= xp_radius and gem.has_method("attract"):
			gem.attract(global_position)
		if dist <= 22.0 and gem.has_method("collect"):
			gem.collect(self)

	for coin in get_tree().get_nodes_in_group("gold_coins"):
		if not is_instance_valid(coin):
			continue
		var dist := global_position.distance_to(coin.global_position)
		if dist <= xp_radius and coin.has_method("attract"):
			coin.attract(global_position)
		if dist <= 22.0 and coin.has_method("collect"):
			coin.collect(self)

func apply_damage(amount: int) -> void:
	if _invincible_timer > 0.0 or current_hp <= 0:
		return
	current_hp = maxi(current_hp - amount, 0)
	_invincible_timer = invincible_duration
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

func add_xp(amount: int) -> void:
	current_xp += amount
	var needed := get_xp_needed()
	while current_xp >= needed:
		current_xp -= needed
		current_level += 1
		needed = get_xp_needed()
		leveled_up.emit(current_level)
	xp_changed.emit(current_xp, get_xp_needed())

func add_gold(amount: int) -> void:
	session_gold += amount
	gold_changed.emit(session_gold)

func add_kill() -> void:
	kill_count += 1
	kill_count_changed.emit(kill_count)

func get_xp_needed() -> int:
	return 5 + current_level * 4
