class_name SoundFx
extends RefCounted

const SAMPLE_RATE: int = 44100

static func _make_stream(buf: PackedByteArray) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SAMPLE_RATE
	s.stereo = false
	s.data = buf
	return s

static func _write_sample(buf: PackedByteArray, idx: int, value: float) -> void:
	var v: int = clampi(int(value * 32767.0), -32767, 32767)
	if v < 0:
		v = 65536 + v
	buf[idx * 2] = v & 0xFF
	buf[idx * 2 + 1] = (v >> 8) & 0xFF

# Single tone with exponential decay envelope
static func tone(freq: float, duration: float, amplitude: float = 0.35, harmonic: float = 0.0) -> AudioStreamWAV:
	var samples: int = int(SAMPLE_RATE * duration)
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var attack_samples: int = int(SAMPLE_RATE * 0.005)
	for i in range(samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-t * 5.0 / duration)
		if i < attack_samples:
			env *= float(i) / float(attack_samples)
		var v: float = sin(t * freq * TAU)
		if harmonic > 0.0:
			v += harmonic * sin(t * freq * 2.0 * TAU)
			v *= 1.0 / (1.0 + harmonic)
		_write_sample(buf, i, v * env * amplitude)
	return _make_stream(buf)

# Sweep up (rising pitch) - good for level-up
static func sweep(freq_start: float, freq_end: float, duration: float, amplitude: float = 0.35) -> AudioStreamWAV:
	var samples: int = int(SAMPLE_RATE * duration)
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var phase: float = 0.0
	var attack_samples: int = int(SAMPLE_RATE * 0.005)
	for i in range(samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var p: float = t / duration
		var freq: float = lerp(freq_start, freq_end, p)
		phase += freq * TAU / float(SAMPLE_RATE)
		var env: float = (1.0 - p)
		if i < attack_samples:
			env *= float(i) / float(attack_samples)
		_write_sample(buf, i, sin(phase) * env * amplitude)
	return _make_stream(buf)

# 3-note arpeggio - good for level up / evolve
# `harmonic` adds a 2nd-partial overtone for richer body.
# `sub` adds a 3rd-partial overtone for sparkle (helpful for victory/evolve).
static func arpeggio(freqs: Array, note_duration: float = 0.08, amplitude: float = 0.35, harmonic: float = 0.0, sub: float = 0.0) -> AudioStreamWAV:
	var per_note: int = int(SAMPLE_RATE * note_duration)
	var samples: int = per_note * freqs.size()
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var phase: float = 0.0
	var h_phase: float = 0.0
	var s_phase: float = 0.0
	for i in range(samples):
		var note_idx: int = i / per_note
		var local_t: float = float(i % per_note) / float(SAMPLE_RATE)
		var freq: float = float(freqs[note_idx])
		phase += freq * TAU / float(SAMPLE_RATE)
		var v: float = sin(phase)
		if harmonic > 0.0:
			h_phase += freq * 2.0 * TAU / float(SAMPLE_RATE)
			v += harmonic * sin(h_phase)
		if sub > 0.0:
			s_phase += freq * 3.0 * TAU / float(SAMPLE_RATE)
			v += sub * sin(s_phase)
		var norm: float = 1.0 + harmonic + sub
		if norm > 1.0:
			v /= norm
		var env: float = exp(-local_t * 8.0 / note_duration)
		_write_sample(buf, i, v * env * amplitude)
	return _make_stream(buf)

# Punch-y tone: short noise transient on the attack + harmonic body.
# Good for hits/kills where pure sine feels too soft.
static func punch_tone(freq: float, duration: float, amplitude: float = 0.4, harmonic: float = 0.5, noise_amt: float = 0.45) -> AudioStreamWAV:
	var samples: int = int(SAMPLE_RATE * duration)
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var attack_samples: int = int(SAMPLE_RATE * 0.003)
	var noise_decay_samples: int = int(SAMPLE_RATE * 0.018)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = exp(-t * 7.0 / duration)
		if i < attack_samples:
			env *= float(i) / float(attack_samples)
		var v: float = sin(t * freq * TAU)
		if harmonic > 0.0:
			v += harmonic * sin(t * freq * 2.0 * TAU)
			v /= 1.0 + harmonic
		# Brief noise burst on attack only — adds bite without muddying the tail.
		if i < noise_decay_samples:
			var n_env: float = 1.0 - float(i) / float(noise_decay_samples)
			v += rng.randf_range(-1.0, 1.0) * noise_amt * n_env
		_write_sample(buf, i, v * env * amplitude)
	return _make_stream(buf)

# Boom: low rumble swept down + noise tail. For boss appearance, etc.
static func boom(duration: float = 0.7, amplitude: float = 0.5) -> AudioStreamWAV:
	var samples: int = int(SAMPLE_RATE * duration)
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var phase: float = 0.0
	var noise_prev: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var p: float = t / duration
		var freq: float = lerp(140.0, 38.0, sqrt(p))
		phase += freq * TAU / float(SAMPLE_RATE)
		var env: float = exp(-t * 3.0)
		var raw: float = rng.randf_range(-1.0, 1.0)
		noise_prev = lerp(noise_prev, raw, 0.06)
		var v: float = sin(phase) * 0.75 + noise_prev * 0.55
		_write_sample(buf, i, v * env * amplitude)
	return _make_stream(buf)

# Procedural BGM loop. Lo-fi bass drone + sparse melody from a minor scale,
# with subtle ambient noise. Mood scales the density and bass octave pattern.
# mood ∈ {"menu", "game", "boss"}.
static func bgm_loop(root_freq: float, bpm: float, bars: int, mood: String = "menu", amplitude: float = 0.18) -> AudioStreamWAV:
	var beat_samples: int = int(SAMPLE_RATE * 60.0 / bpm)
	var total_beats: int = bars * 4
	var samples: int = beat_samples * total_beats
	var buf := PackedByteArray()
	buf.resize(samples * 2)

	# Natural minor scale degrees (1, 2, b3, 4, 5, b6, b7)
	var scale: Array = [1.0, 1.122, 1.189, 1.335, 1.498, 1.587, 1.782]

	var rng := RandomNumberGenerator.new()
	var mood_salt: int = 1
	match mood:
		"game": mood_salt = 7
		"boss": mood_salt = 13
	rng.seed = int(root_freq * 100.0) + mood_salt

	var rest_prob: float = 0.55
	var mel_amp_mult: float = 0.30
	var bass_oct_alt: bool = false
	var kick_amp: float = 0.0
	var hat_amp: float = 0.0
	var hat_on_beat: bool = false
	match mood:
		"game":
			rest_prob = 0.32
			mel_amp_mult = 0.34
			kick_amp = 0.55
			hat_amp = 0.22
		"boss":
			rest_prob = 0.16
			mel_amp_mult = 0.42
			bass_oct_alt = true
			kick_amp = 0.72
			hat_amp = 0.28
			hat_on_beat = true

	# Pre-render one-shot drum samples (kick + hi-hat). Mixed in below at each beat.
	var kick_len: int = int(SAMPLE_RATE * 0.14)
	var kick_data: PackedFloat32Array = PackedFloat32Array()
	kick_data.resize(kick_len)
	var k_phase: float = 0.0
	for ki in range(kick_len):
		var kt: float = float(ki) / float(SAMPLE_RATE)
		var kp: float = kt / 0.14
		var kfreq: float = lerp(120.0, 42.0, sqrt(kp))
		k_phase += kfreq * TAU / float(SAMPLE_RATE)
		var kenv: float = exp(-kt * 16.0)
		# Click on attack for sharper transient
		var click: float = 0.0
		if ki < int(SAMPLE_RATE * 0.004):
			click = sin(kt * 1800.0 * TAU) * exp(-kt * 600.0) * 0.45
		kick_data[ki] = (sin(k_phase) + click) * kenv

	var hat_len: int = int(SAMPLE_RATE * 0.045)
	var hat_data: PackedFloat32Array = PackedFloat32Array()
	hat_data.resize(hat_len)
	var hrng := RandomNumberGenerator.new()
	hrng.seed = int(root_freq) + mood_salt * 31
	var h_prev: float = 0.0
	for hi in range(hat_len):
		var ht: float = float(hi) / float(SAMPLE_RATE)
		var hraw: float = hrng.randf_range(-1.0, 1.0)
		h_prev = lerp(h_prev, hraw, 0.72)
		var hpv: float = hraw - h_prev * 0.5
		var henv: float = exp(-ht * 65.0)
		hat_data[hi] = hpv * henv

	# Compose melody (per beat). Slight rest weighting on first beat for breathing room
	var melody := []
	for b in range(total_beats):
		if (b == 0) or (rng.randf() < rest_prob):
			melody.append(-1.0)
		else:
			var idx: int = rng.randi() % scale.size()
			var oct_mult: float = 1.0 if rng.randf() > 0.4 else 2.0
			melody.append(root_freq * float(scale[idx]) * oct_mult)

	# Bass pattern: root mostly, fifth on accent beats
	var bass_pattern := []
	for b in range(total_beats):
		var base: float = root_freq * 0.5
		if bass_oct_alt and b % 4 == 2:
			base *= 2.0  # alternate higher bass for tension
		elif b % 8 == 4:
			base *= 1.5  # fifth
		bass_pattern.append(base)

	var bass_phase: float = 0.0
	var mel_phase: float = 0.0
	var noise_prev: float = 0.0
	var nrng := RandomNumberGenerator.new()
	nrng.seed = int(root_freq) + mood_salt * 17

	for i in range(samples):
		var beat_idx: int = i / beat_samples
		if beat_idx >= total_beats:
			beat_idx = total_beats - 1
		var beat_t: float = float(i % beat_samples) / float(beat_samples)

		var bass_freq: float = float(bass_pattern[beat_idx])
		bass_phase += bass_freq * TAU / float(SAMPLE_RATE)
		# Slow tremolo on bass for warmth
		var trem: float = 0.85 + 0.15 * sin(float(i) / float(SAMPLE_RATE) * TAU * 0.5)
		var bass: float = sin(bass_phase) * 0.42 * trem

		var mel_freq: float = float(melody[beat_idx])
		var mel: float = 0.0
		if mel_freq > 0.0:
			mel_phase += mel_freq * TAU / float(SAMPLE_RATE)
			# Soft attack/decay envelope per beat
			var env: float = exp(-beat_t * 3.2) * (1.0 - 0.3 * beat_t)
			if beat_t < 0.02:
				env *= beat_t / 0.02
			mel = sin(mel_phase) * mel_amp_mult * env

		var noise_raw: float = nrng.randf_range(-1.0, 1.0)
		noise_prev = lerp(noise_prev, noise_raw, 0.025)
		var amb: float = noise_prev * 0.045

		# Drum mix: kick on every beat, hi-hat on the offbeat (and on-beat for boss).
		var drum: float = 0.0
		if kick_amp > 0.0:
			var bp: int = i - beat_idx * beat_samples
			if bp >= 0 and bp < kick_len:
				drum += kick_data[bp] * kick_amp
			var half_pos: int = bp - beat_samples / 2
			if half_pos >= 0 and half_pos < hat_len:
				drum += hat_data[half_pos] * hat_amp
			if hat_on_beat and bp >= 0 and bp < hat_len:
				drum += hat_data[bp] * hat_amp * 0.55

		_write_sample(buf, i, (bass + mel + amb + drum) * amplitude)

	var stream := _make_stream(buf)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = samples
	return stream

# Low thud (filtered noise)
static func thud(duration: float = 0.18, amplitude: float = 0.4) -> AudioStreamWAV:
	var samples: int = int(SAMPLE_RATE * duration)
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var prev: float = 0.0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var raw: float = rng.randf_range(-1.0, 1.0)
		# 1-pole low pass
		prev = lerp(prev, raw, 0.04)
		var env: float = exp(-t * 12.0)
		var tone: float = sin(t * 80.0 * TAU) * 0.7
		_write_sample(buf, i, (prev * 0.6 + tone) * env * amplitude)
	return _make_stream(buf)
