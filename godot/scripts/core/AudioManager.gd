extends Node

const POOL_SIZE: int = 8
# 사용자가 0..1 슬라이더로 조정한 볼륨을 dB로 변환할 때의 기준선.
# 0 → -60dB (실질 무음), 1 → 0dB (기존 콜사이트의 volume_db 인자에 합산).
const MIN_VOLUME_DB: float = -60.0

var sounds: Dictionary = {}
var _players: Array = []
var _next_idx: int = 0

var bgm_streams: Dictionary = {}
var _bgm_player: AudioStreamPlayer
var _current_bgm: String = ""
var _bgm_tween: Tween

# 사용자 볼륨 오프셋 (dB). 콜사이트가 넘긴 volume_db에 더해 적용한다.
var _bgm_user_db: float = 0.0
var _sfx_user_db: float = 0.0
var _bgm_target_db: float = -10.0  # play_bgm()이 최근 지정한 기본 dB. 슬라이더 즉시 반영용.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

	sounds["pickup_xp"]   = SoundFx.tone(880.0, 0.06, 0.30, 0.4)
	sounds["pickup_gold"] = SoundFx.arpeggio([1046.0, 1396.0], 0.05, 0.32, 0.45)
	sounds["level_up"]    = SoundFx.arpeggio([523.0, 659.0, 784.0], 0.09, 0.38, 0.5, 0.2)
	sounds["evolve"]      = SoundFx.arpeggio([523.0, 659.0, 784.0, 1047.0, 1318.0], 0.09, 0.42, 0.55, 0.25)
	sounds["kill"]        = SoundFx.punch_tone(280.0, 0.10, 0.40, 0.6, 0.45)
	sounds["hit"]         = SoundFx.punch_tone(720.0, 0.06, 0.24, 0.4, 0.35)
	sounds["damage"]      = SoundFx.thud(0.22, 0.55)
	sounds["ui_click"]    = SoundFx.tone(660.0, 0.04, 0.22)
	sounds["boss_appear"] = SoundFx.boom(0.75, 0.55)
	sounds["victory"]     = SoundFx.arpeggio([523.0, 659.0, 784.0, 1047.0], 0.18, 0.42, 0.55, 0.30)
	sounds["defeat"]      = SoundFx.sweep(440.0, 90.0, 0.8, 0.45)

	# Procedural BGM. ~16s loops, generated once at startup.
	# Different root notes + tempo + mood create distinct atmospheres.
	bgm_streams["menu"] = SoundFx.bgm_loop(220.0, 72.0, 8, "menu", 0.16)
	bgm_streams["game"] = SoundFx.bgm_loop(196.0, 104.0, 8, "game", 0.16)
	bgm_streams["boss"] = SoundFx.bgm_loop(165.0, 132.0, 8, "boss", 0.18)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)

	# GameData가 먼저 _ready()로 디스크에서 값을 읽고, AudioManager는 그 뒤에
	# _ready()된다 (autoload 등록 순서). 안전하게 _apply_user_volumes_from_data()로
	# 한 번 동기화하여 첫 메뉴 BGM이 사용자 설정 볼륨으로 재생되도록 한다.
	_apply_user_volumes_from_data()

func _apply_user_volumes_from_data() -> void:
	if GameData == null:
		return
	_bgm_user_db = _linear_to_db(GameData.bgm_volume)
	_sfx_user_db = _linear_to_db(GameData.sfx_volume)

# 슬라이더(0..1)를 콜사이트 볼륨에 합산할 dB 오프셋으로 변환.
# 1 → 0dB, 0 → -60dB (실질 무음). 중간 값은 선형 dB로 매핑 — 사람의 인지와는
# 정확히 일치하지 않지만 슬라이더 UX로는 충분히 자연스럽다.
func _linear_to_db(v: float) -> float:
	v = clampf(v, 0.0, 1.0)
	if v <= 0.0:
		return MIN_VOLUME_DB
	return lerpf(MIN_VOLUME_DB, 0.0, v)

func set_bgm_volume(v: float) -> void:
	_bgm_user_db = _linear_to_db(v)
	# 현재 재생 중인 BGM에 즉시 반영. play_bgm의 fade tween과 싸우지 않도록 tween을 끊는다.
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
	if _bgm_player:
		_bgm_player.volume_db = _bgm_target_db + _bgm_user_db

func set_sfx_volume(v: float) -> void:
	_sfx_user_db = _linear_to_db(v)
	# SFX는 매 play()마다 볼륨을 다시 적용하므로 다음 호출부터 자동 반영된다.

func play(snd: String, volume_db: float = 0.0) -> void:
	if not sounds.has(snd):
		return
	var p: AudioStreamPlayer = _get_player()
	if p == null:
		return
	p.stream = sounds[snd]
	p.volume_db = volume_db + _sfx_user_db
	p.play()

func play_bgm(name: String, volume_db: float = -10.0, fade_sec: float = 0.6) -> void:
	if not bgm_streams.has(name):
		return
	if _current_bgm == name and _bgm_player.playing:
		return
	_current_bgm = name
	_bgm_target_db = volume_db
	var final_db := volume_db + _bgm_user_db
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
	# Fade-out current, swap, fade-in new
	_bgm_tween = create_tween()
	if _bgm_player.playing:
		_bgm_tween.tween_property(_bgm_player, "volume_db", -40.0, fade_sec * 0.5)
		_bgm_tween.tween_callback(_swap_bgm.bind(name, final_db))
	else:
		_swap_bgm(name, final_db)
		_bgm_player.volume_db = -40.0
	_bgm_tween.tween_property(_bgm_player, "volume_db", final_db, fade_sec * 0.7)

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

# 일시정지 메뉴에서 BGM을 잠시 멈춘다. stream_paused는 위치를 유지한 채 정지하므로
# resume 시 같은 지점에서 이어진다. SFX 풀(_players)도 함께 멈춰 효과음 잔향이
# 일시정지 화면 너머로 새지 않도록 한다.
func set_paused(p: bool) -> void:
	if _bgm_player:
		_bgm_player.stream_paused = p
	for player in _players:
		if player is AudioStreamPlayer:
			player.stream_paused = p

func _get_player() -> AudioStreamPlayer:
	for _i in range(POOL_SIZE):
		var p: AudioStreamPlayer = _players[_next_idx]
		_next_idx = (_next_idx + 1) % POOL_SIZE
		if not p.playing:
			return p
	return _players[_next_idx]
