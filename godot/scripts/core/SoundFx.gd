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
static func arpeggio(freqs: Array, note_duration: float = 0.08, amplitude: float = 0.35) -> AudioStreamWAV:
	var per_note: int = int(SAMPLE_RATE * note_duration)
	var samples: int = per_note * freqs.size()
	var buf := PackedByteArray()
	buf.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var note_idx: int = i / per_note
		var local_t: float = float(i % per_note) / float(SAMPLE_RATE)
		var freq: float = float(freqs[note_idx])
		phase += freq * TAU / float(SAMPLE_RATE)
		var env: float = exp(-local_t * 8.0 / note_duration)
		_write_sample(buf, i, sin(phase) * env * amplitude)
	return _make_stream(buf)

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
