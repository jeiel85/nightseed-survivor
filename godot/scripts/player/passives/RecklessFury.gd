extends CharacterPassive
class_name RecklessFury

# Berserker signature — Reckless Fury / 무모한 분노
# Take damage → +8% damage stack for 4s, max 5 stacks. Each fresh hit refreshes
# the timer (full 4s) AND grants another stack. Berserker rewards getting hit
# — the "reckless" half of "reckless force".

const PER_STACK_BONUS := 0.08
const STACK_DURATION := 4.0
const MAX_STACKS := 5

var _stacks: int = 0
var _stack_timer: float = 0.0
var _prev_hp: int = -1

func _on_setup() -> void:
	name_key = "char_passive_reckless_fury_name"
	desc_key = "char_passive_reckless_fury_desc"
	set_process(true)
	player.hp_changed.connect(_on_hp_changed)
	_prev_hp = player.current_hp

func _on_hp_changed(current: int, _max_val: int) -> void:
	if _prev_hp < 0:
		_prev_hp = current
		return
	if current < _prev_hp:
		_stacks = mini(_stacks + 1, MAX_STACKS)
		_stack_timer = STACK_DURATION
		_refresh_damage()
	_prev_hp = current

func _process(delta: float) -> void:
	if _stacks == 0:
		return
	_stack_timer -= delta
	if _stack_timer <= 0.0:
		_stacks = 0
		_refresh_damage()

func _refresh_damage() -> void:
	weapon_manager.passive_damage_mult = 1.0 + float(_stacks) * PER_STACK_BONUS
	weapon_manager._refresh_weapon_multipliers()
