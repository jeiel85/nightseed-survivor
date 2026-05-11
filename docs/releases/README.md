# Release notes

릴리즈 본문(release body)을 손으로 쓰고 싶을 때 사용합니다.

## 흐름

1. 코드 작업 완료 후 main에 푸시
2. **`docs/releases/vX.Y.Z.md`** 파일을 미리 작성해두기 (선택)
3. `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`
4. CI가 자동으로:
   - 4 플랫폼 빌드 (APK / AAB / EXE / Linux)
   - 릴리즈 생성 + 자산 첨부
   - `docs/releases/vX.Y.Z.md` 있으면 그걸 본문으로 사용
   - 없으면 GitHub 자동 changelog (이전 태그 이후 커밋 목록)

## 파일명 규칙

- 정확히 태그 이름과 일치: `v0.14.0.md`, `v1.0.0.md`
- 접두사 `v` 포함, 마침표 `.` 그대로

## 형식 (template)

```markdown
## 🌙 vX.Y.Z — 한 줄 부제

### 🎯 핵심 변경

(2~3줄 요약)

### 섹션별 변경

- 변경 1
- 변경 2

### 다운로드
- 🌐 [웹 즉시 플레이](https://jeiel85.github.io/nightseed-survivor/)
- 📦 Play Store 업로드용: `nightseed-survivor-release.aab`
- 🤖 Android `nightseed-survivor-release.apk`
- 🪟 Windows `nightseed-survivor.exe`
- 🐧 Linux `nightseed-survivor.x86_64`
```

## 정책

- **반드시 한 줄 부제**가 있는 제목으로 (`vX.Y.Z — 주제`)
- 한국어 본문 + 영문 변경사항도 가능
- 너무 짧으면 (한 줄 changelog 링크만) 회수하고 다시 쓰기
- 다운로드 섹션은 매 릴리즈 동일 (자산이 동일하므로)

## 과거 릴리즈

- v0.10.0 — 위협의 다양화 (좋은 예시)
- v0.10.1 — 초반 난이도 + CI 단순화
- v0.11.0 — 비주얼 통합
- v0.12.0 — UI 폴리시 + BGM
- v0.13.0 — 플레이 스토어 출시 자산
