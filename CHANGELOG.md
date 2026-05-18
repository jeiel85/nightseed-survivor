# CHANGELOG.md

## v0.29.0 - 2026-05-18 (이어하기 + Android Back + 클라우드 백업)

GitHub Issues [#1](https://github.com/jeiel85/nightseed-survivor/issues/1) (게임 중 뒤로 가기로 앱 종료) / [#2](https://github.com/jeiel85/nightseed-survivor/issues/2) (게임 현황 저장) 대응.

### Added — Android Back 키 + 일시정지 메뉴

- `project.godot` `application/config/quit_on_go_back=false` 추가 — Godot의 기본 자동 종료를 막고 노드에 `NOTIFICATION_WM_GO_BACK_REQUEST` 가 전달되도록 변경
- `GameRoot`: 전투 중 Back → 일시정지 메뉴 (계속하기 / 메인 메뉴로). 메뉴 패널은 코드로 구성 (`_build_pause_menu()`), 라벨/버튼은 Localization 키로 다국어
- `MainMenu`: Back → "Nightseed Survivor 를 종료할까요?" 확인 다이얼로그 (예/취소)
- `StageSelect` / `CharacterSelect` / `ShopUI` / `CodexUI` / `StoryUI` / `CreditsUI`: Back → 메인 메뉴로 복귀 (각 화면의 기존 `_on_back_pressed()` 호출)

### Added — 이어하기 (`RunPersist` autoload, `user://run_save.json`)

- 전투 중 Back → 일시정지 메뉴를 열면 스냅샷 캡처. "메인 메뉴로" 누르면 commit
- `NOTIFICATION_APPLICATION_PAUSED` (홈 버튼/전화) 시점에도 자동 스냅샷 + commit
- `MainMenu` 상단에 "▶ 이어하기 (스테이지 · Lv.N · M:SS)" CTA — `RunPersist.has_save()` 일 때만 표시
- 이어하기 누르면 `GameData.selected_stage` / `selected_character` / `difficulty` 를 저장된 값으로 핀 후 `GameRoot.tscn` 로 진입 → `GameRoot._ready()` 가 `_apply_resume()` 로 Player / WeaponManager / WaveManager / 런 플래그 일괄 복원
- "PLAY" 새 게임 시작 / 사망 / 승리 / 결과 패널의 메인 메뉴·재시도 누르면 save 삭제 (오래된 dead-state 복원 방지)
- 적/투사체/픽업은 저장 안 함 — WaveManager 가 `_elapsed` 만으로 자연스럽게 재생성

### Added — PGS Saved Games 클라우드 백업 (`CloudSave` autoload)

- PlayGamesSnapshotsClient (`SNAPSHOT_NAME = nightseed_meta`) 래핑. 비-Android / 로그아웃 시 모든 호출 no-op
- `GameData.save_data()` 호출마다 `CloudSave.mark_dirty()` → 10초 throttle 으로 일괄 업로드
- `NOTIFICATION_APPLICATION_PAUSED` 시점에 `flush()` 로 즉시 동기화
- MainMenu 진입 시 1회 `request_load()` → `GameData.apply_cloud_payload()` 가 골드/언락/영구업그레이드를 **safe merge** (max / union 정책) 으로 합침. 로컬 진행을 파괴하지 않음
- 다음 빌드에서 Play Console "Saved games" 활성화 확인 필요 (없으면 클라우드 부분은 자동 비활성, 로컬 저장만 작동)

### Known limitations

- 캐릭터 시그니처 패시브(BladeDance/SoulEcho/...)의 내부 카운터(스택, 발사 카운트, 힐 cadence)는 복원하지 않음 — 이어하기 시 초기 상태로 리셋
- 적·투사체·픽업은 저장 안 함 — 이어하기 직후 짧은 정적 구간 발생 가능
- 결과 패널이 떠 있는 상태에서 Back 키는 무시 — 결과 패널의 "메인 메뉴" / "재시도" 버튼을 사용해야 함

## v0.28.1 - 2026-05-18 (정령의 구 CD 표시 버그 + 레벨업 카드 오버플로 수정)

### Fixed — 정령의 구 CD 가 비현실적인 값(4575초 등)으로 표시되던 버그

- `SpiritOrb`는 `WeaponBase._process`가 절대 발화되지 않도록 `base_cooldown = 9999.0` 으로 둔 상태에서 별도 `DAMAGE_INTERVAL = 0.35` 타이머로 데미지를 처리. 그런데 레벨업 카드는 모든 무기 공통으로 `base_cooldown × cooldown_multiplier` 를 화면에 그대로 출력해, 결과적으로 4000초가 넘는 숫자가 노출되고 카드 폭을 넘어버렸음.
- `WeaponBase`에 `get_display_cooldown()` / `get_display_next_cooldown()` 가상 메서드 추가. 기본 구현은 기존 계산과 동일.
- `SpiritOrb`가 두 메서드를 override 해 `DAMAGE_INTERVAL × cooldown_multiplier` 를 반환. 업그레이드는 발사 간격 대신 구체 수를 늘리므로 next == current.
- `LevelUpUI._generate_options()` 가 새 메서드를 호출하도록 교체.

### Fixed — 레벨업 카드 Stats 라벨 텍스트 오버플로 안전망

- `LevelUpUI.tscn` Card1/Card2/Card3의 `Stats` Label 모두 `autowrap_mode = 3` (WORD_SMART) 추가. 향후 어떤 사유로든 stats 문자열이 길어져도 카드 폭을 넘어가지 않도록 보호.

## v0.28.0 - 2026-05-18 (스테이지 차별화 Phase 1 — 팔레트 + enemy tint)

### Changed — 5개 스테이지 bg 팔레트 hue 분리 (`godot/data/stages.json`, schema v7→v8)

이전까지 5개 스테이지의 보이드/타일/펩블 RGB 가 거의 비슷해 폰 화면에서 "다 어두운 색"으로 보이던 문제 해결. 각 스테이지가 하나의 hue로 통일성을 유지하면서 채도/명도 차이를 키움.

- Forest: 녹/이끼 (기존 톤 강화)
- Frozen Wastes: 얼음/푸른 — void/tile/pebble 모두 청색 계열로
- Twilight Sanctum: 보라 + 따뜻한 횃불 (orange torch_glow로 콘트라스트)
- Inferno Chasm: 불/주홍 — tile R채널 0.48 → 0.62
- Cursed Tomb: 자/분홍 — tile (R0.42 G0.26 B0.36) → (R0.52 G0.22 B0.42)

### Added — 스테이지별 enemy tint 시스템

- `stages.json` 각 entry에 `enemy_tint: [r,g,b,a]` 신규 필드. 적의 `modulate` 에 곱해질 색.
- 같은 적 종류라도 스테이지에 따라 다른 색조로 보임:
  - Forest `[1,1,1,1]` (base — 변화 없음)
  - Frozen Wastes `[0.70, 0.85, 1.10, 1]` (청록빛 — 얼어붙은 느낌)
  - Twilight Sanctum `[0.85, 0.70, 1.10, 1]` (보랏빛 — 마법 들린 느낌)
  - Inferno Chasm `[1.20, 0.75, 0.65, 1]` (주홍빛 — 그을린 느낌)
  - Cursed Tomb `[1.05, 0.70, 0.85, 1]` (자홍빛 — 부패한 느낌)
- `EnemySpawner.setup()` 시점에 tint 캐싱, `register_enemy()` 경로에서 `modulate` 적용 — Splitter가 자체 spawn하는 splitterling 자식들도 같은 hue 입음.
- Forest처럼 `[1,1,1,1]` 인 스테이지는 modulate 호출 자체를 스킵.

### Docs

- `docs/STAGE_DIFFERENTIATION_PLAN.md` — 스테이지 차별화 Stage A(코드만) / Stage B(자산 필요) 작업 계획서. 이번 릴리즈는 Stage A 완료분.

### Known limitations

- 피격 white-flash와 modulate의 곱셈 상호작용은 우선 그대로 둠. 폰에서 어색하면 다음 패치에서 조정.
- 적 DeathBurst 의 burst_color 는 enemy.modulate 영향 안 받음 (별도 노드) — 죽을 때 본래 색 burst. 큰 위화감 없으면 유지.
- 보스/미니보스도 tint 입음. 본래 색이 정체성이라면 별도 처리 검토 필요.
- BGM은 여전히 한 트랙 (계획서 §A4 — 다음 릴리즈 후보).

## v0.27.0 - 2026-05-17 (시그니처 패시브 + 난이도 재조정 + PGS/AdMob fix)

### Added — Character signature passives (Phase Class-1)
- `godot/scripts/player/passives/CharacterPassive.gd` — 추상 base. `setup(player)`에서 weapon_manager 캐싱 + 서브클래스 `_on_setup` hook 실행.
- `BladeDance.gd` (Vagrant) — 처치 5회마다 +5% DMG · 8s · 3중첩. `kill_count_changed` 구독.
- `SoulEcho.gd` (Spirit Sister) — HP <50%: magnet +60 / 풀피: CD −4%. `hp_changed` 구독.
- `FleeAndReload.gd` (Hunter) — 적에서 멀어지면 CD −12% / 정지 시 DMG +15%. 0.3s hysteresis.
- `RecklessFury.gd` (Berserker) — 피격 시 +8% DMG · 4s · 5중첩.
- `EmberRenewal.gd` (Pyromancer) — 3발마다 +5HP (max_hp 50% 상한) / HP<max: CD −3%. `weapon_fired` 구독.
- `Characters.gd` 각 캐릭터에 `passive_id / passive_name_key / passive_desc_key` + `display_passive_name/desc` helper.
- `CharacterSelect.gd` 카드에 시그니처 이름·효과 2줄 표시 (캐릭터 색 강조).
- `Localization.gd` 패시브 이름/설명 10개 키 + `label_signature_fmt`.

### Changed — WeaponBase / WeaponManager 신호 + multiplier 합성
- `WeaponBase.fired` 신호 신규 (fire() 직후 emit). EmberRenewal 카운팅용.
- `WeaponManager.weapon_fired` 신호 신규 (각 weapon의 fired bubble). `passive_damage_mult / passive_cooldown_mult` 필드 추가, `_get_damage_mult / _get_cooldown_mult`에 곱셈으로 합성 — init mult × shop passive × signature passive.
- `Player.passive_xp_radius_bonus` 필드. `_handle_pickups`에서 `xp_radius + passive_xp_radius_bonus` 사용. `_ready`에서 starting weapon 직후 `_create_passive(id)`.

### Changed — Forest 난이도 재조정 (`godot/data/stages.json`)
- Wave 0 interval 1.3s → 1.8s, Wave 1 등장 20s → 35s (초반 −28%)
- Wave 8 count 4 → 5 (3:45~ 압박 +25%)
- Wave 9 interval 0.65s → 0.50s, count 4 → 5 (4:15~ spawn rate +30%)
- Wave 10 count 4 → 5 (보스 동반 minion 압박)
- `EnemySpawner.max_enemies` 200 → 280 (후반 캡 평탄화 제거)

### Fixed — Android headless export PGS/AdMob manifest meta-data
- v0.26.0 "리더보드 / 광고 미동작" Known Issue 해결.
- 원인 정정: `.aar` 누락(오진) → AndroidManifest meta-data 통째 누락(실제). 헤드리스 export가 `EditorExportPlugin._get_android_manifest_application_element_contents()` 훅을 발동시키지 않음.
- `godot/android/build/AndroidManifest.xml` PGS+AdMob APP_ID meta-data 2개 정적 추가.
- `godot/android/build/build.gradle` plugin .aar 3개 + Maven deps (gson, play-services-games-v2, play-services-ads) 정적 선언 — export plugin 미발동 시 안전망.
- 검증: 로컬 headless APK build → aapt2 dump xmltree로 meta-data 7개 + dexdump로 클래스 485개 모두 확인.

### Fixed — 무기 카드 중복 노출
- LevelUp에 같은 무기 카드 2개 동시 노출되던 버그 (Thorn Ring Lv.1→2 + Lv.9→10).
- 루트 원인: `WeaponManager.add_weapon`이 `weapons.append` 후 `add_child` 호출 → weapon_name이 디폴트 "Weapon"인 윈도우에서 `has_weapon` 체크 실패하던 race.
- 3중 방어: (1) add_weapon 순서 교체 (add_child 먼저, append 나중) (2) `GameRoot._add_weapon` has_weapon guard → 이미 있으면 upgrade fallback (3) `LevelUpUI._generate_options` "up:" 루프 `seen_up` dedup.

### Fixed — 결과 패널 영문 버튼 텍스트 잘림
- "Play Agai", "Main Men" 으로 끝글자 잘리던 문제.
- 폰트 사이즈 축소: BtnRestart 32→26, BtnMenu 28→24, BtnRevive/DoubleGold 24→20.
- `size_flags_horizontal=3 + clip_text=true` 일괄 명시 (MainMenu 패턴 일치).

### Resolved — v0.26.0 Known Issues
- "Pyromancer 공격 미작동 의심" — FireWisp 코드 review 결과 정상 동작. FireWisp가 Pyromancer의 base attack 그 자체. 오진 close.
- "리더보드 / 광고 미동작" — 위 PGS/AdMob fix로 해결.

### Documentation
- `docs/releases/v0.27.0.md` GitHub Release 본문 작성.
- `play_store/release_notes/v0.27.0.txt` Play Console 다국어 노트 (KR/EN).
- README 상단에 `docs/images/readme.png` 소개 배너 추가.
- GitHub Pages 소개 페이지의 히어로 배경, Open Graph, Twitter 공유 이미지를 `branding/assets/pages.png` 기반으로 변경.
- README 제목을 `잔불의 밤 (Nightseed Survivor)`로 정정하고, v0.26 기준 재작성.
- GitHub repository description, homepage, topics 최신화.

### Build / CI
- GitHub Actions Pages 배포 단계에서 `branding/assets/pages.png`를 `assets/pages.png`로 복사하도록 추가.
- `version/code` 28 → 29, `version/name` "0.26.0" → "0.27.0" (`godot/export_presets.cfg` preset.0 + preset.4).

### Verification
- 로컬 headless editor import + GameRoot smoke 모두 클린.
- 로컬 headless APK build로 plugin classes + manifest meta-data 모두 포함 확인.
- 로컬 AAB build + 서명/dex 검증.

## v0.26.0 - 2026-05-16 (LevelUp 픽셀아트 + Galmuri 폰트 + 다국어 layout)

### Added — Phase UI-4 LevelUp 카드 자산 통합
- `LevelUpUI.gd` — `panel_card_dark.9.png` StyleBoxTexture로 카드 panel 적용 + rarity별 글로우 overlay (NinePatchRect 동적 추가)
- `GLOW_BY_KIND` 매핑: new→blue, up→gold, evolve→purple, passive_new→green, passive_up→gold
- `NinePatchRect.draw_center=false` + `self_modulate=WHITE` 강제 (parent modulate가 글로우 색 변형 방지)
- 글로우 자산 4장 (blue/green/purple/gold) 채도 기반 알파 처리 — saturation < 40 픽셀 alpha 0, 진한 색 외곽만 보존
- SELECT 버튼에 진한 navy outline 6px 추가 — 어떤 rarity 배경에서도 텍스트 가독
- 카드 높이 372→420, 아이콘 96→108, 폰트 사이즈 일괄 ~1.3배 (카드 title 42, header tag 30, stats 30, desc 28, select 32, "레벨업!" 48)

### Added — Galmuri 11 픽셀 폰트
- `godot/assets/fonts/Galmuri11.ttf` 신규 (5.1 MB, OFL 라이선스, https://github.com/quiple/galmuri)
- `gui/theme/custom_font` Pretendard → Galmuri 11 일괄 교체
- 한글 + 영문 동일 폰트로 픽셀아트 자산과 톤 통일

### Changed — 메인 메뉴 다국어 layout 안전화
- `MainMenu.tscn` VBox 가운데 정렬 + 폭 720 (anchor_left/right=0.5, offset -360~360)
- `project.godot` `stretch_aspect=expand` 복구 + `default_clear_color=Color(0.043,0.054,0.09,1)` (letterbox 영역 navy)
- BtnPlay, StatusCard, PrimaryRow/SecondaryRow/TertiaryRow에 `size_flags_horizontal=3` + `clip_text=true` 일괄 명시
- 폰트 사이즈 영문 fit 보정: BtnPlay 76→60, StatusLabel 30→24, NextGoalLabel 28→22

### Changed — Localization 영문 텍스트 단축 (NextGoalLabel 잘림 fix)
- `menu_next_goal_fmt` "Next upgrade in %d gold" → "%d g to upgrade"
- `menu_next_goal_ready` "★ Upgrade ready · open Shop" → "★ Upgrade ready"
- `menu_next_goal_maxed` "All upgrades maxed" → "All maxed"
- 한국어 텍스트는 변경 없음

### Documentation
- `docs/releases/v0.26.0.md`, `play_store/release_notes/v0.26.0.txt` 신규

### Known Issues (계속)
- ★ RANK 리더보드 / AdMob 광고 미동작 — Godot 4.2 헤드리스 export quirk (PGS/AdMob native .aar 누락). GUI 에디터 빌드 필요. v0.26.1+ fix 예정
- **Pyromancer 캐릭터 공격 미작동 의심** — 폰 검증 중 사용자 보고. FireWisp 코드 review로는 명확한 원인 못 찾음. v0.26.1에서 logcat 진단 + fix 예정

## v0.25.1 - 2026-05-16 (한국어 게임 제목 정리)

### Changed
- `godot/project.godot`
  - `application/config/name` "밤의 씨앗: 서바이버" → "Nightseed Survivor" (default 영문)
  - `application/config/name_localized` 추가 `{"en": "Nightseed Survivor", "ko": "잔불의 밤"}` — 한국어 폰은 "잔불의 밤", 그 외는 영문
- `branding/index.html` — 한국어 게임 제목 10곳 일괄 변경 ("밤의 씨앗: 서바이버" → "잔불의 밤"), SEO keywords에 신규 표기 추가하면서 옛 표기는 검색 유입 호환 위해 보존
- `branding/index.html` — "7분 생존 액션" 잔재 4곳 → "5분 생존 액션" 정정 (v0.18부터 5분 정책)
- 버전 번호 갱신: versionCode 26→27, versionName 0.25.0→0.25.1 (`godot/export_presets.cfg` preset.0 + preset.4)

### Preserved (의도된 그대로)
- 게임 lore 용어 "밤의 씨앗" (Nightseed의 한국어 번역, `docs/story/`) — 게임 세계관 개념
- 영문 코드네임 "Nightseed Survivor" (프로젝트 이름, 외부 등록명)
- 과거 release 노트의 옛 표기 (역사 기록)

### Documentation
- `docs/releases/v0.25.1.md` / `play_store/release_notes/v0.25.1.txt` 신규

### Known Issue (계속)
- ★ RANK / AdMob native (.aar) 빌드 누락 — v0.25.0과 동일 (Godot 4.2 헤드리스 export quirk). GUI 에디터에서 직접 export 필요. v0.25.2 또는 v0.26.0에서 fix 예정

## v0.25.0 - 2026-05-16 (메인 메뉴 픽셀아트 리워크 — AI 자산 31장 + 5명 영웅 일러)

### Added — 메인 메뉴 시각 전면 리워크

**5명 영웅 일러 배경 (BG-04, 720×1280)**
- `bg_menu_hero_lineup.png` — Berserker / Spirit Sister / Vagrant(중앙) / Hunter / Pyromancer 다섯이 야경 숲 앞에 정렬
- 자산 자체를 130 px 위로 shift (메뉴 UI와 안 겹치도록), 빈 하단은 dark navy padding
- `MainMenu.gd._apply_background()` — BG-04 우선, BG-01(야경) → 절차 MenuBackdrop fallback. BG-04 적용 시 단일 캐릭터 `CharacterShowcase` 자동 hide

**픽셀아트 타이틀 로고 (LG-02 / LG-03, 640×288)**
- `assets/logo/title_ko.png` — "잔불의 밤" (한국어)
- `assets/logo/title_en.png` — "NIGHTSEED SURVIVOR" (그 외 모든 언어)
- `MainMenu.tscn` — `TitleLabel` (Label, 시스템 폰트) → `TitleImage` (TextureRect)로 교체
- `MainMenu.gd._refresh_title_texture()` — `Localization.current_lang` 보고 자동 스왑

**9-slice 텍스처 패널 (PN-01 / PN-03)**
- `panel_stone_blue.9.png` (96×96) + `panel_cta_amber.9.png` (192×64)
- 9-slice 마진 텍스처 픽셀 기준 16 / 24 / 12 px로 수정 (이전 1024 px 가정 96/140/36 → 가운데 stretch 영역 0이라 단순 stretch처럼 동작하던 버그 수정)

**메뉴 버튼 3줄 × 2 배치**
- `MainMenu.tscn` — PrimaryRow / SecondaryRow / TertiaryRow (각 2개 버튼). 노드 path 변경에 맞춰 `MainMenu.gd` `@onready` path 갱신
- 영문 라벨 정리: `CHARACTERS` → `HEROES`, `★ LEADERS` → `★ RANK`, DIFF는 prefix 제거 후 난이도 이름만 (`btn_difficulty_short_fmt = "%s"`)
- `clip_text=true` + `custom_minimum_size=(1, 110)` — EXPAND 정상 동작
- 폰트 36 → 32

**6개 네비 아이콘 + 골드 코인 + 설정 톱니 + close X**
- `IC-NAV-01~06` (48×48): heroes / stages / difficulty / shop / story / leaderboard
- `IC-TOP-01~03` (24×24): gold_coin / settings_gear / close_x
- `_set_button_icon()` — `expand_icon=false` + `alignment=CENTER` + `icon_alignment=LEFT` + `icon_max_width=44` + `h_separation=12` + icon_modulate 살짝 lift (1.18~1.25)

**좌하단 코너 — Language / Credits**
- `TopRightRow` 위치 변경 — 우상단 (타이틀과 겹침) → 화면 좌하단 코너 (anchor bottom + offset_left=16)
- 폰트 24 → 22

### Added — AI 자산 후처리 자동화 파이프라인

ChatGPT(GPT-4o) 출력의 공통 결함을 일괄 보정. 31장 자산 모두 같은 파이프라인 통과:
1. **흰 가장자리 자동 crop** (4면에서 95%+ 흰색 행/열 detect)
2. **target ratio alpha padding** + nearest 다운샘플 (비율 보존)
3. **외곽 흰 영역 → 알파 (flood-fill)** — 외곽 alpha 0에서 인접 흰 픽셀만 변환, 가운데 디자인 흰 영역은 보존
4. **1 px navy outline** — 어두운 석판 위 가시성 확보

### Added — P1/P2 후속 화면용 자산 패키지 (import만, 코드 통합은 다음 버전)

LevelUp 카드 (`panel_card_dark.9` + 글로우 프레임 4색), Results 화면 (`banner_stage_clear` + 보상 아이콘 6종), 인게임 HUD (5종), 로고 ornament, 상점 보강 — 총 18장. 자산은 import + 후처리 완료, 화면별 코드 통합은 v0.26.0+ 진행 예정.

### Changed
- `Localization.gd`: `btn_characters` "CHARACTERS"→"HEROES", `btn_leaderboard_short` "★ LEADERS"→"★ RANK", `btn_difficulty_short_fmt` "DIFF: %s"→"%s"
- `MainMenu.gd`: title text → title texture, BG hero-lineup 우선

### Documentation
- `docs/releases/v0.25.0.md`, `play_store/release_notes/v0.25.0.txt` 신규
- `docs/ASSETS_TO_GENERATE.md` §1.1 — BG-04 5명 캐릭터 배경 프롬프트, 메뉴 UI와 안 겹치도록 캐릭터를 화면 가운데 좁은 띠에 배치하는 구도 규칙

### Verification
- 자산 31장 .import 자동 생성 + 헤드리스 부트 검증 통과
- 로컬 APK + AAB 빌드 + R8 서명 통과 (versionCode 26 / versionName 0.25.0)
- 폰 실기 검증 — 메인 메뉴 시각 전체 OK (배경/타이틀/캐릭터 lineup/버튼 3줄/아이콘 alignment)

### Known Issue
- ★ RANK 버튼 클릭 시 PGS 리더보드가 열리지 않음 — Godot 4.2 헤드리스 export(`--export-release`)가 EditorPlugin(AndroidExportPlugin)을 활성화하지 못해 PGS / AdMob native (.aar)이 빌드에 포함 안 됨. APK 안에 `play-games-services` 클래스 0개, `lib/`에 PGS native lib 없음 확인. v0.24.0도 같은 문제였을 가능성 (당시 폰 미검증). 다음 release(v0.25.1 또는 v0.26.0)에서 GUI 에디터 빌드 또는 Godot 4.3+ 업그레이드로 fix 예정

## v0.24.0 - 2026-05-15 (메인 메뉴 Nightseed 비주얼 리워크 1차 + AdMob 보상형 광고 SDK)

### Added

**UI 아트 디렉션 (Phase UI-1 / UI-2)**
- `ButtonStyles.gd`에 Nightseed 톤 Moon/Stone 스타일 추가
  - `apply_moon(button)` — 창백한 달빛 배경(`#DDEBFF`) + 짙은 남색 텍스트 CTA. PLAY 버튼 전용
  - `apply_stone(button, accent)` — 어두운 청회색 패널 + 강조색 상단 테두리. 캐릭터/스테이지/난이도 주요 메뉴
  - `apply_stone_secondary(button, accent)` — 더 어두운 패널 + 얇은 프레임. 스토리/리더보드/언어/크레딧
  - 코너 반경 ≤6, 테두리 2~3px로 봉인석/석판 느낌 강화
- `scripts/ui/MenuBackdrop.gd` 신규 — 절차 배경 레이어 (이미지 애셋 0)
  - 깊은 남색→숲 녹색 32단 수직 그라데이션 + 별 80개 + 달빛 헤일로 + 안개 띠 + 앞/뒤 2단 트리 실루엣 + 반딧불 16개
  - deterministic RNG seed (프레임마다 흔들리지 않음)
- `scripts/ui/CharacterShowcase.gd` 신규 + `MainMenu.tscn`의 `CharacterShowcase` 노드
  - 현재 선택 캐릭터 스프라이트(16×16)를 6× 업스케일 TextureRect로 표시 + 달빛 후광/봉인 링 절차 묘사
  - 스프라이트 누락 시 둥근 머리 + 사다리꼴 몸통 fallback 실루엣
  - 캐릭터 이름 라벨을 후광 아래 배치, 캐릭터 변경 시 즉시 갱신

**AdMob 보상형 광고 SDK 통합 (테스트 ID 단계)**
- Poing Studios AdMob 플러그인 통합
  - 메인 플러그인 v4.3.1: `godot/addons/admob/`
  - Android 백엔드 v4.2.0 (ads only): `godot/addons/admob/android/bin/ads/libs/*.aar`
  - `project.godot`의 `[editor_plugins]`에 admob plugin 활성화
- `godot/android/build/proguard-rules.pro`에 Google Mobile Ads keep 룰

### Changed

**UI 아트 디렉션**
- 메인 메뉴 시각 위계 재정리
  - PLAY 버튼 → 달빛 CTA (가장 강한 액션, 외곽 글로우)
  - 1차 행(CHARACTERS / STAGES / DIFFICULTY) → 강조색 테두리 석판 버튼
  - 2차 행(SHOP / STORY / LEADERS) → 조용한 석판 버튼
  - 상단 우측 코너(Language / Credits) → 더 작은 석판 보조 버튼
  - 타이틀/부제에 짙은 남색 외곽선 추가
- 상태 카드 톤 보정 — 더 어두운 청회색 + 상단 룬 라인 + 모서리 반경 12→6
- 메인 메뉴 배경을 단색 ColorRect → 절차 야경 레이어로 교체

**AdMob**
- `godot/scripts/core/AdManager.gd` 새 SDK API로 재작성
  - 외부 시그널/메서드 인터페이스 (`rewarded_granted/dismissed/failed`, `is_supported`, `is_rewarded_ready`, `show_rewarded(tag)`) 유지 — GameRoot 호출부 변경 없음
  - 내부 구현: `MobileAds.initialize()` → `RewardedAdLoader` + 콜백 람다
  - `ENABLED=true`, **Google 공식 테스트 광고 단위 ID** 사용 — 실제 ID는 사용자 수급 후 두 상수 교체
- `addons/admob/admob.gd` 패치 — iOS exporter 등록 제거 (Godot 4.2 type-inference 호환), AdMob Manager 에디터 메뉴 제거 (iOS handler가 매번 GitHub에서 zip 다운로드)
- `addons/admob/internal/exporters/ios/`에 `.gdignore` 배치
- `docs/ADMOB_SETUP.md` 새 SDK API에 맞게 전면 갱신

**기준 문서/밸런스**
- 현재 제품 기준을 5분 러닝타임(기본 스테이지 300초, Cursed Tomb 330초)으로 문서 정리
- 스토리 자막 위치를 HUD 아래로 이동하고 자막 폰트 확대
- 메인 메뉴 우상단 Language/Credits 버튼 위치/크기 보정
- 레벨업 보상 카드 폰트 전반 확대
- Normal 피해 배율 1.0→0.9, Forest of Echoes 중후반 웨이브 밀도 완화

### Documentation
- `docs/UI_ART_DIRECTION_ROADMAP.md` 추가 — Nightseed UI 디자인 철학, 색/형태 언어, 공통 UI 키트, 메인 메뉴 리워크, 캐릭터 쇼케이스, 레벨업 카드, 결과 화면, 하위 화면 톤 맞추기 단계별 계획
- `docs/ROADMAP.md`, `.agent/tasks.md`에 UI Art Direction 마일스톤 연결
- `GAME_SPEC`, `BALANCE`, PGS 설정 문서의 오래된 10분/PGS 대기 기준 정리

### Verification
- `godot --headless --path godot --quit` 통과 (GDScript 파싱 에러 0)
- 2-pass 에디터 임포트로 `CharacterShowcase`/`MenuBackdrop` 글로벌 클래스 캐시 등록 확인
- `godot --headless --path godot --quit-after 30` 부트 + MainMenu 30프레임 실행 — 스크립트 에러 0
- 720x1280 / 540x960 디자인 좌표 정적 확인 — CharacterShowcase rect(360×180, y=480~660)이 StatusCard(y≤480)·BtnPlay(y≥672)와 무겹침
- 로컬 AAB 빌드(R8 + 키스토어 서명) 통과
- 폰 실기 검증은 사용자 직접 진행 (이번 릴리즈는 비주얼 확인용)

### Notes
- 새 이미지 애셋은 추가하지 않았다. 1차 리워크 결과를 폰에서 본 뒤 추가 필요 후보(메인 배경 일러스트, 캐릭터 큰 portrait, 9-slice 텍스처, 출정/상점/도감/설정/업적 아이콘) 산출 예정
- AdMob은 Google 공식 테스트 ID로 빌드 — 실제 광고 ID 수급(Play Console 공개 트랙 출시 후)되면 두 상수만 교체

## v0.23.0 - 2026-05-14 (폰트 대확대 — 모바일 가독성 최종 보정)

### Changed
- 메인 메뉴 폰트 일괄 대확대 — v0.22의 +4 폭이 모바일에서 여전히 "답답하다"는 피드백 받고 ~1.7배 수준으로 재조정. PLAY 48→76, 1차/2차 버튼 22→36, 타이틀 58→76, 부제 24→36, 골드 30→46, 상태 20→30, 코너 17→24
- 메인 메뉴 컨테이너 높이 재조정 — TitleLabel 110→184, StatusCard 96→140, BtnPlay 136→196, PrimaryRow 88→128, SecondaryRow 80→120, TopRightRow 60→80px
- HUD 폰트 대확대 — 시간 34→56, Lv/Kills/Gold 라벨 20→34, HP 라벨 18→28
- HUD top bar 140 → 210px (확대된 폰트 + 아이콘 수용), HUD.gd `TOP_BAR_BASE_HEIGHT` 동일 갱신
- HUD 아이콘 26×26 → 40×40, HP 바 높이 28→42, XP 바 22→22 유지 (위치만 184→184)
- HP 라벨 외곽선 4 → 5, 외곽선 알파 0.75 → 0.85 (큰 폰트에 맞춰 강화)

### Verification
- `godot --headless` MainMenu / HUD 씬 로드 에러 없음
- 실기 체감 검증: 사용자 폰에서 v0.23.0 빌드로 확인 예정

## v0.22.0 - 2026-05-14 (폰트 가독성 + HUD 아이콘 + 스토리 메뉴)

### Added
- `scenes/ui/StoryUI.tscn` + `scripts/ui/StoryUI.gd` — 스토리 다시 읽기 화면. `Stages.stages` 순회하며 해금된 스테이지는 intro/boss_intro/clear 대사 전부 표시, 미해금은 🔒 + "이 스테이지를 해금하면 이야기가 열립니다." 안내. 우상단 `용어집 →` 버튼으로 CodexUI 이동
- HUD `StatsRow`에 아이콘 셀 — Lv 라벨 앞 pickup_xp 아이콘(청색 tint), Kills 라벨 앞 icon_moon_dagger(주황 tint), Gold 라벨 앞 pickup_gold. 26×26 텍스처 + 6px gap
- HUD `BackdropBorder` — top bar 하단 2px 슬레이트 경계선으로 게임 영역과 분리
- HP 라벨에 검은 외곽선(outline_size=4) — HP 바 위 텍스트가 어떤 fill 색에서도 읽힘
- Localization 신규 키 9개 — `btn_story`, `btn_to_codex`, `btn_back_to_menu`, `story_title`, `story_hint`, `story_locked_long`, `story_section_intro` / `_boss` / `_clear`

### Changed
- 폰트 전반 +4 — 외부 리뷰 "글씨가 너무 작아서 안보여" 대응
  - 메인 메뉴 PLAY 44→48, 1차/2차 행 18→22, 코너 13→17, 부제 20→24, 골드 26→30, 상태 16→20
  - HUD 시간 30→34, 스탯 16→20, HP 라벨 14→18
  - 레벨업 카드 — 타이틀 32→36, 무기명 24→28, select 22→26, stats 16→20, desc 15→19, tags 13→17
- HUD top bar 높이 112 → 140px (확장된 폰트/아이콘 수용)
- 레벨업 카드 — `custom_minimum_size` 320 → 380px, 아이콘 70×70 → 96×96px, header bar 32 → 40px
- 레벨업 카드 아이콘에 무기 컬러 `self_modulate` 적용 — Kenney 베이스 스프라이트(전부 작은 물약)가 XP 픽업과 시각 구분되도록 강한 컬러 틴트
- 메인 메뉴 `btn_codex`(원래 CODEX 라벨) 라우트를 CodexUI → StoryUI 로 변경, 라벨 키 `btn_codex` → `btn_story`. 코덱스는 StoryUI 안의 `용어집 →` 버튼으로 진입

### Verification
- `godot --headless` MainMenu / HUD / LevelUpUI / StoryUI 씬 로드 에러 없음
- 실기 체감 검증: 사용자 폰에서 v0.22.0 빌드로 확인 예정

## v0.21.0 - 2026-05-14 (모바일 레이아웃 수정 — 빈 공간 메우기)

### Changed
- 메인 메뉴 — VBox 안의 기존 6px Spacer를 `size_flags_vertical = 3` + `stretch_ratio = 2.0`로 변경하고 SecondaryRow 뒤에 `stretch_ratio = 1.0` BottomSpacer 추가. 키 큰 폰에서 액션 블록(시작 + 6 버튼)이 화면 상단 절반에 몰리지 않고 ~2/3 지점 (자연스러운 엄지 위치)으로 내려옴. v0.20.0까지는 1080×2340 폰 기준 하단 ~1100px가 빈 검은 공간이었음
- 레벨업 카드 — 카드의 `size_flags_vertical = 3` 제거하고 `custom_minimum_size`를 296→320으로 조정. VBox에 `alignment = 1` (CENTER) 추가. 카드가 화면 높이로 늘어나며 내부 콘텐츠 아래 ~440px 빈 공간이 생기던 문제 해결 — 세 카드가 자연 높이로 화면 중앙에 클러스터링
- 인게임 HUD — XP 바를 HP 바와 더 가까이 (gap 4 → 2px), XP 바 높이 12 → 16px, XP 바에 파란 fill + 어두운 배경 스타일박스 적용 (`HUD.gd._init_xp_bar_style`). HP/XP가 하나의 정보 단위로 묶여 보임

### Changed
- 메인 메뉴 — 푸터 행(Language/Credits) 폐기, 상단 우측 코너의 작은 행으로 이동. PLAY 아래 영역은 6 버튼(캐릭터/스테이지/난이도 + 상점/용어집/순위표)으로 정리되어 시각적 무게 감소. Language 버튼 라벨도 "Language: English" → "English"로 단축
- 인게임 HUD — HP 바 채움 색이 잔여 HP 비율에 따라 동적 변경 (55% 초과 = 초록, 30~55% = 호박→빨강 보간, 30% 이하 = 빨강 + 알파 펄스 0.55↔1.0, 0.35s 사인 루프). 둥근 모서리 + 어두운 배경 스타일박스 적용
- 레벨업 카드 — 카드 전체 탭은 기존부터 지원했지만 시각 피드백이 부족했음. 누르는 순간 scale 0.96 (0.08s, 사인 ease-out) → 떼면 1.0으로 복귀하며 선택 처리. 터치와 마우스 양쪽 모두 적용

### Verification
- `godot --headless` MainMenu / HUD / LevelUpUI 씬 로드 에러 없음
- 실기 체감 검증은 GitHub Actions 산출물 / 폰 빌드로 확인 예정

## v0.19.0 - 2026-05-14 (Phase 1 마무리 + Phase 2: 전투 체감 + 인프라)

### Added
- 스테이지별 배경 톤 — `stages.json` 에 `bg` 블록 추가, `BackgroundTiler.apply_tone()`이 타일·자갈·반딧불·장식·횃불 색상을 스테이지마다 다르게 적용 (Forest는 깊은 청록, Frozen Wastes는 차가운 청회색, Twilight Sanctum은 자보라, Inferno Chasm은 진홍, Cursed Tomb은 검적-자색)
- `EnemyDasher` 돌진 텔레그래프 라인 — 발사 직전 0.55초 동안 플레이어 방향으로 주황 라인이 점점 길어짐
- `EnemyCaster` 발사 텔레그래프 — 발사 전 0.45초 마젠타 조준선, 플레이어 이동에 따라 실시간 갱신
- `EnemySplitter` 분열 임박 펄스 — HP 35% 이하부터 마젠타 펄스, 사망 시 분열과 함께 외향 링 버스트
- `EnemyMiniBoss` 새 패턴 — 6.5초마다 방사형 충격파, 안쪽 영역은 안전하고 외향 링 두께(±36px) 안에 있을 때만 12 피해 + 시각 링 확장
- `EnemyBoss` 격노 페이즈 — HP 30% 이하 진입 시 오라가 진홍으로 변하고, 스파이크 회전이 2.6배 빨라지며 본체가 펄스. 접촉 피해 ×1.45, 이동 속도 ×1.35, 3.2초마다 8발 방사형 탄막. 진입 순간 외향 버스트와 사운드 큐로 이벤트화
- `AdManager` autoload — 보상형 광고 SDK 통합용 인터페이스 (rewarded_granted/dismissed/failed 시그널, 1회/run 한도)
- 결과 화면 광고 버튼 2개 — "부활하기 (광고 시청)" (사망 시, 1회/run, HP 50% + 무적 3초 + 가까운 적 제거), "골드 2배 (광고 시청)" (승리/사망 모두, 1회/run, count-up과 다음 목표 라인을 즉시 갱신)
- Localization 신규 키 — `btn_revive_ad`, `btn_double_gold_ad` (KO/EN)
- `Player.revive(hp_ratio, invincibility_seconds)` 메서드
- `ButtonStyles.REWARD_AD` — 보상형 광고 CTA 전용 보라 톤
- 문서 — `docs/ADMOB_SETUP.md` (콘솔 단계, 플러그인 설치, ID 수급 가이드)

### Changed
- Fire Wisp — 랜덤 위치 폭발 폐기, 화면 안 적 중 K=8개 후보 위치에 대해 폭발 반경 안의 적 수를 점수화해 가장 많이 덮는 위치 선택. 폭발 여러 개일 때는 이미 맞은 적을 제외하고 다음 군집 선택
- Star Needle — 가장 가까운 적 방향 좁은 부채꼴 폐기, 근거리 적 무게중심 방향 우선, 단일 적이면 그 방향, 적이 없으면 플레이어 이동 방향. 부채꼴 폭은 needle_count 에 따라 0.32~1.1 라디안으로 확장
- 게임오버/승리 시 골드 적립과 리더보드 제출 시점을 결과 화면 표시 직후가 아니라 Restart/Menu 누를 때로 이동 — 보상형 광고 "골드 2배" CTA가 적립 직전에 끼어들 수 있게
- `.agent/tasks.md` 를 실제 구현 상태에 맞게 재정리 (v0.18.0 시점 항목 통합, Phase 3+ 후보 정리)

### Fixed
- Play Games Services 활성화 — Play Console PGS 프로젝트 출시 완료(2026-05-14), App ID `442399975649` 와 리더보드 6종 실제 ID를 `game_services_ids.xml` / `LeaderboardManager.LEADERBOARD_IDS` 에 주입. OAuth 동의 화면은 테스트 모드(등록된 테스터만 로그인 가능)

### Verification
- 코드 변경만 수행, 실기 플레이 검증은 GitHub Actions 산출물로 확인 예정
- `AdManager.ENABLED = false` 상태로 출시 — SDK + ID 수급 전까지는 광고 CTA가 빌드에 나타나지 않음

## v0.18.0 - 2026-05-14 (Phase 1: 제품감 정리)

### Changed
- 메인 메뉴 — PLAY 버튼을 시각적 단일 1차 액션으로 강조, 캐릭터/스테이지/난이도를 1차 행, 상점/용어집/순위표를 2차 행, 언어/크레딧을 푸터로 정리
- 메인 메뉴 — 골드 옆에 "다음 강화까지 N 골드 / ★ 강화 가능" 힌트 표시
- 인게임 HUD — 상단 점유 영역을 168→112px로 축소, 시간(생존)을 상단 중앙 강조, HP/XP 바와 폰트 크기 모바일 1손 가독성 기준으로 조정
- 레벨업 카드 — 헤더에 신규/강화/진화 태그, 무기별 실제 DMG·CD 현재값과 다음값, 역할 칩(추적/근접/광역/화력/생존/기동/수집/편의) 표시
- 결과 화면 — 승리/패배에 따른 배경 톤 분리, 타이틀 스케일 팝 애니메이션, 획득 골드 카운트업, "다음 강화까지 N 골드 · ★ 강화 가능" 라인, 신규 업적 강조 라인 추가

### Added
- Localization 신규 키 — `menu_next_goal_fmt`, `menu_next_goal_ready`, `menu_next_goal_maxed`, `btn_difficulty_short_fmt`, `btn_leaderboard_short`, `btn_credits_short`, `levelup_tag_*`, `levelup_new_*`, `levelup_lv_change_fmt`, `levelup_passive_level_fmt`, `levelup_evolve_*`, `levelup_stats_*`, `tag_seek/melee/aoe/ranged/power/defense/survive/mobility/pickup/utility/evolve`, `result_next_goal_fmt`, `result_next_goal_ready`

### Verification
- `godot --headless --path godot --quit` 통과
- `godot --headless --path godot --editor --quit-after 400` 1회 import 성공 (스크립트 파싱 OK)
- 실기 플레이 검증은 GitHub Actions의 export·릴리즈 산출물로 확인 예정

## Unreleased - 2026-05-14 (상용화 개선 분석)

### Documentation
- `docs/COMMERCIALIZATION_ANALYSIS.md` 추가
  - 현재 구현 상태를 기준으로 디자인, 전투 체감, 데이터화, 성능, 저장/플랫폼 QA, 출시 패키징 개선 방향 정리
  - Google Play Games, Google Play 광고 정책, PGS 통계, 2026년 모바일 게임 시장 리뷰, Survivors-like 장르 개요 참고 링크 기록
- `.agent/tasks.md`에 Product Polish 후속 작업 추가
- `.agent/progress.md`, `HISTORY.md` 작업 이력 갱신

### Verification
- 문서 변경만 수행하여 Godot headless 검증은 생략

## Unreleased - 2026-05-13 (런타임 스토리 연결)

### Added
- `godot/data/story_dialogues.json` — 스피커·스테이지별 인트로/보스 인트로/클리어/반복 힌트 대사 묶음
- `Story` autoload (`scripts/core/Story.gd`) — 대사/용어를 현재 언어로 제공하는 단일 진입점
- `StoryBanner` UI (`scripts/ui/StoryBanner.gd`, `scenes/ui/StoryBanner.tscn`) — 비차단 자막 큐, 페이드 인/홀드/페이드 아웃
- 게임 시작 시 스테이지 인트로, 보스 등장 시 "봉인의 파수꾼이 깨어납니다" + 보스 대사, 승리 시 클리어 대사 자동 재생
- 승리 화면 부제 — "기억의 조각을 되찾았습니다."
- `CodexUI` 용어집 화면 (`scripts/ui/CodexUI.gd`, `scenes/ui/CodexUI.tscn`) — 메인 메뉴에서 진입, KO/EN 동기화
- Localization 키 — `boss_warning`, `result_fragment_recovered`, `btn_codex`, `codex_title`, `codex_hint`, `codex_safe_label`
- `WaveManager.boss_spawned` 시그널 — UI/오디오가 보스 등장 시점을 구독할 수 있도록 노출

### Changed
- 메인 메뉴 버튼 배치에 CODEX 항목 추가
- Result 패널 레이아웃에 부제 라벨 추가 (승리 시만 표시)

### Documentation
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md`, `HISTORY.md` 갱신

### Verification
- `story_dialogues.json`, `story_terms.json` JSON 문법 검사 통과
- 로컬 Godot headless 검증은 `godot` 실행 파일이 PATH에 없어 미실행 (정적 리뷰로 대체)

## Unreleased - 2026-05-13 (스토리 기준 문서)

### Added
- `docs/story/` 스토리 기준 문서 세트 추가
- Nightseed 용어 정의, 단계별 대사 공개 기준, UI 카피 기준 추가
- 향후 용어집/도감 UI를 위한 `godot/data/story_terms.json` 추가

### Changed
- 스테이지 설명 문구를 Nightseed 세계관 기준으로 갱신
- 원본 스토리 설계서 패키지를 `docs/story/source/nightseed-lore-story-update/`로 정리

### Documentation
- `docs/GAME_SPEC.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`에 스토리 기반 작업 기준 반영
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md`, `HISTORY.md` 갱신

### Verification
- `stages.json`, `story_terms.json` JSON 문법 검사 통과
- 로컬 Godot headless 검증은 `godot` 실행 파일이 PATH에 없어 미실행

## v0.2.0 - 2026-05-07

### Added
- Godot 4 프로젝트 골격(`godot/`) 및 실행 가능한 `project.godot` 추가
- Milestone 1 플레이어블 프로토타입 씬/스크립트 추가
- 플레이어 이동(WASD/방향키), 체력, 피격 무적, 게임오버/재시작 루프 추가
- 적 기본 씬, 플레이어 추적 이동, 플레이어 주변 스폰 로직 추가
- HUD(HP, 생존 시간) 추가

### Changed
- 작업 우선순위를 Milestone 2(Combat Loop) 중심으로 갱신

### Documentation
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md` 갱신
- `HISTORY.md` 작업 이력 갱신

### Verification
- 로컬 Godot headless 검증 시도 (환경 의존)
- CI 검증은 푸시 후 GitHub Actions에서 확인

## v0.1.0 - 2026-05-06

### Added
- Nightseed Survivor 초기 설계 문서 추가
- Godot 4 기반 2D survivor-like MVP 설계 추가
- 기존 에이전트 작업 지침을 게임 프로젝트용 `AGENTS.md`로 통합
- Placeholder 그래픽 우선 개발 정책 추가
- 기존 장르의 아쉬운 점을 선반영하는 개선 전략 문서 추가
- 릴리즈 산출물 검증 체크리스트 추가

### Documentation
- `docs/GAME_SPEC.md` 추가
- `docs/IMPROVEMENT_STRATEGY.md` 추가
- `docs/ASSET_GUIDE.md` 추가
- `docs/ARCHITECTURE.md` 추가
- `docs/ROADMAP.md` 추가
- `docs/BALANCE.md` 추가
- `docs/RELEASE_CHECKLIST.md` 추가
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md` 추가
- `prompts/FIRST_AGENT_PROMPT.md` 추가

### Verification
- 문서 파일 생성 확인
- 실제 Godot 프로젝트 생성 및 빌드는 아직 수행하지 않음
