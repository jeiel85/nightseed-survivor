"""
Regenerate Play Store phone screenshots reflecting v0.12.0 visuals:
- Procedural ground with rocks/torches (new in v0.11)
- New enemy types: dasher, caster, splitter, miniboss
- Korean UI (default locale)
- Polished UI cards
- 5 screenshots @ 1080x1920 portrait
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import random, os, math

ASSETS = r'D:\Project\nightseed-survivor\godot\assets'
OUT = r'D:\Project\nightseed-survivor\play_store'
SP = os.path.join(ASSETS, 'sprites')
FONT_PATH = os.path.join(ASSETS, 'fonts', 'Pretendard-Regular.otf')

W, H = 1080, 1920


def get_font(size, bold=True):
    candidates = [FONT_PATH,
                  r'C:\Windows\Fonts\malgunbd.ttf' if bold else r'C:\Windows\Fonts\malgun.ttf',
                  r'C:\Windows\Fonts\arialbd.ttf' if bold else r'C:\Windows\Fonts\arial.ttf']
    for c in candidates:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
    return ImageFont.load_default()


def make_night_bg(w, h, seed=42, top=(22, 15, 48), bot=(8, 10, 32)):
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(top[0] + (bot[0] - top[0]) * t)
        g = int(top[1] + (bot[1] - top[1]) * t)
        b = int(top[2] + (bot[2] - top[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
    rng = random.Random(seed)
    star_count = (w * h) // 8000
    for _ in range(star_count):
        x = rng.randint(0, w - 1)
        y = rng.randint(0, int(h * 0.7))
        sz = rng.choice([1, 1, 1, 2, 2, 3])
        bri = rng.randint(160, 255)
        a = rng.randint(170, 255)
        draw.rectangle([x, y, x + sz, y + sz], fill=(bri, bri, bri, a))
    return img


def add_ground_tiles(img, seed=999):
    """Simulate the in-game procedural ground: tinted purple sand tiles + pebbles + torches."""
    rng = random.Random(seed)
    tile_size = 64
    tile_path = os.path.join(SP, 'ground_tile.png')
    if not os.path.exists(tile_path):
        return
    tile = Image.open(tile_path).convert('RGBA')
    tint = Image.new('RGBA', (tile_size, tile_size))
    for y in range(0, H, tile_size):
        for x in range(0, W, tile_size):
            scaled = tile.resize((tile_size, tile_size), Image.NEAREST)
            v = rng.random() * 0.45
            mod_r = int(0.42 * 255 * (1 + v))
            mod_g = int(0.36 * 255 * (1 + v))
            mod_b = int(0.55 * 255 * (1 + v))
            r, g, b, a = scaled.split()
            r = r.point(lambda px, m=mod_r: int(px * m / 255))
            g = g.point(lambda px, m=mod_g: int(px * m / 255))
            b = b.point(lambda px, m=mod_b: int(px * m / 255))
            tinted = Image.merge('RGBA', (r, g, b, a))
            img.alpha_composite(tinted, (x, y))
    # Pebbles
    for _ in range(W * H // 80000):
        px = rng.randint(0, W - 1)
        py = rng.randint(0, H - 1)
        r = rng.randint(2, 5)
        t = rng.random()
        col_a = (174, 158, 199, int(140 * t + 30))
        d = ImageDraw.Draw(img)
        d.ellipse([px - r, py - r, px + r, py + r], fill=col_a)


def paste_sprite(bg, sprite_path, cx, cy, scale, glow_color=None, glow_pad=0.18, glow_blur=18):
    sp = Image.open(sprite_path).convert('RGBA')
    src = sp.resize((int(sp.width * scale), int(sp.height * scale)), Image.NEAREST)
    sw, sh = src.size
    px = cx - sw // 2
    py = cy - sh // 2
    if glow_color:
        halo = Image.new('RGBA', bg.size, (0, 0, 0, 0))
        hd = ImageDraw.Draw(halo)
        pad = int(sw * glow_pad)
        hd.ellipse([px - pad, py - pad, px + sw + pad, py + sh + pad], fill=glow_color)
        halo = halo.filter(ImageFilter.GaussianBlur(radius=glow_blur))
        bg.alpha_composite(halo)
    bg.alpha_composite(src, (px, py))


def draw_button(draw, x, y, w, h, label, font, fill=(50, 70, 110, 255), outline=(180, 200, 255, 255), radius=14):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=radius, fill=fill, outline=outline, width=3)
    bbox = draw.textbbox((0, 0), label, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((x + (w - tw) // 2, y + (h - th) // 2 - 4), label, font=font, fill=(255, 255, 255, 255))


def draw_panel(draw, x, y, w, h, fill=(30, 35, 55, 230), outline=(120, 140, 180, 200), radius=18):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=radius, fill=fill, outline=outline, width=2)


def draw_progress_bar(draw, x, y, w, h, frac, fill=(200, 60, 70, 255), bg=(40, 40, 60, 255)):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=h // 3, fill=bg)
    if frac > 0:
        fw = max(int(w * frac), h)
        draw.rounded_rectangle([x, y, x + fw, y + h], radius=h // 3, fill=fill)


def add_moon(img, cx, cy, r, dark_bg):
    glow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([cx - r * 1.6, cy - r * 1.6, cx + r * 1.6, cy + r * 1.6], fill=(255, 240, 210, 60))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=int(r * 0.6)))
    img.alpha_composite(glow)
    d = ImageDraw.Draw(img)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(245, 235, 210, 255))
    cut = int(r * 0.55)
    d.ellipse([cx - r + cut, cy - r - int(r * 0.05), cx + r + cut, cy + r - int(r * 0.05)], fill=dark_bg)


def add_top_hud(img, hp_frac, xp_frac, time_str, level, kills, gold, max_hp=80):
    draw = ImageDraw.Draw(img)
    bar = Image.new('RGBA', (W, 250), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bar)
    bd.rectangle([0, 0, W, 250], fill=(0, 0, 0, 130))
    img.alpha_composite(bar)
    draw_progress_bar(draw, 30, 25, W - 60, 50, hp_frac, fill=(220, 70, 80, 255))
    f = get_font(28)
    label = f"HP  {int(max_hp * hp_frac)} / {max_hp}"
    bbox = draw.textbbox((0, 0), label, font=f)
    tw = bbox[2] - bbox[0]
    draw.text(((W - tw) // 2, 30), label, font=f, fill=(255, 255, 255, 255))
    draw_progress_bar(draw, 30, 88, W - 60, 28, xp_frac, fill=(80, 200, 240, 255))
    sf = get_font(40)
    sf2 = get_font(34)
    draw.text((W // 2 - 70, 145), time_str, font=sf, fill=(255, 255, 255, 255))
    draw.text((50, 152), f"Lv  {level}", font=sf2, fill=(180, 220, 255, 255))
    draw.text((W - 240, 152), f"처치  {kills}", font=sf2, fill=(255, 255, 255, 255))
    draw.text((50, 200), f"골드  {gold}", font=sf2, fill=(255, 220, 120, 255))


def add_joystick(img, cx=200, cy=H - 350, r=130):
    over = Image.new('RGBA', img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(over)
    od.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 30), outline=(255, 255, 255, 140), width=4)
    hr = 50
    od.ellipse([cx + 30 - hr, cy - 20 - hr, cx + 30 + hr, cy - 20 + hr],
               fill=(255, 255, 255, 80), outline=(255, 255, 255, 220), width=3)
    img.alpha_composite(over)


# === 1: Main Menu ===
bg1 = make_night_bg(W, H, seed=11)
add_moon(bg1, cx=W - 130, cy=140, r=85, dark_bg=(15, 12, 38, 255))
draw = ImageDraw.Draw(bg1)
title_font = get_font(120)
sub_font = get_font(40)
btn_font_l = get_font(80)
btn_font = get_font(42)
btn_font_s = get_font(34)
draw.text((W // 2, 280), "NIGHTSEED", font=title_font, fill=(245, 235, 210, 255), anchor="mm")
draw.text((W // 2, 410), "SURVIVOR", font=title_font, fill=(170, 200, 255, 255), anchor="mm")
draw.text((W // 2, 510), "10분 생존 액션", font=sub_font, fill=(200, 210, 230, 255), anchor="mm")
draw.text((W // 2, 600), "골드:  847", font=get_font(54), fill=(255, 220, 120, 255), anchor="mm")
draw.text((W // 2, 670), "방랑자  ·  메아리의 숲  ·  일반", font=get_font(32), fill=(150, 200, 230, 255), anchor="mm")
draw_button(draw, 100, 780, W - 200, 180, "시작", btn_font_l, fill=(60, 90, 160, 255), outline=(160, 200, 255, 255))
draw_button(draw, 100, 1000, W - 200, 110, "캐릭터", btn_font, fill=(40, 50, 80, 255), outline=(120, 150, 200, 255))
draw_button(draw, 100, 1140, W - 200, 110, "스테이지", btn_font, fill=(40, 50, 80, 255), outline=(120, 150, 200, 255))
draw_button(draw, 100, 1280, W - 200, 110, "상점", btn_font, fill=(40, 50, 80, 255), outline=(120, 150, 200, 255))
draw_button(draw, 100, 1420, W - 200, 95, "난이도:  일반", btn_font_s, fill=(50, 70, 50, 255), outline=(140, 200, 140, 255))
draw_button(draw, 100, 1535, W - 200, 95, "★ 순위표", btn_font_s, fill=(40, 50, 80, 255), outline=(120, 150, 200, 255))
draw_button(draw, 100, 1650, W - 200, 80, "Language:  한국어", get_font(28), fill=(35, 40, 55, 255), outline=(100, 110, 140, 255))
draw_button(draw, 100, 1745, W - 200, 75, "크레딧 / 라이선스", get_font(26), fill=(28, 32, 45, 255), outline=(90, 100, 130, 255))
bg1.save(os.path.join(OUT, 'screenshot_1_menu.png'))

# === 2: Gameplay with new enemies ===
bg2 = make_night_bg(W, H, seed=22, top=(15, 18, 35), bot=(10, 12, 25))
add_ground_tiles(bg2, seed=22)
# Player center
paste_sprite(bg2, os.path.join(SP, 'char_vagrant.png'), W // 2, H // 2 + 100, 22,
             glow_color=(120, 180, 240, 130), glow_pad=0.18, glow_blur=40)
# Mix of new enemies
enemies = [
    ('enemy_slime.png', 280, 700, 12, (130, 220, 130, 90)),
    ('enemy_bat.png', 720, 800, 12, (220, 100, 100, 90)),
    ('enemy_dasher.png', 250, 1500, 14, (255, 150, 60, 110)),  # dasher (telegraph color)
    ('enemy_dasher.png', 820, 1450, 13, (255, 150, 60, 110)),
    ('enemy_caster.png', 180, 1100, 13, (220, 130, 240, 110)),  # caster
    ('enemy_splitter.png', 880, 1150, 14, (130, 220, 130, 90)),
    ('enemy_knight.png', 600, 700, 18, (140, 140, 180, 90)),
]
for path, x, y, sc, gl in enemies:
    paste_sprite(bg2, os.path.join(SP, path), x, y, sc, glow_color=gl, glow_pad=0.15, glow_blur=20)
# Caster projectile orbs
for x, y in [(380, 950), (480, 1250)]:
    paste_sprite(bg2, os.path.join(SP, 'proj_orb.png'), x, y, 3, glow_color=(220, 100, 240, 120), glow_pad=0.5, glow_blur=18)
# XP gems + gold scattered
for x, y in [(400, 950), (700, 1050), (300, 1100), (820, 950), (500, 1450)]:
    paste_sprite(bg2, os.path.join(SP, 'pickup_xp.png'), x, y, 4, glow_color=(100, 240, 130, 100), glow_pad=0.4, glow_blur=15)
for x, y in [(550, 1150), (380, 1300), (700, 1300)]:
    paste_sprite(bg2, os.path.join(SP, 'pickup_gold.png'), x, y, 4, glow_color=(255, 220, 120, 110), glow_pad=0.4, glow_blur=15)
# Projectile trails (player's projectiles)
od = ImageDraw.Draw(bg2)
for x1, y1, x2, y2 in [(W // 2, H // 2 + 100, 250, 1500), (W // 2, H // 2 + 100, 820, 800), (W // 2, H // 2 + 100, 600, 700)]:
    od.line([(x1, y1), (x2, y2)], fill=(255, 240, 130, 140), width=7)
# Death burst
rng = random.Random(7)
for _ in range(6):
    px = 280 + rng.randint(-30, 30)
    py = 700 + rng.randint(-30, 30)
    sz = rng.randint(4, 8)
    od.rectangle([px, py, px + sz, py + sz], fill=(130, 220, 130, 200))
add_top_hud(bg2, 0.65, 0.4, "7:32", 11, 124, 37, max_hp=100)
add_joystick(bg2)
bg2.save(os.path.join(OUT, 'screenshot_2_gameplay.png'))

# === 3: Level Up with star evolve + items ===
bg3 = make_night_bg(W, H, seed=33)
od = ImageDraw.Draw(bg3)
od.rectangle([0, 0, W, H], fill=(0, 0, 0, 200))
draw = ImageDraw.Draw(bg3)
draw.text((W // 2, 130), "- 레벨업! -", font=get_font(72), fill=(255, 230, 130, 255), anchor="mm")
card_h = 480
cards = [
    {"title": "★ 진화: 초승달 폭풍", "desc": "3방향 부채꼴 + 보너스 데미지", "icon": 'icon_moon_dagger.png', "header": (130, 200, 255, 255)},
    {"title": "정령의 구  Lv.4", "desc": "데미지 +25% / 쿨다운 -12%", "icon": 'icon_spirit_orb.png', "header": (100, 240, 240, 255)},
    {"title": "자석 부적", "desc": "경험치 수집 범위 +40", "icon": 'shop_magnet.png', "header": (200, 130, 240, 255)},
]
y = 240
for c in cards:
    draw_panel(draw, 80, y, W - 160, card_h - 30, fill=(40, 45, 65, 240), outline=(120, 140, 180, 255))
    draw.rectangle([80, y, W - 80, y + 50], fill=c["header"])
    paste_sprite(bg3, os.path.join(SP, c["icon"]), W // 2, y + 140, 4)
    draw.text((W // 2, y + 240), c["title"], font=get_font(48), fill=(255, 255, 255, 255), anchor="mm")
    draw.text((W // 2, y + 310), c["desc"], font=get_font(34), fill=(220, 230, 255, 255), anchor="mm")
    draw_button(draw, 130, y + 350, W - 260, 95, "선택", get_font(50), fill=(50, 80, 130, 255), outline=(160, 200, 255, 255))
    y += card_h
bg3.save(os.path.join(OUT, 'screenshot_3_levelup.png'))

# === 4: Boss fight (Mini-boss + Pyromancer) ===
bg4 = make_night_bg(W, H, seed=44, top=(40, 10, 50), bot=(15, 5, 25))
add_ground_tiles(bg4, seed=44)
# Aura
halo = Image.new('RGBA', bg4.size, (0, 0, 0, 0))
hd = ImageDraw.Draw(halo)
hd.ellipse([W // 2 - 280, 640, W // 2 + 280, 1200], fill=(170, 80, 230, 90))
halo = halo.filter(ImageFilter.GaussianBlur(radius=60))
bg4.alpha_composite(halo)
# Mini-boss spikes
sx, sy = W // 2, 920
for ang in [0, 90, 180, 270]:
    rad = math.radians(ang)
    p1 = (sx + int(280 * math.cos(rad)), sy + int(280 * math.sin(rad)))
    perp = math.radians(ang + 90)
    p2 = (sx + int(190 * math.cos(rad) + 40 * math.cos(perp)), sy + int(190 * math.sin(rad) + 40 * math.sin(perp)))
    p3 = (sx + int(190 * math.cos(rad) - 40 * math.cos(perp)), sy + int(190 * math.sin(rad) - 40 * math.sin(perp)))
    ImageDraw.Draw(bg4).polygon([p1, p2, p3], fill=(220, 130, 240, 240))
paste_sprite(bg4, os.path.join(SP, 'enemy_miniboss.png'), W // 2, 920, 22)
paste_sprite(bg4, os.path.join(SP, 'char_pyromancer.png'), W // 2, H - 600, 18,
             glow_color=(255, 140, 60, 180), glow_pad=0.2, glow_blur=40)
# Fire wisps
od2 = ImageDraw.Draw(bg4)
rng99 = random.Random(99)
for _ in range(14):
    px = rng99.randint(150, W - 150)
    py = rng99.randint(900, 1500)
    rr = rng99.randint(20, 60)
    od2.ellipse([px - rr, py - rr, px + rr, py + rr], fill=(255, 130, 30, 100), outline=(255, 200, 80, 200), width=3)
# Star Needle volley
for off in [-60, -30, 0, 30, 60]:
    od2.line([(W // 2 + off, H - 700), (W // 2 + off // 4, 1100)], fill=(255, 240, 130, 160), width=6)
add_top_hud(bg4, 0.45, 0.7, "5:42", 18, 287, 92, max_hp=90)
# Mini-boss HP bar
ad = ImageDraw.Draw(bg4)
ad.rounded_rectangle([100, 290, W - 100, 360], radius=20, fill=(40, 10, 30, 230), outline=(220, 100, 200, 255), width=3)
ad.rounded_rectangle([100, 290, W // 2 + 200, 360], radius=20, fill=(220, 60, 100, 255))
ad.text((W // 2, 325), "미니보스  120 / 200", font=get_font(34), fill=(255, 255, 255, 255), anchor="mm")
add_joystick(bg4)
bg4.save(os.path.join(OUT, 'screenshot_4_boss.png'))

# === 5: Victory ===
bg5 = make_night_bg(W, H, seed=55)
od = ImageDraw.Draw(bg5)
od.rectangle([0, 0, W, H], fill=(0, 0, 0, 200))
draw_panel(od, 80, 380, W - 160, 1100, fill=(30, 35, 55, 245), outline=(220, 200, 100, 255))
od.text((W // 2, 480), "승리!", font=get_font(120), fill=(255, 230, 100, 255), anchor="mm")
od.text((W // 2, 660), "생존:  10:00", font=get_font(54), fill=(220, 230, 240, 255), anchor="mm")
od.text((W // 2, 740), "처치:  427", font=get_font(54), fill=(220, 230, 240, 255), anchor="mm")
od.text((W // 2, 820), "획득 골드:  186", font=get_font(54), fill=(255, 220, 120, 255), anchor="mm")
od.text((W // 2, 950), "★ 신규 업적", font=get_font(44), fill=(255, 230, 130, 255), anchor="mm")
od.text((W // 2, 1020), "첫 생존자  (+200 골드)", font=get_font(36), fill=(200, 230, 200, 255), anchor="mm")
od.text((W // 2, 1080), "킬러 본능  (+100 골드)", font=get_font(36), fill=(200, 230, 200, 255), anchor="mm")
od.text((W // 2, 1140), "보스 슬레이어  (+300 골드)", font=get_font(36), fill=(200, 230, 200, 255), anchor="mm")
draw_button(od, 130, 1230, W - 260, 110, "다시 플레이", get_font(48), fill=(60, 100, 60, 255), outline=(140, 200, 140, 255))
draw_button(od, 130, 1360, W - 260, 100, "메인 메뉴", get_font(40), fill=(40, 45, 65, 255), outline=(140, 160, 200, 255))
bg5.save(os.path.join(OUT, 'screenshot_5_victory.png'))

print('5 screenshots saved')
