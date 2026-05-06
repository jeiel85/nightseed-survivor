# HISTORY.md

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
