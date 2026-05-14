extends Node2D
class_name BackgroundTiler

## Procedural ground for the survival arena.
##
## Performance: redraws only when the camera crosses a movement threshold,
## paints a region wider than the viewport. Between redraws the canvas
## item is cached → zero per-frame work.
##
## Visual:
##   - 3 ground tile variants randomly placed (hash-driven)
##   - Per-tile color tint + horizontal flip variation
##   - Scattered pebbles + soft fireflies per chunk
##   - Large decorations (rocks + torches) sparsely placed at deterministic
##     positions, giving the world landmarks to navigate by

@export var tile_textures: Array[Texture2D] = []
@export var tile_modulate: Color = Color(0.42, 0.36, 0.55, 1.0)
@export var tile_size_px: float = 64.0
@export var follow_target_path: NodePath
@export var pebble_color_a: Color = Color(0.68, 0.62, 0.78, 0.55)
@export var pebble_color_b: Color = Color(0.30, 0.24, 0.42, 0.55)
@export var firefly_color: Color = Color(0.80, 0.95, 1.0, 0.9)
@export var decor_rock_texture: Texture2D
@export var decor_torch_texture: Texture2D
@export var decor_modulate: Color = Color(0.55, 0.50, 0.70, 1.0)
@export var torch_glow_color: Color = Color(1.0, 0.65, 0.30, 0.45)

const REDRAW_THRESHOLD: float = 600.0
const DRAW_HALF: float = 1700.0
const CHUNK_PX: float = 320.0
const DECOR_CHUNK_PX: float = 640.0
const HASH_X: int = 73856093
const HASH_Y: int = 19349663

var _target: Node2D
var _drawn_center: Vector2 = Vector2(INF, INF)

func _ready() -> void:
	z_index = -5
	if not follow_target_path.is_empty():
		_target = get_node_or_null(follow_target_path)

# Stage tone palette. GameRoot calls this once on _ready() with the active
# stage's "bg" block from stages.json. Any missing key keeps its scene default.
func apply_tone(tone: Dictionary) -> void:
	if tone.is_empty():
		return
	if tone.has("tile"):
		tile_modulate = _to_color(tone["tile"], tile_modulate)
	if tone.has("pebble_a"):
		pebble_color_a = _to_color(tone["pebble_a"], pebble_color_a)
	if tone.has("pebble_b"):
		pebble_color_b = _to_color(tone["pebble_b"], pebble_color_b)
	if tone.has("firefly"):
		firefly_color = _to_color(tone["firefly"], firefly_color)
	if tone.has("decor"):
		decor_modulate = _to_color(tone["decor"], decor_modulate)
	if tone.has("torch_glow"):
		torch_glow_color = _to_color(tone["torch_glow"], torch_glow_color)
	# Force a redraw the next time the camera ticks past the threshold.
	_drawn_center = Vector2(INF, INF)
	queue_redraw()

func _to_color(arr_val, fallback: Color) -> Color:
	if not (arr_val is Array) or arr_val.size() < 3:
		return fallback
	var r := float(arr_val[0])
	var g := float(arr_val[1])
	var b := float(arr_val[2])
	var a: float = float(arr_val[3]) if arr_val.size() >= 4 else 1.0
	return Color(r, g, b, a)

func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	if _target.global_position.distance_to(_drawn_center) > REDRAW_THRESHOLD:
		_drawn_center = _target.global_position
		queue_redraw()

func _hash(ix: int, iy: int, salt: int = 0) -> int:
	return ((ix * HASH_X) ^ (iy * HASH_Y) ^ (salt * 982451653)) & 0x7FFFFFFF

func _draw() -> void:
	var center: Vector2 = _drawn_center if _drawn_center.x != INF else Vector2.ZERO
	var half := Vector2(DRAW_HALF, DRAW_HALF)
	var min_p := center - half
	var max_p := center + half

	# 1) Tile fill — pick from variants by hash, per-tile tint and flip.
	if not tile_textures.is_empty():
		var sx: float = floor(min_p.x / tile_size_px) * tile_size_px
		var sy: float = floor(min_p.y / tile_size_px) * tile_size_px
		var x: float = sx
		while x < max_p.x:
			var y: float = sy
			while y < max_p.y:
				var ix: int = int(round(x / tile_size_px))
				var iy: int = int(round(y / tile_size_px))
				var h: int = _hash(ix, iy)
				var tex: Texture2D = tile_textures[h % tile_textures.size()]
				var src_size: Vector2 = tex.get_size()
				var src_rect := Rect2(Vector2.ZERO, src_size)
				var v: float = float(h % 1000) / 1000.0
				var tint: Color = tile_modulate.lerp(tile_modulate * 1.45, v * 0.7)
				tint.a = 1.0
				var dst_rect := Rect2(Vector2(x, y), Vector2(tile_size_px, tile_size_px))
				if (h >> 8) & 1:
					var flipped_src := Rect2(Vector2(src_size.x, 0), Vector2(-src_size.x, src_size.y))
					draw_texture_rect_region(tex, dst_rect, flipped_src, tint)
				else:
					draw_texture_rect_region(tex, dst_rect, src_rect, tint)
				y += tile_size_px
			x += tile_size_px

	# 2) Pebbles + fireflies — small ambient detail per chunk.
	var csx: float = floor(min_p.x / CHUNK_PX) * CHUNK_PX
	var csy: float = floor(min_p.y / CHUNK_PX) * CHUNK_PX
	var cx: float = csx
	while cx < max_p.x:
		var cy: float = csy
		while cy < max_p.y:
			var cix: int = int(round(cx / CHUNK_PX))
			var ciy: int = int(round(cy / CHUNK_PX))
			var seed_val: int = _hash(cix, ciy, 7)
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_val
			var n: int = rng.randi_range(3, 5)
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

	# 3) Large decor — rocks and torches at landmark density (sparser chunks).
	var dsx: float = floor(min_p.x / DECOR_CHUNK_PX) * DECOR_CHUNK_PX
	var dsy: float = floor(min_p.y / DECOR_CHUNK_PX) * DECOR_CHUNK_PX
	var dx: float = dsx
	while dx < max_p.x:
		var dy: float = dsy
		while dy < max_p.y:
			var dix: int = int(round(dx / DECOR_CHUNK_PX))
			var diy: int = int(round(dy / DECOR_CHUNK_PX))
			var dseed: int = _hash(dix, diy, 19)
			var drng := RandomNumberGenerator.new()
			drng.seed = dseed
			var decor_n: int = drng.randi_range(0, 2)
			for k in range(decor_n):
				var dx_pos: float = dx + drng.randf_range(60.0, DECOR_CHUNK_PX - 60.0)
				var dy_pos: float = dy + drng.randf_range(60.0, DECOR_CHUNK_PX - 60.0)
				var pick: int = drng.randi_range(0, 4)
				if pick <= 2 and decor_rock_texture:
					_draw_decor(decor_rock_texture, dx_pos, dy_pos, drng, false)
				elif decor_torch_texture:
					_draw_decor(decor_torch_texture, dx_pos, dy_pos, drng, true)
				elif decor_rock_texture:
					_draw_decor(decor_rock_texture, dx_pos, dy_pos, drng, false)
			dy += DECOR_CHUNK_PX
		dx += DECOR_CHUNK_PX

func _draw_decor(tex: Texture2D, px: float, py: float, rng: RandomNumberGenerator, is_torch: bool) -> void:
	var scale: float = rng.randf_range(2.4, 3.4)
	var size: Vector2 = tex.get_size() * scale
	var rect := Rect2(Vector2(px - size.x * 0.5, py - size.y * 0.5), size)
	if is_torch:
		# Soft warm glow underneath
		var glow_r: float = scale * 24.0
		var glow_color := torch_glow_color
		glow_color.a = 0.20
		draw_circle(Vector2(px, py - size.y * 0.15), glow_r, glow_color)
		draw_circle(Vector2(px, py - size.y * 0.15), glow_r * 0.55, torch_glow_color)
		draw_texture_rect(tex, rect, false, decor_modulate.lerp(Color(1, 0.9, 0.7), 0.35))
	else:
		var src_rect := Rect2(Vector2.ZERO, tex.get_size())
		# Subtle shadow under the rock
		var shadow_r: float = scale * 9.0
		draw_circle(Vector2(px, py + size.y * 0.35), shadow_r, Color(0, 0, 0, 0.30))
		# Flip horizontally for variety
		if rng.randi() % 2 == 0:
			var flipped := Rect2(Vector2(src_rect.size.x, 0), Vector2(-src_rect.size.x, src_rect.size.y))
			draw_texture_rect_region(tex, rect, flipped, decor_modulate)
		else:
			draw_texture_rect_region(tex, rect, src_rect, decor_modulate)
