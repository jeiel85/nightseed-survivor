extends WeaponBase
class_name ThornRing

const PROJ_SCENE := preload("res://scenes/weapons/Projectile.tscn")

var spike_count: int = 8
var proj_speed: float = 230.0

func _ready() -> void:
	weapon_name = "Thorn Ring"
	base_damage = 10
	base_cooldown = 3.5

func fire() -> void:
	for i in range(spike_count):
		var angle := TAU * float(i) / float(spike_count)
		var dir := Vector2.RIGHT.rotated(angle)
		var proj := PROJ_SCENE.instantiate() as Projectile
		get_tree().current_scene.add_child(proj)
		proj.global_position = player.global_position
		proj.launch(dir, get_damage(), proj_speed, 0.9, 1)

func upgrade() -> void:
	super()
	spike_count += 2
