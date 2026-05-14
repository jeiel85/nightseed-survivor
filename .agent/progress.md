# Progress

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
