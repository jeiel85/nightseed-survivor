# UI_ART_DIRECTION_ROADMAP

## 1. 목적

이 문서는 `Nightseed Survivor`의 UI를 기능적인 버튼 모음에서 하나의 게임처럼 보이는 화면으로 끌어올리기 위한 작업 계획서다.

현재 UI는 폰트 가독성과 정보 구조는 개선되었지만, 아직 다음 문제가 남아 있다.

- 메인 화면에 게임의 얼굴이 없다.
- 배경, 캐릭터, 버튼, 카드가 하나의 아트 방향으로 묶이지 않는다.
- 버튼은 기능적으로는 명확하지만 대부분 네모난 박스와 텍스트로 보인다.
- Nightseed 세계관의 핵심인 밤, 봉인, 기억, 달빛, 이름 상실이 UI에서 충분히 드러나지 않는다.

목표는 디자이너 없이도 바이브 코딩으로 단계별 개선이 가능하도록, 시각 철학과 구현 단위를 명확히 정하는 것이다.

---

## 2. 디자인 철학

### 핵심 문장

`밤의 숲 앞에서, 잃어버린 이름을 되찾기 위해 출정하는 화면.`

UI는 밝고 귀여운 판타지보다, 어두운 밤과 창백한 달빛 속에서 봉인을 풀어가는 느낌을 우선한다.

### 핵심 키워드

| 키워드 | UI에서의 표현 |
|---|---|
| 밤 | 깊은 남색/흑녹색 배경, 낮은 명도 |
| 달빛 | 창백한 청백색 하이라이트, 주요 CTA 강조 |
| 기억 | 금색/호박색 파편, 보상/해금/스토리 강조 |
| 봉인 | 돌판, 룬, 얇은 테두리, 균열 장식 |
| 위험 | 붉은색/자홍색, 보스/피격/위험 상태 |
| 숲 | 안개, 나무 실루엣, 바닥 질감, 반딧불 |

### 색 역할

| 역할 | 권장 색 |
|---|---|
| 배경 | 거의 검은 남색 `#0B0E17`, 어두운 숲 녹색 `#08140F` |
| 기본 패널 | 어두운 청회색 `#141923`, 불투명도 80~92% |
| 기본 테두리 | 흐린 달빛색 `#8EA8C8` |
| 강조 CTA | 창백한 달빛 `#DDEBFF` + 짙은 남색 텍스트 |
| 보상/해금 | 기억의 금색 `#F2C66A` |
| 위험/보스 | 진홍 `#D94A5A`, 자홍 `#C45CFF` |
| 비활성 | 회색 청색 `#5B6270` |

### 형태 언어

- 버튼은 단순 사각형보다 낡은 봉인석 또는 석판 느낌을 준다.
- 과도한 장식은 피하고, 반복되는 얇은 테두리/상단 룬 라인/작은 균열을 사용한다.
- 모든 카드와 패널의 모서리 반경은 작게 유지한다. 현재 프로젝트 규칙상 8px 이하가 기준이다.
- 메인 메뉴와 레벨업 화면은 서로 다른 화면이어도 같은 테두리, 같은 강조색, 같은 여백 규칙을 공유한다.

---

## 3. 전체 작업 순서

### Phase UI-1: 공통 UI 키트 정리

목표:

- 화면별로 제각각인 버튼/패널을 `Nightseed` 스타일로 통일한다.
- 이후 메인 메뉴와 레벨업 화면을 고칠 때 반복 작업을 줄인다.

주요 파일:

- `godot/scripts/ui/ButtonStyles.gd`
- `godot/scripts/ui/MainMenu.gd`
- `godot/scenes/ui/MainMenu.tscn`
- `godot/scenes/ui/LevelUpUI.tscn`
- `godot/scripts/ui/LevelUpUI.gd`

구현 작업:

- `ButtonStyles.gd`에 스타일 종류 추가
  - `MOON_PRIMARY`: PLAY 전용, 달빛색 강조
  - `STONE_PRIMARY`: 캐릭터/스테이지/상점 등 주요 메뉴
  - `STONE_SECONDARY`: 언어/크레딧/스토리 등 보조 메뉴
  - `DANGER`: 보스/종료/위험 액션
  - `REWARD`: 보상/골드/해금 액션
- `StyleBoxFlat` 공통 규칙 정의
  - 배경색, 테두리색, hover/pressed 색, content margin
  - border width 2~4
  - corner radius 6 이하
- 버튼 hover/pressed 상태에서 크기 변화는 최소화하고, 색/밝기/테두리만 변화
- 텍스트만 있는 버튼 대신 아이콘을 붙일 수 있는 구조 준비
  - 아이콘이 없으면 텍스트만 표시
  - 추후 `assets/sprites/ui/`에 아이콘 추가 가능

완료 기준:

- 메인 메뉴의 PLAY, 캐릭터, 스테이지, 난이도, 상점, 스토리, 리더보드, 언어, 크레딧 버튼이 같은 스타일 체계에 속한다.
- 새 버튼 스타일을 추가해도 개별 씬 파일을 많이 수정하지 않아도 된다.
- Godot headless에서 MainMenu / LevelUpUI 씬 로드 에러가 없다.

---

### Phase UI-2: 메인 메뉴 비주얼 리워크 1차

목표:

- 첫 화면이 더 이상 네모 버튼 모음으로 보이지 않게 한다.
- Vagrant와 밤의 숲이 첫 화면의 주인공이 되게 한다.

주요 파일:

- `godot/scenes/ui/MainMenu.tscn`
- `godot/scripts/ui/MainMenu.gd`
- `godot/assets/sprites/ui/` 또는 `godot/assets/sprites/backgrounds/`
- 필요 시 `godot/scripts/fx/MenuBackground.gd` 신규

화면 구성 제안:

```text
MainMenu
  Background
    밤 숲/달빛 배경 이미지 또는 절차 배경
    안개/별/반딧불 레이어
  CharacterShowcase
    선택된 캐릭터 큰 실루엣 또는 스프라이트
    은은한 달빛 림라이트
  TitleArea
    NIGHTSEED SURVIVOR
    짧은 서브타이틀
  PrimaryAction
    PLAY
  QuickActions
    Character / Stage / Difficulty
  BottomActions
    Shop / Story / Leaders
  CornerActions
    Language / Credits
```

구현 작업:

- 배경을 단색 `ColorRect`에서 레이어형 배경으로 교체
  - 1차 선택지 A: `TextureRect` 배경 이미지 사용
  - 1차 선택지 B: GDScript로 나무 실루엣, 달, 안개, 반딧불을 절차 생성
- 선택된 캐릭터를 화면 중앙 또는 하단에 크게 표시
  - 실제 큰 일러스트가 없으면 현재 캐릭터 스프라이트를 3~4배 확대하고 어두운 실루엣/림라이트 처리
  - 캐릭터 선택이 바뀌면 MainMenu로 돌아왔을 때 표시 캐릭터도 변경
- PLAY 버튼은 하단 엄지 위치의 가장 큰 액션으로 유지
- 캐릭터/스테이지/난이도는 PLAY 위 또는 아래에 작은 석판 버튼 3개로 유지
- Shop/Story/Leaders는 하단 보조 메뉴로 낮춘다
- Language/Credits는 상단 여백을 유지하되 더 작고 조용하게

디자이너 없이 가능한 배경 제작 옵션:

1. AI 이미지 생성 후 사용
   - 프롬프트 예시:
     ```text
     dark fantasy mobile game main menu background, moonlit haunted forest,
     ancient broken seal stone, subtle fireflies, deep blue black palette,
     no text, no logo, vertical 9:16 composition, readable center area,
     painterly pixel art inspired, low detail, mobile game background
     ```
   - 생성 이미지는 `godot/assets/sprites/backgrounds/menu_night_forest.png`로 저장
   - 실제 저작권/라이선스 확인이 어려운 외부 이미지는 사용하지 않는다.
2. 절차 배경으로 시작
   - 달 원형, 나무 실루엣 Polygon2D, 안개 반투명 ColorRect, 반딧불 점을 코드로 생성
   - 장점: 라이선스 안전, 빠른 반복
   - 단점: 일러스트 완성도는 낮음

권장:

- 1차는 절차 배경으로 구조를 만들고, 이후 AI 생성 배경 또는 직접 제작 배경으로 교체한다.

완료 기준:

- 첫 화면 스크린샷만 봐도 어두운 숲/달빛/캐릭터가 보인다.
- 버튼보다 배경과 캐릭터가 먼저 눈에 들어온다.
- PLAY는 여전히 가장 잘 보인다.
- 720x1280과 540x960 기준으로 텍스트/버튼 겹침이 없다.

---

### Phase UI-3: 메인 메뉴 캐릭터 쇼케이스

목표:

- 선택한 캐릭터가 메뉴에서 눈에 보이게 만들어 게임의 얼굴을 만든다.

주요 파일:

- `godot/scripts/core/Characters.gd`
- `godot/scripts/ui/MainMenu.gd`
- `godot/scenes/ui/MainMenu.tscn`
- `godot/assets/sprites/player/` 또는 기존 캐릭터 스프라이트 경로

구현 작업:

- `Characters.gd`의 캐릭터 데이터에 `portrait` 또는 `menu_sprite` 경로 추가
- `MainMenu.gd`에서 현재 선택 캐릭터의 portrait를 읽어 `TextureRect`에 표시
- portrait가 없으면 시작 무기 또는 기본 플레이어 스프라이트로 fallback
- 캐릭터 아래에 작은 이름 라벨 표시
  - 예: `Vagrant`
  - 너무 설명문처럼 보이지 않게 짧게 유지
- 캐릭터 주변에 은은한 원형 달빛 또는 봉인 원형 장식 추가

완료 기준:

- 캐릭터 선택 후 메인 메뉴로 돌아오면 표시 캐릭터가 바뀐다.
- portrait 누락 시에도 화면이 깨지지 않는다.
- 캐릭터가 버튼과 겹치지 않는다.

---

### Phase UI-4: 레벨업 카드 리워크

목표:

- 레벨업 선택지가 단순 정보 박스가 아니라 "빌드 선택 카드"처럼 보이게 한다.

주요 파일:

- `godot/scenes/ui/LevelUpUI.tscn`
- `godot/scripts/ui/LevelUpUI.gd`
- `godot/scripts/ui/ButtonStyles.gd`
- 필요 시 `godot/assets/sprites/ui/card_*`

카드 구성 제안:

```text
Card
  Header strip: NEW / UPGRADE / EVOLVE
  Icon seal: 무기/패시브 아이콘
  Name
  Level line: Lv 2 -> 3
  Big effect line: DMG 14 -> 18 / CD 1.2 -> 0.9
  Short role chip: SEEK / AOE / SURVIVE
  Select area
```

구현 작업:

- 카드 배경을 단색 패널에서 어두운 석판 스타일로 변경
- 카드마다 무기/패시브 타입에 따라 얇은 강조 테두리 색 지정
  - Moon Dagger: 은색/달빛
  - Spirit Orb: 청보라
  - Fire Wisp: 주황/붉은색
  - Thorn Ring: 녹색
  - Star Needle: 금색/하늘색
  - Passive: 기억의 금색
- `NEW`, `UPGRADE`, `EVOLVE` 태그는 카드 헤더의 작은 리본처럼 표현
- 아이콘 뒤에 원형 봉인 배경 추가
- 설명 문구는 짧게 유지하고, 실제 수치 변화는 가장 잘 보이는 줄에 배치
- 카드 선택 피드백은 scale보다 빛/테두리 강조 중심으로 변경

완료 기준:

- 카드 3장이 한 화면에 안정적으로 들어온다.
- 글자 크기는 현재보다 줄이지 않는다.
- 무기/패시브/진화 카드가 색과 태그만 봐도 구분된다.
- 카드가 단순 네모 버튼이 아니라 보상 카드처럼 보인다.

---

### Phase UI-5: 결과 화면 리워크

목표:

- 죽거나 클리어했을 때 다음 판을 누르고 싶게 만든다.

주요 파일:

- `godot/scenes/main/GameRoot.tscn`
- `godot/scripts/core/GameRoot.gd`
- `godot/scripts/ui/ButtonStyles.gd`

구현 작업:

- 승리/패배 배경 톤을 더 극적으로 분리
  - 승리: 달빛, 금색 파편, 회복된 기억
  - 패배: 어두운 붉은 안개, 깨진 봉인
- 결과 패널을 석판/기억 조각 스타일로 변경
- 획득 골드와 다음 강화까지 남은 골드를 더 크게 표시
- 신규 업적/해금 발생 시 별도 강조 라인 또는 작은 배지 표시
- Restart/Menu 버튼은 PLAY 계열 버튼 스타일로 통일

완료 기준:

- 결과 화면에서 가장 먼저 승리/패배 상태가 읽힌다.
- 두 번째로 획득 보상과 다음 목표가 읽힌다.
- 세 번째로 다시 시작 버튼이 읽힌다.

---

### Phase UI-6: 스테이지/캐릭터/상점 화면 톤 맞추기

목표:

- 메인 메뉴만 좋아지고 나머지 화면은 예전 UI로 남는 문제를 막는다.

주요 파일:

- `godot/scenes/ui/CharacterSelect.tscn`
- `godot/scripts/ui/CharacterSelect.gd`
- `godot/scenes/ui/StageSelect.tscn`
- `godot/scripts/ui/StageSelect.gd`
- `godot/scenes/ui/ShopUI.tscn`
- `godot/scripts/ui/ShopUI.gd`

구현 작업:

- CharacterSelect 카드에 캐릭터 portrait/시작 무기/해금 상태를 명확히 표시
- StageSelect 카드에 스테이지 배경 톤, 예상 시간, 적 성향 태그 표시
- ShopUI 강화 항목을 단순 리스트에서 "기억 조각 강화판" 느낌의 카드로 정리
- 잠금 상태는 회색 처리보다 봉인/자물쇠 느낌의 overlay로 표현

완료 기준:

- 메인 메뉴에서 들어간 하위 화면도 같은 게임의 UI로 보인다.
- 잠금/해금/구매 가능 상태가 색만이 아니라 형태와 아이콘으로도 구분된다.

---

## 4. 작업 우선순위

다음 세션에서 바로 시작한다면 아래 순서를 권장한다.

1. `Phase UI-1` 공통 UI 키트 정리
2. `Phase UI-2` 메인 메뉴 비주얼 리워크 1차
3. `Phase UI-3` 캐릭터 쇼케이스
4. `Phase UI-4` 레벨업 카드 리워크
5. `Phase UI-5` 결과 화면 리워크
6. `Phase UI-6` 하위 화면 톤 맞추기

가장 빠르게 체감되는 최소 작업은 `Phase UI-2`다. 단, 장기적으로 UI가 다시 흩어지는 것을 막으려면 `Phase UI-1`을 먼저 작게라도 끝내는 편이 좋다.

---

## 4.1. 다음 세션 착수 판단

현재 단계에서는 이미지 애셋을 먼저 추가 제작하지 않는다.

우선 기존 Godot UI 스타일, 현재 보유한 캐릭터/아이콘 스프라이트, 절차적 배경 레이어만으로 제품감의 뼈대를 만든다. 메인 메뉴 1차 리워크 이후 실제 화면을 보고 부족한 애셋을 확정한다.

권장 착수 순서:

1. `ButtonStyles.gd`에 공통 Moon/Stone 버튼 스타일을 추가한다.
2. 메인 메뉴의 PLAY / 주요 메뉴 / 보조 메뉴 시각 위계를 먼저 정리한다.
3. `ColorRect`, `Panel`, 얇은 선, 반투명 레이어, 별/먼지 점 같은 절차 요소로 배경 레이어를 만든다.
4. 기존 캐릭터 스프라이트 기반 `CharacterShowcase`를 붙이고, 없을 때는 silhouette 또는 fallback 표시를 사용한다.
5. 리워크 화면을 기준으로 필요한 실제 이미지 애셋 목록을 다시 산출한다.

예상되는 후속 애셋 후보:

- 메인 메뉴 전용 배경 1장
- 캐릭터 쇼케이스용 큰 portrait 1~3장
- 버튼/패널용 9-slice 텍스처
- 출정, 상점, 도감, 설정, 업적 등 작은 아이콘 세트

정리하면 다음 세션의 목표는 "새 이미지 제작"이 아니라 `UI 키트 + 메인 메뉴 구조`를 먼저 세우는 것이다.

---

## 5. 다음 세션용 첫 작업 제안

### 추천 작업명

`feat(ui): 메인 메뉴 Nightseed 비주얼 리워크 1차`

### 범위

- `ButtonStyles.gd`에 Moon/Stone 계열 버튼 스타일 추가
- `MainMenu.tscn` 배경을 단색에서 레이어형 배경으로 변경
- `MainMenu.gd`에 선택 캐릭터 쇼케이스 표시 로직 추가
- PLAY / 주요 메뉴 / 보조 메뉴의 시각 위계 재정리
- 문서/이력 갱신

### 제외

- 실제 최종 일러스트 제작
- 모든 하위 화면 전면 수정
- 저장 데이터 구조 변경
- 신규 의존성 추가
- 광고/IAP/온라인 기능 추가

### 구현 체크리스트

- [ ] `ButtonStyles.gd`에 `MOON_PRIMARY`, `STONE_PRIMARY`, `STONE_SECONDARY` 추가
- [ ] `MainMenu.tscn`에 `MenuBackdrop` 또는 `BackgroundLayers` 노드 추가
- [ ] 절차 배경 또는 임시 배경 이미지 적용
- [ ] `CharacterShowcase` 노드 추가
- [ ] 선택 캐릭터 이미지 fallback 로직 구현
- [ ] PLAY 버튼을 가장 강한 달빛 CTA로 변경
- [ ] 하위 메뉴 버튼을 석판 스타일로 변경
- [ ] 720x1280 기준 겹침 확인
- [ ] 540x960 기준 겹침 확인
- [ ] `CHANGELOG.md`, `HISTORY.md`, `.agent/progress.md`, `.agent/tasks.md` 갱신

### 검증 기준

- `godot --headless --path godot --quit`
- 가능하면 MainMenu 씬 로드 확인
- 가능하면 Android 빌드 산출물로 실기 확인
- 빌드 환경이 아니면 diff, 씬 노드 경로, 누락 리소스 경로를 정적 확인하고 다음 세션 검증 항목으로 남긴다.

---

## 6. 주의 사항

- UI 리워크는 게임플레이 밸런스를 같이 건드리지 않는다.
- 메인 메뉴를 고칠 때 저장 데이터, PGS, 광고 placeholder 흐름을 깨지 않는다.
- 새 이미지 리소스를 추가할 경우 라이선스가 명확해야 한다.
- 생성형 이미지 사용 시 상용 배포 가능 여부를 확인하고, 원본 프롬프트와 사용 이유를 `HISTORY.md` 또는 별도 문서에 남긴다.
- 모바일에서 텍스트가 버튼 밖으로 넘치면 디자인보다 가독성을 우선한다.
- 메인 메뉴 첫 화면은 "설명"보다 "분위기 + 출정"이 먼저 보여야 한다.
