# Nightseed Survivor

10분 생존 액션 — Vampire Survivors 스타일 모바일 게임 (Godot 4.2.2).

[![Android Build](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml/badge.svg)](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml)

## 다운로드

최신 APK는 [Releases](https://github.com/jeiel85/nightseed-survivor/releases) 페이지에서 받을 수 있습니다.

## 폰에 설치하기

### 옵션 A: APK 파일을 폰으로 옮긴 뒤 설치

1. [Releases](https://github.com/jeiel85/nightseed-survivor/releases)에서 `nightseed-survivor-release.apk` 다운로드
2. 카카오톡/이메일/USB로 폰에 전송
3. 폰 설정 → 보안 → "출처를 알 수 없는 앱 설치" 허용 (해당 앱 한정)
4. 파일 매니저에서 APK 탭 → 설치

### 옵션 B: ADB로 USB 설치 (개발자용)

폰에서 USB 디버깅 켜기 (설정 → 휴대전화 정보 → 빌드번호 7번 탭 → 개발자 옵션 → USB 디버깅).

```powershell
.\scripts\install_phone.ps1
```

또는 직접:

```powershell
adb install -r build\nightseed-survivor-release.apk
```

이전 버전이 다른 키스토어로 서명되었다면 먼저 `adb uninstall com.nightseed.survivor`.

## 로컬에서 실행 / 빌드

### 게임 실행 (PC)

```powershell
.\Godot_v4.2.2-stable_win64.exe --path godot
```

키보드 (WASD) 또는 마우스 좌클릭+드래그(가상 조이스틱)로 조작.

### Android APK 빌드

키스토어가 `secrets/release.keystore`에 있어야 합니다. 비밀번호와 키스토어 파일은 별도 보관.

```powershell
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = "$PWD\secrets\release.keystore"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = "nightseed"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = "<password>"

.\Godot_v4.2.2-stable_win64.exe --headless --path godot `
  --export-release "Android" "build\nightseed-survivor-release.apk"
```

### CI

`.github/workflows/android-build.yml`이 `main` 푸시마다 APK를 빌드하고 artifact로 업로드합니다. `release` 이벤트에는 릴리즈 자산으로 첨부합니다.

GitHub Secrets:
- `ANDROID_RELEASE_KEYSTORE_BASE64` — 키스토어를 `base64 -w 0`로 인코딩한 값
- `ANDROID_RELEASE_KEYSTORE_PASSWORD` — 키스토어 비밀번호

## 게임 컨텐츠

- **무기 5종 + 진화 2종**: Moon Dagger → Crescent Storm, Spirit Orb → Eternal Halo, Fire Wisp, Thorn Ring, Star Needle
- **캐릭터 5종**: Vagrant / Spirit Sister / Hunter / Berserker / Pyromancer
- **스테이지 5종**: Forest of Echoes / Frozen Wastes / Twilight Sanctum / Inferno Chasm / Cursed Tomb
- **난이도 3단계**: Normal / Hard / Nightmare
- **업적 10종**: 클리어, 스피드런, 200킬, 무피해, 진화, 보스, 부자, 콤보 마스터, 하드 클리어, 레벨 20
- **영구 패시브 5종**: Swift Boots / Magnet Charm / Iron Heart / Battle Focus / Power Core (상점에서 골드로 강화)

## 프로젝트 구조

```
godot/                 # Godot 프로젝트 루트
  data/stages.json     # 스테이지 정의 (서버 업데이트 가능 형식)
  scenes/              # .tscn 씬 파일
  scripts/
    core/              # GameData, Stages, AudioManager, Characters, ...
    enemies/           # 적 타입
    fx/                # 시각 효과 (DeathBurst, Starfield)
    pickups/           # XP 보석, 골드 코인
    player/            # Player.gd
    ui/                # 메인메뉴, 캐릭터/스테이지 선택, 상점, ...
    weapons/           # 무기 5종 + 베이스
.github/workflows/     # GitHub Actions
secrets/               # 키스토어 (gitignored)
build/                 # APK 빌드 결과 (gitignored)
```
