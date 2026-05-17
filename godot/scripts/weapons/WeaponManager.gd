extends Node2D
class_name WeaponManager

# Re-emitted whenever any owned weapon fires. EmberRenewal (Pyromancer
# signature passive) hooks this to count fires for its heal cadence.
signal weapon_fired

var weapons: Array = []
var passives: Dictionary = {
	"swift_boots": 0,
	"magnet_charm": 0,
	"iron_heart": 0,
	"battle_focus": 0,
	"power_core": 0,
}
var _init_damage_mult: float = 1.0
var _init_cooldown_mult: float = 1.0
# Per-character signature passives stamp into these. Multiplied on top of the
# init multipliers and shop passive bonuses inside _get_*_mult().
var passive_damage_mult: float = 1.0
var passive_cooldown_mult: float = 1.0

func add_weapon(weapon: WeaponBase) -> void:
	weapon.player = get_parent()
	weapon.damage_multiplier = _get_damage_mult()
	weapon.cooldown_multiplier = _get_cooldown_mult()
	# add_child fires the weapon's _ready, which sets the canonical weapon_name
	# (e.g. "Thorn Ring"). Append AFTER so has_weapon() never sees the default
	# "Weapon" placeholder mid-insert — that race let "new:" cards re-add a
	# starting weapon at Lv.1 alongside the existing upgraded one.
	add_child(weapon)
	weapons.append(weapon)
	weapon.fired.connect(_on_weapon_fired)

func _on_weapon_fired() -> void:
	weapon_fired.emit()

func has_weapon(wname: String) -> bool:
	for w in weapons:
		if w.weapon_name == wname:
			return true
	return false

func upgrade_weapon(wname: String) -> void:
	for w in weapons:
		if w.weapon_name == wname:
			w.upgrade()
			return

func evolve_weapon(wname: String) -> void:
	for w in weapons:
		if w.weapon_name == wname and not w.evolved:
			w.evolve()
			return

func apply_passive(key: String) -> void:
	passives[key] = passives.get(key, 0) + 1
	var p := get_parent()
	match key:
		"swift_boots":
			p.move_speed += 20.0
		"magnet_charm":
			p.xp_radius += 40.0
		"iron_heart":
			p.max_hp += 20
			p.current_hp = mini(p.current_hp + 20, p.max_hp)
			p.hp_changed.emit(p.current_hp, p.max_hp)
		"battle_focus", "power_core":
			_refresh_weapon_multipliers()

func get_passive_level(key: String) -> int:
	return passives.get(key, 0)

func _get_damage_mult() -> float:
	return _init_damage_mult * (1.0 + passives.get("power_core", 0) * 0.15) * passive_damage_mult

func _get_cooldown_mult() -> float:
	return maxf(_init_cooldown_mult * (1.0 - passives.get("battle_focus", 0) * 0.08) * passive_cooldown_mult, 0.3)

func _refresh_weapon_multipliers() -> void:
	var dm := _get_damage_mult()
	var cm := _get_cooldown_mult()
	for w in weapons:
		w.damage_multiplier = dm
		w.cooldown_multiplier = cm
