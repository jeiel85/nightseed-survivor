# Tasks

> 이 파일은 [docs/COMMERCIALIZATION_ANALYSIS.md](../docs/COMMERCIALIZATION_ANALYSIS.md)의
> Phase 1~4 로드맵을 작업 단위로 풀어 놓은 운영 목록입니다. 코드 상태를
> 기준으로 한 마지막 동기화는 v0.23.0 작업 시작 시점입니다.

## 2026-05-17 완료 (README / GitHub Pages 소개 이미지 적용)

- [x] `Downloads/readme.png`를 README 상단 배너 이미지로 추가
- [x] `Downloads/pages.png`를 GitHub Pages 소개 페이지 히어로/공유 이미지로 추가
- [x] GitHub Actions Pages 배포 자산 복사 목록에 `pages.png` 추가

## v0.26.0 완료 (LevelUp 픽셀아트 + Galmuri 폰트 + 다국어 layout)

### LevelUp Phase UI-4
- [x] panel_card_dark.9 + rarity 글로우 4색 통합
- [x] NinePatchRect.draw_center=false + self_modulate WHITE
- [x] 글로우 자산 채도 기반 알파 처리
- [x] SELECT navy outline + 폰트 사이즈 ~1.3배

### 픽셀아트 폰트
- [x] Galmuri 11 ttf 다운로드 + 전역 default font

### 다국어 layout 안전화
- [x] VBox 가운데 정렬 + 폭 720
- [x] stretch_aspect=expand + clear_color navy
- [x] size_flags + clip_text 일괄
- [x] 영문 fit fix (BtnPlay/StatusLabel/NextGoal 폰트 + 텍스트 단축)

### Known Issues → v0.26.1
- [ ] PGS / AdMob native (.aar) 빌드 누락 fix (GUI 에디터 export)
- [ ] Pyromancer FireWisp 공격 미작동 진단 (logcat)

## v0.25.1 완료 (한국어 게임 제목 정리)

- [x] `config/name_localized` 추가 — 한국어 폰 "잔불의 밤", 그 외 "Nightseed Survivor"
- [x] `branding/index.html` 한국어 표기 10곳 + "7분"→"5분" 4곳 일괄 정리
- [x] AAB 빌드 + 바탕화면 복사 + release 노트

### v0.25.2 또는 v0.26.0 → 다음 release 차단 해제 필요
- [ ] PGS / AdMob native (.aar) 빌드 누락 fix — Godot GUI 에디터로 export

## v0.25.0 완료 (메인 메뉴 픽셀아트 리워크)

### 메인 메뉴 시각 전면 리워크
- [x] BG-04 5명 영웅 일러 배경 + 메뉴 UI 안 겹치게 130 px shift
- [x] 픽셀아트 타이틀 로고 KO "잔불의 밤" / EN "NIGHTSEED SURVIVOR" 자동 스왑
- [x] 9-slice 마진 버그 수정 (96/140/36 → 16/24/12 px 텍스처 픽셀 기준)
- [x] 메뉴 버튼 3줄 × 2 재배치
- [x] 영문 라벨 정리 (HEROES, ★ RANK, DIFF=난이도이름만)
- [x] 아이콘 alignment center + h_separation
- [x] TopRightRow 좌하단 코너로 이동
- [x] 자산 31장 후처리 자동화 파이프라인 (crop / alpha padding / flood-fill / outline)

### Known Issue → v0.25.1
- [ ] PGS / AdMob native (.aar) 빌드 누락 fix — Godot 4.2 헤드리스 export quirk

## v0.23.0 완료

### 폰트 대확대 — 모바일 가독성 최종 보정
- [x] 메인 메뉴 폰트 ~1.7배 (PLAY 48→76, 1차/2차 22→36, 타이틀 58→76)
- [x] HUD 폰트 ~1.7배 (시간 34→56, 스탯 20→34, HP 18→28)
- [x] 컨테이너 높이 동시 조정 (잘림 방지)

## v0.22.0 완료

### 폰트 / HUD 폴리시 (외부 리뷰 2차)
- [x] 메인 메뉴 / HUD / 레벨업 폰트 전반 +4 (외부 리뷰 "글씨가 너무 작아서 안보여" 대응)
- [x] HUD top bar 112→140px, Lv/Kills/Gold 아이콘 셀 + 하단 경계선 + HP 라벨 외곽선
- [x] 레벨업 카드 아이콘 70→96px + 무기 컬러 self_modulate (XP 픽업과 시각 구분)
- [x] 스토리 화면 신규 — StoryUI (해금 상태별 대사 표시, 코덱스 진입점 유지)

## v0.21.0 완료

### 모바일 레이아웃 수정 (v0.20.0 폰 검증 후)
- [x] 메인 메뉴 하단 빈 공간 제거 (Spacer EXPAND + BottomSpacer)
- [x] 레벨업 카드 자연 높이 + 중앙 클러스터링
- [x] HUD HP/XP 바 그룹화 (간격 조이고 XP 스타일박스)

## v0.20.0 완료

### UI 폴리시 — 외부 리뷰 반영
- [x] 메인 메뉴 푸터(Language/Credits)를 상단 우측 코너 작은 행으로 이동
- [x] 인게임 HUD HP 바 동적 색상 (초록 / 호박 / 빨강+펄스)
- [x] 레벨업 카드 탭 시각 피드백 (scale 0.96 → 1.0)

## v0.19.0 완료

### Phase 1 잔여 — 제품감 정리 마무리
- [x] 스테이지별 배경 톤 정리 (`stages.json` bg 블록 → BackgroundTiler.apply_tone)
- [x] `.agent/tasks.md` 실제 구현 상태로 재정리

### Phase 2 — 전투 체감 강화
- [x] Fire Wisp 타깃팅을 적 밀집도 기반으로 변경
- [x] Star Needle 방향성 개선 (이동 방향 + 밀집 방향, 넓은 부채꼴)
- [x] 돌진/캐스터/스플리터 텔레그래프 강화
- [x] 미니보스 패턴 1개 추가 (방사형 충격파)
- [x] 보스전 마지막 구간(HP 30% 이하) 격노 연출

### 상용화 인프라
- [x] Play Games Services 활성화 — App ID + 리더보드 6종 실제 ID 주입
- [x] AdMob 보상형 광고 SDK 통합 — Poing Studios 플러그인 v4.3.1 + 백엔드 v4.2.0 배치, AdManager 새 API로 재작성, Google 공식 테스트 광고 ID로 ENABLED=true. 사용자 실제 ID 수급 시 `config.gd`/`AdManager.gd` 두 상수 교체로 라이브 전환

---

## 완료된 큰 흐름 (요약)

- **v0.1~0.5** Playable Prototype + Combat Loop + Growth Loop + UI/Audio
- **v0.6~0.10** 무기 5종 + 진화 + 스테이지 5종 + 난이도 3단 + 상점/메타 강화
- **v0.11~0.15** 적 다양화 (Dasher/Caster/Splitter/MiniBoss) + 업적 + Codex + Story Banner
- **v0.16** Play Games Services 코드 wiring (ID는 placeholder)
- **v0.17** 5분 페이스 압축 + 모바일 가독성·노치 대응
- **v0.18** Phase 1 1차 — 메뉴/HUD/레벨업/결과 화면 가독성 정리

세부 항목은 git log + [docs/releases/](../docs/releases/) 참고. 본 목록은
**현재 작업 중 + 즉시 다음 후보**만 유지합니다.

---

## Phase 3+ 후보 (대기열)

### UI 아트 디렉션 / 제품감 고도화
- [x] `docs/UI_ART_DIRECTION_ROADMAP.md` 기준 공통 UI 키트 1차 정리 (Phase UI-1)
  - `ButtonStyles.gd`에 Moon CTA (`apply_moon`) + Stone primary (`apply_stone`) + Stone secondary (`apply_stone_secondary`) 추가, 코너 반경 ≤6 / 테두리 2~3
- [x] 메인 메뉴 Nightseed 비주얼 리워크 1차 (Phase UI-2)
  - `MenuBackdrop.gd` 절차 배경 (수직 그라데이션 + 별 + 달빛 헤일로 + 안개 + 트리 실루엣 + 반딧불)
  - `CharacterShowcase.gd` + 노드 — 현재 캐릭터 스프라이트(16×16) 6× 업스케일 + 후광/봉인 링 + 이름 라벨, 스프라이트 누락 시 silhouette fallback
  - PLAY 달빛 CTA / 1차 행 강조 석판 / 2차 행 + 코너 조용한 석판으로 위계 재정리
- [x] 1차 리워크 후 실제 추가 애셋 필요성 산출 — `docs/UI_REDESIGN_SPEC.md` + `docs/ASSETS_TO_GENERATE.md`로 확정 (6화면 × 30여 자산, 우선순위 P0/P1/P2)
- [x] Phase UI-3 메인 메뉴 1차 자산 통합 — BG-01/PN-01/PN-03/IC-TOP-01,02/IC-NAV-01~06 (총 10장 P0) + BG-02/BG-03 보너스 2장. `ButtonStyles.apply_stone_texture`/`apply_amber_texture` 추가, `MainMenu.tscn`에 `BackgroundImage`+`GoldCoinIcon` 노드, 모든 텍스처는 `ResourceLoader.exists()` 가드로 fallback.
- [x] P1/P2 누락 자산 생성 자동화 — `scripts/generate_missing_ui_assets.py` 추가. P0 보호/기존 파일 skip/dry-run 확인 완료. 실제 생성은 OpenAI `billing_hard_limit_reached` 해제 후 재시도 필요.
- [ ] **다음 세션(빌드 가능 PC)에서**: `.import` 자동 생성 커밋 → 헤드리스 검증 → 로컬 AAB 빌드 → 폰 실기 검증 → 9-slice margin(96/140/36) 시각 검수 후 필요시 조정 → 통과시 Play Console 비공개 트랙 업로드
- [ ] P4: 나머지 5화면 자산 통합 — LevelUp → Results → CharSelect → Shop → BattleHUD (P3 폰 검증 통과 후 진입)
- [ ] Phase UI-3 캐릭터 쇼케이스 고도화 (Characters.DATA에 `portrait` 키 추가 + 실제 큰 이미지 도입)
- [ ] Phase UI-4 레벨업 카드 보상 카드 스타일 리워크
- [ ] Phase UI-5 결과 화면 승패/보상 연출 리워크
- [ ] Phase UI-6 캐릭터/스테이지/상점 화면 톤 통일

### 데이터/성능 기반화
- [ ] 무기/패시브/캐릭터/적 수치 데이터화 (`weapons.json` 등으로 분리)
- [ ] 저장 데이터 `schema_version` 도입 및 마이그레이션 계획
- [ ] 투사체/XP 보석/골드 object pool
- [ ] 적 탐색 캐시 (`get_nodes_in_group` 매 프레임 호출 제거)
- [ ] QA용 로컬 run summary 저장
- [ ] Android 실기기 성능 체크리스트

### 출시 패키징 (Phase 4)
- [ ] 스토어 스크린샷 / 피처 그래픽 / 아이콘 최종화
- [ ] 개인정보 처리방침 갱신
- [ ] PGS 로그인 실패·오프라인 모드 QA
- [ ] GitHub Actions 산출물 검증 자동화 강화

### 미해결 외부 의존
- [x] PGS App ID + 리더보드 6개 ID 수급 → `LeaderboardManager.LEADERBOARD_IDS`
      및 `res/values/game_services_ids.xml` 반영 완료
- [ ] AdMob 실제 앱 ID + 보상형 광고 단위 ID 수급 → `addons/admob/android/config.gd`의
      `APPLICATION_ID`와 `scripts/core/AdManager.gd`의 `REWARDED_UNIT_ID` 교체.
      현재는 Google 공식 테스트 ID로 SDK 통합/빌드 검증 가능 상태.
      **전제: Play Console 공개 트랙 출시 후 AdMob 콘솔 검색에서 앱이 잡힘.**
- [ ] iOS 빌드 (Mac + Apple Dev 계정 필요, 보류)
