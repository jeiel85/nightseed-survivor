extends EnemyBase
class_name EnemySplitter

## On death, spawns smaller "splitterling" copies that scatter outward.

@export var splitterling_scene: PackedScene
@export var splitterling_count: int = 3
@export var split_speed_boost: float = 1.4

func _die() -> void:
	if splitterling_scene != null:
		_spawn_splitterlings()
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
