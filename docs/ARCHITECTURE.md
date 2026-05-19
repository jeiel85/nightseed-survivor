# ARCHITECTURE

## 1. 목적

이 문서는 Nightseed Survivor의 코드와 씬 구조를 정의한다.

목표는 작은 MVP를 빠르게 만들되, 무기/적/스테이지/애셋을 나중에 확장하기 쉬운 구조를 유지하는 것이다.

---

## 2. 권장 레포 구조

```text
nightseed-survivor/
  README.md
  AGENTS.md
  CHANGELOG.md
  HISTORY.md
  .gitignore

  docs/
    GAME_SPEC.md
    IMPROVEMENT_STRATEGY.md
    ASSET_GUIDE.md
    ARCHITECTURE.md
    ROADMAP.md
    BALANCE.md
    RELEASE_CHECKLIST.md
    story/
      README.md
      STORY_FINAL_SPEC.md
      STORY_NIGHTSEED_LORE.md
      STORY_STAGE_DIALOGUE.md
      STORY_UI_COPY.md

  godot/
    project.godot
    scenes/
    scripts/
    assets/
    data/

  .agent/
    tasks.md
    progress.md
    decisions.md

  prompts/
    FIRST_AGENT_PROMPT.md

  .github/
    workflows/
```

---

## 3. Godot 씬 구조

```text
godot/scenes/
  main/
    MainMenu.tscn
    GameRoot.tscn
    PauseMenu.tscn
    GameOverScreen.tscn
    ClearScreen.tscn

  player/
    Player.tscn

  enemies/
    EnemyBase.tscn
    ShadowSlime.tscn
    BoneBat.tscn
    HollowKnight.tscn
    RotHound.tscn
    AncientShade.tscn

  weapons/
    Projectile.tscn
    OrbitOrb.tscn
    AreaPulse.tscn

  pickups/
    ExperienceGem.tscn
    GoldCoin.tscn

  ui/
    HUD.tscn
    LevelUpScreen.tscn
    UpgradeCard.tscn
    PermanentUpgradeScreen.tscn
```

---

## 4. 스크립트 구조

```text
godot/scripts/
  core/
    GameManager.gd
    GameState.gd
    SaveManager.gd
    SignalBus.gd
    ObjectPool.gd

  player/
    Player.gd
    PlayerStats.gd
    PlayerInput.gd

  enemies/
    EnemyBase.gd
    EnemySpawner.gd
    WaveDirector.gd

  weapons/
    WeaponBase.gd
    WeaponManager.gd
    MoonDagger.gd
    SpiritOrb.gd
    FireWisp.gd
    ThornRing.gd
    StarNeedle.gd
    Projectile.gd

  pickups/
    ExperienceGem.gd
    GoldCoin.gd

  upgrades/
    UpgradeManager.gd
    UpgradeOption.gd
    PassiveUpgrade.gd

  ui/
    HUD.gd
    LevelUpScreen.gd
    UpgradeCard.gd
    MainMenu.gd
    GameOverScreen.gd
    ClearScreen.gd
```

---

## 5. 주요 시스템

### GameManager

역할:

- 게임 시작
- 게임 종료
- 일시정지
- 클리어 판정
- 게임오버 판정
- 전체 상태 관리

상태:

```text
MAIN_MENU
PLAYING
PAUSED
LEVEL_UP
GAME_OVER
CLEAR
```

### Player

역할:

- 이동 처리
- 체력 관리
- 피격 처리
- 경험치 획득
- 레벨업 이벤트 발생
- 무기 시스템 보유

### EnemySpawner

역할:

- 플레이어 주변 바깥쪽에서 적 생성
- 현재 시간에 맞는 적 종류 선택
- 스폰 간격 조절
- 최대 적 수 제한

### WaveDirector

역할:

- 게임 시간에 따라 적 웨이브를 변경
- 스폰 속도 증가
- 특정 시간에 보스 등장
- 적 종류별 가중치 변경

### WeaponManager

역할:

- 플레이어가 보유한 무기 관리
- 무기 추가
- 무기 레벨업
- 각 무기 쿨다운 업데이트
- 공격 실행

### UpgradeManager

역할:

- 레벨업 선택지 생성
- 보유 무기/패시브 상태 확인
- 최대 레벨 여부 확인
- 선택 결과 적용

### SaveManager

역할:

- `user://save_data.json` 저장
- 저장 데이터 로드
- 기본 저장값 생성
- 버전 변경 시 마이그레이션 진입점 제공

---

## 6. 충돌 레이어 설계

| 레이어 | 대상 |
|---|---|
| 1 | Player |
| 2 | Enemy |
| 3 | PlayerProjectile |
| 4 | Pickup |
| 5 | EnemyHitbox |
| 6 | World |

### 충돌 규칙

- Player는 Enemy와 충돌한다.
- PlayerProjectile은 Enemy와 충돌한다.
- Player는 Pickup과 충돌한다.
- Enemy끼리는 충돌하지 않아도 된다.
- 적끼리 밀림 처리는 성능 문제가 생기면 생략한다.

---

## 7. 로직과 비주얼 분리

모든 핵심 엔티티는 로직 노드와 시각 노드를 분리한다.

예시:

```text
EnemyBase
  CollisionShape2D
  Visual
    Sprite2D
```

규칙:

- 이동, 체력, 충돌, 피격 로직은 루트 스크립트가 담당한다.
- 색상, 스프라이트, 애니메이션은 `Visual` 하위 노드가 담당한다.
- 실제 애셋 교체 시 가능하면 `Visual` 하위만 수정한다.

---

## 8. 성능 설계

### 필수 정책

- 투사체는 Object Pool 사용
- 경험치 보석도 Object Pool 사용
- 적도 가능하면 Object Pool 사용
- 매 프레임 전체 적 탐색 금지
- 가까운 적 탐색은 일정 주기마다 수행
- 화면 밖 너무 먼 적은 위치를 재조정하거나 제거
- 파티클은 MVP에서 최소화
- 데미지 숫자는 MVP에서 생략 가능

### 초기 목표

| 항목 | 목표 |
|---|---|
| PC | 60 FPS |
| Android 중급기 | 30 FPS 이상 |
| 최대 적 수 | 150 ~ 250 |
| 최대 투사체 수 | 200 이하 |
| 최대 보석 수 | 300 이하 |

---

## 9. 데이터 주도 설계

무기, 적, 패시브, 웨이브 수치는 가능하면 코드에 직접 박지 않는다.

초기에는 GDScript 상수로 시작해도 되지만, 구조는 나중에 JSON/Resource로 분리 가능해야 한다.

권장 경로:

```text
godot/data/
  weapons.json
  passives.json
  enemies.json
  waves.json
  story_dialogues.json
  story_chapters.json
  story_terms.json
```

스토리 데이터는 용도별로 분리한다.

- `story_dialogues.json`: 인게임 `StoryBanner`에서 쓰는 짧은 시작/보스/클리어 자막 데이터.
- `story_chapters.json`: 메인 메뉴 StoryUI에서 읽는 스테이지별 상세 장부 데이터. `stage_unlocked`, `stage_cleared`, `campaign_cleared` 조건으로 본문 공개 시점을 나눈다.
- `story_terms.json`: 향후 용어집, 도감, 툴팁 UI에서 사용할 스토리 용어 데이터.
