# Play Console release notes

Google Play Console에 업로드할 릴리즈 노트(언어별)를 보관합니다.
GitHub Release 본문([docs/releases/](../../docs/releases/))과는 별도 — 형식 제약이 다릅니다.

## 파일명

- 정확히 `vX.Y.Z.txt` (태그 이름 + `.txt`)
- 예: `v0.16.0.txt`, `v0.17.0.txt`

## 형식

BCP-47 언어 태그로 언어별 블록을 감쌉니다. 현재 지원 언어:

- `<ko-KR>` (기본)
- `<en-US>`

```
<ko-KR>
🌙 v0.X.Y 한 줄 부제

새로 추가
• 변경 1
• 변경 2

다듬기
• ...
</ko-KR>
<en-US>
🌙 v0.X.Y headline

What's new
• Change 1
• Change 2

Polish
• ...
</en-US>
```

## 제약

- **언어당 최대 500자** (공백/이모지 포함). 초과하면 Play Console이 잘라냅니다
- 마크다운 미지원 — 줄바꿈만 됨, `**굵게**` 같은 문법은 그대로 노출됨
- HTML 미지원 (BCP-47 언어 태그만 허용됨)
- 이모지·유니코드 OK
- 항목 머리표는 `•` (불릿) 또는 `-` 권장

## 업로드 방법

1. Play Console → 앱 → **Production** (또는 internal/closed) → 새 릴리즈 만들기
2. **App bundles** 에 GitHub Release의 `nightseed-survivor-release.aab` 업로드
3. ⚠️ **같은 화면에서 `nightseed-survivor-release.mapping.txt` 도 함께 업로드**
   (AAB 옆 ⋮ 메뉴 → "Upload deobfuscation file" — Play Console의 R8/ProGuard 경고 해소용)
4. **What's new in this release** 입력란에 `vX.Y.Z.txt` 내용을 통째로 복사 (태그 포함)
5. Play Console이 언어 태그를 자동으로 분리해서 저장

체크리스트:
- [ ] AAB 업로드
- [ ] mapping.txt 업로드 (= R8 deobfuscation 파일)
- [ ] 릴리즈 노트 붙여넣기 (`<ko-KR>` + `<en-US>` 블록 모두 포함됐는지 확인)

## GitHub Release 노트와의 관계

| 위치 | 용도 | 형식 |
|---|---|---|
| `docs/releases/vX.Y.Z.md` | GitHub Release 본문 | 마크다운, 한국어 풍부한 본문 |
| `play_store/release_notes/vX.Y.Z.txt` | Play Console 본문 | 평문, 다국어 BCP-47 태그, 500자 제한 |

같은 변경 사항이지만 형식·길이·언어가 다릅니다. 두 파일 다 함께 유지.
