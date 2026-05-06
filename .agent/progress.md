# Progress

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
