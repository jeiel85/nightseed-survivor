extends Node

const POOL_SIZE: int = 8

var sounds: Dictionary = {}
var _players: Array = []
var _next_idx: int = 0

var bgm_streams: Dictionary = {}
var _bgm_player: AudioStreamPlayer
var _current_bgm: String = ""
var _bgm_tween: Tween

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

	# Procedural BGM. ~16s loops, generated once at startup.
	# Different root notes + tempo + mood create distinct atmospheres.
	bgm_streams["menu"] = SoundFx.bgm_loop(220.0, 72.0, 8, "menu", 0.16)
	bgm_streams["game"] = SoundFx.bgm_loop(196.0, 104.0, 8, "game", 0.16)
	bgm_streams["boss"] = SoundFx.bgm_loop(165.0, 132.0, 8, "boss", 0.18)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)

func play(snd: String, volume_db: float = 0.0) -> void:
	if not sounds.has(snd):
		return
	var p: AudioStreamPlayer = _get_player()
	if p == null:
		return
	p.stream = sounds[snd]
	p.volume_db = volume_db
	p.play()

func play_bgm(name: String, volume_db: float = -10.0, fade_sec: float = 0.6) -> void:
	if not bgm_streams.has(name):
		return
	if _current_bgm == name and _bgm_player.playing:
		return
	_current_bgm = name
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
	# Fade-out current, swap, fade-in new
	_bgm_tween = create_tween()
	if _bgm_player.playing:
		_bgm_tween.tween_property(_bgm_player, "volume_db", -40.0, fade_sec * 0.5)
		_bgm_tween.tween_callback(_swap_bgm.bind(name, volume_db))
	else:
		_swap_bgm(name, volume_db)
		_bgm_player.volume_db = -40.0
	_bgm_tween.tween_property(_bgm_player, "volume_db", volume_db, fade_sec * 0.7)

func _swap_bgm(name: String, target_volume: float) -> void:
	_bgm_player.stop()
	_bgm_player.stream = bgm_streams[name]
	_bgm_player.volume_db = -40.0
	_bgm_player.play()

func stop_bgm(fade_sec: float = 0.4) -> void:
	if not _bgm_player.playing:
		return
	_current_bgm = ""
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(_bgm_player, "volume_db", -40.0, fade_sec)
	_bgm_tween.tween_callback(_bgm_player.stop)

func _get_player() -> AudioStreamPlayer:
	for _i in range(POOL_SIZE):
		var p: AudioStreamPlayer = _players[_next_idx]
		_next_idx = (_next_idx + 1) % POOL_SIZE
		if not p.playing:
			return p
	return _players[_next_idx]
