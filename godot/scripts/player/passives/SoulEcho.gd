extends CharacterPassive
class_name SoulEcho

# Spirit Sister signature — Soul Echo / 영혼의 메아리
# Below 50% HP: passive_xp_radius_bonus +60 (desperation pulls XP closer).
# At full HP: cooldown −4% (calm focus).
# Theme: fragile-magnetic, rewarded for HP extremes.

const LOW_HP_RATIO := 0.5
const LOW_HP_RADIUS_BONUS := 60.0
const FULL_HP_CD_MULT := 0.96

func _on_setup() -> void:
	name_key = "char_passive_soul_echo_name"
	desc_key = "char_passive_soul_echo_desc"
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.current_hp, player.max_hp)

func _on_hp_changed(current: int, max_val: int) -> void:
	var ratio: float = float(current) / float(maxi(max_val, 1))
	if ratio < LOW_HP_RATIO:
		player.passive_xp_radius_bonus = LOW_HP_RADIUS_BONUS
		weapon_manager.passive_cooldown_mult = 1.0
	elif ratio >= 1.0:
		player.passive_xp_radius_bonus = 0.0
		weapon_manager.passive_cooldown_mult = FULL_HP_CD_MULT
	else:
		player.passive_xp_radius_bonus = 0.0
		weapon_manager.passive_cooldown_mult = 1.0
	weapon_manager._refresh_weapon_multipliers()
