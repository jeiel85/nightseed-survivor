extends CharacterBody2D
class_name Player

signal hp_changed(current: int, max_val: int)
signal died
signal xp_changed(current: int, needed: int)
signal leveled_up(level: int)
signal gold_changed(total: int)
signal kill_count_changed(count: int)

@export var move_speed: float = 160.0
@export var max_hp: int = 100
@export var invincible_duration: float = 0.5

var current_hp: int
var xp_radius: float = 80.0
# Character signature passives (SoulEcho specifically) stamp a transient
# bonus here. _handle_pickups adds it to the base xp_radius so the magnet
# pull respects both shop-bought magnet_charm and conditional passives.
var passive_xp_radius_bonus: float = 0.0
var current_xp: int = 0
var current_level: int = 1
var kill_count: int = 0
var session_gold: int = 0
var _invincible_timer: float = 0.0

@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var aura: Polygon2D = $Visual/Aura
@onready var sprite_visual: Sprite2D = $Visual/Sprite
@onready var aim_visual: Polygon2D = $Visual/Aim

func _ready() -> void:
	var ch: Dictionary = Characters.get_data(GameData.selected_character)
	max_hp = int(ch["max_hp"]) + GameData.get_hp_bonus()
	move_speed = float(ch["move_speed"]) + GameData.get_speed_bonus()
	xp_radius = float(ch["xp_radius"]) + GameData.get_magnet_bonus()
	weapon_manager._init_damage_mult = float(ch["damage_mult"]) * GameData.get_damage_multiplier()
	weapon_manager._init_cooldown_mult = float(ch["cooldown_mult"]) * GameData.get_cooldown_multiplier()
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	xp_changed.emit(0, get_xp_needed())
	if sprite_visual and ch.has("sprite"):
		var tex: Texture2D = load(String(ch["sprite"]))
		if tex:
			sprite_visual.texture = tex
	if aura:
		var aura_c: Color = ch["color"]
		aura_c.a = 0.18
		aura.color = aura_c
	var w := _create_starting_weapon(ch["starting_weapon"])
	if w:
		weapon_manager.add_weapon(w)
	# Signature passive — instantiated AFTER the starting weapon so EmberRenewal
	# can connect to weapon_manager.weapon_fired in time for the first shot.
	var passive_id: String = String(ch.get("passive_id", ""))
	if not passive_id.is_empty():
		var passive_node := _create_passive(passive_id)
		if passive_node:
			add_child(passive_node)
			passive_node.setup(self)

func _create_starting_weapon(weapon_name: String) -> WeaponBase:
	match weapon_name:
		"Moon Dagger":  return MoonDagger.new()
		"Spirit Orb":   return SpiritOrb.new()
		"Fire Wisp":    return FireWisp.new()
		"Thorn Ring":   return ThornRing.new()
		"Star Needle":  return StarNeedle.new()
	return MoonDagger.new()

func _create_passive(id: String) -> CharacterPassive:
	match id:
		"blade_dance":   return BladeDance.new()
		"soul_echo":     return SoulEcho.new()
		"flee_reload":   return FleeAndReload.new()
		"reckless_fury": return RecklessFury.new()
		"ember_renewal": return EmberRenewal.new()
	return null

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.is_zero_approx():
		input = TouchInput.move_vector
	if input.length() > 1.0:
		input = input.normalized()
	velocity = input * move_speed
	move_and_slide()
	if _invincible_timer > 0.0:
		_invincible_timer = maxf(_invincible_timer - delta, 0.0)
	_handle_pickups()
	_update_visuals(delta)

func _update_visuals(delta: float) -> void:
	if aura:
		var t: float = float(Time.get_ticks_msec()) / 1000.0
		var s: float = 1.0 + 0.08 * sin(t * 2.5)
		aura.scale = Vector2(s, s)
	if aim_visual:
		var nearest := _find_nearest_enemy()
		if is_instance_valid(nearest):
			aim_visual.visible = true
			var dir: Vector2 = global_position.direction_to(nearest.global_position)
			aim_visual.rotation = dir.angle()
			aim_visual.position = dir * 24.0
		else:
			aim_visual.visible = false

func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nd: float = INF
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d: float = global_position.distance_squared_to(e.global_position)
		if d < nd:
			nd = d
			nearest = e
	return nearest

func _handle_pickups() -> void:
	var effective_radius: float = xp_radius + passive_xp_radius_bonus
	for gem in get_tree().get_nodes_in_group("xp_gems"):
		if not is_instance_valid(gem):
			continue
		var dist := global_position.distance_to(gem.global_position)
		if dist <= effective_radius and gem.has_method("attract"):
			gem.attract(global_position)
		if dist <= 22.0 and gem.has_method("collect"):
			gem.collect(self)

	for coin in get_tree().get_nodes_in_group("gold_coins"):
		if not is_instance_valid(coin):
			continue
		var dist := global_position.distance_to(coin.global_position)
		if dist <= effective_radius and coin.has_method("attract"):
			coin.attract(global_position)
		if dist <= 22.0 and coin.has_method("collect"):
			coin.collect(self)

func apply_damage(amount: int) -> void:
	if _invincible_timer > 0.0 or current_hp <= 0:
		return
	current_hp = maxi(current_hp - amount, 0)
	_invincible_timer = invincible_duration
	AudioManager.play("damage", -4.0)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

# Called by GameRoot after a rewarded-ad revive grant. Heals to half max
# and grants a longer-than-normal invincibility window so the player can
# re-orient before re-engaging.
func revive(hp_ratio: float = 0.5, invincibility_seconds: float = 3.0) -> void:
	current_hp = maxi(int(float(max_hp) * hp_ratio), 1)
	_invincible_timer = invincibility_seconds
	hp_changed.emit(current_hp, max_hp)

func add_xp(amount: int) -> void:
	current_xp += amount
	var needed := get_xp_needed()
	while current_xp >= needed:
		current_xp -= needed
		current_level += 1
		needed = get_xp_needed()
		leveled_up.emit(current_level)
	xp_changed.emit(current_xp, get_xp_needed())

func add_gold(amount: int) -> void:
	session_gold += amount
	gold_changed.emit(session_gold)

func add_kill() -> void:
	kill_count += 1
	kill_count_changed.emit(kill_count)

func get_xp_needed() -> int:
	return 5 + current_level * 4
