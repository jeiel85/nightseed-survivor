# Tasks

## Current Priority

### Commercialization Analysis
- [x] 현재 구현/문서/스토어 자산 기준 상용화 개선 보고서 작성

### Story Foundation
- [x] Add canonical story document folder under `docs/story/`
- [x] Add Nightseed lore definition
- [x] Add staged dialogue guide
- [x] Add story UI copy guide
- [x] Add glossary data in `godot/data/story_terms.json`
- [x] Update stage descriptions with story copy
- [x] Add runtime story event UI (StoryBanner + stage intro / boss warning / boss intro / clear lines)
- [x] Add codex/glossary UI for story terms
- [x] Wire boss warning + fragment-recovered subtitle into result flow

### Infrastructure & Deployment
- [x] Refactor GitHub Pages structure (Branding page at root, game at `/live/`)
- [x] Add branding page source in `branding/`
- [x] Update CI/CD workflow for organized deployment

### Milestone 1: Playable Prototype

- [x] Create Godot 4 project under `godot/`
- [x] Add main gameplay scene
- [x] Add placeholder player
- [x] Add WASD and arrow-key movement
- [x] Add camera follow
- [x] Add placeholder enemy
- [x] Add enemy spawner
- [x] Make enemies move toward the player
- [x] Add player HP
- [x] Add contact damage
- [x] Add HUD with HP and survival time
- [x] Add game over state
- [x] Update `.agent/progress.md`
- [x] Update `HISTORY.md`
- [x] Update `CHANGELOG.md` if user-visible behavior changes

---

## Next Priority

### Product Polish
- [x] 메인 메뉴 정보 구조 및 버튼 위계 개선
- [x] HUD 크기/배치/가독성 개선
- [x] 레벨업 카드에 실제 효과/태그/현재 레벨 정보 강화
- [x] 결과 화면 보상 연출 및 다음 목표 표시 개선
- [ ] 스테이지별 배경 톤 정리 (Phase 1 잔여)
- [ ] 무기/패시브/캐릭터/적 수치 데이터화 설계
- [ ] 저장 데이터 `schema_version` 도입 및 마이그레이션 계획 작성

### Milestone 2: Combat Loop

- [x] Add WeaponManager
- [x] Add WeaponBase
- [x] Add Moon Dagger
- [x] Add projectile collision
- [x] Add enemy HP
- [x] Add enemy death
- [x] Add kill counter
- [ ] Add simple object pool for projectiles

---

## Backlog

- [ ] Add experience gems
- [ ] Add level-up UI
- [ ] Add passive upgrades
- [ ] Add wave director
- [ ] Add boss
- [ ] Add save manager
- [ ] Add permanent upgrades
- [ ] Add virtual joystick
- [ ] Add Android export
