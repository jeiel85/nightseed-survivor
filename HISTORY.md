# HISTORY.md

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
