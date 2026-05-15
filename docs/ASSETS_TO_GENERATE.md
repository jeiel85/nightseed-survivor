# ASSETS_TO_GENERATE

`docs/UI_REDESIGN_SPEC.md` §5 컴포넌트 카탈로그를 **Nano Banana로 바로 생성할 수 있는 프롬프트 표**로 풀어놓은 문서. 사용자가 한 줄씩 복사해 Gemini 2.5 Flash Image에 던지면 된다.

`docs/ASSET_GUIDE.md`는 MVP placeholder(도형) 정책이고, 이 문서는 시안 기반 신규 UI 자산 생성용 — 별개 문서다.

---

## 사용법

1. 각 행의 **"Prompt 본문"** 을 복사
2. 뒤에 **§ "공통 접미사"** 를 그대로 붙임 (반드시)
3. Nano Banana에 입력 → 1장 생성 → 마음에 들 때까지 시드 변경하며 재생성
4. 결과를 **"파일 경로"** 그대로 저장 (확장자 .png, 투명 배경)
5. 같은 카테고리 안 여러 자산은 같은 세션에서 연속 생성 → 톤 일관성 유지

## 우선순위

- **P0** = 메인 메뉴 1차 리워크에 즉시 필요 (Phase 3 진입 차단)
- **P1** = 메인 메뉴 다음 화면들에 필요 (Phase 4 첫 두 화면)
- **P2** = 폴리시 / 선택 사항

---

## 공통 접미사 (모든 프롬프트 끝에 붙임)

```
pixel art style, crisp pixel edges, no anti-aliasing, no text, no letters,
no border frame, transparent background, dark fantasy mobile game UI,
moonlit color palette (deep navy #0B0E17, pale moonlight #DDEBFF,
ember gold #F2C66A), Kenney Tiny Dungeon aesthetic, flat front view,
centered subject, single subject only
```

> Nano Banana는 같은 채팅 세션 안에서 톤을 잘 유지한다. **같은 카테고리는 한 세션에서 연속 생성** 권장.

---

## 1. 배경 (Backgrounds)

| ID | 우선 | 파일 경로 | 원본 크기 | Prompt 본문 |
|---|---|---|---|---|
| BG-01 | **P0** | `godot/assets/sprites/ui/bg/bg_menu_night_sky.png` | 720×1280 | `vertical 9:16 mobile game background, night sky over distant haunted forest silhouette at the bottom edge, deep indigo to violet gradient from top to bottom, scattered tiny stars and faint nebula dust, faint pale moon top-right, center area kept relatively empty for UI overlay, no characters, no buildings, no creatures` |
| BG-02 | P1 | `godot/assets/sprites/ui/bg/bg_battle_floor.png` | 256×256 (tile) | `seamless tileable dark fantasy floor texture, mossy cracked stone ground at night, deep teal-green and navy palette, subtle dirt patches, no plants, no objects, viewed straight from above, tileable on all four sides` |
| BG-03 | P2 | `godot/assets/sprites/ui/bg/bg_logo_glow_ornament.png` | 512×256 | `decorative horizontal banner ornament for game logo background, two thin ornate silver vines curving outward from center, pale moonlight glow behind, ember gold sparkles, transparent background, suitable as backdrop for centered logo text` |

---

## 2. Panels / Frames (9-slice)

> **중요**: 9-slice용 자산은 가운데가 **타일링 가능한 단순 패턴**이어야 한다. 모서리 장식은 코너에만 두고, 중앙 16×16은 거의 균일한 텍스처여야 늘려도 자연스럽다.

| ID | 우선 | 파일 경로 | 원본 크기 | Prompt 본문 |
|---|---|---|---|---|
| PN-01 | **P0** | `godot/assets/sprites/ui/panel/panel_stone_blue.9.png` | 96×96 | `9-slice UI panel texture for mobile game button, dark navy blue stone slab #141923, thin pale moonlight border 2px #8EA8C8, four tiny rune dots only in the four corners, center region is plain smooth dark navy suitable for tiling, slight inner shadow at top edge, no character, no icon, square frame, viewed straight on` |
| PN-02 | P1 | `godot/assets/sprites/ui/panel/panel_card_dark.9.png` | 128×160 | `vertical 9-slice card panel for level-up reward, dark navy blue stone tablet #141923, thin pale silver border 2px, small crack details only at the very top and very bottom edges, center is plain dark stone suitable for icon and text overlay, rounded corners 6px, no icon inside, no text` |
| PN-03 | **P0** | `godot/assets/sprites/ui/panel/panel_cta_amber.9.png` | 192×64 | `9-slice CTA button panel, warm amber gold #E89A3D rectangular plate with brighter highlight strip #F4C46A along the top 6 pixels, thin dark navy outline 2px, slight inner shadow at bottom, rounded corners 5px, center region is plain amber gradient suitable for text overlay, no text, no icon` |
| PN-05 | P1 | `godot/assets/sprites/ui/panel/frame_card_glow_blue.9.png` | 144×176 | `transparent 9-slice card glow frame, bright cyan-blue neon outline #7CB8FF with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it` |
| PN-06 | P1 | `godot/assets/sprites/ui/panel/frame_card_glow_green.9.png` | 144×176 | `transparent 9-slice card glow frame, bright lime green neon outline #5DE39B with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it` |
| PN-07 | P1 | `godot/assets/sprites/ui/panel/frame_card_glow_purple.9.png` | 144×176 | `transparent 9-slice card glow frame, bright magenta-purple neon outline #C45CFF with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it` |
| PN-08 | P2 | `godot/assets/sprites/ui/panel/frame_card_glow_gold.9.png` | 144×176 | `transparent 9-slice card glow frame, warm ember gold neon outline #F2C66A with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners` |
| PN-09 | P1 | `godot/assets/sprites/ui/panel/banner_stage_clear.png` | 480×120 | `ornate horizontal trophy banner for game victory header, dark navy blue scroll plate with thin silver border and small golden trophy emblem in each top corner, decorative vines curving up at both ends, ember gold accents, center region is plain dark navy ready for text overlay on top, transparent background outside the banner shape` |

---

## 3. Icons — Top Bar (24×24)

| ID | 우선 | 파일 경로 | Prompt 본문 |
|---|---|---|---|
| IC-TOP-01 | **P0** | `godot/assets/sprites/ui/icon_top/icon_gold_coin.png` | `single round gold coin viewed from front, ember gold #F2C66A with brighter highlight on top-left, darker rim, tiny star symbol stamped in the center, no text, no numbers` |
| IC-TOP-02 | **P0** | `godot/assets/sprites/ui/icon_top/icon_settings_gear.png` | `single settings gear cog wheel, six teeth, pale moonlight silver #8EA8C8 with darker hollow center, no text, no numbers` |
| IC-TOP-03 | P2 | `godot/assets/sprites/ui/icon_top/icon_close_x.png` | `simple bold X close mark, two crossed pale silver strokes, slight ember gold edge, no border, no circle, no text` |

---

## 4. Icons — Main Menu Navigation (48×48)

> 6개 모두 P0. **같은 Nano Banana 세션 안에서 연속 생성**해서 톤이 흩어지지 않게 한다.

| ID | 우선 | 파일 경로 | Prompt 본문 |
|---|---|---|---|
| IC-NAV-01 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_heroes.png` | `small pixel art bust silhouette of a hooded fantasy warrior facing forward, deep navy body with pale moonlight rim light on the hood edge, tiny ember gold pin on the chest, no weapon` |
| IC-NAV-02 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_stages.png` | `small pixel art stone watchtower on a tiny hill, dark navy stone with pale silver moonlight on one side, single tiny window glowing ember gold, no flag, no people` |
| IC-NAV-03 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_difficulty.png` | `small pixel art skull facing forward, pale bone color with deep navy eye sockets glowing faint magenta inside, slight ember gold crack on the forehead, no jaw bones below` |
| IC-NAV-04 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_shop.png` | `small pixel art leather merchant pouch with drawstring top, deep brown body with pale silver string, ember gold coin half visible spilling out at the bottom, no text` |
| IC-NAV-05 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_story.png` | `small pixel art rolled parchment scroll tied with a thin silver ribbon, pale beige paper with ember gold seal wax in the middle, slightly aged edges, no visible writing` |
| IC-NAV-06 | **P0** | `godot/assets/sprites/ui/icon_nav/icon_nav_leaderboard.png` | `small pixel art two-handled trophy cup, ember gold body with darker base, pale moonlight highlight on the left rim, tiny star symbol embossed in the center, no text, no numbers` |

---

## 5. Icons — HUD (32×32)

| ID | 우선 | 파일 경로 | Prompt 본문 |
|---|---|---|---|
| IC-HUD-01 | P1 | `godot/assets/sprites/ui/icon_hud/icon_hud_timer.png` | `small pixel art round analog clock, dark navy frame with pale moonlight face, two thin silver hands pointing roughly up and right, no numbers on the face` |
| IC-HUD-02 | P1 | `godot/assets/sprites/ui/icon_hud/icon_hud_kills.png` | `small pixel art tiny skull with crossed shape behind, pale bone color, deep navy eye sockets, ember gold tint on top of the skull, no jaw teeth visible` |
| IC-HUD-03 | P1 | `godot/assets/sprites/ui/icon_hud/icon_hud_joystick_base.png` | `circular virtual joystick base ring viewed from above, thin pale cyan-blue outline #7CB8FF with soft outer glow, fully transparent inside the ring, no thumb stick on top, just the empty base circle` |
| IC-HUD-04 | P1 | `godot/assets/sprites/ui/icon_hud/icon_hud_joystick_thumb.png` | `solid round virtual joystick thumb knob viewed from above, pale moonlight silver #DDEBFF with subtle cyan rim, slight inner gradient brighter at top-left, no shadow underneath` |
| IC-HUD-05 | P1 | `godot/assets/sprites/ui/icon_hud/icon_hud_skill_button.png` | `large circular skill button base, deep navy stone disc with bright cyan-blue glowing outline #7CB8FF, slight inner shadow, small star spark glint in the center, ready to overlay a skill icon on top` |

---

## 6. Icons — Permanent Upgrades Shop (48×48)

> **먼저 기존 `shop_*.png` 5개를 검수**하고 톤이 맞으면 그대로 사용. 신규 필요 시에만 아래 프롬프트 사용.

| ID | 우선 | 파일 경로 | 비고 / Prompt (필요시) |
|---|---|---|---|
| IC-SHOP-01 | P2 | `godot/assets/sprites/shop_swift.png` | 기존 — 검수만 |
| IC-SHOP-02 | P2 | `godot/assets/sprites/shop_heart.png` | 기존 — 검수만 |
| IC-SHOP-03 | P2 | `godot/assets/sprites/shop_focus.png` | 기존 — 검수만 |
| IC-SHOP-04 | P2 | `godot/assets/sprites/shop_magnet.png` | 기존 — 검수만 |
| IC-SHOP-05 | P2 | `godot/assets/sprites/shop_power.png` | 기존 — 검수만 (Wealth/Might 매핑 확인) |
| IC-SHOP-06 | P1 | `godot/assets/sprites/shop_warriors_might.png` | (필요시) `small pixel art crossed sword and axe head emblem on a dark stone medallion, ember gold weapon edges with pale silver center jewel, no text` |

---

## 7. Icons — Results Rewards (48×48)

| ID | 우선 | 파일 경로 | Prompt 본문 |
|---|---|---|---|
| IC-REW-01 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_chest_closed.png` | `small pixel art closed treasure chest viewed from front-three-quarter angle, dark brown wood with ember gold metal bands and a single round gold lock in the middle, slight moonlight highlight on the lid top` |
| IC-REW-02 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_chest_open.png` | `small pixel art open treasure chest viewed from front-three-quarter angle, dark brown wood with ember gold metal bands, lid tilted back, soft ember gold glow rising from inside the chest, no coins or items visible above the rim` |
| IC-REW-03 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_sword.png` | `small pixel art shortsword pointing diagonally up-right, pale silver blade with pale moonlight rim, dark brown wrapped grip, tiny ember gold pommel jewel, no scabbard` |
| IC-REW-04 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_potion.png` | `small pixel art round-bottomed potion flask, cork stopper on top, glass filled with bright cyan-blue liquid #7CB8FF with a brighter highlight bubble, dark navy outline, no label` |
| IC-REW-05 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_magic_tome.png` | `small pixel art closed spellbook tilted slightly, deep navy leather cover with ember gold corner clasps and a single round gold rune symbol stamped in the center, no text` |
| IC-REW-06 | P1 | `godot/assets/sprites/ui/icon_reward/icon_reward_coins.png` | `small pixel art pile of three gold coins stacked at varying angles, ember gold with darker rim, pale highlight on the top coin edge, no text, no numbers` |

---

## 8. Logo

| ID | 우선 | 파일 경로 | 원본 크기 | Prompt 본문 |
|---|---|---|---|---|
| LG-01 | P1 | `godot/assets/logo/logo_nightseed_survivor.png` | 600×240 | `horizontal decorative emblem behind a game title, two ornate dark silver vines arching upward from the center with small ember gold leaves, faint pale moonlight halo behind the center, transparent background outside the emblem shape, no text, no letters, suitable as backdrop for centered title text overlay` |

> 글자는 Godot Label로 합성. 이 자산은 **장식 프레임**만 만든다.

---

## 9. P0 묶음 (메인 메뉴 1차 리워크에 필요한 최소 세트)

다음 **10개**만 먼저 만들면 P3 (메인 메뉴 코드) 시작 가능:

| ID | 파일 |
|---|---|
| BG-01 | `bg_menu_night_sky.png` |
| PN-01 | `panel_stone_blue.9.png` |
| PN-03 | `panel_cta_amber.9.png` |
| IC-TOP-01 | `icon_gold_coin.png` |
| IC-TOP-02 | `icon_settings_gear.png` |
| IC-NAV-01~06 | (메뉴 네비 아이콘 6개) |

생성 순서 권장:
1. BG-01 먼저 (전체 톤 기준점)
2. PN-01, PN-03 (패널 톤)
3. IC-TOP-01, IC-TOP-02 (작은 디테일 톤 맞추기)
4. IC-NAV-01~06 한 세션에서 연속 (가장 톤이 중요한 그룹)

---

## 10. 생성 후 체크리스트 (자산 1개당)

- [ ] 글자/숫자 없는지 확인 (있으면 재생성)
- [ ] 배경 투명 (체크무늬 보이는지) — 안 그러면 [remove.bg](https://remove.bg) 같은 도구로 알파 처리
- [ ] 위 §1 표의 정확한 픽셀 크기로 resize (PixelPerfect 또는 nearest 모드)
- [ ] 파일 경로대로 저장
- [ ] Godot에서 import 후 filter=Nearest 확인
- [ ] 다른 자산 옆에 놓고 톤 일관성 시각 확인

톤이 1개라도 튀면 그 자산만 재생성. 다 끝나면 P2 단계로 클로한테 검수 요청.

---

## 11. 라이선스

- Nano Banana / Gemini 생성 이미지의 상용 사용 정책 확인 후 사용
- 사용한 정확한 프롬프트는 이 파일에 그대로 남아 있으므로 추후 추적 가능
- 생성 이미지 사용 사실은 `HISTORY.md`의 해당 릴리즈 노트에 한 줄로 기록 (예: `UI 자산: Nano Banana 생성 (프롬프트는 docs/ASSETS_TO_GENERATE.md)`)
