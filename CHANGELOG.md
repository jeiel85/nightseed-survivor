# CHANGELOG.md

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
