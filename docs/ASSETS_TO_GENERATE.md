# ASSETS_TO_GENERATE

`docs/UI_REDESIGN_SPEC.md` §5 컴포넌트 카탈로그를 **ChatGPT(GPT-4o 이미지 생성)로 바로 생성할 수 있는 프롬프트 표**로 풀어놓은 문서. 사용자가 한 줄씩 복사해 ChatGPT에 던지면 된다.

`docs/ASSET_GUIDE.md`는 MVP placeholder(도형) 정책이고, 이 문서는 시안 기반 신규 UI 자산 생성용 — 별개 문서다.

---

## ChatGPT 사용 전략 (중요)

ChatGPT/DALL-E는 **그냥 두면 일러스트풍으로 흘러간다**. 픽셀아트 결과를 안정적으로 받으려면 다음 순서를 지킨다:

### 자동 생성 스크립트

P0 자산을 덮어쓰지 않고, 현재 저장소에 없는 P1/P2 자산만 OpenAI Images API로 생성하려면:

```powershell
python scripts\generate_missing_ui_assets.py --dry-run
python scripts\generate_missing_ui_assets.py
```

- 기본 모델은 `gpt-image-2`이며, 필요 시 `OPENAI_IMAGE_MODEL` 환경 변수로 바꿀 수 있다.
- `OPENAI_API_KEY`는 프로세스 환경 변수 또는 Windows 사용자 환경 변수에서 읽는다.
- 이미 존재하는 파일은 우선순위와 관계없이 건너뛰며, P0 ID는 항상 제외한다.
- 생성 결과는 표의 원본 크기로 nearest-neighbor 리사이즈해 저장한다.

### 0. 세션 첫 메시지 — 톤 앵커링 (반드시)

새 ChatGPT 채팅을 시작하고 **첫 메시지에 참조 이미지 1~2장을 업로드**한다. 추천:

- `godot/assets/sprites/char_vagrant.png` (16×16 캐릭터 스프라이트)
- `godot/assets/sprites/icon_moon_dagger.png` 또는 무기 아이콘 1개
- 또는 `docs/stitch_nightseed_survivor_main_menu_redesign/nightseed_survivor_main_menu_redesign/screen.png` (시안 1장)

첫 메시지 예시:

```
이 이미지들과 동일한 픽셀아트 톤으로 UI 자산을 만들 거야.
- 16x16 또는 32x32 픽셀 기준 픽셀아트
- 안티에일리어싱 없음, 픽셀 가장자리 선명
- Kenney Tiny Dungeon 미학
- 색 팔레트: 짙은 남색 #0B0E17, 창백한 달빛 #DDEBFF, 호박색 #F2C66A
- 항상 단일 피사체, 글자/숫자 없음
- 배경은 가능한 투명 (체크무늬)

이 톤을 기준으로 앞으로 내가 요청하는 자산들을 만들어줘.
첫 번째 요청 보낼게.
```

### 1. 자산별 요청
참조 톤이 잡힌 뒤 한 번에 1개씩 아래 표의 **Prompt 본문**을 보낸다.

### 2. 결과가 마음에 안 들면
같은 채팅 안에서 자연어로 보정: "더 어둡게 / 안티에일리어싱 빼고 / 모서리 더 각지게 / 색을 더 푸르게 / 글자 빼고 다시" 등.

### 3. 같은 시리즈는 같은 채팅에서 연속 생성
특히 **메뉴 네비 아이콘 6개는 한 세션에서 연속**해야 톤이 흩어지지 않는다.

### 4. 후처리 (거의 항상 필요)
- ChatGPT 출력은 보통 1024×1024 또는 1024×1792 정사각/세로 → **picpick / Pixel Perfect / nearest 모드 리사이즈**로 표의 원본 크기로 다운샘플
- 배경이 투명이 아니면 [remove.bg](https://remove.bg) 또는 GIMP/Photopea 알파 처리
- 파일명/경로 정확히 맞춰 저장

---

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
centered subject, single subject only, 32x32 native pixel grid feel,
no painterly shading, no illustration style
```

> 마지막 두 줄(`32x32 native pixel grid feel`, `no painterly shading, no illustration style`)이 ChatGPT가 일러스트로 드리프트하는 걸 막는 핵심이다. **빼지 말 것**.

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

- [ ] **픽셀아트 톤 확인** — 일러스트/그라데이션/안티에일리어싱이 강하면 재생성
- [ ] 글자/숫자 없는지 확인 (있으면 재생성)
- [ ] 배경 투명 (체크무늬 보이는지) — 안 그러면 [remove.bg](https://remove.bg) / Photopea / GIMP 알파 처리
- [ ] **원본 크기로 다운샘플** — ChatGPT는 보통 1024px 출력 → §1~8 표의 정확한 픽셀 크기로 nearest 모드 리사이즈
- [ ] 파일 경로대로 저장
- [ ] Godot에서 import 후 filter=Nearest 확인
- [ ] 다른 자산 옆에 놓고 톤 일관성 시각 확인

톤이 1개라도 튀면 그 자산만 재생성. 다 끝나면 P2 단계로 클로한테 검수 요청.

### ChatGPT가 자주 틀리는 것 (재생성 트리거)
- 글자를 만들어 넣는다 ("Heroes", "Shop" 등) → "글자/숫자 빼고 다시"
- 부드러운 일러스트풍으로 만든다 → "안티에일리어싱 빼고 도트 픽셀로"
- 배경에 잎/별/배경 디테일을 채운다 → "투명 배경, 단일 피사체만"
- 카메라 각도가 비스듬하다 → "정면 평면도, flat front view"

---

## 11. 라이선스

- ChatGPT/OpenAI 생성 이미지의 상용 사용 정책 확인 후 사용 (현재 ChatGPT Plus/Pro 기준 상용 사용 허용 — 정책 변경 가능성 있으니 출시 직전 재확인)
- 사용한 정확한 프롬프트는 이 파일에 그대로 남아 있으므로 추후 추적 가능
- 생성 이미지 사용 사실은 `HISTORY.md`의 해당 릴리즈 노트에 한 줄로 기록 (예: `UI 자산: ChatGPT 생성 (프롬프트는 docs/ASSETS_TO_GENERATE.md)`)
