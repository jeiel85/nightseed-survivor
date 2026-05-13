# 밤의 씨앗: 서바이버 (Nightseed Survivor)

5분 생존 액션 — Vampire Survivors 스타일 모바일 게임 (Godot 4.2).

[![Build](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml/badge.svg)](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml)

> 밤의 씨앗이 깨어난 세계. 자동 발사 무기로 사방에서 몰려드는 군단을 베어내고, 레벨업 카드로 빌드를 골라가며 5분 끝의 보스를 처치하세요. 죽으면 메타 영구 패시브로 더 강해져서 돌아옵니다.

## 다운로드

| 플랫폼 | 자산 / 링크 |
|---|---|
| **▶️ Google Play** | [Play 스토어에서 받기](https://play.google.com/store/apps/details?id=com.nightseed.survivor) |
| **🌐 웹** | https://jeiel85.github.io/nightseed-survivor/ — 브라우저에서 즉시 플레이 |
| **🤖 Android (APK)** | [APK 다운로드](https://github.com/jeiel85/nightseed-survivor/releases/latest) |
| **🪟 Windows** | [.exe 다운로드](https://github.com/jeiel85/nightseed-survivor/releases/latest) |
| **🐧 Linux** | [.x86_64 다운로드](https://github.com/jeiel85/nightseed-survivor/releases/latest) |

모든 빌드는 [태그 push](#릴리즈) 시 CI가 자동 생성합니다.

## 게임 컨텐츠

### 무기 (5종 + 진화 2종)
| 무기 | 효과 | 진화 조건 |
|---|---|---|
| Moon Dagger | 가장 가까운 적에게 자동 발사 | + Battle Focus Lv3 → **Crescent Storm** (3방향 부채꼴) |
| Spirit Orb | 공전하는 데미지 구체 | + Magnet Charm Lv3 → **Eternal Halo** (오브 2배, 큰 궤도) |
| Fire Wisp | 무작위 지역 폭발 | — |
| Thorn Ring | 방사형 가시 폭발 | — |
| Star Needle | 퍼지는 침 일제 발사 | — |

### 캐릭터 (5종, 골드로 해금)
- **Vagrant** (기본): Moon Dagger 시작, 균형 잡힌 스탯
- **Spirit Sister** (200g): Spirit Orb 시작, 자석 강화, HP 낮음
- **Hunter** (500g): Star Needle 시작, 빠른 이속
- **Berserker** (1000g): Thorn Ring 시작, 고HP·고데미지·느림
- **Pyromancer** (1500g): Fire Wisp 시작, 시작부터 위습 충전

### 적 (10종 + 보스)
- **기본형**: Slime / Bat / Knight / Hound
- **패턴형**: Dasher (텔레그래프 후 돌진) / Caster (원거리 핑크 투사체) / Splitter (사망 시 3마리 분열)
- **보스**: MiniBoss (60초 간격 4회 자동 출현) / 최종 보스 (4분 30초 시점)

### 스테이지 (5종, JSON 정의)
Forest of Echoes / Frozen Wastes / Twilight Sanctum / Inferno Chasm / Cursed Tomb (5분 30초)

스테이지 데이터는 [`godot/data/stages.json`](godot/data/stages.json)에 정의 — 향후 서버 업데이트 가능 구조.

### 난이도 (3단계)
Normal HP 0.85x / Hard (HP x1.5, DMG x1.3) / Nightmare (HP x2.5, DMG x1.7)

**시간 경과 스케일링**: 적이 분 단위로 강해짐. 5분차에 HP ~2.4x, 속도 ~1.28x, 데미지 ~1.7x → 자동 사냥 방지.

### 영구 패시브 (5종, 골드로 강화)
Swift Boots (이속) / Magnet Charm (자석) / Iron Heart (HP) / Battle Focus (쿨다운) / Power Core (데미지) — 각 10레벨

### 업적 (10종)
First Survivor / Speed Runner / Killer Instinct / Untouchable / Evolver / Boss Slayer / Wealthy / Combo Master / Trial by Fire / Completionist

## 기능

- **다국어**: 한국어 / English. 시스템 로케일 자동 감지 + 메인 메뉴에서 토글. Pretendard 폰트 번들로 깨짐 없음
- **터치 조작**: 화면 왼쪽 절반 어디든 터치 → 다이나믹 플로팅 가상 조이스틱. PC에선 WASD 또는 마우스 좌클릭+드래그
- **세로 모바일 UI**: 540×960 윈도우 / 720×1280 캔버스
- **절차 생성 사운드**: 외부 오디오 자산 없이 GDScript에서 사인/스윕/아르페지오 합성
- **리더보드 (PGS)**: Play Games Services 통합 (Play Console 설정 후 활성화)

## 폰에 설치하기

### 옵션 A: APK 파일을 폰으로 옮긴 뒤 설치
1. [Releases](https://github.com/jeiel85/nightseed-survivor/releases)에서 `nightseed-survivor-release.apk` 다운로드
2. 카카오톡/이메일/USB로 폰에 전송
3. 설정 → 보안 → "출처를 알 수 없는 앱 설치" 해당 앱에 허용
4. 파일 매니저에서 APK 탭 → 설치

### 옵션 B: ADB로 USB 설치 (개발자용)
USB 디버깅 켠 뒤 (설정 → 휴대전화 정보 → 빌드번호 7회 탭 → 개발자 옵션 → USB 디버깅):
```powershell
adb install -r build\nightseed-survivor-release.apk
```
이전 버전이 다른 키스토어로 서명되어 있다면 먼저 `adb uninstall com.nightseed.survivor`.

## 로컬 빌드

### PC에서 바로 실행 (편집기 없이)
```powershell
.\Godot_v4.2.2-stable_win64.exe --path godot
```

### 멀티플랫폼 빌드
```powershell
# Windows
.\Godot_v4.2.2-stable_win64.exe --headless --path godot `
  --export-release "Windows Desktop" "build\nightseed-survivor.exe"

# Linux
.\Godot_v4.2.2-stable_win64.exe --headless --path godot `
  --export-release "Linux/X11" "build\nightseed-survivor.x86_64"

# Web (build/web/index.html)
.\Godot_v4.2.2-stable_win64.exe --headless --path godot `
  --export-release "Web" "build\web\index.html"

# Android (키스토어 + 환경변수 필요)
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = "$PWD\secrets\release.keystore"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = "nightseed"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = "<password>"
.\Godot_v4.2.2-stable_win64.exe --headless --path godot `
  --export-release "Android" "build\nightseed-survivor-release.apk"
```

## CI / 릴리즈

[`.github/workflows/android-build.yml`](.github/workflows/android-build.yml)이 자동 처리:

| 트리거 | 동작 |
|---|---|
| `main` 푸시 | 4 플랫폼 빌드 (APK / EXE / Linux / Web) + 웹 → GitHub Pages 자동 배포 |
| `v*` 태그 푸시 | 빌드 + GitHub 릴리즈 자동 생성 + APK·EXE·Linux 첨부 |

### 새 릴리즈 만들기
```powershell
git tag -a v0.X.Y -m "메모"
git push origin v0.X.Y
```
끝. CI가 알아서 모든 플랫폼 빌드 + 릴리즈 생성 + 자산 첨부 + 자동 릴리즈 노트.

### GitHub Secrets
- `ANDROID_RELEASE_KEYSTORE_BASE64` — 키스토어를 `base64 -w 0`로 인코딩
- `ANDROID_RELEASE_KEYSTORE_PASSWORD` — 키스토어 비밀번호

## 자산 라이선스

- **스프라이트**: [Kenney Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) (CC0 1.0 Public Domain)
- **폰트**: [Pretendard](https://github.com/orioncactus/pretendard) (SIL Open Font License)
- **엔진**: [Godot Engine 4.2.2](https://godotengine.org/) (MIT)
- **PGS 플러그인**: [godot-sdk-integrations/godot-play-game-services](https://github.com/godot-sdk-integrations/godot-play-game-services) v3.1.0 (MIT)
- **COI 서비스 워커**: [gzuidhof/coi-serviceworker](https://github.com/gzuidhof/coi-serviceworker) (MIT, 웹 SharedArrayBuffer 우회)
- **오디오**: 절차 생성 (외부 자산 없음)

## 프로젝트 구조

```
godot/                       # Godot 프로젝트 루트
  addons/
    GodotPlayGameServices/   # Android Play Games Services 플러그인
  android/
    build/                   # Android Build Template (gradle 모드용)
  assets/
    fonts/                   # Pretendard
    icons/                   # 앱 아이콘 (런처/어댑티브)
    sprites/                 # 캐릭터/적/픽업/무기/패시브/배경 데코
  data/
    stages.json              # 스테이지 정의 (i18n 키 포함)
  scenes/
    enemies/                 # 10종 적 + 발사체 + 미니보스
    main/                    # GameRoot, HUD
    pickups/                 # XP 보석, 골드 코인
    player/                  # Player
    ui/                      # 메인메뉴, 캐릭터/스테이지/상점/레벨업/크레딧
    weapons/                 # Projectile 베이스
  scripts/
    core/                    # GameData, Localization, Stages, Characters,
                             # Difficulty, Achievements, Evolutions,
                             # WaveManager, AudioManager, LeaderboardManager
    enemies/                 # 기본형 + 패턴형(Dasher/Caster/Splitter) + 미니보스
    fx/                      # BackgroundTiler, Starfield, DeathBurst
    pickups/                 # XPGem, GoldCoin
    player/                  # Player.gd
    ui/                      # 화면별 컨트롤러
    weapons/                 # 무기 5종 + 베이스
  web_extras/
    coi-serviceworker.js     # Web 빌드 COI 우회용
docs/
  PLAY_GAMES_SERVICES_SETUP.md  # Play Console 설정 가이드
play_store/                  # 스토어 자산 (아이콘 512, 피처그래픽, 스크린샷, 리스팅)
.github/workflows/           # CI
secrets/                     # 키스토어 (gitignored)
tools/                       # rcedit-x64.exe (.exe 메타데이터 임베딩)
build/                       # 빌드 결과 (gitignored)
```
