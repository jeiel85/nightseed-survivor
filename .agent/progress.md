# Progress

## 2026-05-15 — P1/P2 UI 자산 생성 자동화

### Status

`docs/ASSETS_TO_GENERATE.md`의 P1/P2 누락 자산만 생성하는 스크립트를 추가했다. 실제 OpenAI API 호출은 키 인증 이후 billing hard limit에 막혀 중단됐다.

### Completed

- `scripts/generate_missing_ui_assets.py` 신규
  - 기본 모델 `gpt-image-2`
  - `OPENAI_API_KEY`를 프로세스 환경 변수 또는 Windows 사용자 환경 변수에서 읽음
  - P0 ID는 항상 제외
  - 이미 존재하는 파일은 덮어쓰지 않음
  - 생성 이미지를 표의 원본 크기로 nearest-neighbor 리사이즈
  - `--dry-run`으로 생성 대상만 확인 가능
- `docs/ASSETS_TO_GENERATE.md`에 자동 생성 실행 방법 추가
- dry-run 확인: 누락 P1/P2 20개 대상, 기존 P0 및 BG-02/BG-03 제외

### Not Yet Done

- OpenAI API 실제 생성 — `billing_hard_limit_reached`로 중단
- 생성된 PNG의 Godot import 및 headless 검증

## 2026-05-15 — 메인 메뉴 Phase UI-3 (AI 자산 1차 통합)

### Status

ChatGPT(GPT-4o)로 생성한 P0 자산 10개 + BG-02/03 보너스 2개를 메인 메뉴에 1차 통합. 로컬 빌드 불가 환경이라 코드만 푸시하고 빌드/실기 검증은 다음 세션(빌드 가능 PC)에 위임.

### Completed

- 자산 12장 배치 — `godot/assets/sprites/ui/{bg,panel,icon_top,icon_nav}/`
- 디자인 스펙 2장 — `docs/UI_REDESIGN_SPEC.md`, `docs/ASSETS_TO_GENERATE.md` (ChatGPT 워크플로우 반영)
- `ButtonStyles.gd` 확장 — `apply_stone_texture(Button, accent)`, `apply_amber_texture(Button)` + 9-slice margin 상수 + 텍스처 누락 시 기존 `apply_stone`/`apply` 자동 fallback
- `MainMenu.tscn` — `BackgroundImage` (TextureRect) 추가, 기존 절차 `MenuBackdrop`은 fallback용으로 visible=false, `GoldCoinIcon` (TextureRect) GoldRow에 추가
- `MainMenu.gd` — `_apply_background()` / `_apply_button_icons()` 추가, `_apply_button_styles()` 텍스처 기반으로 전환 (Language/Credits만 flat 보조 유지), 모든 텍스처 로드는 `ResourceLoader.exists()` 가드

### Not Yet Done — 다음 세션(빌드 가능 PC)에서

- `.import` 파일 자동 생성 (Godot 에디터 첫 실행) → 커밋
- `godot --headless --path godot --quit` 헤드리스 검증
- 로컬 Android AAB 빌드 + 실기 확인 (메인 메뉴 새 배경/버튼/아이콘 렌더)
- 9-slice margin 96/140/36 px가 실제 렌더에서 의도대로 나오는지 시각 검수 (어긋나면 `ButtonStyles.gd`의 `STONE_NINE_MARGIN`/`AMBER_NINE_L_R`/`AMBER_NINE_T_B` 조정)
- Play Console 비공개 트랙 업로드 (검증 후)
- 통과 시 P4 진입: LevelUp → Results → CharSelect → Shop → BattleHUD 순차 적용

## 2026-05-15 — v0.24.0 릴리즈 준비

### Status

v0.23.0 이후 누적된 작업 4건(UI 비주얼 리워크 1차 + AdMob SDK 통합 + 문서 정리 + 밸런스 보정)을 v0.24.0 한 릴리즈로 묶음. 사용자가 폰에서 비주얼을 직접 확인한 뒤 태그 푸시 여부를 결정.

### Completed

- 버전 번호 갱신
  - `godot/export_presets.cfg` versionCode 24→25, versionName 0.23.0→0.24.0 (preset.0 + preset.4 동시)
  - `min_sdk` 21→24 (Poing AdMob aar가 minSdk 24 요구 — Android 5.x/6.x 단말 제외)
- 릴리즈 노트 작성
  - `docs/releases/v0.24.0.md` — GitHub Release 본문 (한국어 마크다운)
  - `play_store/release_notes/v0.24.0.txt` — Play Console 다국어 (KO 430자 / EN 445자, 500자 이내)
- CHANGELOG.md — 누적 Unreleased 4섹션 → v0.24.0 한 섹션으로 통합
- 로컬 AAB 빌드 + R8 키 서명 — `build/nightseed-survivor-release.aab` + mapping.txt
- 바탕화면 복사 (`C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.24.0.aab/.txt`)
- main 브랜치 커밋 + push

### Not Yet Done

- 폰 실기 검증 — 메인 메뉴 비주얼 리워크 / AdMob 테스트 광고 재생 / minSdk 24 호환성 확인
- 태그 푸시 — 사용자 확인 후 진행 (`git tag -a v0.24.0 -m "..."` && `git push origin v0.24.0`)
- 사용자 확인 OK 이후: Play Console 비공개 트랙 업로드 + mapping.txt deobfuscation 업로드

## 2026-05-15 — 메인 메뉴 Nightseed 비주얼 리워크 1차 (Phase UI-1 + UI-2)

### Status

`docs/UI_ART_DIRECTION_ROADMAP.md` §4.1·§5의 방침대로 새 이미지 애셋을 추가하지 않고 ButtonStyles 확장 + 절차 배경 + 기존 캐릭터 스프라이트 기반 쇼케이스로 1차 리워크를 진행했다. PLAY 버튼은 달빛 CTA, 1차 행은 강조색 석판, 2차 행/코너는 조용한 석판으로 시각 위계가 정리됐다.

### Completed

- `ButtonStyles.gd` 확장
  - `MOON_PRIMARY`/`MOON_TEXT`/`MOON_BORDER` 상수 (창백한 달빛 CTA용)
  - `STONE_PRIMARY`/`STONE_SECONDARY`/`STONE_TEXT`/`STONE_BORDER` 상수
  - `apply_moon(button)` — 달빛 배경 + 짙은 남색 텍스트 + 외곽 글로우 (shadow_size 8)
  - `apply_stone(button, accent)` — 어두운 청회색 패널 + 강조색 상단 룬 라인 (border_top 3, 나머지 2)
  - `apply_stone_secondary(button, accent)` — 더 어두운 패널 + 얇은 프레임
  - 기존 `apply(button, base)` 함수는 다른 화면(레벨업/결과 등) 호환을 위해 유지
- `scripts/ui/MenuBackdrop.gd` 신규 — 절차 야경 배경 (이미지 0)
  - 깊은 남색 → 숲 녹색 32단 수직 그라데이션
  - 상단 영역에 별 80개 (deterministic seed)
  - 우상단 달 + 6단 푸른 헤일로
  - 지평선 근처 안개 가로 띠 14장 (sin 기반 알파)
  - 뒤쪽 옅은 트리 라인 + 앞쪽 진한 트리 라인 (사각형 삼각형 polygon)
  - 지평선 아래 검은 흙 + 달빛 라인
  - 반딧불 16개 (작은 글로우 + 점)
- `scripts/ui/CharacterShowcase.gd` 신규
  - GameData.selected_character 기준으로 `Characters.DATA[key].sprite` 로드 → TextureRect (`stretch_mode = KEEP_ASPECT_CENTERED`, NEAREST 필터)
  - 후광 6단 외곽 + 5단 코어 + 봉인 링 2줄 + 발판 그림자 ellipse
  - 스프라이트 누락/로드 실패 시 둥근 머리 + 사다리꼴 몸통 fallback silhouette
  - `refresh()`를 외부에서 호출하면 캐릭터 변경 후 즉시 갱신
- `MainMenu.tscn` 노드 추가/연결
  - `MenuBackdrop` (anchor full rect, mouse_filter=IGNORE) — 가장 뒷 레이어
  - `CharacterShowcase` (360×180, screen y=480~660, anchor=0.5) — StatusCard와 BtnPlay 사이 Spacer 영역
  - Portrait 96×96 (16×16 스프라이트 6× 업스케일), NameLabel 36px (하단 코너)
- `MainMenu.gd` 갱신
  - `_apply_title_styles()` — 타이틀/부제에 짙은 남색 외곽선 추가
  - `_apply_button_styles()` — PLAY → apply_moon, 1차 행 → apply_stone, 2차 행 + 코너 → apply_stone_secondary
  - `_apply_status_card_style()` — 카드 톤 더 어둡게, 상단 룬 라인, 모서리 12→6
  - `_refresh()` 끝에 `character_showcase.refresh()` 호출 (난이도 사이클/언어 변경 시도 갱신)
- 문서 갱신
  - CHANGELOG.md Unreleased 섹션 추가
  - HISTORY.md 항목 추가
  - .agent/tasks.md Phase UI-1/UI-2 체크 + 후속 항목 분리

### Verification

- `godot --headless --path godot --quit` 통과 (GDScript 파싱 에러 0)
- 2-pass 에디터 임포트(`--editor --quit-after 30` × 2)로 `CharacterShowcase`/`MenuBackdrop` 글로벌 클래스 캐시 등록 — 이후 MainMenu.gd의 `@onready var character_showcase: CharacterShowcase` 타입 인식 OK
- `godot --headless --path godot --quit-after 30` (autoload 포함 부트 + MainMenu 30프레임) 통과 — 스크립트 에러 0, ObjectDB leak 경고만 (headless `--quit-after`에서 흔히 보이는 비치명)
- 720x1280 / 540x960 디자인 좌표 정적 확인:
  - VBox children 누적: Title 0–184 → 196 Subtitle 196–248 → 260 StatusCard 260–400 → 412 Spacer(flex 2.0) 412–580 → 592 BtnPlay 592–788 → 800 PrimaryRow 800–928 → 940 SecondaryRow 940–1060 → 1072 BottomSpacer(flex 1.0) 1072–1156
  - 스크린 좌표(+80): StatusCard 끝 y=480, BtnPlay 시작 y=672, 그 사이 Spacer 영역 y=492~660
  - CharacterShowcase y=480~660: StatusCard와 BtnPlay 어디와도 겹치지 않음
  - Halo center y=70 (showcase local), radius 61 → halo top=9, bottom=131. 모두 showcase 내부 또는 알파 0.18 이하의 외곽 헤일로만 미세 bleed (시각적 손상 없음)

### Not Yet Done

- 폰 실기 검증 — 다음 AAB 빌드에서 가독성/겹침 최종 확인
- 실제 필요한 추가 애셋 목록 최종 산출 (메뉴 배경 일러스트 / 캐릭터 큰 portrait / 9-slice / 출정·상점·도감·설정·업적 아이콘)
- Phase UI-3 portrait 도입, Phase UI-4 레벨업 카드, Phase UI-5 결과 화면, Phase UI-6 하위 화면 톤 통일

## 2026-05-15 — 다음 UI 리워크 착수 판단 기록

### Status

메인 메뉴 Nightseed 비주얼 리워크는 새 이미지 애셋 제작보다 공통 UI 키트와 메인 메뉴 구조 개선을 먼저 진행하기로 정리했다.

### Completed

- `docs/UI_ART_DIRECTION_ROADMAP.md`에 다음 세션 착수 판단 추가
- `ButtonStyles.gd` Moon/Stone 스타일 → 메인 메뉴 버튼 위계 → 절차 배경 → 기존 스프라이트 기반 CharacterShowcase 순서로 진행하도록 정리
- 1차 리워크 후 필요한 배경, portrait, 9-slice, 아이콘 애셋 후보를 다시 산출하는 흐름으로 기록

### Not Yet Done

- 실제 UI 스타일/씬 구현
- 메인 메뉴 720x1280, 540x960 레이아웃 검증
- 추가 이미지 애셋 필요 여부 최종 확정

## 2026-05-15 — AdMob 보상형 광고 SDK 통합 (테스트 ID 단계)

### Status

비공개 테스트 트랙이라 AdMob 콘솔 앱 검색이 안 잡히는 상태. 사용자 실제 ID
없이 SDK 통합 + 빌드 검증 가능한 데까지 모두 진행 (옵션 A). 실제 ID는
Play Console 공개 트랙 출시 후 두 상수만 교체.

### Completed

- Poing Studios godot-admob-plugin v4.3.1 + godot-admob-android v4.2.0
  (Godot 4.2 호환 백엔드) 다운로드 및 배치
  - 메인 플러그인: `godot/addons/admob/` (csharp/sample/donate/docs 폴더는 제거)
  - Android 백엔드 ads/ .aar 4개: `godot/addons/admob/android/bin/ads/libs/`
  - 다른 mediation (adcolony/meta/vungle)은 config에서 비활성, 백엔드 .aar
    포함 안 함
- `project.godot` [editor_plugins]에 `res://addons/admob/plugin.cfg` 활성화
- `godot/addons/admob/admob.gd` 외부 플러그인 원본 수정:
  - iOS exporter 등록 제거 (Godot 4.3+ 전용 GDScript 패턴이라 4.2 파싱 실패)
  - AdMob Manager 에디터 메뉴 제거 (메뉴 진입 시 iOS 백엔드 zip을 GitHub에서
    자동 다운로드)
- `godot/addons/admob/internal/exporters/ios/`에 `.gdignore` (4.2 파싱 스킵)
- `godot/scripts/core/AdManager.gd` 전면 재작성 — 외부 시그널/메서드
  인터페이스(`rewarded_granted`/`rewarded_dismissed`/`rewarded_failed`,
  `is_supported`/`is_rewarded_ready`/`show_rewarded(tag)`) 유지하여 GameRoot
  호출부 변경 없음. 내부 구현은 `MobileAds.initialize()` →
  `RewardedAdLoader` + 콜백 람다 + `OnUserEarnedRewardListener`
- `godot/android/build/proguard-rules.pro`에 Google Mobile Ads keep 룰 추가
- `docs/ADMOB_SETUP.md` 새 SDK API에 맞게 전면 재작성 — 실제 ID 수급 후
  교체할 두 상수 경로 명시
- Godot 4.2.2 헤드리스 에디터 임포트 통과: GDScript 파싱 에러 0, 글로벌
  클래스 캐시 2-pass 후 모든 플러그인 클래스 인식

### Not Yet Done

- AAB 빌드 검증 — Gradle이 `com.google.android.gms:play-services-ads:24.9.0`
  처음 다운로드, R8 stripping이 새 .aar 의존성을 깨지 않는지 확인
- 비공개 테스트 트랙 업로드 + 폰에서 부활/골드 2배 CTA 표시·재생·보상 적용
- 사용자 AdMob 콘솔 등록(공개 트랙 출시 이후) → 실제 ID로 두 상수 교체

## 2026-05-15 — UI 아트 디렉션 로드맵 작성

### Status

사용자 피드백: 현재 UI는 가독성은 좋아졌지만, 메인 화면 배경/캐릭터/세계관 표현이 부족하고 네모 버튼 중심이라 모바일 게임 완성도 측면에서 아쉬움이 있음.

### Completed

- `docs/UI_ART_DIRECTION_ROADMAP.md` 추가
- Nightseed UI 디자인 철학 정리: 밤, 달빛, 기억, 봉인, 숲, 위험
- 공통 UI 키트, 메인 메뉴 비주얼 리워크, 캐릭터 쇼케이스, 레벨업 카드, 결과 화면, 하위 화면 톤 맞추기 순서로 작업 단계 정의
- 다음 세션에서 바로 시작 가능한 `feat(ui): 메인 메뉴 Nightseed 비주얼 리워크 1차` 체크리스트 작성
- `docs/ROADMAP.md`, `.agent/tasks.md`에 UI Art Direction 마일스톤/대기열 연결

### Not Yet Done

- 실제 UI 구현은 다음 세션에서 진행
- 배경 이미지/캐릭터 portrait 실제 리소스 선정

## 2026-05-15 — 기준 문서 정리 + UI/Normal 완화

### Status

빌드 환경이 아닌 작업 환경에서 소스/문서만 수정. Godot 실행 검증은 다음 빌드 가능한 작업 루프에서 이어받는 전제로 생략.

### Completed

- 10분 MVP 기준으로 남아 있던 `GAME_SPEC`, `ROADMAP`, PGS 설정 문서를 현재 5분 러닝타임 기준으로 정리
- `.agent/tasks.md`의 PGS App ID/리더보드 ID 대기 항목을 실제 완료 상태로 갱신
- 스토리 자막 위치를 v0.23 HUD 아래로 이동하고 자막 폰트를 확대
- 메인 메뉴 우상단 Language/Credits 버튼을 최상단에서 내려 안전 여백 확보
- 레벨업 카드 폰트 확대: 제목/이름/레벨/수치/설명/태그/선택 버튼 전반
- Normal 피해 배율 1.0→0.9, Forest of Echoes 중후반 웨이브 간격 완화

### Not Yet Done

- Godot headless / export 검증 (현재 환경에서는 빌드하지 않기로 함)
- 폰 실기 확인: 스토리 자막 HUD 비겹침, 레벨업 카드 가독성, Normal 첫 스테이지 체감

## 2026-05-14 — v0.23.0 폰트 대확대

### Status

v0.22의 +4 폭이 모바일에서 여전히 "답답하다"는 피드백. 메인 메뉴와 HUD의 모든 폰트를 ~1.7배 수준으로 재조정. 컨테이너 높이도 함께 키워 잘림 방지.

### Completed

- 메인 메뉴 폰트 일괄: 타이틀 58→76, PLAY 48→76, 1차/2차 버튼 22→36, 부제 24→36, 골드 30→46, 상태 20→30, 코너 17→24
- 메인 메뉴 컨테이너 높이: Title 110→184, StatusCard 96→140, BtnPlay 136→196, PrimaryRow 88→128, SecondaryRow 80→120
- HUD 폰트 일괄: 시간 34→56, 스탯 20→34, HP 라벨 18→28
- HUD 아이콘 26→40, HP 바 두께 28→42, top bar 140→210
- HP 라벨 외곽선 4→5, 알파 0.75→0.85

### Not Yet Done

- 실기 검증 — 이번 v0.23.0이 충분히 보이는지 폰에서 확인
- 레벨업 카드는 v0.22에서 충분히 크다고 판단, 손대지 않음 (피드백 들어오면 재조정)

## 2026-05-14 — v0.22.0 폰트/HUD/스토리 메뉴

### Status

v0.21.0 폰 빌드 후 사용자 피드백 4건 일괄 대응. 외부 리뷰의 "UI overhaul"이 사실 폰트 사이즈 얘기였음이 확인됨.

### Completed

- 폰트 전반 +4: 메인 메뉴 PLAY 44→48, 1차/2차 18→22, 코너 13→17, HUD 시간 30→34, 스탯 16→20, 레벨업 타이틀 32→36, 무기명 24→28, desc 15→19 등
- HUD: top bar 112→140px, Lv/Kills/Gold 아이콘 셀 (pickup_xp/icon_moon_dagger/pickup_gold, 26×26 tint), 하단 2px 슬레이트 경계선, HP 라벨 외곽선
- 레벨업 카드: 최소 높이 320→380, 아이콘 70→96, 무기 컬러 self_modulate로 XP 픽업과 시각 구분
- StoryUI 신규: 스테이지별 intro/boss_intro/clear 대사 표시, 미해금은 🔒 + 안내, 우상단 용어집 → 버튼
- 메인 메뉴 btn_codex 라우트 → StoryUI, 라벨 키 btn_story로 변경
- Localization 9개 키 추가 (스토리 화면 + 백버튼)

### Not Yet Done

- 실기 검증 (v0.22.0 AAB 폰 설치 후)
- 무기 스프라이트 셋 자체 교체 (현재는 색만 다른 같은 물약 — 컬러 tint로 우회)

## 2026-05-14 — v0.21.0 모바일 레이아웃 수정

### Status

v0.20.0 빌드를 폰에서 돌려본 뒤 사용자가 발견한 결함 3개 수정. 키 큰 폰에서 콘텐츠가 화면 일부에만 몰리고 나머지가 검은 공간으로 남던 컨테이너 레이아웃 결함.

### Completed

- 메인 메뉴 — 기존 6px Spacer를 size_flags_vertical=3 + stretch_ratio=2.0로 변경, SecondaryRow 뒤에 stretch_ratio=1.0 BottomSpacer 추가. 액션 블록이 화면 2:1 비율로 중앙 아래에 자리잡음
- 레벨업 카드 — size_flags_vertical=3 제거, custom_minimum_size 296→320, VBox alignment=1 (CENTER). 카드 안쪽 빈 공간 사라지고 세 카드가 중앙에 클러스터링
- 인게임 HUD — XP 바 위치 96→94, 높이 12→16, 파란 fill + 어두운 배경 스타일박스 추가 (`_init_xp_bar_style`). HP/XP가 한 정보 단위로 묶여 보임
- `godot --headless` 세 씬 로드 에러 없음

### Not Yet Done

- 실기 검증 (v0.21.0 AAB 폰 설치 후 확인)
- AdMob SDK 통합 (ID 수급 후)

## 2026-05-14 — v0.20.0 UI 폴리시 (외부 리뷰 반영)

### Status

비공개 테스트 첫 외부 리뷰("UI 좀 손봤으면")에 대응한 짧은 폴리시 라운드. 게임플레이는 건드리지 않고, 사용자가 가장 자주 보는 메인 메뉴 / 인게임 HUD / 레벨업 카드 세 화면의 디테일만 다듬었다.

### Completed

- 메인 메뉴 — 푸터 행(Language/Credits) 제거, 상단 우측 코너의 작은 행으로 이동 (`MainMenu.tscn`, `MainMenu.gd`). Language 라벨도 "Language: English" → "English"로 단축
- 인게임 HUD — HP 바 채움 색을 잔여 비율에 따라 동적 변경 (초록 / 호박 / 빨강+펄스), ProgressBar fill·background 스타일박스 직접 오버라이드 (`HUD.gd`)
- 레벨업 카드 — 카드 탭 시 scale 0.96 → 1.0 트윈으로 시각 피드백 추가, 터치/마우스 양쪽 (`LevelUpUI.gd`)
- `godot --headless` MainMenu / HUD / LevelUpUI 씬 로드 에러 없음

### Not Yet Done

- 실기 체감 검증 (폰 빌드 / GitHub Actions 산출물)
- AdMob SDK 통합 (v0.19.0 인프라만 들어감, ID 수급 후)
- 추후 외부 리뷰가 더 구체적으로 들어오면 카드 배경 그라데이션 / 메뉴 분위기 배경 등 2차 패스 후보

## 2026-05-14 — Phase 1 제품감 정리

### Status

상용화 분석 보고서의 Phase 1: 제품감 정리 작업을 메뉴/HUD/레벨업/결과 4개 영역 모두에 적용했다. 기능을 늘리지 않고 기존 화면들의 정보 위계와 가독성을 다듬는 1차 리워크.

### Completed

- 메인 메뉴 정보 구조 재배치 — PLAY 단일 강조, 1차 행(캐릭터/스테이지/난이도) · 2차 행(상점/용어집/순위표) · 푸터(언어/크레딧)
- 메인 메뉴 — 골드 카드에 다음 강화까지 남은 골드 또는 "★ 강화 가능" 힌트 표시
- 인게임 HUD — 상단 영역 168→112px, 생존 시간 상단 중앙 강조, HP/XP/스탯 폰트 가독성 정리
- 레벨업 카드 — 신규/강화/진화 태그, 현재→다음 레벨, 무기별 실제 DMG/CD 변화 수치, 역할 칩 표시
- 결과 화면 — 승리/패배 배경 톤, 타이틀 팝 애니메이션, 획득 골드 카운트업, 다음 강화 힌트, 신규 업적 강조
- Localization 신규 키 약 25개 추가 (KO/EN)
- `godot --headless --quit` + editor import 통과 확인

### Not Yet Done

- Phase 2 전투 체감 (무기별 실제 레벨업 설명, Fire Wisp 타깃팅, Star Needle 방향성, 텔레그래프 강화)
- 스테이지별 배경 톤 정리
- 저장 데이터 `schema_version` 도입 마이그레이션 계획
- 무기/패시브/캐릭터/적 데이터 파일 분리

## 2026-05-14 — 상용화 개선 분석 보고서

### Status

현재 구현, 문서, 스토어 자산, 최신 플랫폼/시장 참고 자료를 기준으로 상용화 전 개선 방향을 정리했다.

### Completed

- `docs/COMMERCIALIZATION_ANALYSIS.md` 추가
- 디자인, 게임 디자인, 기술 구조, 저장 데이터, 플랫폼 기능, QA, 출시 패키징 관점의 개선 우선순위 정리
- 실제 구현 상태에 맞춰 `.agent/tasks.md`의 전투 루프 완료 항목 일부 갱신
- 다음 우선순위를 Product Polish로 정리

### Not Yet Done

- 보고서 기반 실제 UI/아트 리워크
- 저장 데이터 `schema_version` 도입 마이그레이션 계획
- 무기/패시브/캐릭터/적 데이터 파일 분리

## 2026-05-13 — 런타임 스토리 연결

### Status

Nightseed 스토리 런타임 UI 1차 연결 완료. 스테이지 인트로 / 보스 경고 / 보스 인트로 / 클리어 자막이 게임 화면 위로 비차단으로 흘러간다.

### Completed

- `data/story_dialogues.json` 추가 (스피커, 스테이지별 인트로/보스 인트로/클리어, 반복 힌트)
- `Story.gd` autoload 추가 (대사/용어를 현재 언어 기준으로 제공)
- `StoryBanner` UI 추가 — 비차단 자막 큐 (페이드 인/홀드/페이드 아웃, 일시정지 중에도 동작)
- `GameRoot`에 스테이지 시작·보스 등장·승리 시 자막 연결
- 승리 화면 부제 "기억의 조각을 되찾았습니다." 추가
- `CodexUI` 용어집 화면 추가 — 메인 메뉴에 진입 버튼 추가
- Localization 키 추가: `boss_warning`, `result_fragment_recovered`, `codex_*`

### Not Yet Done

- 같은 스테이지를 두 번째 이상 플레이할 때 인트로를 반복 힌트로 대체하는 분기
- 보스 등장과 동시에 발생하는 사운드/배너 큐의 시퀀싱 다듬기
- 용어 잠금/해금 (스테이지 클리어 시 추가 용어 등장) 로직

## 2026-05-13

### Status

Nightseed 스토리 기반 문서화 및 스테이지 문구 반영 완료.

### Completed

- `docs/story/` 정식 스토리 문서 폴더 추가
- Nightseed 용어 정의, 단계별 대사 공개 기준, UI 카피 기준 정리
- 원본 스토리 설계서 패키지를 `docs/story/source/nightseed-lore-story-update/`로 이동
- 향후 용어집/도감 UI 기반 데이터 `godot/data/story_terms.json` 추가
- 스테이지 선택 설명 문구를 Nightseed 세계관 기준으로 갱신

### Not Yet Done

- 플레이 중 대사/스토리 이벤트 UI 구현
- 용어집 또는 도감 UI 구현
- 보스 경고/클리어 보조 문구의 런타임 연결

## 2026-05-13

### Status

GitHub Pages 배포 구조 개편 완료.

### Completed

- 브랜딩 페이지용 HTML/CSS 작성 (`branding/index.html`)
- GitHub Actions 워크플로우(`android-build.yml`) 수정
- 루트(`/`) 배포 디렉토리에 브랜딩 페이지 및 자산 배치 로직 추가
- 게임 실행 경로를 `/live/` 폴더로 이동하여 웹 플레이 환경 분리
- `play_store` 자산을 브랜딩 페이지에서 사용하도록 복사 자동화

## 2026-05-07

### Status

Milestone 1 Playable Prototype 구현 완료.

### Completed

- Godot 4 프로젝트 구조(`godot/`) 초기화
- `project.godot` 생성 및 입력 액션(WASD/화살표) 설정
- 메인 게임 씬(`GameRoot.tscn`) 생성
- 플레이어 이동/체력/피격 무적 처리 구현
- 플레이어 추적 적(`EnemyBase`) 및 접촉 데미지 구현
- 플레이어 주변 스폰 방식의 `EnemySpawner` 구현
- 카메라 추적 구성
- HUD(HP/생존 시간) 구현
- HP 0 시 게임오버 및 재시작 버튼 구현

### Not Yet Done

- 무기 자동 공격 루프(Milestone 2)
- 적 HP/사망 및 처치 카운트
- 경험치/레벨업 시스템
- 영구 강화/저장 시스템
- Android export 검증
- GitHub Actions 워크플로우 구축 및 검증
