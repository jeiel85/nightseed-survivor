extends Node

## Lightweight in-code localization. Two languages (ko, en).
##
## - On boot: if GameData.language == "auto", detect from OS.get_locale().
## - User can cycle in main menu — saves to GameData.
## - All UI scripts call `Localization.tr_key("...")` and listen to
##   `language_changed` to refresh visible text.

signal language_changed(lang: String)

const SUPPORTED: Array = ["en", "ko"]
const DEFAULT_LANG: String = "en"

const STRINGS: Dictionary = {
	# --- Main menu ---
	"app_title":           {"en": "NIGHTSEED\nSURVIVOR", "ko": "밤의 씨앗\n서바이버"},
	"app_subtitle":        {"en": "5-Minute Survival Action", "ko": "5분 생존 액션"},
	"label_gold":          {"en": "Gold:  %d", "ko": "골드:  %d"},
	"label_status":        {"en": "%s  ·  %s  ·  %s", "ko": "%s  ·  %s  ·  %s"},
	"btn_play":            {"en": "PLAY",        "ko": "시작"},
	"btn_characters":      {"en": "HEROES",      "ko": "캐릭터"},
	"btn_stages":          {"en": "STAGES",      "ko": "스테이지"},
	"btn_shop":            {"en": "SHOP",        "ko": "상점"},
	"btn_difficulty_fmt":  {"en": "DIFFICULTY:  %s", "ko": "난이도:  %s"},
	"btn_difficulty_short_fmt": {"en": "%s",       "ko": "%s"},
	"btn_leaderboard":     {"en": "★ LEADERBOARDS", "ko": "★ 순위표"},
	"btn_leaderboard_short": {"en": "★ RANK",    "ko": "★ 순위표"},
	"btn_credits":         {"en": "Credits & Licenses", "ko": "크레딧 / 라이선스"},
	"btn_credits_short":   {"en": "Credits", "ko": "크레딧"},
	"btn_codex":           {"en": "CODEX", "ko": "용어집"},
	"btn_story":           {"en": "STORY", "ko": "스토리"},
	"btn_to_codex":        {"en": "Codex →", "ko": "용어집 →"},
	"btn_back_to_menu":    {"en": "← Back to Menu", "ko": "← 메뉴로"},
	"story_title":         {"en": "Story", "ko": "스토리"},
	"story_hint":          {"en": "Re-read the story from stages you've unlocked.", "ko": "해금한 스테이지의 이야기를 다시 읽을 수 있습니다."},
	"story_locked_long":   {"en": "Locked — unlock this stage to read its story.", "ko": "이 스테이지를 해금하면 이야기가 열립니다."},
	"story_section_intro": {"en": "— Intro —", "ko": "— 시작 —"},
	"story_section_boss":  {"en": "— Boss —", "ko": "— 보스 등장 —"},
	"story_section_clear": {"en": "— Clear —", "ko": "— 클리어 —"},
	"btn_language_fmt":    {"en": "Language:  %s", "ko": "언어:  %s"},
	"lang_ko_label":       {"en": "한국어", "ko": "한국어"},
	"lang_en_label":       {"en": "English", "ko": "English"},
	"menu_next_goal_fmt":   {"en": "%d g to upgrade",       "ko": "다음 강화까지 %d 골드"},
	"menu_next_goal_ready": {"en": "★ Upgrade ready",       "ko": "★ 강화 가능 · 상점에서 확인"},
	"menu_next_goal_maxed": {"en": "All maxed",             "ko": "모든 강화 완료"},

	# --- HUD ---
	"hud_hp_fmt":          {"en": "HP  %d / %d", "ko": "HP  %d / %d"},
	"hud_level_fmt":       {"en": "Lv  %d", "ko": "Lv  %d"},
	"hud_kills_fmt":       {"en": "Kills  %d", "ko": "처치  %d"},
	"hud_gold_fmt":        {"en": "Gold  %d", "ko": "골드  %d"},

	# --- Level up ---
	"levelup_title":       {"en": "- LEVEL UP! -", "ko": "- 레벨업! -"},
	"btn_select":          {"en": "SELECT", "ko": "선택"},
	"upgrade_desc_default":{"en": "DMG +25% / CD -12%", "ko": "데미지 +25% / 쿨다운 -12%"},
	"levelup_tag_new":     {"en": "NEW",          "ko": "신규"},
	"levelup_tag_up_fmt":  {"en": "UP · Lv.%d",   "ko": "강화 · Lv.%d"},
	"levelup_tag_evolve":  {"en": "★ EVOLVE",     "ko": "★ 진화"},
	"levelup_new_weapon":  {"en": "Add to your loadout", "ko": "새 무기 획득"},
	"levelup_new_passive": {"en": "New passive",          "ko": "새 패시브"},
	"levelup_lv_change_fmt": {"en": "Lv.%d → Lv.%d",      "ko": "Lv.%d → Lv.%d"},
	"levelup_passive_level_fmt": {"en": "Lv.%d → Lv.%d (max 5)", "ko": "Lv.%d → Lv.%d (최대 5)"},
	"levelup_evolve_base_fmt":   {"en": "From %s · final form", "ko": "%s 의 최종 형태"},
	"levelup_evolve_stats":      {"en": "Unique attack pattern unlocked", "ko": "고유 패턴 해금"},
	"levelup_stats_start_fmt":   {"en": "DMG %d · CD %.2fs",       "ko": "데미지 %d · CD %.2f초"},
	"levelup_stats_up_fmt":      {"en": "DMG %d → %d · CD %.2fs → %.2fs", "ko": "데미지 %d → %d · CD %.2f초 → %.2f초"},
	"tag_seek":     {"en": "SEEK",     "ko": "추적"},
	"tag_melee":    {"en": "MELEE",    "ko": "근접"},
	"tag_aoe":      {"en": "AOE",      "ko": "광역"},
	"tag_ranged":   {"en": "RANGED",   "ko": "원거리"},
	"tag_power":    {"en": "POWER",    "ko": "화력"},
	"tag_defense":  {"en": "DEFENSE",  "ko": "방어"},
	"tag_survive":  {"en": "SURVIVE",  "ko": "생존"},
	"tag_mobility": {"en": "MOBILITY", "ko": "기동"},
	"tag_pickup":   {"en": "PICKUP",   "ko": "수집"},
	"tag_utility":  {"en": "UTILITY",  "ko": "편의"},
	"tag_evolve":   {"en": "EVOLVE",   "ko": "진화"},

	# --- Result ---
	"result_victory":      {"en": "VICTORY!", "ko": "승리!"},
	"result_gameover":     {"en": "GAME OVER", "ko": "게임 오버"},
	"result_fragment_recovered": {"en": "A fragment of memory has returned.", "ko": "기억의 조각을 되찾았습니다."},
	"boss_warning":        {"en": "A WARDEN OF THE SEAL AWAKENS", "ko": "봉인의 파수꾼이 깨어납니다"},
	"result_survived_fmt": {"en": "Survived:  %d:%02d", "ko": "생존:  %d:%02d"},
	"result_kills_fmt":    {"en": "Kills:  %d", "ko": "처치:  %d"},
	"result_gold_fmt":     {"en": "Gold earned:  %d", "ko": "획득 골드:  %d"},
	"result_new_ach":      {"en": "★ NEW ACHIEVEMENTS", "ko": "★ 신규 업적"},
	"result_ach_line":     {"en": "%s  (+%d gold)", "ko": "%s  (+%d 골드)"},
	"result_stage_unlocked_fmt": {"en": "★ Next stage unlocked: %s", "ko": "★ 다음 스테이지 해금: %s"},
	"result_first_clear_bonus_fmt": {"en": "★ First %s clear!  +%d gold", "ko": "★ 첫 %s 클리어!  +%d 골드"},
	"result_campaign_finished": {"en": "★ All stages conquered — the eternal night sleeps.", "ko": "★ 모든 스테이지 정복 — 영원한 밤이 잠들었습니다."},
	"result_next_goal_fmt":   {"en": "Next upgrade in %d gold", "ko": "다음 강화까지 %d 골드"},
	"result_next_goal_ready": {"en": "★ Upgrade ready — visit Shop", "ko": "★ 강화 가능 — 상점에서 확인"},
	"btn_play_again":      {"en": "Play Again", "ko": "다시 플레이"},
	"btn_main_menu":       {"en": "Main Menu", "ko": "메인 메뉴"},
	"btn_retry":           {"en": "Retry", "ko": "재시도"},
	"btn_revive_ad":       {"en": "▶ Revive  (Watch ad)", "ko": "▶ 부활하기  (광고 시청)"},
	"btn_double_gold_ad":  {"en": "▶ Double Gold  (Watch ad)", "ko": "▶ 골드 2배  (광고 시청)"},

	# --- Selects / shared ---
	"choose_character":    {"en": "CHOOSE CHARACTER", "ko": "캐릭터 선택"},
	"choose_stage":        {"en": "CHOOSE STAGE", "ko": "스테이지 선택"},
	"stage_cleared_fmt":   {"en": "Cleared:  %s", "ko": "클리어:  %s"},
	"shop_title":          {"en": "PERMANENT UPGRADES", "ko": "영구 업그레이드"},
	"btn_back":            {"en": "Back to Menu", "ko": "메뉴로 돌아가기"},
	"btn_unlock_fmt":      {"en": "UNLOCK  (%d gold)", "ko": "해금  (%d 골드)"},
	"btn_buy":             {"en": "BUY", "ko": "구매"},
	"btn_selected":        {"en": "SELECTED", "ko": "선택됨"},
	"btn_max":             {"en": "MAX", "ko": "최대"},
	"label_cost_fmt":      {"en": "Cost:  %d", "ko": "비용:  %d"},
	"label_lv_fmt":        {"en": "Lv  %d", "ko": "Lv  %d"},
	"label_start_fmt":     {"en": "Start:  %s", "ko": "시작 무기:  %s"},
	"stage_duration_fmt":  {"en": "Duration: %d:%02d   ·   %d waves", "ko": "시간: %d:%02d   ·   %d 웨이브"},

	# --- Difficulty ---
	"difficulty_normal":    {"en": "Normal", "ko": "일반"},
	"difficulty_hard":      {"en": "Hard", "ko": "어려움"},
	"difficulty_nightmare": {"en": "Nightmare", "ko": "악몽"},

	# --- Character names + descs ---
	"char_vagrant_name":   {"en": "Vagrant", "ko": "방랑자"},
	"char_vagrant_desc":   {"en": "Balanced loner with a moonlit blade.", "ko": "달빛 검을 든 균형잡힌 외톨이."},
	"char_spirit_sister_name": {"en": "Spirit Sister", "ko": "정령의 수녀"},
	"char_spirit_sister_desc": {"en": "Channels orbiting souls. Frail but magnetic.", "ko": "공전하는 영혼을 다룬다. 약하지만 자성이 강함."},
	"char_hunter_name":    {"en": "Hunter", "ko": "사냥꾼"},
	"char_hunter_desc":    {"en": "Swift archer. High mobility, low defense.", "ko": "빠른 활잡이. 기동성 높고 방어 낮음."},
	"char_berserker_name": {"en": "Berserker", "ko": "광전사"},
	"char_berserker_desc": {"en": "Reckless force. High HP and damage, slow.", "ko": "무모한 힘. HP·데미지 높고 느림."},
	"char_pyromancer_name":{"en": "Pyromancer", "ko": "화염술사"},
	"char_pyromancer_desc":{"en": "Fire-bound caster. Wisp-charged from start.", "ko": "불을 다루는 시전자. 시작부터 위습 충전."},

	# --- Character signature passives (auto-active, one per character) ---
	"char_passive_blade_dance_name":   {"en": "Blade Dance",   "ko": "칼날 무용"},
	"char_passive_blade_dance_desc":   {"en": "Every 5 kills: +5% DMG for 8s (stacks ×3)", "ko": "처치 5회마다 8초간 +5% 피해 (최대 3중첩)"},
	"char_passive_soul_echo_name":     {"en": "Soul Echo",     "ko": "영혼의 메아리"},
	"char_passive_soul_echo_desc":     {"en": "Below 50% HP: +60 magnet  ·  Full HP: −4% CD", "ko": "HP 50% 이하: 자력 +60  ·  풀피: 쿨다운 −4%"},
	"char_passive_flee_reload_name":   {"en": "Flee & Reload", "ko": "재장전 도약"},
	"char_passive_flee_reload_desc":   {"en": "Kiting: −12% CD  ·  Standing still: +15% DMG", "ko": "적에서 멀어지는 중: 쿨다운 −12%  ·  정지 시: 피해 +15%"},
	"char_passive_reckless_fury_name": {"en": "Reckless Fury", "ko": "무모한 분노"},
	"char_passive_reckless_fury_desc": {"en": "Take damage: +8% DMG for 4s (stacks ×5)", "ko": "피격 시 4초간 +8% 피해 (최대 5중첩)"},
	"char_passive_ember_renewal_name": {"en": "Ember Renewal", "ko": "재연소"},
	"char_passive_ember_renewal_desc": {"en": "Every 3 shots: heal +5 HP (capped)  ·  Below max HP: −3% CD", "ko": "3발마다 +5 HP 회복 (상한 있음)  ·  풀피 미만: 쿨다운 −3%"},

	# --- CharacterSelect signature passive label ---
	"label_signature_fmt": {"en": "Signature:  %s", "ko": "특성:  %s"},

	# --- Weapon names ---
	"weapon_moon_dagger": {"en": "Moon Dagger", "ko": "달의 단검"},
	"weapon_spirit_orb":  {"en": "Spirit Orb",  "ko": "정령의 구"},
	"weapon_fire_wisp":   {"en": "Fire Wisp",   "ko": "화염 위습"},
	"weapon_thorn_ring":  {"en": "Thorn Ring",  "ko": "가시 고리"},
	"weapon_star_needle": {"en": "Star Needle", "ko": "별의 침"},
	"weapon_desc_moon_dagger": {"en": "Auto-fires at nearest enemy", "ko": "가장 가까운 적에게 자동 발사"},
	"weapon_desc_spirit_orb":  {"en": "Orbiting damage orbs", "ko": "공전하며 데미지를 주는 구체"},
	"weapon_desc_fire_wisp":   {"en": "Random area explosions", "ko": "무작위 지역 폭발"},
	"weapon_desc_thorn_ring":  {"en": "Burst of radial spikes", "ko": "방사형 가시 폭발"},
	"weapon_desc_star_needle": {"en": "Spread needle volley", "ko": "퍼지는 침 일제발사"},

	# --- Passives ---
	"passive_swift_boots_name":  {"en": "Swift Boots", "ko": "신속의 부츠"},
	"passive_swift_boots_desc":  {"en": "Move speed +20", "ko": "이동속도 +20"},
	"passive_magnet_charm_name": {"en": "Magnet Charm", "ko": "자석 부적"},
	"passive_magnet_charm_desc": {"en": "XP pickup range +40", "ko": "경험치 수집 범위 +40"},
	"passive_iron_heart_name":   {"en": "Iron Heart", "ko": "철의 심장"},
	"passive_iron_heart_desc":   {"en": "Max HP +20", "ko": "최대 HP +20"},
	"passive_battle_focus_name": {"en": "Battle Focus", "ko": "전투 집중"},
	"passive_battle_focus_desc": {"en": "All cooldowns -8%", "ko": "모든 쿨다운 -8%"},
	"passive_power_core_name":   {"en": "Power Core", "ko": "파워 코어"},
	"passive_power_core_desc":   {"en": "All damage +15%", "ko": "모든 데미지 +15%"},

	# --- Shop upgrade names + descs (per-level shop) ---
	"shop_swift_boots_desc":  {"en": "Move Speed +12 per level", "ko": "이동속도 +12/레벨"},
	"shop_magnet_charm_desc": {"en": "XP Radius +20 per level", "ko": "경험치 범위 +20/레벨"},
	"shop_iron_heart_desc":   {"en": "Max HP +10 per level", "ko": "최대 HP +10/레벨"},
	"shop_battle_focus_desc": {"en": "Cooldowns -4% per level", "ko": "쿨다운 -4%/레벨"},
	"shop_power_core_desc":   {"en": "All Damage +5% per level", "ko": "모든 데미지 +5%/레벨"},

	# --- Stages (id matches data/stages.json id) ---
	"stage_forest_name": {"en": "Forest of Echoes", "ko": "메아리의 숲"},
	"stage_forest_desc": {"en": "A forest where moonlight calls a lost name.", "ko": "달빛이 잃어버린 이름을 부르는 숲."},
	"stage_frozen_wastes_name": {"en": "Frozen Wastes", "ko": "얼어붙은 황무지"},
	"stage_frozen_wastes_desc": {"en": "A frozen land where broken oaths sleep below.", "ko": "깨어진 맹세가 얼음 아래 잠든 땅."},
	"stage_twilight_sanctum_name": {"en": "Twilight Sanctum", "ko": "황혼의 성소"},
	"stage_twilight_sanctum_desc": {"en": "A twilight chamber that sealed memories away.", "ko": "기억을 봉인한 황혼의 방."},
	"stage_inferno_chasm_name": {"en": "Inferno Chasm", "ko": "화염의 협곡"},
	"stage_inferno_chasm_desc": {"en": "A chasm where the seed must be revealed, not burned.", "ko": "씨앗을 태우는 대신 비춰야 하는 심연."},
	"stage_cursed_tomb_name": {"en": "Cursed Tomb", "ko": "저주받은 무덤"},
	"stage_cursed_tomb_desc": {"en": "A tomb that records the last knight's name.", "ko": "마지막 기사의 이름이 기록된 무덤."},

	# --- Achievements ---
	"ach_first_survivor_name":   {"en": "First Survivor", "ko": "첫 생존자"},
	"ach_first_survivor_desc":   {"en": "Survive the full duration", "ko": "전 시간 생존"},
	"ach_speed_runner_name":     {"en": "Speed Runner", "ko": "스피드러너"},
	"ach_speed_runner_desc":     {"en": "Reach Level 10 in under 3 minutes", "ko": "3분 안에 레벨 10 도달"},
	"ach_killer_instinct_name": {"en": "Killer Instinct", "ko": "킬러 본능"},
	"ach_killer_instinct_desc": {"en": "Kill 200 enemies in one run", "ko": "한 판에 200 처치"},
	"ach_untouchable_name":     {"en": "Untouchable", "ko": "무적"},
	"ach_untouchable_desc":     {"en": "Reach Level 5 without taking damage", "ko": "피해 없이 레벨 5 도달"},
	"ach_evolver_name":         {"en": "Evolver", "ko": "진화자"},
	"ach_evolver_desc":         {"en": "Evolve a weapon", "ko": "무기를 진화"},
	"ach_boss_slayer_name":     {"en": "Boss Slayer", "ko": "보스 슬레이어"},
	"ach_boss_slayer_desc":     {"en": "Defeat the final boss", "ko": "최종 보스 처치"},
	"ach_wealthy_name":         {"en": "Wealthy", "ko": "부유한 자"},
	"ach_wealthy_desc":         {"en": "Earn 500 gold in one run", "ko": "한 판에 500 골드 획득"},
	"ach_combo_master_name":    {"en": "Combo Master", "ko": "콤보 마스터"},
	"ach_combo_master_desc":    {"en": "Carry 4 different weapons at once", "ko": "동시에 4종 무기 보유"},
	"ach_hard_mode_clear_name":{"en": "Trial by Fire", "ko": "불의 시련"},
	"ach_hard_mode_clear_desc":{"en": "Win on Hard or Nightmare difficulty", "ko": "어려움/악몽 난이도 클리어"},
	"ach_completionist_name":  {"en": "Completionist", "ko": "완벽주의자"},
	"ach_completionist_desc":  {"en": "Reach Level 20 in one run", "ko": "한 판에 레벨 20 도달"},

	# --- Codex ---
	"codex_title":         {"en": "CODEX", "ko": "용어집"},
	"codex_hint":          {"en": "Select a term to read.", "ko": "용어를 선택해 읽어보세요."},
	"codex_safe_label":    {"en": "Used as", "ko": "이렇게 표현됩니다"},

	# --- Pause / Quit confirm (v0.29.0) ---
	"pause_title":          {"en": "- PAUSED -", "ko": "- 일시정지 -"},
	"btn_resume":           {"en": "Resume", "ko": "계속하기"},
	"btn_quit_to_menu":     {"en": "Quit to Menu", "ko": "메인 메뉴로"},
	"pause_save_hint":      {"en": "Progress is saved — you can continue later.", "ko": "진행 상태가 저장됩니다 — 나중에 이어할 수 있습니다."},
	"quit_confirm_title":   {"en": "Quit Nightseed Survivor?", "ko": "Nightseed Survivor 를 종료할까요?"},
	"btn_quit_app":         {"en": "Quit", "ko": "종료"},
	"btn_cancel":           {"en": "Cancel", "ko": "취소"},

	# --- Run resume / cloud save (v0.29.0) ---
	"btn_resume_run":       {"en": "▶ Continue run", "ko": "▶ 이어하기"},
	"resume_run_info_fmt":  {"en": "%s · Lv.%d · %d:%02d", "ko": "%s · Lv.%d · %d:%02d"},
	"resume_run_discard":   {"en": "Start a new run will discard your saved run.", "ko": "새 게임을 시작하면 이어하기 데이터는 삭제됩니다."},
	"cloud_save_title":     {"en": "Cloud save found", "ko": "클라우드 저장 발견"},
	"cloud_save_msg":       {"en": "A newer cloud save was found. Use it?", "ko": "더 최신인 클라우드 저장이 있습니다. 사용할까요?"},
	"btn_use_cloud":        {"en": "Use Cloud", "ko": "클라우드 사용"},
	"btn_keep_local":       {"en": "Keep Local", "ko": "로컬 유지"},
}

var current_lang: String = DEFAULT_LANG

func _ready() -> void:
	_resolve_initial_lang()

func _resolve_initial_lang() -> void:
	var saved: String = GameData.language if GameData else "auto"
	if saved == "auto" or not (saved in SUPPORTED):
		current_lang = _detect_system_lang()
	else:
		current_lang = saved

func _detect_system_lang() -> String:
	var loc: String = OS.get_locale().to_lower().substr(0, 2)
	return loc if loc in SUPPORTED else DEFAULT_LANG

func tr_key(key: String, fallback: String = "") -> String:
	if not STRINGS.has(key):
		return fallback if fallback != "" else key
	var entry: Dictionary = STRINGS[key]
	return String(entry.get(current_lang, entry.get(DEFAULT_LANG, key)))

func set_language(lang: String) -> void:
	if not (lang in SUPPORTED):
		return
	if lang == current_lang:
		return
	current_lang = lang
	if GameData:
		GameData.language = lang
		GameData.save_data()
	language_changed.emit(lang)

func cycle_language() -> void:
	var idx: int = SUPPORTED.find(current_lang)
	set_language(SUPPORTED[(idx + 1) % SUPPORTED.size()])

func current_label() -> String:
	return tr_key("lang_%s_label" % current_lang)
