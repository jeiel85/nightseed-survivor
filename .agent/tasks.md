# Tasks

> 이 파일은 [docs/COMMERCIALIZATION_ANALYSIS.md](../docs/COMMERCIALIZATION_ANALYSIS.md)의
> Phase 1~4 로드맵을 작업 단위로 풀어 놓은 운영 목록입니다. 코드 상태를
> 기준으로 한 마지막 동기화는 v0.19.0 작업 시작 시점입니다.

## v0.19.0 진행 중

### Phase 1 잔여 — 제품감 정리 마무리
- [x] 스테이지별 배경 톤 정리 (`stages.json` bg 블록 → BackgroundTiler.apply_tone)
- [x] `.agent/tasks.md` 실제 구현 상태로 재정리

### Phase 2 — 전투 체감 강화
- [ ] Fire Wisp 타깃팅을 적 밀집도 기반으로 변경
- [ ] Star Needle 방향성 개선 (이동 방향 + 밀집 방향, 넓은 부채꼴)
- [ ] 돌진/캐스터/스플리터 텔레그래프 강화
- [ ] 미니보스 패턴 1개 추가 (방사형 펄스)
- [ ] 보스전 마지막 구간(HP 30% 이하) 격노 연출

### 상용화 인프라
- [ ] Play Games Services placeholder 정리 + 사용자 ID 수급 후 wiring
- [ ] AdMob 보상형 광고 SDK 통합 (placeholder ID, 부활/골드 2배 훅)

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
- [ ] PGS App ID + 리더보드 6개 ID 수급 → `LeaderboardManager.LEADERBOARD_IDS`
      및 `res/values/game_services_ids.xml` 채우기
- [ ] AdMob 앱 ID + 보상형 광고 단위 ID 수급 → `AdManager` 활성화
- [ ] iOS 빌드 (Mac + Apple Dev 계정 필요, 보류)
