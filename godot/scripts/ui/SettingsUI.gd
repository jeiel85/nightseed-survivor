extends Control

# 모바일 게임 기본 설정 화면 (v0.31.0~).
# BGM/SFX 음량은 슬라이더 변경 즉시 AudioManager에 반영하고, 진동 토글은
# GameData에 저장만 한다 (실제 호출은 추후 SFX 콜사이트에서 GameData 체크).

@onready var title_label: Label = $VBox/Title
@onready var bgm_label: Label = $VBox/BgmRow/BgmLabel
@onready var bgm_slider: HSlider = $VBox/BgmRow/BgmSlider
@onready var bgm_value: Label = $VBox/BgmRow/BgmValue
@onready var sfx_label: Label = $VBox/SfxRow/SfxLabel
@onready var sfx_slider: HSlider = $VBox/SfxRow/SfxSlider
@onready var sfx_value: Label = $VBox/SfxRow/SfxValue
@onready var vibration_label: Label = $VBox/VibrationRow/VibrationLabel
@onready var vibration_check: CheckButton = $VBox/VibrationRow/VibrationCheck
@onready var btn_back: Button = $VBox/BtnBack

func _ready() -> void:
	AudioManager.play_bgm("menu")
	_apply_localized_text()
	_populate_from_data()
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	vibration_check.toggled.connect(_on_vibration_toggled)
	btn_back.pressed.connect(_on_back_pressed)
	if Localization:
		Localization.language_changed.connect(_on_language_changed)

func _apply_localized_text() -> void:
	title_label.text = Localization.tr_key("settings_title")
	bgm_label.text = Localization.tr_key("settings_bgm")
	sfx_label.text = Localization.tr_key("settings_sfx")
	vibration_label.text = Localization.tr_key("settings_vibration")
	btn_back.text = Localization.tr_key("btn_back")

func _populate_from_data() -> void:
	bgm_slider.value = GameData.bgm_volume
	sfx_slider.value = GameData.sfx_volume
	vibration_check.button_pressed = GameData.vibration_enabled
	_refresh_value_labels()

func _refresh_value_labels() -> void:
	bgm_value.text = "%d%%" % int(round(GameData.bgm_volume * 100.0))
	sfx_value.text = "%d%%" % int(round(GameData.sfx_volume * 100.0))

func _on_bgm_changed(v: float) -> void:
	GameData.bgm_volume = clampf(v, 0.0, 1.0)
	AudioManager.set_bgm_volume(GameData.bgm_volume)
	GameData.save_data()
	_refresh_value_labels()

func _on_sfx_changed(v: float) -> void:
	GameData.sfx_volume = clampf(v, 0.0, 1.0)
	AudioManager.set_sfx_volume(GameData.sfx_volume)
	GameData.save_data()
	_refresh_value_labels()
	# 슬라이더 조작 결과 체감용 효과음 — 매 프레임 호출 부담을 피해 마지막 한 번만 들리도록 짧은 클릭.
	AudioManager.play("ui_click")

func _on_vibration_toggled(on: bool) -> void:
	GameData.vibration_enabled = on
	GameData.save_data()
	# 체감용 한 번 진동 — 토글 ON일 때만, 그리고 단말이 지원할 때만.
	if on and OS.has_feature("mobile"):
		Input.vibrate_handheld(40)

func _on_language_changed(_lang: String) -> void:
	_apply_localized_text()

func _on_back_pressed() -> void:
	Transition.change_scene("res://scenes/ui/MainMenu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_back_pressed()
