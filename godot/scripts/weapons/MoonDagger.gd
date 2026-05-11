extends WeaponBase
class_name MoonDagger

const PROJ_SCENE := preload("res://scenes/weapons/Projectile.tscn")
const PROJ_TEX := preload("res://assets/sprites/icon_moon_dagger.png")

func _ready() -> void:
	weapon_name = "Moon Dagger"
	base_damage = 12
	base_cooldown = 1.2

func fire() -> void:
	var target := find_nearest_enemy()
	if not is_instance_valid(target):
		return
	var dir: Vector2 = player.global_position.direction_to(target.global_position)
	if evolved:
		_fire_dagger(dir.rotated(deg_to_rad(-15.0)))
		_fire_dagger(dir)
		_fire_dagger(dir.rotated(deg_to_rad(15.0)))
	else:
		_fire_dagger(dir)

func _fire_dagger(dir: Vector2) -> void:
	var proj := PROJ_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(proj)
	proj.global_position = player.global_position
	proj.set_visual(PROJ_TEX, Color(0.7, 0.85, 1.0, 0.5), 1.8)
	proj.launch(dir, get_damage(), 460.0, 2.0, 1)
