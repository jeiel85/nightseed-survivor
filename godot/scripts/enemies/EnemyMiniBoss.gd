extends EnemyDasher
class_name EnemyMiniBoss

## Mid-run mini-boss. Behaves like a dasher but tougher, larger, and
## gets a glowing aura. Drops bonus gold on death.

@export var aura_color: Color = Color(0.95, 0.4, 1.0, 0.18)
@export var aura_radius: float = 60.0

var _aura_node: Polygon2D = null

func _ready() -> void:
	super()
	_add_aura()

func _add_aura() -> void:
	var visual: Node = $Visual
	if visual == null:
		return
	var aura := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var a := float(i) * TAU / 16.0
		pts.append(Vector2(cos(a), sin(a)) * aura_radius)
	aura.polygon = pts
	aura.color = aura_color
	visual.add_child(aura)
	visual.move_child(aura, 0)
	_aura_node = aura

func _physics_process(delta: float) -> void:
	super(delta)
	if _aura_node:
		_aura_node.rotation += delta * 1.2
