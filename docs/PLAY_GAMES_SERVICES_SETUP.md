# Google Play Games Services Setup Guide

`Nightseed Survivor`에 리더보드를 붙이려면 Play Console 쪽 일회성 작업이 필요합니다. 이 문서를 따라가며 진행 후, 마지막에 받은 ID 값들을 알려주시면 코드에 꽂아넣겠습니다.

소요 시간: **30~45분** (한 번만)

---

## 사전 정보

| 항목 | 값 |
|---|---|
| 패키지명 | `com.nightseed.survivor` |
| 앱 이름 | `Nightseed Survivor` |
| 릴리즈 키스토어 SHA-1 | `37:55:17:57:07:7D:48:6E:1D:A1:0C:C2:64:CB:A0:F4:0B:02:92:44` |
| 릴리즈 키스토어 SHA-256 | `B8:18:CF:6A:71:C8:D9:DE:E7:B8:30:78:E0:5E:F8:8E:F1:63:2B:E9:3C:6C:4D:71:EF:07:02:3B:00:E9:71:05` |
| 디버그 키스토어 SHA-1 | `35:55:F3:D9:81:59:8B:72:FB:93:98:08:BA:D7:AF:6C:4A:CC:2F:FA` |

> ⚠ **Google Play App Signing**을 사용하시면 Play Console이 자체 키로 다시 서명합니다. 그 경우 SHA-1 fingerprint는 위 값이 아니라 Play Console에 표시되는 "App signing key certificate" 값이 됩니다. **App signing 사용 여부 알려주세요** — 그에 맞는 SHA-1을 등록해야 합니다.

---

## Step 1 — Play Console에 앱 등록

이미 Play Console 계정 있으시니 패스 가능. 앱이 아직 없다면:

1. https://play.google.com/console → 앱 만들기
2. 앱 이름: `Nightseed Survivor`
3. 기본 언어: 한국어 (ko-KR), 게임/무료/광고 없음
4. "내부 테스트" 트랙 만들고 v0.5.0 APK 한 번 업로드 (PGS 연동에 앱 등록 필요)

**중요**: PGS는 앱이 Play Console에 등록되어 있어야만 "Linked App" 설정이 가능합니다. 그래서 일단 v0.5.0 APK를 내부 테스트로 올려두고 시작하시면 됩니다 (공개는 안 해도 됨).

---

## Step 2 — Play Games Services 프로젝트 생성

1. Play Console 좌측 메뉴 → **성장 (Grow)** → **Play Games Services** → **설정 및 관리** → **구성 (Configuration)**
2. **"새 게임 만들기"** → **"Yes, my game already uses Google APIs"** 또는 **"No, my game doesn't use Google APIs"** 선택
   - 이 프로젝트가 첫 PGS 연동이면 "No" 선택 (새 클라우드 프로젝트 자동 생성)
3. **게임 이름**: `Nightseed Survivor`
4. **카테고리**: Action

---

## Step 3 — 자격 증명 (Credentials) 등록

자격 증명 메뉴에서:

1. **"자격 증명 추가"** → **Android** 선택
2. **이름**: `Nightseed Survivor (Release)`
3. **권한 부여**: OAuth client 생성 필요. **"Create OAuth client"** 클릭
   - Google Cloud Console로 이동 → 새 OAuth client 생성
   - **Application type**: Android
   - **Package name**: `com.nightseed.survivor`
   - **SHA-1**: `37:55:17:57:07:7D:48:6E:1D:A1:0C:C2:64:CB:A0:F4:0B:02:92:44` (위 표 값)
   - 만약 Play App Signing 쓰면 그쪽 SHA-1 추가로 등록
4. 만든 OAuth client를 PGS 자격 증명에 연결
5. **디버그용도 추가**: 같은 방식으로 `Nightseed Survivor (Debug)` 자격 증명 만들고 디버그 SHA-1 등록 (개발 중 테스트용)

---

## Step 4 — 리더보드 6개 생성 (한/영 다국어)

PGS 메뉴 → **리더보드 (Leaderboards)** → **새 리더보드**

각 리더보드 생성 시:

1. **Primary language**를 **Korean (ko-KR)** 으로 선택 → 한국어 이름·설명 입력
2. **"+ Add translation"** → **English (United States)** 추가 → 영문 이름·설명 입력
3. **Format**: Numeric / **Sort order**: Larger is better
4. **저장**

> 사용자 폰 언어에 따라 자동으로 한/영 전환됨. 게임 내부 i18n (`Localization.gd`의 `stage_*_name`)과 일치시킴.

### 입력값 — 이름 (Name)

| # | 내부 ID | 🇰🇷 Korean | 🇺🇸 English | Format |
|---|---|---|---|---|
| 1 | `forest` | 메아리의 숲 — 최고 점수 | Forest of Echoes — Best Score | Numeric |
| 2 | `frozen_wastes` | 얼어붙은 황무지 — 최고 점수 | Frozen Wastes — Best Score | Numeric |
| 3 | `twilight_sanctum` | 황혼의 성소 — 최고 점수 | Twilight Sanctum — Best Score | Numeric |
| 4 | `inferno_chasm` | 화염의 협곡 — 최고 점수 | Inferno Chasm — Best Score | Numeric |
| 5 | `cursed_tomb` | 저주받은 무덤 — 최고 점수 | Cursed Tomb — Best Score | Numeric |
| 6 | `total_kills` | 누적 처치 수 | Total Kills — All Time | Numeric **Cumulative** |

### 입력값 — 설명 (Description, 선택)

| # | 🇰🇷 설명 | 🇺🇸 Description |
|---|---|---|
| 1 | 모든 것이 시작된 곳 | Where it all began |
| 2 | 박쥐와 사냥개가 추위를 지배한다 | Bats and hounds dominate the cold |
| 3 | 모든 적의 균형잡힌 시련 | Balanced trial of all foes |
| 4 | 기사와 사냥개가 불의 파도로 | Knights and hounds in waves of fire |
| 5 | 끝없는 언데드의 파도. 두려움 없는 자에게. | Endless undead tide. For the fearless. |
| 6 | 모든 판에서 처치한 적의 합산 | Sum of enemies defeated across all runs |

각 리더보드 저장하면 **Leaderboard ID** 값이 발급됩니다 (예: `CgkI...AQ`).

> 🔔 **각 리더보드 ID를 한 곳에 복사해두세요** — 마지막에 저한테 보내주실 6개 ID 입니다.

---

## Step 5 — App ID 확인

PGS 첫 페이지 우측 상단 또는 **Configuration** 탭에 **App ID** 표시됩니다 (숫자만으로 된 12~13자리, 예: `123456789012`).

이 값도 필요합니다.

---

## Step 6 — Testing accounts (선택, 권장)

PGS는 발행 전에는 **Tester** 계정만 PGS 기능 사용 가능합니다. **테스터** 메뉴에서:
- 본인 구글 계정 추가
- 테스트할 친구 계정 추가

이거 안 하면 본인이 게임 켜도 "PGS 사용 불가" 에러 납니다.

---

## 🎯 마지막 — 저한테 보내주실 정보

다 끝나면 다음 7가지를 알려주세요:

```
APP_ID = 123456789012  (Step 5)

LEADERBOARD_FOREST = CgkI...AQ
LEADERBOARD_FROZEN_WASTES = CgkI...AQ
LEADERBOARD_TWILIGHT_SANCTUM = CgkI...AQ
LEADERBOARD_INFERNO_CHASM = CgkI...AQ
LEADERBOARD_CURSED_TOMB = CgkI...AQ
LEADERBOARD_TOTAL_KILLS = CgkI...AQ

(추가) Play App Signing 사용 여부: yes/no
(yes면) Play App Signing SHA-1: AA:BB:...
```

받으면 바로 코드에 꽂아넣고 v0.6.0 APK로 내부 테스트 트랙 업로드 → 폰에서 동작 확인 가능합니다.

---

## 우리 게임의 점수 공식 (참고용)

리더보드에 제출되는 `score` 정수값은:

```
base = (kills × 10) + (gold × 5) + survival_seconds
multiplier = Normal 1.0 / Hard 1.5 / Nightmare 2.5
score = floor(base × multiplier)
```

승리(10분 풀생존)이든 사망이든 매 런 끝에 자동 제출. 리더보드는 "Larger is better" 모드라 최고 기록만 갱신.

`Total Kills`는 누적 모드(cumulative): 매 런마다 그 판 킬수만 increment 제출 → Play가 누적 합산.
