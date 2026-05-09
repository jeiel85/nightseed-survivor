extends Node2D
class_name BackgroundTiler

## Procedural ground for the survival arena.
##
## Performance: instead of redrawing every frame (~600 draw ops, brutal on
## WebGL), we only redraw when the player crosses a movement threshold and
## paint a region wider than the viewport. Between redraws, Godot caches
## the canvas item and the camera transform alone scrolls the world — zero
## per-frame work.

@export var tile_texture: Texture2D
@export var tile_modulate: Color = Color(0.42, 0.36, 0.55, 1.0)
@export var tile_size_px: float = 64.0
@export var follow_target_path: NodePath
@export var pebble_color_a: Color = Color(0.68, 0.62, 0.78, 0.55)
@export var pebble_color_b: Color = Color(0.30, 0.24, 0.42, 0.55)
@export var firefly_color: Color = Color(0.80, 0.95, 1.0, 0.9)

# How far the player can drift from the last drawn center before we
# repaint a new ground region. Smaller = more redraws, larger = bigger
# initial paint cost.
const REDRAW_THRESHOLD: float = 600.0
# Half-extent of the painted region (so each axis paints 2x this around
# the player). Must comfortably exceed REDRAW_THRESHOLD + viewport/2 so
# the visible area is always filled between repaints.
const DRAW_HALF: float = 1600.0
const CHUNK_PX: float = 256.0
const HASH_X: int = 73856093
const HASH_Y: int = 19349663

var _target: Node2D
var _drawn_center: Vector2 = Vector2(INF, INF)

func _ready() -> void:
	z_index = -5
	if not follow_target_path.is_empty():
		_target = get_node_or_null(follow_target_path)

func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	if _target.global_position.distance_to(_drawn_center) > REDRAW_THRESHOLD:
		_drawn_center = _target.global_position
		queue_redraw()

func _hash(ix: int, iy: int) -> int:
	return ((ix * HASH_X) ^ (iy * HASH_Y)) & 0x7FFFFFFF

func _draw() -> void:
	var center: Vector2 = _drawn_center if _drawn_center.x != INF else Vector2.ZERO
	var half := Vector2(DRAW_HALF, DRAW_HALF)
	var min_p := center - half
	var max_p := center + half

	# 1) Tile fill with per-tile color tint + flip variation
	if tile_texture:
		var src_rect := Rect2(Vector2.ZERO, tile_texture.get_size())
		var src_size: Vector2 = tile_texture.get_size()
		var sx: float = floor(min_p.x / tile_size_px) * tile_size_px
		var sy: float = floor(min_p.y / tile_size_px) * tile_size_px
		var x: float = sx
		while x < max_p.x:
			var y: float = sy
			while y < max_p.y:
				var ix: int = int(round(x / tile_size_px))
				var iy: int = int(round(y / tile_size_px))
				var h: int = _hash(ix, iy)
				var v: float = float(h % 1000) / 1000.0
				var tint: Color = tile_modulate.lerp(tile_modulate * 1.45, v * 0.7)
				tint.a = 1.0
				var dst_rect := Rect2(Vector2(x, y), Vector2(tile_size_px, tile_size_px))
				if (h >> 8) & 1:
					var flipped_src := Rect2(Vector2(src_size.x, 0), Vector2(-src_size.x, src_size.y))
					draw_texture_rect_region(tile_texture, dst_rect, flipped_src, tint)
				else:
					draw_texture_rect_region(tile_texture, dst_rect, src_rect, tint)
				y += tile_size_px
			x += tile_size_px

	# 2) Decorative scatter — fewer than before, deterministic per chunk
	var csx: float = floor(min_p.x / CHUNK_PX) * CHUNK_PX
	var csy: float = floor(min_p.y / CHUNK_PX) * CHUNK_PX
	var cx: float = csx
	while cx < max_p.x:
		var cy: float = csy
		while cy < max_p.y:
			var cix: int = int(round(cx / CHUNK_PX))
			var ciy: int = int(round(cy / CHUNK_PX))
			var seed_val: int = _hash(cix, ciy)
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_val
			var n: int = rng.randi_range(2, 4)
			for i in range(n):
				var px: float = cx + rng.randf_range(8.0, CHUNK_PX - 8.0)
				var py: float = cy + rng.randf_range(8.0, CHUNK_PX - 8.0)
				var rr: float = rng.randf_range(2.0, 5.0)
				var t: float = rng.randf()
				var col: Color = pebble_color_a.lerp(pebble_color_b, t)
				draw_circle(Vector2(px, py), rr, col)
			# 0-1 firefly per chunk
			if rng.randi_range(0, 2) == 0:
				var fx: float = cx + rng.randf_range(0.0, CHUNK_PX)
				var fy: float = cy + rng.randf_range(0.0, CHUNK_PX)
				var c1: Color = firefly_color
				c1.a = 0.10
				draw_circle(Vector2(fx, fy), rng.randf_range(8.0, 14.0), c1)
				var c2: Color = firefly_color
				c2.a = 0.45
				draw_circle(Vector2(fx, fy), 2.5, c2)
			cy += CHUNK_PX
		cx += CHUNK_PX
