# Story Index

이 문서는 Nightseed Survivor의 스토리 기반 작업 진입점이다.

## 정식 스토리 문서

| 문서 | 목적 |
|---|---|
| `STORY_FINAL_SPEC.md` | 전체 스토리 구조와 Nightseed 핵심 정의 |
| `STORY_NIGHTSEED_LORE.md` | Nightseed 용어, 상징, 금지 표현 기준 |
| `STORY_STAGE_DIALOGUE.md` | 스테이지별 정보 공개 순서와 대사 기준 |
| `STORY_UI_COPY.md` | UI, 로딩, 스테이지 설명, 스토어 문구 기준 |

## 데이터

| 파일 | 목적 |
|---|---|
| `godot/data/story_dialogues.json` | 인게임 `StoryBanner`에서 쓰는 짧은 시작/보스/클리어 자막 데이터 |
| `godot/data/story_chapters.json` | 메인 메뉴 StoryUI에서 읽는 스테이지별 상세 장부/연대기 데이터 |
| `godot/data/story_terms.json` | 향후 도감, 용어집, 툴팁 UI에서 재사용할 스토리 용어 데이터 |

## 출처 자료

초기 설계서 패키지는 아래 위치에 보존한다.

```text
docs/story/source/nightseed-lore-story-update/
```

이 폴더는 원본 패치 묶음이며, 실제 적용 기준은 `docs/story/`의 정식 문서를 우선한다.

## 적용 원칙

- 스토리는 게임 플레이를 방해하지 않는 짧은 문구로 단계적으로 공개한다.
- MVP 범위의 `복잡한 컷신 제외` 원칙을 유지한다.
- Nightseed는 악마, 숭배, 계약, 제물 의식과 연결하지 않는다.
- 스토리 문구는 한국어/영어 병기를 기본으로 한다.
- 런타임 구현은 필요할 때 데이터 파일을 먼저 확장하고, UI는 그 다음 연결한다.
