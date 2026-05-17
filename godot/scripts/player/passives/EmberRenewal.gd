extends CharacterPassive
class_name EmberRenewal

# Pyromancer signature — Ember Renewal / 재연소
# Every 3 weapon fires: heal +5 HP (capped at +50% of starting max_hp per run
# so it doesn't trivialize tanking by holding fire on enemies).
# While below max HP: cooldown −3%.
# Theme: casting renews the wisp — the more you burn, the more you mend.

const FIRES_PER_HEAL := 3
const HEAL_AMOUNT := 5
const HEAL_CAP_RATIO := 0.5
const LOW_HP_CD_MULT := 0.97

var _fire_count: int = 0
var _total_healed: int = 0
var _heal_cap: int = 0

func _on_setup() -> void:
	name_key = "char_passive_ember_renewal_name"
	desc_key = "char_passive_ember_renewal_desc"
	_heal_cap = int(float(player.max_hp) * HEAL_CAP_RATIO)
	player.hp_changed.connect(_on_hp_changed)
	weapon_manager.weapon_fired.connect(_on_weapon_fired)
	_on_hp_changed(player.current_hp, player.max_hp)

func _on_weapon_fired() -> void:
	_fire_count += 1
	if _fire_count < FIRES_PER_HEAL:
		return
	_fire_count = 0
	if _total_healed >= _heal_cap:
		return
	if player.current_hp >= player.max_hp:
		return
	var heal: int = mini(HEAL_AMOUNT, _heal_cap - _total_healed)
	heal = mini(heal, player.max_hp - player.current_hp)
	if heal <= 0:
		return
	_total_healed += heal
	player.current_hp += heal
	player.hp_changed.emit(player.current_hp, player.max_hp)

func _on_hp_changed(current: int, max_val: int) -> void:
	if current < max_val:
		weapon_manager.passive_cooldown_mult = LOW_HP_CD_MULT
	else:
		weapon_manager.passive_cooldown_mult = 1.0
	weapon_manager._refresh_weapon_multipliers()
