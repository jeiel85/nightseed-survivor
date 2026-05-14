extends WeaponBase
class_name FireWisp

# Fire Wisp lands explosions on enemy clusters instead of random offsets.
# The wisp picks K candidate centers (from enemies near the player) and
# detonates on whichever covers the most enemies. Each extra explosion in
# the same fire() reroutes to the *next* densest cluster so multi-wisp
# upgrades clean different pockets rather than stacking.

const CANDIDATE_LIMIT: int = 8
const SCAN_RADIUS: float = 460.0
const FALLBACK_RANGE: float = 220.0

var explosion_radius: float = 65.0
var explosion_count: int = 1

func _ready() -> void:
	weapon_name = "Fire Wisp"
	base_damage = 22
	base_cooldown = 2.8

func fire() -> void:
	var enemies := _enemies_in_scan_range()
	for i in range(explosion_count):
		var pos := _pick_cluster_center(enemies)
		_explode(pos, enemies)

func _enemies_in_scan_range() -> Array:
	var out: Array = []
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if player.global_position.distance_to(e.global_position) <= SCAN_RADIUS:
			out.append(e)
	return out

# Returns a position the wisp should detonate on. If enemies are available,
# scores K random candidates by how many enemies they cover and picks the
# best. With no enemies in range, falls back to a random offset around the
# player so the cooldown still feels alive.
func _pick_cluster_center(enemies: Array) -> Vector2:
	if enemies.is_empty():
		return player.global_position + Vector2(
			randf_range(-FALLBACK_RANGE, FALLBACK_RANGE),
			randf_range(-FALLBACK_RANGE, FALLBACK_RANGE)
		)
	var candidates: Array = enemies.duplicate()
	candidates.shuffle()
	if candidates.size() > CANDIDATE_LIMIT:
		candidates.resize(CANDIDATE_LIMIT)
	var best_pos: Vector2 = candidates[0].global_position
	var best_score: int = -1
	var r2: float = explosion_radius * explosion_radius
	for c in candidates:
		if not is_instance_valid(c):
			continue
		var pos: Vector2 = c.global_position
		var hits: int = 0
		for e in enemies:
			if not is_instance_valid(e):
				continue
			if pos.distance_squared_to(e.global_position) <= r2:
				hits += 1
		if hits > best_score:
			best_score = hits
			best_pos = pos
	return best_pos

func _explode(pos: Vector2, enemies: Array) -> void:
	var r2: float = explosion_radius * explosion_radius
	var hit_list: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_squared_to(pos) <= r2:
			if enemy.has_method("take_damage"):
				enemy.take_damage(get_damage())
				hit_list.append(enemy)
	# Remove enemies we just hit so the next explosion in the same fire()
	# call targets a *different* pocket instead of double-dipping the same
	# pack.
	for h in hit_list:
		enemies.erase(h)
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
