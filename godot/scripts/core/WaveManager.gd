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
var _stage: Dictionary = {}
var _waves: Array = []
var _scene_map: Dictionary = {}
var _boss_time: float = 570.0
var _total_time: float = 600.0

func _ready() -> void:
	_scene_map = {
		"slime": slime_scene,
		"bat": bat_scene,
		"knight": knight_scene,
		"hound": hound_scene,
		"boss": boss_scene,
	}

func setup(spawner: EnemySpawner, stage_id: String = "") -> void:
	_spawner = spawner
	if stage_id.is_empty():
		stage_id = GameData.selected_stage if GameData.selected_stage else Stages.get_default_id()
	_stage = Stages.get_stage(stage_id)
	if _stage.is_empty():
		push_error("WaveManager: stage '%s' not found" % stage_id)
		return
	_waves = _stage.get("waves", [])
	_boss_time = float(_stage.get("boss_time", 570.0))
	_total_time = float(_stage.get("total_time", 600.0))

func get_total_time() -> float:
	return _total_time

func update(delta: float) -> void:
	_elapsed += delta
	_check_wave_transitions()
	if _elapsed >= _boss_time and not _boss_spawned and boss_scene != null:
		_boss_spawned = true
		var boss_type: String = String(_stage.get("boss_type", "boss"))
		var bs: PackedScene = _scene_map.get(boss_type, boss_scene)
		_spawner.spawn_specific(bs)
		AudioManager.play("boss_appear", 0.0)

func _check_wave_transitions() -> void:
	if _waves.is_empty():
		return
	var new_idx: int = 0
	for i in range(_waves.size()):
		if _elapsed >= float(_waves[i].get("time", 0.0)):
			new_idx = i
	if new_idx != _current_wave_idx:
		_current_wave_idx = new_idx
		_apply_wave(new_idx)

func _apply_wave(idx: int) -> void:
	var wave: Dictionary = _waves[idx]
	var pool: Array = []
	for type_str in wave.get("types", []):
		var sc: PackedScene = _scene_map.get(String(type_str), null)
		if sc != null:
			pool.append(sc)
	if pool.is_empty():
		return
	_spawner.set_wave(pool, float(wave.get("interval", 1.0)), int(wave.get("count", 2)))
