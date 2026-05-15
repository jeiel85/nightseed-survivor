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

## R8 / Play Console 디오뷰스케이션 파일

- Release AAB는 `minifyEnabled=true`로 R8 통과 ([godot/android/build/build.gradle](godot/android/build/build.gradle), [godot/android/build/proguard-rules.pro](godot/android/build/proguard-rules.pro))
- 빌드 산출물: `build/nightseed-survivor-release.mapping.txt` — CI가 자동 수집 + GitHub Release에 첨부
- Play Console 업로드 시: **Release dashboard → 해당 AAB → "Add deobfuscation file"** 에 `mapping.txt` 업로드 (또는 App bundle explorer → Native debug symbols/ProGuard 탭). AAB 업로드 직후 한 번만 하면 됨
- proguard-rules.pro는 Godot 엔진 + PGS + Google Play Services를 전부 keep하는 보수적 룰. 빌드 후 게임이 실제 단말에서 안 켜지면 1) 이 룰에 클래스 추가 또는 2) `minifyEnabled=false`로 잠시 롤백

## Android minSdk 정책 (v0.24.0~ )

- `gradle_build/min_sdk="24"` ([godot/export_presets.cfg](godot/export_presets.cfg)). **21로 되돌리지 말 것.**
- 이유: Poing Studios AdMob aar (`poing-godot-admob-ads-release.aar`)가 `minSdk 24` 요구. 21에서 빌드하면 Manifest merger가 "uses-sdk:minSdkVersion 21 cannot be smaller than version 24" 로 실패함
- 영향: Android 5.0(API 21) / 5.1(API 22) / 6.0(API 23) 단말 제외. 2026년 한국 시장 점유율 < 1%
- 만약 minSdk를 다시 낮추려면 AdMob 통합부터 빼야 함 (보상형 광고 기능 손실)

## Play Console 업로드 시 흔한 경고 (v0.24.0에서 확인됨)

업로드 후 두 경고가 나오는 게 정상이고 **그대로 진행하면 됨**:

1. **"이 출시 버전은 이전 버전에서 지원되던 기기 N개를 더 이상 지원하지 않습니다"**
   - 원인: minSdk 24 정책의 트레이드오프 (위 항목 참고)
   - 대응: 무시. 의도된 결정

2. **"네이티브 코드 디버그 기호가 업로드되지 않았습니다"**
   - 원인: Godot 엔진의 stripped `.so` 라이브러리. Godot 4.2 공식 export는 native symbols zip을 자동 생성하지 않음
   - 대응: 무시. 우리는 Crashlytics 등 native crash 분석 도구를 안 쓰고, `mapping.txt`만 deobfuscation에 올리면 됨
   - 만약 native crash가 Play Console에 자주 보이면 그때 대응 (Godot 엔진 디버그 심볼 보존 빌드 필요)

## 미해결/대기 항목

- **Play Games Services**: 2026-05-14 활성화 완료. App ID `442399975649`, 6개 리더보드 ID 코드 반영됨 ([godot/scripts/core/LeaderboardManager.gd](godot/scripts/core/LeaderboardManager.gd), [godot/android/build/res/values/game_services_ids.xml](godot/android/build/res/values/game_services_ids.xml)). Play App Signing 사용 — OAuth client 등록 SHA-1은 `DA:65:E3:75:98:2B:4D:6D:B2:26:7C:D5:A8:E7:89:15:F2:AB:EF:FB`. OAuth 동의 화면은 테스트 모드 (jeiel85@gmail.com 테스터 등록). 다음 빌드(v0.19.0+)부터 폰에서 PGS 로그인/리더보드 동작 검증 필요.
- **AdMob**: v0.24.0(2026-05-15)에서 SDK 통합 완료, Google 공식 **테스트 광고 ID**로 빌드 중. 실제 광고 ID 수급 후 두 상수만 교체 — `addons/admob/android/config.gd`의 `APPLICATION_ID`, `scripts/core/AdManager.gd`의 `REWARDED_UNIT_ID`. 전제: Play Console 공개 트랙 출시 후 AdMob 콘솔 검색에 앱이 잡힘
- **iOS**: 안 함 (Mac + Apple Dev 계정 필요)

## 자산 라이선스 (커밋 메시지/릴리즈 노트 작성 시 참고)

- 스프라이트: Kenney Tiny Dungeon (CC0)
- 폰트: Pretendard (SIL OFL)
- PGS 플러그인: godot-sdk-integrations/godot-play-game-services v3.1.0 (MIT)
- COI service worker: gzuidhof/coi-serviceworker (MIT)
- 사운드/음악: 절차 합성 (자산 0)
