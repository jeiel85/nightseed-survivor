extends WeaponBase
class_name StarNeedle

const PROJ_SCENE := preload("res://scenes/weapons/Projectile.tscn")
const PROJ_TEX := preload("res://assets/sprites/icon_star_needle.png")

var needle_count: int = 3
var spread: float = 0.28
var proj_speed: float = 520.0

func _ready() -> void:
	weapon_name = "Star Needle"
	base_damage = 8
	base_cooldown = 0.75

func fire() -> void:
	var target := find_nearest_enemy()
	var base_dir: Vector2
	if is_instance_valid(target):
		base_dir = player.global_position.direction_to(target.global_position)
	else:
		base_dir = Vector2.RIGHT
	for i in range(needle_count):
		var offset := (float(i) - float(needle_count - 1) / 2.0) * spread
		var dir := base_dir.rotated(offset)
		var proj := PROJ_SCENE.instantiate() as Projectile
		get_tree().current_scene.add_child(proj)
		proj.global_position = player.global_position
		proj.set_visual(PROJ_TEX, Color(0.95, 0.85, 0.4, 0.45), 1.5)
		proj.launch(dir, get_damage(), proj_speed, 1.5, 1)

func upgrade() -> void:
	super()
	if level % 2 == 0:
		needle_count += 1
