# Decisions

## 2026-05-06

### Decision: Use `nightseed-survivor` as repository name

Reason:

- The name clearly communicates the survivor-like genre.
- `Nightseed` provides a distinctive project identity.
- The repository name is short, readable, and suitable for GitHub.

### Decision: Use `Nightseed Survivor` as project/game name

Reason:

- The name fits the dark fantasy direction.
- It is suitable for a small 2D survival action game.
- It can remain as the store-facing title unless a naming conflict is later found.

### Decision: Use `NIGHTSEED` as project codename

Reason:

- Short and easy to reference in documentation.
- Distinct from the user-facing game name.

### Decision: Use Godot 4 and GDScript

Reason:

- Godot is suitable for 2D games.
- GDScript is fast for iteration.
- Scene-based workflows are friendly to agentic coding.

### Decision: Start with placeholder graphics

Reason:

- Final art assets are not available.
- Core gameplay can be validated without final art.
- Logic and visual nodes will be separated to make later asset replacement easier.

### Decision: Do not add online, ads, login, analytics, or IAP in MVP

Reason:

- MVP should validate the core game loop first.
- These features add policy, privacy, build, and maintenance complexity.

## 2026-05-07

### Decision: Milestone 1은 플러그인 없이 Godot 기본 기능으로 구현

Reason:

- 요구된 기능(이동, 추적 AI, 스폰, HUD, 게임오버)은 엔진 기본 노드와 GDScript로 충분히 구현 가능함.
- 외부 의존성을 추가하지 않으면 초기 안정성과 유지보수성이 높음.
- AGENTS.md 의존성 최소화 원칙과 일치함.

### Decision: Placeholder 시각은 `Visual` 하위 Polygon2D로 고정

Reason:

- 로직 노드와 시각 노드 분리를 구조적으로 강제할 수 있음.
- 이후 실제 Sprite2D/애니메이션으로 교체 시 충돌/이동 로직 영향을 줄일 수 있음.
