extends WeaponBase
class_name SpiritOrb

var orb_count: int = 1
var orbit_radius: float = 85.0
var orbit_speed: float = 2.2
var _orbit_angle: float = 0.0
var _orbs: Array = []
var _damage_timer: float = 0.0

const DAMAGE_INTERVAL: float = 0.35

func _ready() -> void:
	weapon_name = "Spirit Orb"
	base_damage = 8
	base_cooldown = 9999.0
	_rebuild_orbs()

func _rebuild_orbs() -> void:
	for orb in _orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	_orbs.clear()
	for i in range(orb_count):
		var orb := _make_orb()
		add_child(orb)
		_orbs.append(orb)

func _make_orb() -> Node2D:
	var node := Node2D.new()
	var vis := Polygon2D.new()
	vis.color = Color(0.4, 0.9, 1.0, 0.9)
	var pts := PackedVector2Array()
	for i in range(8):
		var a := i * TAU / 8.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 10.0))
	vis.polygon = pts
	node.add_child(vis)
	return node

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_orbit_angle += orbit_speed * delta
	for i in range(_orbs.size()):
		var orb = _orbs[i]
		if not is_instance_valid(orb):
			continue
		var angle := _orbit_angle + (TAU * float(i) / float(_orbs.size()))
		orb.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * orbit_radius

	_damage_timer -= delta
	if _damage_timer <= 0.0:
		_damage_timer = DAMAGE_INTERVAL * cooldown_multiplier
		_deal_orb_damage()

func _deal_orb_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for orb in _orbs:
		if not is_instance_valid(orb):
			continue
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if orb.global_position.distance_to(enemy.global_position) <= 24.0:
				if enemy.has_method("take_damage"):
					enemy.take_damage(get_damage())

func fire() -> void:
	pass

func upgrade() -> void:
	super()
	if level % 2 == 0:
		orb_count += 1
		_rebuild_orbs()
