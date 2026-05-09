extends Node

const POOL_SIZE: int = 8

var sounds: Dictionary = {}
var _players: Array = []
var _next_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

	sounds["pickup_xp"]   = SoundFx.tone(880.0, 0.06, 0.30, 0.4)
	sounds["pickup_gold"] = SoundFx.arpeggio([1046.0, 1396.0], 0.05, 0.30)
	sounds["level_up"]    = SoundFx.arpeggio([523.0, 659.0, 784.0], 0.08, 0.32)
	sounds["evolve"]      = SoundFx.arpeggio([523.0, 659.0, 784.0, 1047.0, 1318.0], 0.08, 0.34)
	sounds["kill"]        = SoundFx.tone(330.0, 0.08, 0.28, 0.3)
	sounds["hit"]         = SoundFx.tone(700.0, 0.05, 0.16)
	sounds["damage"]      = SoundFx.thud(0.18, 0.45)
	sounds["ui_click"]    = SoundFx.tone(660.0, 0.04, 0.22)
	sounds["boss_appear"] = SoundFx.sweep(120.0, 60.0, 0.6, 0.45)
	sounds["victory"]     = SoundFx.arpeggio([523.0, 659.0, 784.0, 1047.0], 0.18, 0.34)
	sounds["defeat"]      = SoundFx.sweep(440.0, 110.0, 0.7, 0.4)

func play(snd: String, volume_db: float = 0.0) -> void:
	if not sounds.has(snd):
		return
	var p: AudioStreamPlayer = _get_player()
	if p == null:
		return
	p.stream = sounds[snd]
	p.volume_db = volume_db
	p.play()

func _get_player() -> AudioStreamPlayer:
	for _i in range(POOL_SIZE):
		var p: AudioStreamPlayer = _players[_next_idx]
		_next_idx = (_next_idx + 1) % POOL_SIZE
		if not p.playing:
			return p
	# All playing — reuse oldest
	return _players[_next_idx]
