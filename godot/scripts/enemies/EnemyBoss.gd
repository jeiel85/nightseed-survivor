extends EnemyBase

@onready var spikes: Node2D = $Visual/Spikes if has_node("Visual/Spikes") else null
@onready var aura: Polygon2D = $Visual/Aura if has_node("Visual/Aura") else null

func _process(delta: float) -> void:
	if is_instance_valid(spikes):
		spikes.rotation += delta * 0.55
	if is_instance_valid(aura):
		var t: float = float(Time.get_ticks_msec()) / 1000.0
		var s: float = 1.0 + 0.07 * sin(t * 1.6)
		aura.scale = Vector2(s, s)

func _spawn_death_burst() -> void:
	for i in range(3):
		var burst := DeathBurst.new()
		burst.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		burst.burst_color = body_color
		burst.particle_count = 18
		burst.spread = 90.0
		burst.lifetime = 0.65
		get_tree().current_scene.add_child(burst)
