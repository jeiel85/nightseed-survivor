extends CharacterPassive
class_name BladeDance

# Vagrant signature — Blade Dance / 칼날 무용
# Every 5 kills gain a stack of +5% damage lasting 8s, up to 3 stacks.
# Each fresh stack refreshes the timer for all current stacks.
# Reinforces Vagrant's rhythm: stay engaged and the blade sings louder.

const KILLS_PER_STACK := 5
const STACK_DURATION := 8.0
const PER_STACK_BONUS := 0.05
const MAX_STACKS := 3

var _stacks: int = 0
var _stack_remaining: float = 0.0
var _kill_progress: int = 0
var _prev_kill_count: int = 0

func _on_setup() -> void:
	name_key = "char_passive_blade_dance_name"
	desc_key = "char_passive_blade_dance_desc"
	set_process(true)
	player.kill_count_changed.connect(_on_kill)
	_prev_kill_count = player.kill_count

func _on_kill(count: int) -> void:
	var delta_kills: int = count - _prev_kill_count
	_prev_kill_count = count
	if delta_kills <= 0:
		return
	_kill_progress += delta_kills
	while _kill_progress >= KILLS_PER_STACK:
		_kill_progress -= KILLS_PER_STACK
		_stacks = mini(_stacks + 1, MAX_STACKS)
		_stack_remaining = STACK_DURATION
		_refresh_damage()

func _process(delta: float) -> void:
	if _stacks == 0:
		return
	_stack_remaining -= delta
	if _stack_remaining <= 0.0:
		_stacks = 0
		_refresh_damage()

func _refresh_damage() -> void:
	weapon_manager.passive_damage_mult = 1.0 + float(_stacks) * PER_STACK_BONUS
	weapon_manager._refresh_weapon_multipliers()
