extends Node
class_name WaveManager

@export var slime_scene: PackedScene
@export var bat_scene: PackedScene
@export var knight_scene: PackedScene
@export var hound_scene: PackedScene
@export var boss_scene: PackedScene

var _elapsed: float = 0.0
var _current_wave_idx: int = -1
var _boss_spawned: bool = false
var _spawner: EnemySpawner

const WAVES: Array = [
	{"time": 0,   "interval": 1.6, "count": 2, "types": [0]},
	{"time": 60,  "interval": 1.3, "count": 2, "types": [0, 0, 1]},
	{"time": 120, "interval": 1.1, "count": 3, "types": [0, 1]},
	{"time": 240, "interval": 0.9, "count": 3, "types": [0, 1, 2]},
	{"time": 360, "interval": 0.75,"count": 4, "types": [0, 1, 2, 3]},
	{"time": 480, "interval": 0.55,"count": 4, "types": [1, 2, 3]},
	{"time": 570, "interval": 0.65,"count": 3, "types": [1, 3, 0]},
]

func setup(spawner: EnemySpawner) -> void:
	_spawner = spawner

func update(delta: float) -> void:
	_elapsed += delta
	_check_wave_transitions()
	if _elapsed >= 570.0 and not _boss_spawned and boss_scene != null:
		_boss_spawned = true
		_spawner.spawn_specific(boss_scene)

func _check_wave_transitions() -> void:
	var new_idx: int = 0
	for i in range(WAVES.size()):
		if _elapsed >= float(WAVES[i]["time"]):
			new_idx = i
	if new_idx != _current_wave_idx:
		_current_wave_idx = new_idx
		_apply_wave(new_idx)

func _apply_wave(idx: int) -> void:
	var wave: Dictionary = WAVES[idx]
	var all_scenes: Array = [slime_scene, bat_scene, knight_scene, hound_scene]
	var pool: Array = []
	for type_idx in wave["types"]:
		if type_idx < all_scenes.size() and all_scenes[type_idx] != null:
			pool.append(all_scenes[type_idx])
	if pool.is_empty():
		return
	_spawner.set_wave(pool, float(wave["interval"]), int(wave["count"]))
