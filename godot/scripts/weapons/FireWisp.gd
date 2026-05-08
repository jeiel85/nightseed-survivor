extends WeaponBase
class_name FireWisp

var explosion_radius: float = 65.0
var explosion_count: int = 1

func _ready() -> void:
	weapon_name = "Fire Wisp"
	base_damage = 22
	base_cooldown = 2.8

func fire() -> void:
	for _i in range(explosion_count):
		var offset := Vector2(randf_range(-220.0, 220.0), randf_range(-220.0, 220.0))
		var pos := player.global_position + offset
		_explode(pos)

func _explode(pos: Vector2) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(pos) <= explosion_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(get_damage())
	_show_explosion_vfx(pos)

func _show_explosion_vfx(pos: Vector2) -> void:
	var node := Node2D.new()
	node.global_position = pos
	var vis := Polygon2D.new()
	vis.color = Color(1.0, 0.45, 0.1, 0.65)
	var pts := PackedVector2Array()
	for i in range(12):
		var a := i * TAU / 12.0
		pts.append(Vector2(cos(a) * explosion_radius, sin(a) * explosion_radius))
	vis.polygon = pts
	node.add_child(vis)
	get_tree().current_scene.add_child(node)
	var tw := node.create_tween()
	tw.tween_property(vis, "color:a", 0.0, 0.4)
	tw.tween_callback(node.queue_free)

func upgrade() -> void:
	super()
	explosion_radius = minf(explosion_radius + 12.0, 130.0)
	if level % 3 == 0:
		explosion_count += 1
