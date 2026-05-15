extends Control
class_name MenuBackdrop

# Procedural night-forest backdrop for the main menu (Phase UI-2 1차).
# 새 이미지 애셋을 추가하지 않고, ColorRect/원/폴리곤만으로
# 깊은 남색 하늘 + 달빛 헤일로 + 별 + 안개 + 나무 실루엣 + 반딧불 레이어를 그린다.
# 실제 일러스트 배경이 준비되면 이 노드를 TextureRect로 교체할 예정.

@export var rng_seed: int = 1337

const COLOR_SKY_TOP    := Color(0.043, 0.055, 0.090)  # 거의 검은 남색
const COLOR_SKY_BOTTOM := Color(0.031, 0.078, 0.063)  # 어두운 숲 녹색
const COLOR_GROUND     := Color(0.020, 0.030, 0.045)  # 검은 흙
const COLOR_TREE       := Color(0.018, 0.034, 0.054)  # 거의 검은 청록
const COLOR_MOON       := Color(0.945, 0.965, 1.000)  # 창백한 달
const COLOR_MOON_GLOW  := Color(0.760, 0.860, 1.000)  # 푸른 달빛
const COLOR_MIST       := Color(0.530, 0.610, 0.770)  # 안개 톤
const COLOR_FIREFLY    := Color(0.980, 0.840, 0.460)  # 호박색 반딧불

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	_draw_sky(s)
	_draw_stars(s)
	_draw_moon(s)
	_draw_mist(s)
	_draw_trees(s)
	_draw_ground(s)
	_draw_fireflies(s)

func _draw_sky(s: Vector2) -> void:
	# 32단 수직 그라데이션 (단순 draw_rect 반복으로 셰이더 없이 표현)
	var steps := 32
	for i in steps:
		var t: float = float(i) / float(steps - 1)
		var c: Color = COLOR_SKY_TOP.lerp(COLOR_SKY_BOTTOM, t)
		var y: float = s.y * t
		var h: float = s.y / float(steps) + 1.0
		draw_rect(Rect2(Vector2(0.0, y), Vector2(s.x, h)), c, true)

func _draw_stars(s: Vector2) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	var count := 80
	for _i in count:
		var x: float = rng.randf() * s.x
		var y: float = rng.randf() * s.y * 0.58
		var a: float = rng.randf_range(0.25, 0.85)
		var r: float = rng.randf_range(0.6, 1.6)
		draw_circle(Vector2(x, y), r, Color(0.93, 0.95, 1.0, a))

func _draw_moon(s: Vector2) -> void:
	var moon_center := Vector2(s.x * 0.74, s.y * 0.18)
	var moon_r: float = min(s.x, s.y) * 0.085
	# 외곽 헤일로 — 6단 (가장 바깥은 거의 투명)
	for i in 6:
		var halo_t: float = float(i + 1) / 6.0
		var halo_r: float = moon_r * (1.0 + halo_t * 2.4)
		var halo_a: float = 0.10 * (1.0 - halo_t)
		draw_circle(moon_center, halo_r, Color(COLOR_MOON_GLOW.r, COLOR_MOON_GLOW.g, COLOR_MOON_GLOW.b, halo_a))
	# 본체
	draw_circle(moon_center, moon_r, COLOR_MOON)
	# 살짝 어두운 반사 (월면 디테일 흉내)
	draw_circle(moon_center + Vector2(moon_r * 0.30, -moon_r * 0.15), moon_r * 0.78, Color(COLOR_SKY_TOP.r, COLOR_SKY_TOP.g, COLOR_SKY_TOP.b, 0.18))

func _draw_mist(s: Vector2) -> void:
	# 안개 가로 띠 (지평선 근처)
	var bands := 14
	for i in bands:
		var t: float = float(i) / float(bands - 1)
		var y: float = s.y * (0.48 + t * 0.22)
		var alpha: float = 0.04 + 0.06 * sin(t * PI)
		draw_rect(Rect2(Vector2(0.0, y), Vector2(s.x, s.y * 0.024)), Color(COLOR_MIST.r, COLOR_MIST.g, COLOR_MIST.b, alpha), true)

func _draw_trees(s: Vector2) -> void:
	var ground_y: float = s.y * 0.80
	# 뒤쪽 트리 라인 (먼 산처럼 작고 흐리게)
	var back_count := 14
	var back_step: float = s.x / float(back_count - 1)
	for i in back_count:
		var cx: float = i * back_step + sin(float(i) * 1.7) * back_step * 0.18
		var h: float = s.y * (0.10 + 0.04 * fmod(float(i) * 0.43, 1.0))
		var w: float = back_step * 0.95
		var pts := PackedVector2Array([
			Vector2(cx - w * 0.5, ground_y + 6.0),
			Vector2(cx, ground_y - h),
			Vector2(cx + w * 0.5, ground_y + 6.0),
		])
		draw_colored_polygon(pts, Color(COLOR_TREE.r * 1.4, COLOR_TREE.g * 1.4, COLOR_TREE.b * 1.4, 0.55))
	# 앞쪽 트리 라인 (더 크고 진하게)
	var count := 9
	var step: float = s.x / float(count - 1)
	for i in count:
		var cx: float = i * step + sin(float(i) * 1.3 + 0.7) * step * 0.22
		var h: float = s.y * (0.16 + 0.10 * fmod(float(i) * 0.31 + 0.2, 1.0))
		var w: float = step * 0.90
		var pts := PackedVector2Array([
			Vector2(cx - w * 0.5, ground_y + 10.0),
			Vector2(cx, ground_y - h),
			Vector2(cx + w * 0.5, ground_y + 10.0),
		])
		draw_colored_polygon(pts, COLOR_TREE)

func _draw_ground(s: Vector2) -> void:
	var ground_y: float = s.y * 0.80
	draw_rect(Rect2(Vector2(0.0, ground_y), Vector2(s.x, s.y - ground_y)), COLOR_GROUND, true)
	# 지평선 강조 한 줄 (희미한 달빛 반사)
	draw_rect(Rect2(Vector2(0.0, ground_y), Vector2(s.x, 1.5)), Color(COLOR_MOON_GLOW.r, COLOR_MOON_GLOW.g, COLOR_MOON_GLOW.b, 0.18), true)

func _draw_fireflies(s: Vector2) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed + 7
	for _i in 16:
		var x: float = rng.randf() * s.x
		var y: float = rng.randf_range(s.y * 0.58, s.y * 0.86)
		var r: float = rng.randf_range(1.2, 2.4)
		var a: float = rng.randf_range(0.35, 0.85)
		# 작은 글로우 한 겹 + 본체
		draw_circle(Vector2(x, y), r * 2.4, Color(COLOR_FIREFLY.r, COLOR_FIREFLY.g, COLOR_FIREFLY.b, a * 0.18))
		draw_circle(Vector2(x, y), r, Color(COLOR_FIREFLY.r, COLOR_FIREFLY.g, COLOR_FIREFLY.b, a))
