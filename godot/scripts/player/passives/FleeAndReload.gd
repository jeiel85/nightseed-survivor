extends CharacterPassive
class_name FleeAndReload

# Hunter signature — Flee & Reload / 재장전 도약
# Moving away from the nearest enemy: cooldown −12% (kiting reward).
# Standing still: damage +15% (aimed shot).
# Otherwise: neutral. 0.3s hysteresis so brief jitter doesn't flicker bonuses.

const MOVING_AWAY_CD_MULT := 0.88
const STANDING_DMG_MULT := 1.15
const HYSTERESIS_SECONDS := 0.3
const STILL_SPEED_THRESHOLD := 8.0  # px/s — below counts as still
const AWAY_DOT_THRESHOLD := -0.2     # velocity vs vector-to-enemy

enum State { NEUTRAL, FLEEING, STANDING }
var _state: int = State.NEUTRAL
var _candidate_state: int = State.NEUTRAL
var _candidate_timer: float = 0.0

func _on_setup() -> void:
	name_key = "char_passive_flee_reload_name"
	desc_key = "char_passive_flee_reload_desc"
	set_process(true)

func _process(delta: float) -> void:
	var classified: int = _classify()
	if classified == _state:
		_candidate_state = _state
		_candidate_timer = 0.0
		return
	if classified != _candidate_state:
		_candidate_state = classified
		_candidate_timer = 0.0
	_candidate_timer += delta
	if _candidate_timer >= HYSTERESIS_SECONDS:
		_state = _candidate_state
		_candidate_timer = 0.0
		_apply()

func _classify() -> int:
	var speed: float = player.velocity.length()
	if speed < STILL_SPEED_THRESHOLD:
		return State.STANDING
	var nearest := player._find_nearest_enemy()
	if not is_instance_valid(nearest):
		return State.NEUTRAL
	var to_enemy: Vector2 = (nearest.global_position - player.global_position).normalized()
	var move_dir: Vector2 = player.velocity.normalized()
	if to_enemy.dot(move_dir) < AWAY_DOT_THRESHOLD:
		return State.FLEEING
	return State.NEUTRAL

func _apply() -> void:
	match _state:
		State.STANDING:
			weapon_manager.passive_damage_mult = STANDING_DMG_MULT
			weapon_manager.passive_cooldown_mult = 1.0
		State.FLEEING:
			weapon_manager.passive_damage_mult = 1.0
			weapon_manager.passive_cooldown_mult = MOVING_AWAY_CD_MULT
		_:
			weapon_manager.passive_damage_mult = 1.0
			weapon_manager.passive_cooldown_mult = 1.0
	weapon_manager._refresh_weapon_multipliers()
