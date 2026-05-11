extends Node

## Global scene transition fader. Use `Transition.change_scene(path)` instead
## of `get_tree().change_scene_to_file(path)` to get a smooth fade-out → swap
## → fade-in pulse.

const FADE_DURATION: float = 0.22

var _overlay: CanvasLayer
var _rect: ColorRect
var _busy: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = CanvasLayer.new()
	_overlay.layer = 100
	add_child(_overlay)
	_rect = ColorRect.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.color = Color(0.04, 0.05, 0.09, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_rect)

func change_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 1.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().change_scene_to_file(path)
	# Wait one frame so the new scene is in tree before fading in
	await get_tree().process_frame
	var tween2 := create_tween()
	tween2.tween_property(_rect, "color:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween2.finished
	_busy = false

func flash_in() -> void:
	# Used right after a hard scene reload (e.g., restart from game over) to
	# smooth the cut. Call from the new scene's _ready.
	_rect.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
