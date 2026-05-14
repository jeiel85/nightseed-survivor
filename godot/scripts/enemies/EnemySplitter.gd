extends EnemyBase
class_name EnemySplitter

## On death, spawns smaller "splitterling" copies that scatter outward.
## We also play a "split warning" pulse when HP drops below the split
## threshold so the player reads the upcoming swarm spawn as risk, not
## as a free kill (per the design note in COMMERCIALIZATION_ANALYSIS.md).

@export var splitterling_scene: PackedScene
@export var splitterling_count: int = 3
@export var split_speed_boost: float = 1.4
@export var warning_threshold: float = 0.35
@export var warning_color: Color = Color(1.0, 0.6, 1.8)
@export var pulse_rate: float = 6.0

var _warned: bool = false
var _warning_t: float = 0.0

func _physics_process(delta: float) -> void:
	super(delta)
	if not _warned and float(current_hp) / float(max(max_hp, 1)) <= warning_threshold:
		_warned = true
		AudioManager.play("kill", -18.0)
	if _warned and is_instance_valid(visual_sprite) and _flash_timer <= 0.0:
		_warning_t += delta * pulse_rate
		var k: float = 0.5 + 0.5 * sin(_warning_t)
		visual_sprite.modulate = Color.WHITE.lerp(warning_color, k * 0.85)

func _die() -> void:
	if splitterling_scene != null:
		_spawn_splitterlings()
		_spawn_split_burst()
	super()

func _spawn_splitterlings() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	var spawners: Array = get_tree().get_nodes_in_group("enemy_spawner")
	var spawner: Node = spawners[0] if not spawners.is_empty() else null
	for i in range(splitterling_count):
		var child := splitterling_scene.instantiate()
		var angle: float = TAU * float(i) / float(splitterling_count) + randf_range(-0.3, 0.3)
		var offset: Vector2 = Vector2.RIGHT.rotated(angle) * 18.0
		child.global_position = global_position + offset
		if child.has_method("set_target"):
			child.set_target(target)
		if spawner and spawner.has_method("register_enemy"):
			spawner.register_enemy(child)
		parent.add_child(child)

# Soft outward ring at the moment of split so the spawn pop reads as an
# event, not just three sprites appearing.
func _spawn_split_burst() -> void:
	var burst := DeathBurst.new()
	burst.global_position = global_position
	burst.burst_color = warning_color
	burst.particle_count = 14
	burst.spread = 120.0
	burst.lifetime = 0.55
	get_tree().current_scene.add_child(burst)
