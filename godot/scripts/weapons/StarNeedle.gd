extends WeaponBase
class_name StarNeedle

# Star Needle is a directional volley. The base direction prefers, in order:
#   1. centroid of nearby enemy clusters (sweeps the densest pocket)
#   2. single nearest enemy
#   3. player's current movement direction (so dodging redirects fire)
#   4. last facing fallback (Vector2.RIGHT)
# Spread also widens with needle_count so the late-game volley reads as
# "sweeping shot" rather than a tight beam.

const PROJ_SCENE := preload("res://scenes/weapons/Projectile.tscn")
const PROJ_TEX := preload("res://assets/sprites/icon_star_needle.png")
const CLUSTER_RADIUS: float = 360.0
const PER_NEEDLE_SPREAD: float = 0.14
const MIN_SPREAD_TOTAL: float = 0.32
const MAX_SPREAD_TOTAL: float = 1.1

var needle_count: int = 3
var proj_speed: float = 520.0
var _last_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	weapon_name = "Star Needle"
	base_damage = 8
	base_cooldown = 0.75

func fire() -> void:
	var base_dir := _pick_base_dir()
	_last_dir = base_dir
	var spread_total: float = clampf(
		PER_NEEDLE_SPREAD * float(needle_count - 1),
		MIN_SPREAD_TOTAL,
		MAX_SPREAD_TOTAL,
	)
	var step: float = spread_total / float(max(needle_count - 1, 1)) if needle_count > 1 else 0.0
	for i in range(needle_count):
		var offset: float = (float(i) - float(needle_count - 1) * 0.5) * step
		var dir := base_dir.rotated(offset)
		var proj := PROJ_SCENE.instantiate() as Projectile
		get_tree().current_scene.add_child(proj)
		proj.global_position = player.global_position
		proj.set_visual(PROJ_TEX, Color(0.95, 0.85, 0.4, 0.45), 1.5)
		proj.launch(dir, get_damage(), proj_speed, 1.5, 1)

func _pick_base_dir() -> Vector2:
	var nearby: Array = []
	var nearest: Node2D = null
	var nearest_d: float = INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var d: float = player.global_position.distance_to(e.global_position)
		if d <= CLUSTER_RADIUS:
			nearby.append(e)
		if d < nearest_d:
			nearest_d = d
			nearest = e
	if nearby.size() >= 2:
		var centroid := Vector2.ZERO
		for e in nearby:
			centroid += e.global_position
		centroid /= float(nearby.size())
		var dir: Vector2 = (centroid - player.global_position)
		if dir.length() > 0.001:
			return dir.normalized()
	if is_instance_valid(nearest):
		return player.global_position.direction_to(nearest.global_position)
	if is_instance_valid(player) and "velocity" in player:
		var v: Vector2 = player.velocity
		if v.length() > 8.0:
			return v.normalized()
	return _last_dir

func upgrade() -> void:
	super()
	if level % 2 == 0:
		needle_count += 1
