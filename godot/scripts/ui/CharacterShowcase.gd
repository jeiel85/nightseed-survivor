extends Control
class_name CharacterShowcase

# Phase UI-3 1차 — 메인 메뉴에서 현재 선택 캐릭터를 큰 실루엣으로 보여주는 작은 컨테이너.
# 신규 일러스트 없이, 보유 중인 16×16 캐릭터 스프라이트를 ~6배 확대하고
# 뒤에 원형 달빛 헤일로/봉인 링을 절차적으로 그려서 "기억의 봉인 앞에 선 인물" 분위기를 낸다.

const COLOR_HALO_INNER := Color(0.760, 0.860, 1.000)  # 푸른 달빛
const COLOR_HALO_OUTER := Color(0.520, 0.620, 0.820)  # 흐려진 달빛
const COLOR_RUNE_RING  := Color(0.560, 0.660, 0.800)  # 봉인 링
const COLOR_GROUND_PAD := Color(0.020, 0.030, 0.045)  # 발판 그림자

# 스프라이트가 없거나 로드 실패 시에도 화면이 깨지지 않도록 fallback 색
const COLOR_FALLBACK_SILHOUETTE := Color(0.082, 0.110, 0.180)

@export var character_key: String = ""

@onready var _portrait: TextureRect = $Portrait
@onready var _name_label: Label = $NameLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	if _portrait:
		_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if character_key == "" and typeof(GameData) != TYPE_NIL:
		character_key = String(GameData.selected_character)
	refresh()

func refresh() -> void:
	var key: String = character_key
	if key == "" and typeof(GameData) != TYPE_NIL:
		key = String(GameData.selected_character)
	if key == "":
		key = "vagrant"
	character_key = key
	var data: Dictionary = Characters.get_data(key)
	if _portrait:
		var sprite_path: String = String(data.get("sprite", ""))
		var tex: Texture2D = null
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			tex = load(sprite_path) as Texture2D
		_portrait.texture = tex
		_portrait.visible = tex != null
	if _name_label:
		_name_label.text = Characters.display_name(key)
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	# Halo는 Portrait(96×96, 위로 20px 치우침)의 정중앙과 맞춘다.
	# Showcase 높이 180 기준 portrait center y ≈ 70, 따라서 halo center y = s.y*0.5 - 20.
	var center := Vector2(s.x * 0.5, s.y * 0.5 - 20.0)
	# 0.34: 헤일로 외곽이 showcase 사각형을 살짝 넘지 않게 유지하면서도
	# 캐릭터 스프라이트(96×96)를 충분히 감싸는 크기.
	var radius: float = min(s.x, s.y) * 0.34
	# 바깥 후광 (6단)
	for i in 6:
		var t: float = float(i + 1) / 6.0
		var rr: float = radius * (1.0 + t * 0.55)
		var a: float = 0.18 * (1.0 - t)
		draw_circle(center, rr, Color(COLOR_HALO_OUTER.r, COLOR_HALO_OUTER.g, COLOR_HALO_OUTER.b, a))
	# 안쪽 코어 글로우
	for i in 5:
		var t: float = float(i + 1) / 5.0
		var rr: float = radius * (0.45 + t * 0.55)
		var a: float = 0.10 * (1.0 - t)
		draw_circle(center, rr, Color(COLOR_HALO_INNER.r, COLOR_HALO_INNER.g, COLOR_HALO_INNER.b, a))
	# 봉인 링 (두 줄)
	draw_arc(center, radius * 1.02, 0.0, TAU, 64, Color(COLOR_RUNE_RING.r, COLOR_RUNE_RING.g, COLOR_RUNE_RING.b, 0.40), 1.5, false)
	draw_arc(center, radius * 1.14, 0.0, TAU, 64, Color(COLOR_RUNE_RING.r, COLOR_RUNE_RING.g, COLOR_RUNE_RING.b, 0.18), 1.0, false)
	# 바닥 그림자 (캐릭터 발 밑)
	var pad_y: float = center.y + radius * 0.55
	var pad_rx: float = radius * 0.55
	var pad_ry: float = radius * 0.10
	draw_colored_polygon(_ellipse_polygon(Vector2(center.x, pad_y), pad_rx, pad_ry, 32), Color(COLOR_GROUND_PAD.r, COLOR_GROUND_PAD.g, COLOR_GROUND_PAD.b, 0.55))
	# 스프라이트가 없을 때 실루엣 fallback (작은 사람 모양)
	if _portrait == null or _portrait.texture == null:
		_draw_fallback_silhouette(center, radius)

func _draw_fallback_silhouette(center: Vector2, radius: float) -> void:
	# 단순한 둥근 머리 + 사다리꼴 몸통 실루엣 — 스프라이트 누락 시에만 사용
	var head_r: float = radius * 0.22
	var head_pos := center + Vector2(0.0, -radius * 0.28)
	draw_circle(head_pos, head_r, COLOR_FALLBACK_SILHOUETTE)
	var body_top: float = head_pos.y + head_r * 0.7
	var body_bot: float = center.y + radius * 0.45
	var body_half_top: float = head_r * 1.0
	var body_half_bot: float = head_r * 1.6
	var body := PackedVector2Array([
		Vector2(center.x - body_half_top, body_top),
		Vector2(center.x + body_half_top, body_top),
		Vector2(center.x + body_half_bot, body_bot),
		Vector2(center.x - body_half_bot, body_bot),
	])
	draw_colored_polygon(body, COLOR_FALLBACK_SILHOUETTE)

static func _ellipse_polygon(c: Vector2, rx: float, ry: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a: float = TAU * float(i) / float(steps)
		pts.push_back(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts
