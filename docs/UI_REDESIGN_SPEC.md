# UI_REDESIGN_SPEC

`docs/UI_ART_DIRECTION_ROADMAP.md`의 철학을 6개 화면 시안(`docs/stitch_nightseed_survivor_main_menu_redesign/`)에 맞춰 **실행 가능한 명세**로 굳힌 문서. 이 문서는 자산 생성과 코드 리워크의 **단일 진실원(single source of truth)** 으로 동작한다.

- 시안 위치: `docs/stitch_nightseed_survivor_main_menu_redesign/` (6장)
- 아트 톤: **전부 픽셀아트**로 통일 (현재 Kenney Tiny Dungeon 인게임 자산과 일관)
- AI 도구: Google **Nano Banana** (Gemini 2.5 Flash Image)

---

## 1. 그리드 / 해상도 / 안전 영역

| 항목 | 값 |
|---|---|
| 게임 기준 해상도 | 720 × 1280 (세로 9:16) |
| 보조 해상도 | 540 × 960 (저사양 폰) |
| 안전 여백 | 좌우 24px, 상하 32px (노치/하단바 회피) |
| 그리드 단위 | 8px (모든 패딩/간격은 8의 배수) |
| 픽셀아트 스케일 | 원본 32×32 → 화면에 4× nearest-neighbor 확대 표시 |
| 폰 크기 권장 | 본문 26~30px, 큰 CTA 36~44px, 타이틀 56~72px |

> 모든 신규 PNG는 **원본 픽셀 해상도**로 저장하고, Godot import에서 filter=Nearest로 설정한다. 자산 파일은 절대 미리 확대해 저장하지 않는다.

---

## 2. 통합 색 팔레트 (확정)

`UI_ART_DIRECTION_ROADMAP.md §2.3`의 안을 시안에서 추출한 색과 교차 검증해 확정. 모든 신규 자산/스타일박스는 **이 표 안에서만** 색을 고른다.

| 토큰 | HEX | RGBA | 용도 |
|---|---|---|---|
| `BG_NIGHT_DEEP`     | `#0B0E17` | (11,14,23)    | 메인 배경 (별/달밤) |
| `BG_FOREST_DEEP`    | `#08140F` | (8,20,15)     | 인게임 풀밭 톤 (대체 배경) |
| `PANEL_STONE`       | `#141923` | (20,25,35)    | 1차 패널 (버튼 본체, 카드 본체) |
| `PANEL_STONE_DEEP`  | `#0E1018` | (14,16,24)    | 2차 패널 (보조 버튼, 리스트 행) |
| `BORDER_MOON_SOFT`  | `#8EA8C8` | (142,168,200) | 흐린 달빛 테두리 (1차) |
| `BORDER_MOON_DIM`   | `#5B6270` | (91,98,112)   | 비활성/2차 테두리 |
| `CTA_MOON`          | `#DDEBFF` | (221,235,255) | 가장 강한 액션 (PLAY) — 텍스트는 짙은 남색 |
| `CTA_MOON_TEXT`     | `#0B1426` | (11,20,38)    | Moon CTA 위 텍스트 |
| `CTA_AMBER`         | `#E89A3D` | (232,154,61)  | 보상/구매 CTA (BUY, Try Again, Start Game) |
| `CTA_AMBER_HI`      | `#F4C46A` | (244,196,106) | Amber CTA 상단 하이라이트 |
| `MEMORY_GOLD`       | `#F2C66A` | (242,198,106) | 골드/해금/타이틀 강조 |
| `DANGER_RED`        | `#D94A5A` | (217,74,90)   | 보스/위험/패배 |
| `DANGER_MAGENTA`    | `#C45CFF` | (196,92,255)  | 마법/특수 효과 |
| `RARITY_COMMON`     | `#7CB8FF` | (124,184,255) | 일반 등급 (파랑) |
| `RARITY_UNCOMMON`   | `#5DE39B` | (93,227,155)  | 고급 등급 (녹색) |
| `RARITY_EPIC`       | `#C45CFF` | (196,92,255)  | 영웅 등급 (보라) |
| `RARITY_LEGEND`     | `#F2C66A` | (242,198,106) | 전설 등급 (금) |
| `TEXT_PRIMARY`      | `#E8EEFA` | (232,238,250) | 본문 (살짝 푸른 흰색) |
| `TEXT_DIM`          | `#9AA3B5` | (154,163,181) | 보조 텍스트 (설명, 라벨) |
| `TEXT_GOLD`         | `#F2C66A` | (242,198,106) | 수치 강조 (시간, 킬 수, 골드량) |

**ButtonStyles.gd 매핑** (이미 정의된 상수 → 위 토큰):

| ButtonStyles 상수 | 스펙 토큰 |
|---|---|
| `MOON_PRIMARY`     | `CTA_MOON` |
| `MOON_TEXT`        | `CTA_MOON_TEXT` |
| `MOON_BORDER`      | `BORDER_MOON_SOFT` |
| `STONE_PRIMARY`    | `PANEL_STONE` |
| `STONE_SECONDARY`  | `PANEL_STONE_DEEP` |
| `STONE_BORDER`     | `BORDER_MOON_DIM` |
| `STONE_TEXT`       | `TEXT_PRIMARY` |
| `PLAY` (legacy)    | `CTA_AMBER` (점진적 교체) |

---

## 3. 형태 언어

### 3.1. 모서리 / 테두리
- 모서리 반경: **5~8px** 사이만 사용 (현재 `_moon_box`=6, `_stone_box`=4~5)
- 테두리 두께: **2~4px**, 1차 액션은 두껍게 (3~4), 2차는 얇게 (2)
- 1차 액션은 **상단 보더만 굵게** (룬 라인 효과) — 이미 `_stone_box`에서 `border_width_top=3` 적용 중

### 3.2. 그림자 / 글로우
- 일반 패널은 그림자 없음
- Moon CTA는 외부 글로우 8px, 알파 0.18 (`_moon_box` 현행)
- 레벨업 카드는 **카드별 등급색 외부 글로우** (RARITY_* 색, 알파 0.35)

### 3.3. 9-slice 규칙
모든 패널/카드 텍스처는 다음 규격으로 제작·import:

| 자산 종류 | 원본 크기 | 9-slice margin |
|---|---|---|
| 큰 패널 (카드, 통계 박스) | 96×96 | 16 / 16 / 16 / 16 |
| 작은 패널 (버튼) | 64×32 | 12 / 12 / 8 / 8 |
| CTA 버튼 | 96×40 | 20 / 20 / 10 / 10 |

---

## 4. 타이포

- 본문 폰트: **Pretendard** (이미 프로젝트 사용 중, SIL OFL)
- 게임 타이틀/STAGE CLEAR 등 장식 텍스트: Pretendard ExtraBold + `MEMORY_GOLD` + 1px 외곽선 `BG_NIGHT_DEEP`
- AI 생성 자산에는 **글자를 절대 포함하지 않는다** (글자는 Godot Label로 합성, 다국어 대응)

| 위계 | 크기 | 색 | 굵기 |
|---|---|---|---|
| H1 (게임 타이틀) | 72px | `MEMORY_GOLD` | ExtraBold |
| H2 (화면 제목) | 48px | `TEXT_PRIMARY` | Bold |
| H3 (섹션) | 32px | `TEXT_PRIMARY` | Bold |
| Body | 26~28px | `TEXT_PRIMARY` | Regular |
| Caption | 20px | `TEXT_DIM` | Regular |
| Number (수치) | 32~44px | `TEXT_GOLD` | Bold (등폭) |

---

## 5. 컴포넌트 카탈로그

이 카탈로그가 6개 화면을 구성하는 **레고 블록**이다. 자산은 이 단위로 생성한다.

### 5.1. Backgrounds
| ID | 파일 | 용도 | 화면 |
|---|---|---|---|
| BG-01 | `bg_menu_night_sky.png` | 별 + 보라/남색 그라디언트, 중앙 비움 | MainMenu, CharacterSelect, Shop, Results |
| BG-02 | `bg_battle_floor.png` | 어두운 풀밭 타일 (현재 `ground_tile_*` 재활용 가능) | BattleHUD, LevelUp |
| BG-03 | `bg_logo_glow_ornament.png` (선택) | 타이틀 뒷배경 발광 장식 | MainMenu |

### 5.2. Panels / Frames (9-slice)
| ID | 파일 | 용도 |
|---|---|---|
| PN-01 | `panel_stone_blue.9.png` | 일반 패널 — 메뉴 버튼, 리스트 행, 통계 박스 |
| PN-02 | `panel_card_dark.9.png` | 레벨업 카드 본체 |
| PN-03 | `panel_cta_amber.9.png` | Start Game / BUY / Try Again 등 호박색 CTA |
| PN-04 | `panel_cta_moon.9.png` (선택) | Moon CTA (현재는 코드 StyleBox로 충분) |
| PN-05 | `frame_card_glow_blue.9.png` | 카드 외곽 발광 (RARITY_COMMON) |
| PN-06 | `frame_card_glow_green.9.png` | RARITY_UNCOMMON |
| PN-07 | `frame_card_glow_purple.9.png` | RARITY_EPIC |
| PN-08 | `frame_card_glow_gold.9.png` | RARITY_LEGEND |
| PN-09 | `banner_stage_clear.png` | 결과 화면 상단 트로피 배너 (장식) |

### 5.3. Icons — Top Bar (24×24)
| ID | 파일 | 용도 |
|---|---|---|
| IC-TOP-01 | `icon_gold_coin.png` | 골드 화폐 (이미 `pickup_gold.png` 존재 — 검토 후 재활용 또는 신규) |
| IC-TOP-02 | `icon_settings_gear.png` | 설정 톱니바퀴 |
| IC-TOP-03 | `icon_close_x.png` | 패널 닫기 |

### 5.4. Icons — Main Menu Navigation (48×48)
| ID | 파일 | 용도 |
|---|---|---|
| IC-NAV-01 | `icon_nav_heroes.png` | 캐릭터 선택 (영웅 흉상) |
| IC-NAV-02 | `icon_nav_stages.png` | 스테이지 (지도/탑) |
| IC-NAV-03 | `icon_nav_difficulty.png` | 난이도 (해골) |
| IC-NAV-04 | `icon_nav_shop.png` | 상점 (가방/카트) |
| IC-NAV-05 | `icon_nav_story.png` | 스토리 (양피지 두루마리) |
| IC-NAV-06 | `icon_nav_leaderboard.png` | 리더보드 (트로피) |

### 5.5. Icons — HUD (32×32)
| ID | 파일 | 용도 |
|---|---|---|
| IC-HUD-01 | `icon_hud_timer.png` | 시계 |
| IC-HUD-02 | `icon_hud_kills.png` | 적 처치 (해골) |
| IC-HUD-03 | `icon_hud_joystick_base.png` | 가상 조이스틱 베이스 |
| IC-HUD-04 | `icon_hud_joystick_thumb.png` | 조이스틱 엄지 |
| IC-HUD-05 | `icon_hud_skill_button.png` | 우하단 메인 스킬 버튼 |

> 좌측 스킬 슬롯 아이콘은 **기존 무기 아이콘 재사용**: `icon_moon_dagger`, `icon_spirit_orb`, `icon_fire_wisp`, `icon_thorn_ring`, `icon_star_needle`.

### 5.6. Icons — Permanent Upgrades Shop (48×48)
> 기존 `shop_*` 5개 검수 후 부족분만 신규 생성. 6번째 "Warrior's Might"는 신규 필요 가능성 있음.

| ID | 파일 | 기존? |
|---|---|---|
| IC-SHOP-01 | `shop_swift.png` (Swift Boots) | 있음 |
| IC-SHOP-02 | `shop_heart.png` (Iron Heart) | 있음 |
| IC-SHOP-03 | `shop_focus.png` (Battle Focus) | 있음 |
| IC-SHOP-04 | `shop_magnet.png` (Magnet Amulet) | 있음 |
| IC-SHOP-05 | `shop_power.png` (Wealth Seeker 또는 Warrior's Might) | 있음 — 매핑 확인 필요 |
| IC-SHOP-06 | `shop_warriors_might.png` (Warrior's Might) | 신규 가능성 |

### 5.7. Icons — Results Rewards (48×48)
| ID | 파일 |
|---|---|
| IC-REW-01 | `icon_reward_chest_closed.png` |
| IC-REW-02 | `icon_reward_chest_open.png` |
| IC-REW-03 | `icon_reward_sword.png` |
| IC-REW-04 | `icon_reward_potion.png` |
| IC-REW-05 | `icon_reward_magic_tome.png` |
| IC-REW-06 | `icon_reward_coins.png` |

### 5.8. Logo
| ID | 파일 | 용도 |
|---|---|---|
| LG-01 | `logo_nightseed_survivor.png` | 메인 메뉴 타이틀 영역 (장식만, 글자는 Label로) |

---

## 6. 화면별 컴포넌트 분해

각 화면의 요소를 위 카탈로그 ID로만 표현. 이 표가 P3/P4 코드 작업의 입력값.

### 6.1. Main Menu
```
BG-01 (배경)
├ Top bar
│  ├ Label "Gold: 2521" + IC-TOP-01
│  └ IconButton IC-TOP-02 (settings)
├ LG-01 (로고 장식) + Label "Nightseed Survivor" (H1, MEMORY_GOLD)
├ PN-03 + Label "Start Game" + IC-NAV-? (큰 CTA)
└ Grid 2×3 of PN-01 buttons:
   PN-01 + IC-NAV-01 + "Heroes"
   PN-01 + IC-NAV-02 + "Stages"
   PN-01 + IC-NAV-03 + "Difficulty"
   PN-01 + IC-NAV-04 + "Shop"
   PN-01 + IC-NAV-05 + "Story"
   PN-01 + IC-NAV-06 + "Leaderboard"
```

### 6.2. Character Selection
```
BG-01
├ H2 "Nightseed Survivor / Character Selection"
├ Gold pill (top): IC-TOP-01 + "Gold: 2521"
└ 세로 리스트 (각 행: PN-01 + 캐릭터 portrait 64×64 + 이름/클래스/스탯)
   - 선택된 행은 FR-? frame 글로우 + "선택됨" 배지
   - 미해금 행은 PN-01 + 자물쇠 overlay + 호박색 "200 골드" pill
└ 하단 PN-04(또는 Moon StyleBox) "메뉴로 돌아가기"
```

### 6.3. Battle HUD (인게임)
```
BG-02 (실제 게임 월드)
├ Top bar (PN-01 둥근 알약):
│  IC-HUD-01 "08:24" | IC-HUD-02 "2,451"
├ Left skill column (5 슬롯):
│  PN-01 작은 정사각형 + 기존 무기 아이콘
├ HP/MP 바: 좌측 세로 + 플레이어 위
├ Bottom-left: IC-HUD-03 + IC-HUD-04 (조이스틱)
└ Bottom-right: IC-HUD-05 (대형 스킬)
```

### 6.4. Level Up
```
BG-02 (반투명 어둠 overlay 0.6)
├ H2 "- LEVEL UP! -" (TEXT_PRIMARY)
└ 3 카드 (세로):
   PN-02 + FR-05/06/07/08 (등급별 글로우)
   ├ 아이콘 (기존 무기/패시브 아이콘 64×64)
   ├ Korean name (H3) + sub 효과 (Body)
   └ PN-03 "선택" 작은 CTA
```

### 6.5. Permanent Upgrades Shop
```
BG-01
├ H2 "Nightseed Survivor / Permanent Upgrades Shop"
├ Gold pill (top): IC-TOP-01 + "Gold: 2521"
└ 세로 리스트 6행:
   PN-01 + IC-SHOP-01~06 + 이름/Lv x/y/설명 + PN-03 "BUY XXXG"
└ 하단 PN-01 (stone secondary) "Back to Menu"
```

### 6.6. Game Results & Rewards
```
BG-01
├ PN-09 banner_stage_clear (이미지) + Label "STAGE CLEAR" (H1, MEMORY_GOLD)
├ PN-01 통계 박스 (4행):
│  IC-HUD-01 "Time Survived: 12:45"
│  IC-HUD-02 "Kills: 256"
│  IC-NAV-03(또는 별도) "Level Reached: 10"
│  IC-TOP-01 "Gold Earned: 500"
├ Section "REWARDS FOUND" (H3, MEMORY_GOLD)
│  ├ Row of 3: IC-REW-01 또는 IC-REW-02 (체스트)
│  └ Row of 4: IC-REW-03~06 (작은 아이템 아이콘)
└ Bottom row:
   PN-01 "Main Menu" (좌, 보조) | PN-03 "Try Again" (우, 강조)
```

---

## 7. 자산 생성 / 임포트 규칙

### 7.1. Nano Banana 공통 프롬프트 베이스
모든 픽셀아트 자산 생성시 다음을 **공통 접미사**로 붙인다:

```
pixel art style, crisp pixel edges, no anti-aliasing, no text, no border frame,
transparent background, dark fantasy mobile game UI, moonlit color palette
(deep navy #0B0E17, pale moonlight #DDEBFF, ember gold #F2C66A),
Kenney Tiny Dungeon aesthetic, flat front view, centered subject
```

> 단위 자산별 본문 프롬프트는 P1 (`docs/ASSETS_TO_GENERATE.md`)에서 자산마다 1줄씩 정리한다.

### 7.2. Godot Import 설정
```
Texture
  filter = Nearest
  mipmaps = Off
  fix_alpha_border = On (투명 PNG)
9-slice 자산: Region 모드는 사용하지 않고 StyleBoxTexture로 margin 지정
```

### 7.3. 파일 배치
```
godot/assets/sprites/
├ ui/
│  ├ bg/        ← BG-01~03
│  ├ panel/     ← PN-01~09
│  ├ icon_nav/  ← IC-NAV-01~06
│  ├ icon_hud/  ← IC-HUD-01~05
│  ├ icon_top/  ← IC-TOP-01~03
│  └ icon_reward/ ← IC-REW-01~06
└ logo/
   └ logo_nightseed_survivor.png
```

`shop_*`, `icon_*무기*`, `char_*`는 기존 위치(`sprites/`) 유지.

---

## 8. 검증 기준 (Definition of Done — 화면별)

각 화면을 "완성"으로 판단하는 공통 체크리스트:

- [ ] 720×1280 / 540×960 두 해상도에서 텍스트가 버튼 밖으로 넘치지 않음
- [ ] 다국어 (`ko-KR`, `en-US`) 양쪽에서 레이아웃 안정
- [ ] 색 토큰만 사용 (하드코딩 hex 금지)
- [ ] 자산 PNG는 `nearest` 필터, 미리 확대본 저장 금지
- [ ] 텍스트는 Label/Button 노드로만 렌더 (이미지 안에 글자 없음)
- [ ] `godot --headless --path godot --quit` 에서 씬 로드 에러 없음
- [ ] HUD/메인 메뉴는 실기 빌드 1회 이상 확인 (불가하면 다음 세션 검증 항목으로 명시)

---

## 9. 다음 단계

1. **P1**: `docs/ASSETS_TO_GENERATE.md` — 위 카탈로그 ID 별로 Nano Banana 프롬프트 1줄씩, 우선순위(P0/P1/P2), 픽셀 사이즈 표 작성
2. **P2**: 너가 Nano Banana로 P0 우선순위만 생성 → 클로가 검수
3. **P3**: `ButtonStyles.gd` 확장 + `MainMenu.tscn` 리워크
4. **P4**: 화면별 순차 적용 (LevelUp → Results → CharSelect → Shop → BattleHUD)
5. **P5**: 폴리시 (트랜지션/사운드/터치 피드백)

각 단계는 별도 PR로 분리. 자산이 마음에 안 들면 그 단계만 롤백.
