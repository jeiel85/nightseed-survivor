extends Node2D
class_name WeaponBase

# Emitted right after fire() runs each cooldown tick. EmberRenewal (Pyromancer)
# listens via WeaponManager.weapon_fired to count fires for its heal cadence.
signal fired

@export var weapon_name: String = "Weapon"
@export var base_damage: int = 10
@export var base_cooldown: float = 1.0

var player: Node2D
var level: int = 1
var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
var evolved: bool = false
var _cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = maxf(base_cooldown * cooldown_multiplier, 0.15)
		fire()
		fired.emit()

func fire() -> void:
	pass

func get_damage() -> int:
	return int(base_damage * damage_multiplier)

func upgrade() -> void:
	level += 1
	base_damage = int(base_damage * 1.25)
	base_cooldown = maxf(base_cooldown * 0.88, 0.2)

func evolve() -> void:
	evolved = true
	base_damage = int(base_damage * 1.4)
	base_cooldown = maxf(base_cooldown * 0.85, 0.15)

func find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d: float = player.global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest
