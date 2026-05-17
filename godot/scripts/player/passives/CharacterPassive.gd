extends Node
class_name CharacterPassive

# Base for per-character signature passives. One is created in Player._ready
# from Characters.gd's `passive_id` field and added as a child of Player.
#
# Subclasses tap into Player signals (kill_count_changed, hp_changed) or
# WeaponManager.weapon_fired, and modify either:
#   - weapon_manager.passive_damage_mult / passive_cooldown_mult, then call
#     weapon_manager._refresh_weapon_multipliers() to push to all weapons
#   - player.passive_xp_radius_bonus (folded into the pickup radius)
#   - player.current_hp directly (heals)
#
# Keep mechanics conditional (HP threshold, kill streak, etc.) so the passive
# reads as a class identity trait rather than a flat stat bonus.

var player: Player
var weapon_manager: WeaponManager

# Localization keys. CharacterSelect / future tooltips read these.
var name_key: String = ""
var desc_key: String = ""

func setup(p: Player) -> void:
	player = p
	weapon_manager = p.weapon_manager
	_on_setup()

# Subclasses override.
func _on_setup() -> void:
	pass
