# Project conventions

이 파일은 Claude가 세션마다 자동으로 읽음. 프로젝트별 정책·관습을 짧게 기록.

## 응답 언어
- 한국어 우선. 코드/식별자는 영문, 대화·커밋·릴리즈 노트는 한국어.

## 릴리즈

**규칙: 모든 릴리즈는 손으로 쓴 노트를 가진다. 빈 본문 금지.**

릴리즈 노트는 **두 군데**를 따로 유지한다:

| 위치 | 용도 | 형식 |
|---|---|---|
| `docs/releases/vX.Y.Z.md` | GitHub Release 본문 | 마크다운, 한국어 |
| `play_store/release_notes/vX.Y.Z.txt` | Play Console 본문 | 평문 + BCP-47 다국어 태그 (`<ko-KR>`, `<en-US>`), 언어당 500자 제한, 마크다운/HTML 미지원 |

세부 규약은 각 폴더의 README 참고: [docs/releases/README.md](docs/releases/README.md), [play_store/release_notes/README.md](play_store/release_notes/README.md).

흐름:
1. 릴리즈 전에 `docs/releases/vX.Y.Z.md` 파일을 먼저 작성 (한국어, 템플릿 따름)
2. AAB 빌드 / 업로드용이면 `play_store/release_notes/vX.Y.Z.txt` 도 함께 작성 (다국어 태그 필수)
3. 태그 푸시 (`git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`)
4. CI가 자동으로 `docs/releases/` 파일을 GitHub Release 본문으로 사용
5. Play Console에 AAB 업로드 시 `play_store/release_notes/` 파일 내용을 통째로 복사 (Play Console이 언어 태그를 자동 분리)

만약 파일을 깜빡하고 푸시했다면:
- 자동 생성된 `Full Changelog: ...` 한 줄짜리 빈 노트가 됨
- 즉시 `gh release edit vX.Y.Z --notes "$(cat <<'EOF' ... EOF)"` 로 수정
- 그리고 docs/releases/vX.Y.Z.md 도 함께 추가 (다음 백필용)

제목 패턴: `vX.Y.Z — 한 줄 부제` (예: `v0.10.0 — 위협의 다양화`)

`generate_release_notes`는 폴백일 뿐 정상 동작 아님 — PR 라벨이 없는 직접 푸시 워크플로우에서는 한 줄 changelog만 나옴.

## 빌드/배포

- **이미 푸시된 태그를 다시 빌드할 일 X** — `gh release create` 수동 호출 금지. 태그 push 한 번이면 CI가 4 플랫폼 (APK / AAB / EXE / Linux) + 웹 GitHub Pages 자동 배포.
- 키스토어: `secrets/release.keystore`, 비밀번호는 사용자가 보관 (커밋된 적 없음)
- secrets/ 절대 commit X
- `.gitignore`: `/build/` (선행 슬래시 중요 — `godot/android/build/` 보호)

## 보안/시크릿

- 환경변수 / GitHub Secrets만 사용:
  - `ANDROID_RELEASE_KEYSTORE_BASE64`, `ANDROID_RELEASE_KEYSTORE_PASSWORD`
- `export_presets.cfg`에는 keystore 정보 비워둠 (`GODOT_ANDROID_KEYSTORE_*` env로 주입)

## Godot 빌드 quirks (재발 방지 메모)

- 처음 export 전: 2-pass 에디터 import 필요 (class_name 캐시) — `--editor --quit-after 250` 두 번
- Android export 실패 시 verbose 출력이 비어있으면 → `rendering/textures/vram_compression/import_etc2_astc=true` 확인 (Windows 호스트 quirk)
- gradle build template: `godot/android/build/` 소스만 커밋, `libs/`·`build/`·`assets/`·`.gradle/`는 .gitignore (CI에서 재추출)
- `gradlew` 실행 권한: `git update-index --chmod=+x` 로 100755 보존

## 미해결/대기 항목

- **Play Games Services**: 코드는 완비, placeholder ID 상태. 사용자가 [docs/PLAY_GAMES_SERVICES_SETUP.md](docs/PLAY_GAMES_SERVICES_SETUP.md) 따라 Play Console 설정 + APP_ID/6 leaderboard ID 회수하면 활성화
- **AdMob**: 사용자가 계정만 있음. 광고 SDK 통합 미시작. ad unit ID 받으면 진행
- **iOS**: 안 함 (Mac + Apple Dev 계정 필요)

## 자산 라이선스 (커밋 메시지/릴리즈 노트 작성 시 참고)

- 스프라이트: Kenney Tiny Dungeon (CC0)
- 폰트: Pretendard (SIL OFL)
- PGS 플러그인: godot-sdk-integrations/godot-play-game-services v3.1.0 (MIT)
- COI service worker: gzuidhof/coi-serviceworker (MIT)
- 사운드/음악: 절차 합성 (자산 0)
