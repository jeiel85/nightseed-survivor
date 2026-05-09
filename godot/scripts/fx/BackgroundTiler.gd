extends Node2D
class_name BackgroundTiler

## Manual tile renderer that follows the camera. Uses _draw() directly
## so we don't depend on texture_repeat support.

@export var tile_texture: Texture2D
@export var tile_modulate: Color = Color(0.32, 0.28, 0.40, 1)
@export var tile_scale: float = 2.0
@export var follow_target_path: NodePath

var _target: Node2D
var _tile_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	if tile_texture:
		_tile_size = tile_texture.get_size() * tile_scale
	if not follow_target_path.is_empty():
		_target = get_node_or_null(follow_target_path)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if tile_texture == null or _tile_size == Vector2.ZERO:
		return
	var center: Vector2 = _target.global_position if is_instance_valid(_target) else Vector2.ZERO
	var view: Vector2 = get_viewport_rect().size
	var half: Vector2 = view * 0.5 + _tile_size  # 1 tile of buffer
	var sx: float = floor((center.x - half.x) / _tile_size.x) * _tile_size.x
	var sy: float = floor((center.y - half.y) / _tile_size.y) * _tile_size.y
	var ex: float = center.x + half.x
	var ey: float = center.y + half.y
	var dst_size := _tile_size
	var src_rect := Rect2(Vector2.ZERO, tile_texture.get_size())
	var x: float = sx
	while x < ex:
		var y: float = sy
		while y < ey:
			draw_texture_rect_region(tile_texture, Rect2(Vector2(x, y), dst_size), src_rect, tile_modulate)
			y += _tile_size.y
		x += _tile_size.x
