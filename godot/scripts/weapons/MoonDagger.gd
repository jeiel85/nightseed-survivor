extends WeaponBase
class_name MoonDagger

const PROJ_SCENE := preload("res://scenes/weapons/Projectile.tscn")

func _ready() -> void:
	weapon_name = "Moon Dagger"
	base_damage = 12
	base_cooldown = 1.2

func fire() -> void:
	var target := find_nearest_enemy()
	if not is_instance_valid(target):
		return
	var proj := PROJ_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = player.global_position
	proj.launch(
		player.global_position.direction_to(target.global_position),
		get_damage(), 420.0, 2.0, 1
	)
