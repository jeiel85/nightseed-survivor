# AdMob Rewarded Ads — Setup Guide

`Nightseed Survivor`는 보상형(rewarded) 광고만 사용합니다. 정책상 가장 안전하고,
[COMMERCIALIZATION_ANALYSIS.md](COMMERCIALIZATION_ANALYSIS.md) §5.4 권고에도
부합합니다. 일반(non-rewarded) 전면 광고, 배너, 자동 광고는 사용하지 않습니다.

**현재 상태 (v0.24.0 이후):** Poing Studios AdMob 플러그인이 이미 통합되어
있고, `AdManager.ENABLED = true`에 **Google 공식 테스트 광고 단위 ID**가
박혀 있습니다. 즉 빌드는 광고 SDK를 포함한 채로 나가지만 실제 광고는
테스트 광고만 표시됩니다. 사용자가 진짜 ID를 확보한 시점에 두 상수만
교체하면 라이브 모드로 전환됩니다.

---

## 통합된 구성요소

| 구성요소 | 위치 / 버전 |
|---|---|
| 메인 플러그인 | `godot/addons/admob/` — Poing Studios godot-admob-plugin v4.3.1 |
| Android 백엔드 .aar | `godot/addons/admob/android/bin/ads/libs/` — v4.2.0 |
| GDScript 래퍼 | `godot/scripts/core/AdManager.gd` |
| Android App ID | `godot/addons/admob/android/config.gd` 의 `APPLICATION_ID` |
| Rewarded Ad Unit ID | `godot/scripts/core/AdManager.gd` 의 `REWARDED_UNIT_ID` |
| Proguard 룰 | `godot/android/build/proguard-rules.pro` (Google Mobile Ads keep) |
| Manifest meta-data | `addons/admob/internal/exporters/android/export_plugin.gd` 가 자동 주입 (`com.google.android.gms.ads.APPLICATION_ID`) — 수동 편집 불필요 |

---

## 실제 AdMob ID로 전환 (사용자가 ID를 확보한 시점)

**전제:** 앱이 Play Console **공개(Production) 트랙**으로 출시되어 있어야
AdMob 콘솔에서 검색됩니다. 비공개/내부 테스트 단계에서는 AdMob의 앱 검색
인덱스에 안 잡힙니다. 비공개 단계라면 옵션은:

1. **그대로 테스트 광고 ID 유지** — 통합 검증 목적이면 이게 가장 안전
2. AdMob 콘솔에서 "Google Play에 없음" → 수동 등록 — 단, 라이브 광고 fill rate가
   매우 낮고 invalid activity로 플래그될 위험 있음 (비권장)
3. 공개 출시 후 정식 등록

### Step 1 — AdMob 콘솔에 앱 등록

1. https://admob.google.com → **앱 → 앱 만들기**
2. 플랫폼: **Android**, "Google Play에 등록된 앱입니까?": **예**
3. 앱 검색: **`Nightseed Survivor`** 선택
4. 등록 후 **앱 설정 → 앱 ID** 복사 — 형식: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` (물결 `~`)

### Step 2 — 보상형 광고 단위 만들기

1. AdMob → 좌측 **앱 → Nightseed Survivor → 광고 단위 → 광고 단위 추가**
2. **보상형 (Rewarded)** 선택
3. 광고 단위 이름: `Rewarded — Revive & Double Gold`
4. 보상: `Reward` × 1 (보고서용 라벨, 실제 동작에는 영향 없음)
5. 생성 후 **광고 단위 ID** 복사 — 형식: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ` (슬래시 `/`)

> 부활과 골드 2배 모두 **같은 rewarded 광고 단위 1개를 공유**합니다.

### Step 3 — 코드 두 군데에 ID 박기

**`godot/addons/admob/android/config.gd`** 의 `APPLICATION_ID` 상수:

```gdscript
const APPLICATION_ID := "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"   # Step 1 값 (~)
```

**`godot/scripts/core/AdManager.gd`** 의 `REWARDED_UNIT_ID` 상수:

```gdscript
const REWARDED_UNIT_ID: String = "ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ"   # Step 2 값 (/)
```

`ENABLED`는 이미 `true`로 박혀 있으므로 추가 변경 불필요.

### Step 4 — Play Console 광고 표시 토글

Play Console → 앱 → 정책 및 프로그램 → 광고 → **"앱에 광고가 있나요?" → 예** 선택.
스토어 등록정보에 "광고 포함" 배지가 표시됩니다.

---

## 동작 개요

| 상황 | 광고 CTA | 보상 | 1회/run 한도 |
|---|---|---|---|
| 사망 후 결과 화면 | "부활하기 (광고 시청)" | HP 50% 회복 + 무적 3초 + 가까운 적 제거 → 게임 재개 | ✅ |
| 사망/승리 후 결과 화면 | "골드 2배 (광고 시청)" | 이번 판 골드 × 2 (count-up + 다음 목표 라인도 즉시 갱신) | ✅ |

광고가 로드되지 않았거나 SDK가 비활성화 상태이면 두 버튼 모두 숨김.
부활을 한 번 사용한 뒤 다시 사망해도 부활 버튼은 더 이상 나타나지 않음.

---

## SDK 기술 메모

### Plugin patch
`addons/admob/admob.gd`는 외부 플러그인 원본을 직접 수정한 상태입니다 (iOS
exporter와 AdMob Manager 메뉴 제거). 이유:

- iOS exporter (`internal/exporters/ios/export_plugin.gd`) 가 Godot 4.3+ 전용
  GDScript type-inference 패턴을 써서 4.2에서 컴파일 실패
- AdMob Manager 메뉴의 iOS handler가 에디터 열 때마다 GitHub에서 iOS 백엔드
  zip을 자동 다운로드

`addons/admob/internal/exporters/ios/`에는 `.gdignore`를 두어 Godot이 폴더 전체를
스킵하도록 했습니다. 향후 Godot 4.3+로 업그레이드하거나 iOS 빌드를 시작하면
원본을 복구해야 합니다.

### 의존성
플러그인이 자동으로 declare하는 Maven 의존성: `com.google.android.gms:play-services-ads:24.9.0`
(`addons/admob/android/bin/ads/poing_godot_admob_ads.gd` 참고). Gradle이 처음
빌드할 때 다운로드합니다.

### 디버그 / 릴리즈 .aar
`addons/admob/android/bin/ads/libs/` 안에 debug/release 두 쌍이 있습니다
(`poing-godot-admob-ads-*`, `poing-godot-admob-core-*`). 플러그인이 빌드 변형에 따라
자동 선택합니다.

### Test ad unit
`ca-app-pub-3940256099942544/5224354917` 는 Google이 공식적으로 공개한 rewarded
테스트 단위입니다. 무한 호출 가능, 수익 발생 X, 정책 위반 X. 개발/내부 테스트
단계에서는 반드시 이 ID로 유지하세요. 실제 단위 ID로 셀프 테스트하면 AdMob
계정이 invalid activity로 정지될 수 있습니다.
