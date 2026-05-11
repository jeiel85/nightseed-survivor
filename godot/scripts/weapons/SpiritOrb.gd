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

const ORB_TEX := preload("res://assets/sprites/proj_orb.png")

func _make_orb() -> Node2D:
	var node := Node2D.new()
	# Soft cyan glow halo
	var halo := Polygon2D.new()
	var hpts := PackedVector2Array()
	for i in range(12):
		var a := i * TAU / 12.0
		hpts.append(Vector2(cos(a), sin(a)) * 16.0)
	halo.polygon = hpts
	halo.color = Color(0.4, 0.9, 1.0, 0.28)
	node.add_child(halo)
	# Sprite
	var sprite := Sprite2D.new()
	sprite.texture = ORB_TEX
	sprite.scale = Vector2(1.6, 1.6)
	sprite.modulate = Color(0.6, 0.95, 1.1)
	node.add_child(sprite)
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

func evolve() -> void:
	super()
	orb_count = max(orb_count * 2, 6)
	orbit_radius = 130.0
	orbit_speed = 2.8
	_rebuild_orbs()
