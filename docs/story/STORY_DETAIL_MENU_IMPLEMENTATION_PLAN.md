# Story Detail Menu Implementation Plan

## 목적

인게임 스토리는 플레이 흐름을 방해하지 않는 핵심 요약 자막으로 유지하고, 메인 메뉴의 스토리 화면에서는 같은 사건을 더 자세한 장부/연대기 형태로 읽을 수 있게 분리한다.

현재 StoryUI는 `story_dialogues.json`의 인게임 자막을 다시 보여주는 구조라서, 스토리 메뉴가 "다시 보기" 이상으로 확장되기 어렵다. 다음 구현에서는 런타임 자막 데이터와 상세 읽기 데이터를 분리한다.

## 기준 문서

- `docs/story/STORY_FINAL_SPEC.md`
- `docs/story/STORY_NIGHTSEED_LORE.md`
- `docs/story/STORY_STAGE_DIALOGUE.md`
- `docs/story/STORY_UI_COPY.md`
- `.agent/decisions.md`의 런타임 스토리 연결 결정

## 핵심 방향

### 인게임 자막

- 시작, 보스 등장, 클리어처럼 중요한 진행 지점에서만 표시한다.
- 한 번에 1~2줄 정도의 짧은 요약만 사용한다.
- 기존 `StoryBanner` 비차단 자막 구조를 유지한다.
- 기존 `godot/data/story_dialogues.json`는 인게임 요약 자막 전용 데이터로 유지한다.

### 스토리 메뉴

- 스테이지별 상세 챕터를 제공한다.
- 인게임 자막을 상단 요약으로 재사용하되, 본문은 별도 상세 텍스트를 표시한다.
- 각 챕터는 Nightseed 정보 공개 순서를 따른다.
- 해금 전에는 스포일러를 숨기고, 해금 후에는 상세 내용을 읽을 수 있게 한다.
- 클리어 여부에 따라 추가 단서나 회고 문단을 여는 구조를 우선 검토한다.

## 데이터 구조 제안

새 파일:

```text
godot/data/story_chapters.json
```

예상 스키마:

```json
{
  "version": 1,
  "chapters": {
    "forest": {
      "title": {
        "ko": "메아리의 숲",
        "en": "Forest of Echoes"
      },
      "summary": {
        "ko": "숲은 방랑자의 잃어버린 이름을 처음으로 흔든다.",
        "en": "The forest first stirs the Vagrant's lost name."
      },
      "body": [
        {
          "unlock": "stage_unlocked",
          "heading": {
            "ko": "숲이 기억하는 이름",
            "en": "The Name the Forest Remembers"
          },
          "text": {
            "ko": "상세 본문...",
            "en": "Detailed body..."
          }
        },
        {
          "unlock": "stage_cleared",
          "heading": {
            "ko": "남은 조각",
            "en": "The Remaining Fragment"
          },
          "text": {
            "ko": "클리어 후 열리는 상세 단서...",
            "en": "A clue unlocked after clearing the stage..."
          }
        }
      ],
      "revealed_terms": ["nightseed"]
    }
  }
}
```

잠금 조건 후보:

- `stage_unlocked`: 스테이지가 해금되면 표시
- `stage_cleared`: 해당 스테이지 최초 클리어 후 표시
- `campaign_cleared`: 마지막 스테이지 클리어 후 표시

## 구현 순서

1. `.agent/tasks.md`에 `feat: 스토리 메뉴 상세 장부 데이터 분리` 작업을 등록한다.
2. `godot/data/story_chapters.json`를 추가한다.
3. `Story.gd`에 상세 챕터 로드와 현 언어 기준 조회 API를 추가한다.
   - `get_stage_chapter(stage_id: String) -> Dictionary`
   - `get_chapter_sections(stage_id: String) -> Array`
   - 잠금 조건 판정은 `Story.gd` 또는 `StoryUI.gd` 중 기존 책임에 맞춰 최소 구현한다.
4. `StoryUI.gd`를 수정한다.
   - 카드 상단에는 챕터 라벨, 스테이지명, 짧은 요약을 표시한다.
   - 본문에는 `story_chapters.json`의 상세 섹션을 표시한다.
   - 인게임 자막은 "요약 자막" 또는 "전투 중 기록" 정도의 접힌/짧은 섹션으로만 남긴다.
5. `Localization.gd`에 필요한 UI 키를 추가한다.
   - 예: `story_section_summary`, `story_section_detail`, `story_section_battle_quotes`, `story_locked_clear_required`
6. 문서를 갱신한다.
   - `docs/story/README.md`: 새 데이터 파일 목적 추가
   - `docs/ARCHITECTURE.md`: `story_chapters.json` 데이터 역할 추가
   - `HISTORY.md`, `CHANGELOG.md`, `.agent/progress.md`: 실제 구현 후 결과 기록
7. 검증한다.
   - JSON 문법 검사
   - `godot --headless --path godot --quit`
   - 가능하면 `StoryUI.tscn` 단독 로드
   - 해금/미해금/클리어 상태별 표시 확인

## 스토리 작성 가이드

- `STORY_STAGE_DIALOGUE.md`의 정보 공개 순서를 유지한다.
- 인게임 자막보다 길어도 되지만, 모바일 화면에서 한 카드가 지나치게 길어지지 않게 섹션을 나눈다.
- Nightseed는 악마, 숭배, 계약, 제물 의식과 연결하지 않는다.
- 각 스테이지는 "장소의 기억 왜곡"을 중심으로 설명한다.
- 보스는 단순 악당이 아니라 봉인과 기억에 묶인 파수꾼으로 다룬다.
- 한국어/영어 병기를 기본으로 한다.

## 스테이지별 상세 내용 방향

| 스테이지 | 상세 메뉴에서 드러낼 내용 |
|---|---|
| Forest of Echoes | Nightseed라는 이름이 처음 등장하고, 숲이 방랑자의 이름을 기억하고 있음을 암시 |
| Frozen Wastes | 밤의 씨앗이 잊힌 맹세와 연결되어 있음을 설명 |
| Twilight Sanctum | 방랑자가 봉인을 지킨 자이자 연 자라는 모순을 부각 |
| Inferno Chasm | Nightseed는 단순히 태우거나 파괴할 수 없다는 사실을 확장 |
| Cursed Tomb | 방랑자가 마지막 기사였고, 잃어버린 이름이 봉인과 연결되어 있음을 상세히 공개 |

## 완료 기준

- 인게임에서는 기존처럼 짧은 진행 자막만 표시된다.
- StoryUI에서는 별도 상세 챕터 본문을 읽을 수 있다.
- 해금되지 않은 스테이지는 상세 스포일러를 보여주지 않는다.
- 클리어 후 추가 단서가 필요한 경우 클리어 조건에 맞춰 표시된다.
- `story_dialogues.json`와 `story_chapters.json`의 역할이 문서에 명확히 구분된다.
- Godot headless 실행 또는 실행 불가 사유가 기록된다.

## 비범위

- 컷신 추가
- 분기 스토리 추가
- 신규 외부 의존성 추가
- 로그인/서버/온라인 저장 기반 스토리 동기화
- 저작권 있는 기존 게임의 문구, 화면 구성, 아이콘 복제

## 다음 세션 시작 메모

작업 시작 시 기존 미추적 StoryUI 이미지와 StoryUI 변경분이 남아 있을 수 있다. 먼저 `git status`로 사용자 변경을 확인하고, 계획 구현과 직접 관련 없는 변경은 보존한다.
