# Progress

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
