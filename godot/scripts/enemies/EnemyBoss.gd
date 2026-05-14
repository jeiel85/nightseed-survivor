extends EnemyBase

# Final boss. Picks up an "enraged" phase once HP drops below ENRAGE_HP_RATIO:
#   - Aura swells to a hot red
#   - Spikes spin faster
#   - Body sprite pulses
#   - Contact damage and move speed scale up by a fixed multiplier
#   - Periodically emits a radial spread of slow projectiles so the last
#     30s feels like a real climax rather than a softer enemy with more HP.
# Per COMMERCIALIZATION_ANALYSIS.md §5.3: "the final boss should be a
# 30-second goal, not decoration."

const ENEMY_PROJECTILE_SCENE := preload("res://scenes/enemies/EnemyProjectile.tscn")
const ENRAGE_HP_RATIO: float = 0.30
const ENRAGE_DAMAGE_MULT: float = 1.45
const ENRAGE_SPEED_MULT: float = 1.35
const SPREAD_INTERVAL: float = 3.2
const SPREAD_PROJECTILE_DAMAGE: int = 14
const SPREAD_PROJECTILE_SPEED: float = 200.0
const SPREAD_PROJECTILE_COUNT: int = 8

@onready var spikes: Node2D = $Visual/Spikes if has_node("Visual/Spikes") else null
@onready var aura: Polygon2D = $Visual/Aura if has_node("Visual/Aura") else null
@onready var visual_root: Node2D = $Visual if has_node("Visual") else null

var _enraged: bool = false
var _spread_timer: float = 0.0
var _enrage_pulse_t: float = 0.0

func _process(delta: float) -> void:
	var spin_mult: float = 2.6 if _enraged else 1.0
	if is_instance_valid(spikes):
		spikes.rotation += delta * 0.55 * spin_mult
	if is_instance_valid(aura):
		var t: float = float(Time.get_ticks_msec()) / 1000.0
		var amp: float = 0.14 if _enraged else 0.07
		var rate: float = 3.4 if _enraged else 1.6
		var s: float = 1.0 + amp * sin(t * rate)
		aura.scale = Vector2(s, s)

func _physics_process(delta: float) -> void:
	super(delta)
	if not _enraged and float(current_hp) / float(max(max_hp, 1)) <= ENRAGE_HP_RATIO:
		_enter_enrage()
	if _enraged:
		_tick_enrage(delta)

func _enter_enrage() -> void:
	_enraged = true
	contact_damage = int(contact_damage * ENRAGE_DAMAGE_MULT)
	move_speed = move_speed * ENRAGE_SPEED_MULT
	if is_instance_valid(aura):
		aura.color = Color(1.0, 0.25, 0.20, 0.30)
	# Brief red flash on the boss body so the threshold reads as an event.
	if is_instance_valid(visual_sprite):
		visual_sprite.modulate = Color(2.4, 0.6, 0.6)
		var tw := visual_sprite.create_tween()
		tw.tween_property(visual_sprite, "modulate", Color.WHITE, 0.5)
	# Outward warning ring at the transition moment.
	var burst := DeathBurst.new()
	burst.global_position = global_position
	burst.burst_color = Color(1.0, 0.35, 0.30, 1.0)
	burst.particle_count = 22
	burst.spread = 180.0
	burst.lifetime = 0.7
	get_tree().current_scene.add_child(burst)
	AudioManager.play("boss_appear", 0.0)
	# Stagger the first spread shot so the rage entrance isn't immediately
	# followed by a wall of bullets.
	_spread_timer = SPREAD_INTERVAL * 0.6

func _tick_enrage(delta: float) -> void:
	_enrage_pulse_t += delta * 6.0
	if is_instance_valid(visual_root):
		var s: float = 1.0 + 0.04 * sin(_enrage_pulse_t)
		visual_root.scale = Vector2(s, s)
	_spread_timer -= delta
	if _spread_timer <= 0.0:
		_spread_timer = SPREAD_INTERVAL
		_fire_radial_spread()

func _fire_radial_spread() -> void:
	var n: int = SPREAD_PROJECTILE_COUNT
	var phase: float = randf() * TAU / float(n)
	for i in range(n):
		var dir := Vector2.RIGHT.rotated(phase + float(i) * TAU / float(n))
		var proj := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position
		proj.launch(dir, SPREAD_PROJECTILE_DAMAGE, SPREAD_PROJECTILE_SPEED)

func _spawn_death_burst() -> void:
	for i in range(3):
		var burst := DeathBurst.new()
		burst.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		burst.burst_color = body_color
		burst.particle_count = 18
		burst.spread = 90.0
		burst.lifetime = 0.65
		get_tree().current_scene.add_child(burst)
