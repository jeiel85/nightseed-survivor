# HISTORY.md

## 2026-05-17 (README / GitHub Pages 소개 이미지 적용)

- 날짜: 2026-05-17
- 작업: 사용자가 다운로드 폴더에 준비한 도트 일러스트 2장을 README 상단 배너와 GitHub Pages 소개 페이지 히어로/공유 이미지로 적용.
- 변경 파일:
  - README.md
  - docs/images/readme.png
  - branding/index.html
  - branding/assets/pages.png
  - .github/workflows/android-build.yml
  - .agent/tasks.md
  - .agent/progress.md
  - CHANGELOG.md
- 검증:
  - 이미지 원본 크기 1672×941 확인
  - 정적 경로 및 GitHub Actions 배포 복사 경로 확인
  - `godot --headless --path godot --quit` 실행 시도 — 로컬 PATH에서 `godot` 실행 파일을 찾을 수 없어 미실행
- 결과:
  - README는 `docs/images/readme.png`를 상단에서 표시
  - GitHub Pages 소개 페이지는 `assets/pages.png`를 히어로 배경과 공유 카드 이미지로 사용
- 후속 작업:
  - push 후 GitHub Actions Pages 배포 결과 확인

## 2026-05-16 (v0.26.0 릴리즈 — LevelUp 픽셀아트 + Galmuri 폰트 + 다국어 layout)

- 날짜: 2026-05-16
- 작업: LevelUp 카드에 picture 자산 (panel_card_dark + rarity 글로우 4색) 통합, Pretendard → Galmuri 11 픽셀 폰트 일괄 교체, 메인 메뉴 다국어(영문/한국어) 모두 안전 fit 보정. PGS native 미해결 + Pyromancer 공격 버그 의심은 known issue로 명시.
- 변경 파일:
  - godot/export_presets.cfg (versionCode 27→28, versionName 0.25.1→0.26.0)
  - godot/scripts/ui/LevelUpUI.gd (panel + glow overlay 적용, SELECT outline)
  - godot/scenes/ui/LevelUpUI.tscn (폰트 사이즈 + 카드 높이 + 아이콘 사이즈)
  - godot/scripts/ui/MainMenu.gd, godot/scenes/ui/MainMenu.tscn (VBox 가운데 정렬, size_flags 명시)
  - godot/scripts/core/Localization.gd (영문 menu_next_goal 단축)
  - godot/project.godot (gui/theme/custom_font = Galmuri11, stretch_aspect=expand, clear_color navy)
  - godot/assets/fonts/Galmuri11.ttf (신규 5.1MB, OFL)
  - godot/assets/sprites/ui/panel/frame_card_glow_{blue,green,purple,gold}.9.png (채도 기반 알파 처리)
  - CHANGELOG.md, docs/releases/v0.26.0.md, play_store/release_notes/v0.26.0.txt
- 검증:
  - 폰 실기 검증 — 메인 메뉴 (한국어 + 영문 둘 다 fit), LevelUp 카드 (panel + glow + SELECT outline)
  - AAB 매니페스트 versionName "0.26.0" 확인
  - 로컬 AAB 빌드 + R8 서명 통과
- Known Issues:
  - PGS 리더보드 / AdMob 광고 native (.aar) 빌드 누락 — Godot 4.2 헤드리스 export quirk. GUI 에디터 빌드 필요. v0.26.1+ 예정
  - **Pyromancer 캐릭터 공격 미작동 의심** — 사용자 보고. FireWisp 코드 review로는 명확한 원인 못 찾음. v0.26.1에서 logcat 진단 + fix 예정
- 산출물:
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.26.0.aab
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.26.0-release-notes.txt
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.aab
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.mapping.txt

## 2026-05-16 (v0.25.1 릴리즈 — 한국어 게임 제목 정리)

- 날짜: 2026-05-16
- 작업: v0.25.0 픽셀아트 타이틀 로고가 "잔불의 밤"으로 바뀌었지만 안드로이드 앱 이름, 브랜딩 페이지에 옛 "밤의 씨앗: 서바이버" 표기가 남아있던 것을 일괄 정리. 영문은 "Nightseed Survivor" 유지. 게임 로직/자산 변화 없음.
- 변경 파일:
  - godot/project.godot (`config/name` + `config/name_localized` 추가)
  - godot/export_presets.cfg (versionCode 26→27, versionName 0.25.0→0.25.1)
  - branding/index.html (한국어 제목 10곳 + "7분"→"5분" 4곳)
  - CHANGELOG.md, docs/releases/v0.25.1.md, play_store/release_notes/v0.25.1.txt
- 검증:
  - AAB 매니페스트 versionName "0.25.1" 확인
  - 로컬 AAB 빌드 + R8 서명 통과
- Known Issue (계속):
  - ★ RANK / AdMob native (.aar) 빌드 누락 (Godot 4.2 헤드리스 export quirk). GUI 에디터 빌드 필요. v0.25.2 또는 v0.26.0에서 fix 예정
- 산출물:
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.25.1.aab
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.25.1-release-notes.txt
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.aab
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.mapping.txt

## 2026-05-16 (v0.25.0 릴리즈 준비 — 메인 메뉴 픽셀아트 리워크)

- 날짜: 2026-05-16
- 작업: ChatGPT(GPT-4o) 픽셀아트 자산 31장 + 5명 영웅 일러 배경 + 한국어/영어 픽셀아트 타이틀 로고로 메인 메뉴 시각 전면 리워크. 메뉴 버튼 3줄×2 재배치. 자산 후처리 자동화 파이프라인(흰 가장자리 crop / alpha padding / flood-fill / outline) 정착.
- 변경 파일:
  - godot/export_presets.cfg (versionCode 25→26, versionName 0.24.0→0.25.0)
  - godot/scenes/ui/MainMenu.tscn (TitleLabel→TitleImage, 3줄×2 행, TopRightRow 좌하단)
  - godot/scripts/ui/MainMenu.gd (BG hero-lineup 우선, title texture KO/EN 자동 스왑, icon alignment center)
  - godot/scripts/ui/ButtonStyles.gd (9-slice 마진 96/140/36 → 16/24/12 px 수정)
  - godot/scripts/core/Localization.gd (HEROES, ★ RANK, DIFF=난이도 이름만)
  - godot/assets/sprites/ui/ (P0/P1/P2 자산 31장 후처리)
  - godot/assets/sprites/ui/bg/bg_menu_hero_lineup.png (BG-04, 신규, 130 px 위로 shift)
  - godot/assets/logo/title_ko.png, title_en.png (LG-02/03, 신규)
  - CHANGELOG.md, docs/releases/v0.25.0.md, play_store/release_notes/v0.25.0.txt
  - docs/ASSETS_TO_GENERATE.md §1.1 (BG-04 캐릭터 영역 가운데 띠 구도 규칙)
- 검증:
  - 자산 31장 .import 자동 생성 + 헤드리스 부트 OK
  - 로컬 APK + AAB 빌드 + R8 서명 통과
  - 폰 실기 검증 — 메인 메뉴 시각 전체 OK (KO/EN 둘 다)
- Known Issue:
  - ★ RANK 버튼 클릭 시 PGS 리더보드 안 열림. APK/AAB에 PGS native (.aar) 누락. Godot 4.2 헤드리스 export가 EditorPlugin(AndroidExportPlugin)을 활성화하지 못하는 quirk. v0.24.0도 같은 상태였을 것 (당시 폰 미검증). v0.25.1 또는 v0.26.0에서 GUI 에디터 빌드로 fix 예정
- 산출물:
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.25.0.aab
  - C:\Users\jeiel\OneDrive\바탕 화면\nightseed-survivor-v0.25.0-release-notes.txt
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.aab
  - D:\Project\nightseed-survivor\build\nightseed-survivor-release.mapping.txt

## 2026-05-15 (P1/P2 UI 자산 생성 자동화)

- 날짜: 2026-05-15
- 작업: `docs/ASSETS_TO_GENERATE.md` 기준으로 기존 P0 자산을 보호하고, 없는 P1/P2 자산만 OpenAI Images API로 생성하는 자동화 스크립트 추가.
- 변경 파일:
  - scripts/generate_missing_ui_assets.py (신규)
  - docs/ASSETS_TO_GENERATE.md
  - CHANGELOG.md, HISTORY.md, .agent/progress.md, .agent/tasks.md
- 검증:
  - `python scripts\generate_missing_ui_assets.py --dry-run` 통과 — 누락 P1/P2 20개 확인, P0 및 기존 BG-02/BG-03 제외 확인
  - 실제 API 호출 시 `billing_hard_limit_reached`로 OpenAI 요청 중단. 자산 PNG는 생성되지 않음
- 결과:
  - 결제 한도 해제 후 같은 스크립트로 누락 자산 생성 재시도 가능
- 후속 작업:
  - OpenAI billing hard limit 해제 후 `python scripts\generate_missing_ui_assets.py` 재실행
  - 생성 완료 후 Godot import 및 headless 검증

## 2026-05-15 (v0.24.0 릴리즈 준비 — UI 리워크 1차 + AdMob SDK)

- 날짜: 2026-05-15
- 작업: v0.23.0 이후 누적된 UI 비주얼 리워크 1차 + AdMob 보상형 SDK 통합 + 문서·밸런스 정리를 v0.24.0으로 묶음. export_presets.cfg versionCode 24→25, versionName 0.23.0→0.24.0. minSdkVersion 21→24 (AdMob aar 요구로 인한 강제 상승, Android 5.x~6.x 단말 제외).
- 변경 파일:
  - godot/export_presets.cfg (versionCode/Name + min_sdk 24)
  - CHANGELOG.md (Unreleased × 4 → v0.24.0 통합)
  - docs/releases/v0.24.0.md (신규, GitHub Release 본문)
  - play_store/release_notes/v0.24.0.txt (신규, 다국어 KO/EN, 500자 이하)
  - HISTORY.md, .agent/progress.md, .agent/tasks.md
  - build/nightseed-survivor-release.aab (산출물)
  - build/nightseed-survivor-release.mapping.txt (R8 deobfuscation)
- 검증:
  - 로컬 AAB 빌드 + 키스토어 서명 (nightseed alias) 통과
  - mapping.txt 생성 확인
  - 폰 실기 검증은 사용자 직접 (이번 릴리즈가 비주얼 확인용)
- 결과:
  - 폰 설치 가능한 AAB + 다국어 노트가 바탕화면에 준비됨
  - 태그 푸시는 사용자 폰 검증 후 결정하도록 보류
- 후속 작업:
  - 사용자 폰에서 UI 확인 → OK면 태그 푸시(`git tag -a v0.24.0 && git push origin v0.24.0`) → CI 자동 GitHub Release
  - 추가 애셋 필요 여부 결정
  - Phase UI-3 이후 진행

## 2026-05-15 (메인 메뉴 Nightseed 비주얼 리워크 1차)

- 날짜: 2026-05-15
- 작업: docs/UI_ART_DIRECTION_ROADMAP.md §4.1·§5 기준으로 Phase UI-1 공통 버튼 키트 + Phase UI-2 메인 메뉴 1차 리워크를 함께 진행. 신규 이미지 애셋 없이 ButtonStyles 확장 + 절차 배경 + 기존 캐릭터 스프라이트 기반 쇼케이스로 구현.
- 변경 파일:
  - godot/scripts/ui/ButtonStyles.gd (Moon/Stone 스타일 추가)
  - godot/scripts/ui/MenuBackdrop.gd (신규)
  - godot/scripts/ui/CharacterShowcase.gd (신규)
  - godot/scenes/ui/MainMenu.tscn (MenuBackdrop / CharacterShowcase 노드 추가, 새 스타일 연결)
  - godot/scripts/ui/MainMenu.gd (타이틀 외곽선, 새 버튼 스타일, 쇼케이스 갱신)
  - CHANGELOG.md, .agent/tasks.md, .agent/progress.md, HISTORY.md
- 검증:
  - `godot --headless --path godot --quit` 통과 (GDScript 파싱 에러 0)
  - 2-pass 에디터 임포트로 `CharacterShowcase`/`MenuBackdrop` 글로벌 클래스 캐시 등록 확인
  - `godot --headless --path godot --quit-after 30` 부트 + MainMenu 30프레임 실행 — 스크립트 에러 0
  - 720x1280 / 540x960 디자인 좌표에서 CharacterShowcase 사각형(360×180, y=480~660)이 StatusCard(y≤480)·BtnPlay(y≥672)와 겹치지 않음을 좌표 정적 확인
- 결과:
  - 메인 메뉴가 단색 ColorRect + 사각 버튼 모음에서 "달빛 밤숲 앞에 선 캐릭터 + Moon CTA + Stone 보조 메뉴" 구성으로 전환
  - 새 일러스트/리소스 추가 없음 — 모두 절차 묘사 + 기존 16×16 스프라이트
- 후속 작업:
  - 폰 실기 빌드(AAB)에서 가독성/겹침 최종 확인
  - 1차 리워크 후 실제 필요한 애셋(메뉴 배경 일러스트, 캐릭터 큰 portrait, 9-slice, 출정/상점/도감/설정/업적 아이콘) 목록을 다음 세션에서 산출
  - Phase UI-3 캐릭터 쇼케이스 고도화 (큰 portrait 도입), Phase UI-4 레벨업 카드 리워크

## 2026-05-15 (다음 UI 리워크 착수 판단)

- 날짜: 2026-05-15
- 작업: 다음 세션에서 메인 메뉴 Nightseed 비주얼 리워크를 바로 시작할 수 있도록 착수 순서와 애셋 판단 기록
- 변경 파일:
  - docs/UI_ART_DIRECTION_ROADMAP.md
  - .agent/tasks.md
  - .agent/progress.md
  - CHANGELOG.md
- 검증:
  - 문서 변경만 수행하여 Godot 실행/빌드 검증은 생략
- 결과:
  - 이미지 애셋 선제작이 아니라 공통 UI 키트와 메인 메뉴 구조 개선부터 진행하도록 기록 완료
- 후속 작업:
  - `ButtonStyles.gd` Moon/Stone 스타일 추가 후 메인 메뉴 Nightseed 비주얼 리워크 1차 진행

## 2026-05-15 (AdMob 보상형 광고 SDK 통합 — 테스트 광고 ID로)

- 날짜: 2026-05-15
- 작업: 사용자 AdMob ID 수급 전 단계에서 가능한 모든 통합 작업 진행. SDK + 플러그인 배치, AdManager 새 API로 재작성, 에디터 임포트 검증까지 완료. 실제 ID 교체는 사용자가 Play Console에서 공개 트랙으로 전환 후 AdMob 콘솔에 앱 등록할 때.
- 변경 파일:
  - godot/addons/admob/ (신규, 전체)
  - godot/scripts/core/AdManager.gd
  - godot/project.godot (editor_plugins)
  - godot/android/build/proguard-rules.pro
  - docs/ADMOB_SETUP.md
  - CHANGELOG.md, .agent/tasks.md, .agent/progress.md
- 검증:
  - Godot 4.2.2 헤드리스 에디터 임포트 통과 (GDScript 파싱 에러 0)
  - 글로벌 클래스 캐시 2-pass 후 `MobileAds`, `RewardedAdLoader`, `RewardedAd`, `AdRequest`, `OnInitializationCompleteListener`, `OnUserEarnedRewardListener`, `RewardedAdLoadCallback`, `FullScreenContentCallback`, `LoadAdError`, `AdError`, `RewardedItem` 인식
- 후속 작업:
  - 비공개 테스트 트랙용 AAB 빌드 + 폰 검증 — 부활/골드 2배 CTA 표시, 광고 재생, 보상 적용 확인
  - 사용자 AdMob 콘솔 등록 (공개 트랙 출시 후) → 실제 App ID와 광고 단위 ID 수급 → `config.gd`, `AdManager.gd` 두 상수 교체

## 2026-05-15 (UI 아트 디렉션 로드맵 작성)

- 날짜: 2026-05-15
- 작업: 현재 UI의 제품감/아트 방향 부족 문제를 해결하기 위한 단계별 작업 계획서 작성
- 변경 파일:
  - docs/UI_ART_DIRECTION_ROADMAP.md
  - docs/ROADMAP.md
  - .agent/tasks.md
  - .agent/progress.md
  - CHANGELOG.md
- 검증:
  - 문서 변경만 수행하여 Godot 실행/빌드 검증은 생략
- 결과:
  - Nightseed UI 디자인 철학과 메인 메뉴/레벨업/결과 화면 리워크 단계를 다음 세션에서 바로 작업 가능한 수준으로 정리
- 후속 작업:
  - `feat(ui): 메인 메뉴 Nightseed 비주얼 리워크 1차` 착수

## 2026-05-15 (기준 문서 정리 + UI/Normal 완화)

- 날짜: 2026-05-15
- 작업: 현재 실제 구현 상태에 맞춰 5분 러닝타임 기준을 문서에 반영하고, 모바일 UI 피드백 3건 및 Normal 첫 스테이지 난이도 완화 반영
- 변경 파일:
  - AGENTS.md, README.md
  - docs/GAME_SPEC.md, docs/BALANCE.md, docs/ROADMAP.md, docs/COMMERCIALIZATION_ANALYSIS.md, docs/PLAY_GAMES_SERVICES_SETUP.md
  - .agent/tasks.md, .agent/progress.md
  - godot/scenes/ui/StoryBanner.tscn, godot/scenes/ui/MainMenu.tscn, godot/scenes/ui/LevelUpUI.tscn
  - godot/scripts/core/Difficulty.gd
  - godot/data/stages.json
  - CHANGELOG.md
- 검증:
  - 빌드 환경이 아니므로 Godot 실행/빌드는 생략
  - `stages.json`, `story_dialogues.json`, `story_terms.json` 문법 확인
  - 주요 문자열 및 변경 diff 정적 리뷰
- 결과:
  - 10분 기준으로 남아 있던 현재 문서를 5분/5분 30초 기준으로 정리
  - 스토리 자막이 HUD 아래로 내려가고, 우상단 메뉴 버튼 여백 및 레벨업 카드 폰트 가독성 개선
  - Normal 피해량과 Forest 웨이브 밀도를 낮춰 첫 스테이지 체감을 조금 느슨하게 조정
- 후속 작업:
  - 다음 빌드 가능 환경에서 Godot headless, Android 산출물, 실기 UI/난이도 확인

## 2026-05-14 (v0.23.0: 폰트 대확대 — 모바일 가독성 최종 보정)

- 날짜: 2026-05-14
- 작업: v0.22의 +4 폭이 여전히 "답답하다"는 피드백. 메인 메뉴 / HUD 폰트 ~1.7배로 재조정
- 변경 파일:
  - godot/scenes/ui/MainMenu.tscn (모든 폰트 + 컨테이너 높이 일괄)
  - godot/scenes/main/HUD.tscn (모든 폰트 + 아이콘 + 바 두께 + top bar 높이)
  - godot/scripts/ui/HUD.gd (TOP_BAR_BASE_HEIGHT 140 → 210)
  - godot/export_presets.cfg (0.22.0 → 0.23.0, code 23 → 24)
  - CHANGELOG.md, docs/releases/v0.23.0.md, play_store/release_notes/v0.23.0.txt
- 검증:
  - `godot --headless` MainMenu / HUD 씬 로드 에러 없음
- 결과:
  - PLAY 48→76, 시간 34→56, 스탯 20→34, HP 18→28 등 대확대
  - 컨테이너 높이도 같이 키워서 폰트 잘림 없음
  - 레벨업 카드는 v0.22에서 충분히 크다고 판단, 손대지 않음
- 후속 작업:
  - 폰 실기 검증 (이번엔 폰트 충분히 보이는지)

## 2026-05-14 (v0.22.0: 폰트 가독성 + HUD 아이콘 + 스토리 메뉴)

- 날짜: 2026-05-14
- 작업: v0.21.0 폰 빌드 후 사용자 피드백 4건 일괄 대응 — 폰트 너무 작음, HUD 밋밋함, Spirit Orb 아이콘이 XP 픽업과 동일, 스토리 다시 읽기 메뉴 부재
- 변경 파일:
  - godot/scenes/ui/MainMenu.tscn (폰트 +4 일괄)
  - godot/scenes/main/HUD.tscn (top bar 112→140, 폰트 +4, Lv/Kills/Gold 아이콘 셀 추가, 하단 슬레이트 경계선, HP 라벨 외곽선)
  - godot/scripts/ui/HUD.gd (TOP_BAR_BASE_HEIGHT 112→140, 라벨 노드 경로 갱신)
  - godot/scenes/ui/LevelUpUI.tscn (카드 high 320→380, 아이콘 70→96, 헤더 32→40, 폰트 +4)
  - godot/scripts/ui/LevelUpUI.gd (아이콘 self_modulate 무기 컬러 tint)
  - godot/scenes/ui/StoryUI.tscn + godot/scripts/ui/StoryUI.gd (신규 — 스토리 다시 읽기 화면)
  - godot/scripts/ui/MainMenu.gd (btn_codex 라우트 → StoryUI, 라벨 키 btn_story)
  - godot/scripts/core/Localization.gd (9개 키 추가)
  - godot/export_presets.cfg (0.21.0 → 0.22.0, code 22 → 23)
  - CHANGELOG.md, docs/releases/v0.22.0.md, play_store/release_notes/v0.22.0.txt
- 검증:
  - `godot --headless` MainMenu / HUD / LevelUpUI / StoryUI 네 씬 로드 에러 없음
- 결과:
  - 모바일에서 글씨 가독성 회복
  - HUD가 텍스트 일색에서 아이콘+경계선 있는 정보 패널로
  - 레벨업 카드 아이콘이 픽업과 시각 구분 (컬러 tint + 큰 사이즈 + 카드 보더)
  - 새 스토리 메뉴로 잠금/해금 별 대사 다시 보기 가능
- 후속 작업:
  - 폰 실기 검증 (v0.22.0 AAB Play Console 업로드 후)
  - 추후 무기 스프라이트 셋 자체 교체 (Kenney 외 후보 탐색 필요)

## 2026-05-14 (v0.21.0: 모바일 레이아웃 수정 — 빈 공간 메우기)

- 날짜: 2026-05-14
- 작업: v0.20.0 빌드를 폰에서 돌려본 뒤 발견한 모바일 레이아웃 결함 3개 수정. 게임플레이는 손대지 않음
- 변경 파일:
  - godot/scenes/ui/MainMenu.tscn (Spacer EXPAND + BottomSpacer 추가)
  - godot/scenes/ui/LevelUpUI.tscn (카드 size_flags_vertical=3 제거, custom_minimum_size 296→320, VBox alignment=1)
  - godot/scenes/main/HUD.tscn (XP 바 위치 96→94, 높이 12→16)
  - godot/scripts/ui/HUD.gd (`_init_xp_bar_style` 추가 — XP 바 파란 fill + 어두운 배경)
  - godot/export_presets.cfg (version 0.20.0 → 0.21.0, versionCode 21 → 22)
  - CHANGELOG.md, docs/releases/v0.21.0.md, play_store/release_notes/v0.21.0.txt
- 검증:
  - `godot --headless` MainMenu / LevelUpUI / HUD 씬 로드 에러 없음
  - 실기 체감 검증: 사용자 폰에서 v0.21.0 빌드로 재확인 예정
- 결과:
  - 메인 메뉴: 액션 블록이 화면 중앙 아래(엄지 위치)로 이동, 하단 빈 공간 사라짐
  - 레벨업 카드: 자연 높이로 클러스터링, 카드 안쪽 빈 공간 사라짐
  - HUD: HP/XP 두 바가 한 정보 단위로 보임
- 후속 작업:
  - v0.21.0 AAB Play Console 업로드 + PGS 실기 검증

## 2026-05-14 (v0.20.0: UI 폴리시 — 외부 리뷰 반영)

- 날짜: 2026-05-14
- 작업: 비공개 테스트 첫 외부 리뷰("UI 좀 손봤으면")에 대응한 짧은 UI 디테일 폴리시
- 변경 파일:
  - godot/scenes/ui/MainMenu.tscn, godot/scripts/ui/MainMenu.gd (Language/Credits를 상단 우측 코너로 이동, 푸터 행 제거)
  - godot/scripts/ui/HUD.gd (HP 바 채움 색 동적 변경 + 30% 이하 알파 펄스)
  - godot/scripts/ui/LevelUpUI.gd (카드 탭 시 scale 0.96 → 1.0 시각 피드백)
  - godot/export_presets.cfg (version 0.19.0 → 0.20.0, versionCode 20 → 21)
  - CHANGELOG.md, docs/releases/v0.20.0.md, play_store/release_notes/v0.20.0.txt
- 검증:
  - `godot --headless` MainMenu / HUD / LevelUpUI 씬 로드 에러 없음
  - 실기 체감 검증은 GitHub Actions 산출물 / 폰 빌드로 확인 예정
- 결과:
  - 메인 메뉴 첫 화면 버튼 9개 → 7개(PLAY + 6) + 코너 미니 2개로 시각 밀도 감소
  - HP 위험 상태가 색·펄스로 즉시 알아챌 수 있게 됨
  - 레벨업 카드 탭이 "진짜 눌렸나" 의심되지 않게 됨
- 후속 작업:
  - 폰에서 실기 검증
  - 추가 리뷰가 더 구체적으로 들어오면 2차 패스(카드 배경 그라데이션, 메뉴 분위기 배경)

## 2026-05-14 (Phase 1: 제품감 정리)

- 날짜: 2026-05-14
- 작업: 상용화 분석 Phase 1 — 메인 메뉴/HUD/레벨업 카드/결과 화면 가독성과 정보 위계 개선
- 변경 파일:
  - godot/scenes/ui/MainMenu.tscn, godot/scripts/ui/MainMenu.gd (정보 카드 + 1차/2차 행 분리, 다음 강화 힌트)
  - godot/scenes/main/HUD.tscn, godot/scripts/ui/HUD.gd (상단 영역 168→112px 축소, Time 강조)
  - godot/scenes/ui/LevelUpUI.tscn, godot/scripts/ui/LevelUpUI.gd (태그 + 현재 레벨 + 실제 수치 변화 + 역할 칩)
  - godot/scenes/main/GameRoot.tscn, godot/scripts/core/GameRoot.gd (결과 화면 배경 톤·타이틀 팝·골드 카운트업·다음 강화 힌트)
  - godot/scripts/core/Localization.gd (메뉴/레벨업/결과 화면용 신규 키)
  - CHANGELOG.md, .agent/tasks.md, .agent/progress.md (이력 갱신)
- 검증:
  - `godot --headless --path godot --quit` 통과 (스크립트 파싱 OK)
  - `godot --headless --path godot --editor --quit-after 400` 1회 import 성공
  - 인게임 실기 검증은 GitHub Actions의 export·릴리즈 단계에서 진행
- 결과:
  - 첫 화면(메인 메뉴)에서 1차 행동(시작/캐릭터/스테이지/난이도)이 시각적으로 분리됨
  - HUD 상단 점유 면적 약 33% 축소
  - 레벨업 카드가 "DMG +25%" 같은 일반 문구 대신 무기별 실제 수치 변화와 역할 태그를 표시
  - 결과 화면에 골드 카운트업, 다음 강화까지 남은 골드, 신규 업적 강조 추가
- 후속 작업:
  - Phase 2 전투 체감 (무기별 실제 레벨업 설명, Fire Wisp 타깃팅 등)
  - 스테이지별 배경 톤 정리
  - 저장 데이터 schema_version 도입 여부 결정

## 2026-05-14

- 날짜: 2026-05-14
- 작업: 상용화 개선 분석 보고서 작성
- 변경 파일:
  - docs/COMMERCIALIZATION_ANALYSIS.md (신규)
  - .agent/tasks.md (수정)
  - .agent/progress.md (수정)
  - CHANGELOG.md (수정)
- 검증:
  - 저장소 문서, 실제 Godot 스크립트/씬/데이터, 스토어 스크린샷 확인
  - Google Play Games Level Up, Google Play 광고 정책, PGS 통계, GameRefinery 2026년 4월 시장 리뷰, Survivors-like 장르 개요 확인
  - 문서 변경만 수행하여 Godot headless 실행은 생략
- 결과:
  - 디자인 리워크, 전투 체감, 데이터화, 성능, 저장/플랫폼 QA, 출시 패키징 우선순위를 정리한 보고서 추가 완료
- 후속 작업:
  - 메인 메뉴/HUD/레벨업/결과 화면 Product Polish 착수
  - 저장 데이터 schema_version 도입 여부 결정 및 마이그레이션 계획 작성

## 2026-05-13

- 날짜: 2026-05-13
- 작업: Nightseed 런타임 스토리 연결 (StoryBanner + CodexUI)
- 변경 파일:
  - godot/data/story_dialogues.json (신규)
  - godot/scripts/core/Story.gd (신규 autoload)
  - godot/scripts/ui/StoryBanner.gd (신규)
  - godot/scenes/ui/StoryBanner.tscn (신규)
  - godot/scripts/ui/CodexUI.gd (신규)
  - godot/scenes/ui/CodexUI.tscn (신규)
  - godot/project.godot (Story autoload 등록)
  - godot/scripts/core/WaveManager.gd (`boss_spawned` 시그널 추가)
  - godot/scripts/core/GameRoot.gd (스테이지 인트로/보스 등장/승리 자막 연결)
  - godot/scenes/main/GameRoot.tscn (StoryBanner 노드, Result 부제 라벨 추가)
  - godot/scripts/ui/MainMenu.gd (CODEX 버튼 연결)
  - godot/scenes/ui/MainMenu.tscn (CODEX 버튼 추가)
  - godot/scripts/core/Localization.gd (codex_*, boss_warning, result_fragment_recovered 등 키 추가)
  - .agent/tasks.md, .agent/progress.md, .agent/decisions.md, CHANGELOG.md (수정)
- 검증:
  - `godot/data/story_dialogues.json` JSON 문법 검사 통과
  - 정적 코드 리뷰로 노드 경로/시그널/Localization 키 일치 확인
  - 로컬 환경에서 `godot` 실행 파일이 PATH에 없어 Godot headless 검증은 미실행 — Godot 설치 환경에서 한 판 플레이 검증 필요
- 결과:
  - 게임 시작 시 스테이지 인트로, 보스 등장 시 경고 + 보스 대사, 승리 시 클리어 대사가 비차단 자막으로 흐름
  - 메인 메뉴 → CODEX 진입 가능, KO/EN 토글 동기화
- 후속 작업:
  - 반복 플레이 시 인트로를 반복 힌트로 대체하는 분기
  - 용어 잠금/해금 (스테이지 클리어 시 추가 용어 노출)

## 2026-05-13

- 날짜: 2026-05-13
- 작업: Nightseed 스토리 기반 문서화 및 스테이지 문구 반영
- 변경 파일:
  - docs/story/README.md (신규)
  - docs/story/STORY_FINAL_SPEC.md (신규)
  - docs/story/STORY_NIGHTSEED_LORE.md (신규)
  - docs/story/STORY_STAGE_DIALOGUE.md (신규)
  - docs/story/STORY_UI_COPY.md (신규)
  - docs/story/source/nightseed-lore-story-update/ (원본 설계서 이동)
  - godot/data/story_terms.json (신규)
  - godot/data/stages.json (수정)
  - godot/scripts/core/Localization.gd (수정)
  - docs/GAME_SPEC.md (수정)
  - docs/ARCHITECTURE.md (수정)
  - docs/ROADMAP.md (수정)
  - .agent/tasks.md (수정)
  - .agent/progress.md (수정)
  - .agent/decisions.md (수정)
  - CHANGELOG.md (수정)
- 검증:
  - `godot/data/stages.json`, `godot/data/story_terms.json` JSON 문법 검사 통과
  - `godot --headless --path godot --quit` 실행 시도
  - 로컬 환경에서 `godot` 실행 파일을 찾을 수 없어 Godot headless 검증은 미실행
- 결과:
  - 스토리 기준 문서와 기반 데이터 추가 완료. 런타임 실행 검증은 CI 또는 Godot 설치 환경에서 확인 필요.
- 후속 작업:
  - 런타임 스토리 이벤트 UI 구현

## 2026-05-13

- 날짜: 2026-05-13
- 작업: GitHub Pages 배포 구조 개편 및 브랜딩 페이지 적용
- 변경 파일:
  - branding/index.html (신규)
  - .github/workflows/android-build.yml (수정)
- 검증:
  - 브랜딩 페이지 HTML 생성 확인
  - GitHub Actions 워크플로우 로직 수정 확인 (루트: 브랜딩, /live: 게임)
- 결과:
  - 성공. 이제 `main` 브랜치 푸시 시 새로운 구조로 자동 배포됨.
- 후속 작업:
  - 브랜딩 페이지 디자인 고도화 (필요시)

## 2026-05-07

- 날짜: 2026-05-07
- 작업: Milestone 1 Playable Prototype 구현 (Godot 프로젝트 초기화 및 기본 생존 루프)
- 변경 파일:
  - godot/project.godot
  - godot/scenes/main/GameRoot.tscn
  - godot/scenes/main/HUD.tscn
  - godot/scenes/player/Player.tscn
  - godot/scenes/enemies/EnemyBase.tscn
  - godot/scripts/core/GameRoot.gd
  - godot/scripts/player/Player.gd
  - godot/scripts/enemies/EnemyBase.gd
  - godot/scripts/enemies/EnemySpawner.gd
  - godot/scripts/ui/HUD.gd
  - .agent/tasks.md
  - .agent/progress.md
  - .agent/decisions.md
  - CHANGELOG.md
  - HISTORY.md
- 검증:
  - `godot --headless --path godot --quit` 실행 시도
  - CI는 로컬 푸시 후 GitHub Actions 확인 예정
- 결과:
  - 플레이어 이동, 적 스폰/추적, 접촉 데미지, HP/HUD, 게임오버 루프 구현 완료
- 후속 작업:
  - Milestone 2(자동 무기/전투 루프) 구현

## 2026-05-06

- 작업: Nightseed Survivor 최종 설계 묶음 작성
- 변경 파일:
  - README.md
  - AGENTS.md
  - CHANGELOG.md
  - HISTORY.md
  - docs/GAME_SPEC.md
  - docs/IMPROVEMENT_STRATEGY.md
  - docs/ASSET_GUIDE.md
  - docs/ARCHITECTURE.md
  - docs/ROADMAP.md
  - docs/BALANCE.md
  - docs/RELEASE_CHECKLIST.md
  - .agent/tasks.md
  - .agent/progress.md
  - .agent/decisions.md
  - prompts/FIRST_AGENT_PROMPT.md
- 검증:
  - 문서 구조 생성 확인
  - 실제 Godot 프로젝트 생성 및 실행 검증은 아직 수행하지 않음
- 결과:
  - 성공
- 후속 작업:
  - GitHub 저장소 생성
  - 문서 묶음 업로드
  - Godot 프로젝트 초기화
  - Milestone 1: Playable Prototype 구현 시작
