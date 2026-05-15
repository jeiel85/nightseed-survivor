#!/usr/bin/env python3
"""Generate missing non-P0 UI assets from docs/ASSETS_TO_GENERATE.md.

The script intentionally never overwrites existing files and excludes all P0
assets. It uses the OpenAI Images API, then resizes the returned PNG to the
native project size with nearest-neighbor sampling for pixel-art use.
"""

from __future__ import annotations

import base64
import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path

from PIL import Image


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MODEL = "gpt-image-2"
API_URL = "https://api.openai.com/v1/images/generations"

COMMON_SUFFIX = (
    "pixel art style, crisp pixel edges, no anti-aliasing, no text, no letters, "
    "no border frame, transparent background, dark fantasy mobile game UI, "
    "moonlit color palette (deep navy #0B0E17, pale moonlight #DDEBFF, "
    "ember gold #F2C66A), Kenney Tiny Dungeon aesthetic, flat front view, "
    "centered subject, single subject only, 32x32 native pixel grid feel, "
    "no painterly shading, no illustration style"
)


@dataclass(frozen=True)
class AssetSpec:
    asset_id: str
    priority: str
    path: str
    width: int
    height: int
    prompt: str


ASSETS: tuple[AssetSpec, ...] = (
    AssetSpec("BG-02", "P1", "godot/assets/sprites/ui/bg/bg_battle_floor.png", 256, 256, "seamless tileable dark fantasy floor texture, mossy cracked stone ground at night, deep teal-green and navy palette, subtle dirt patches, no plants, no objects, viewed straight from above, tileable on all four sides"),
    AssetSpec("BG-03", "P2", "godot/assets/sprites/ui/bg/bg_logo_glow_ornament.png", 512, 256, "decorative horizontal banner ornament for game logo background, two thin ornate silver vines curving outward from center, pale moonlight glow behind, ember gold sparkles, transparent background, suitable as backdrop for centered logo text"),
    AssetSpec("PN-02", "P1", "godot/assets/sprites/ui/panel/panel_card_dark.9.png", 128, 160, "vertical 9-slice card panel for level-up reward, dark navy blue stone tablet #141923, thin pale silver border 2px, small crack details only at the very top and very bottom edges, center is plain dark stone suitable for icon and text overlay, rounded corners 6px, no icon inside, no text"),
    AssetSpec("PN-05", "P1", "godot/assets/sprites/ui/panel/frame_card_glow_blue.9.png", 144, 176, "transparent 9-slice card glow frame, bright cyan-blue neon outline #7CB8FF with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it"),
    AssetSpec("PN-06", "P1", "godot/assets/sprites/ui/panel/frame_card_glow_green.9.png", 144, 176, "transparent 9-slice card glow frame, bright lime green neon outline #5DE39B with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it"),
    AssetSpec("PN-07", "P1", "godot/assets/sprites/ui/panel/frame_card_glow_purple.9.png", 144, 176, "transparent 9-slice card glow frame, bright magenta-purple neon outline #C45CFF with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners, suitable to overlay on top of a darker card panel beneath it"),
    AssetSpec("PN-08", "P2", "godot/assets/sprites/ui/panel/frame_card_glow_gold.9.png", 144, 176, "transparent 9-slice card glow frame, warm ember gold neon outline #F2C66A with soft outer glow halo, hollow center fully transparent, thin 3px stroke on the inside edge, rounded corners"),
    AssetSpec("PN-09", "P1", "godot/assets/sprites/ui/panel/banner_stage_clear.png", 480, 120, "ornate horizontal trophy banner for game victory header, dark navy blue scroll plate with thin silver border and small golden trophy emblem in each top corner, decorative vines curving up at both ends, ember gold accents, center region is plain dark navy ready for text overlay on top, transparent background outside the banner shape"),
    AssetSpec("IC-TOP-03", "P2", "godot/assets/sprites/ui/icon_top/icon_close_x.png", 24, 24, "simple bold X close mark, two crossed pale silver strokes, slight ember gold edge, no border, no circle, no text"),
    AssetSpec("IC-HUD-01", "P1", "godot/assets/sprites/ui/icon_hud/icon_hud_timer.png", 32, 32, "small pixel art round analog clock, dark navy frame with pale moonlight face, two thin silver hands pointing roughly up and right, no numbers on the face"),
    AssetSpec("IC-HUD-02", "P1", "godot/assets/sprites/ui/icon_hud/icon_hud_kills.png", 32, 32, "small pixel art tiny skull with crossed shape behind, pale bone color, deep navy eye sockets, ember gold tint on top of the skull, no jaw teeth visible"),
    AssetSpec("IC-HUD-03", "P1", "godot/assets/sprites/ui/icon_hud/icon_hud_joystick_base.png", 32, 32, "circular virtual joystick base ring viewed from above, thin pale cyan-blue outline #7CB8FF with soft outer glow, fully transparent inside the ring, no thumb stick on top, just the empty base circle"),
    AssetSpec("IC-HUD-04", "P1", "godot/assets/sprites/ui/icon_hud/icon_hud_joystick_thumb.png", 32, 32, "solid round virtual joystick thumb knob viewed from above, pale moonlight silver #DDEBFF with subtle cyan rim, slight inner gradient brighter at top-left, no shadow underneath"),
    AssetSpec("IC-HUD-05", "P1", "godot/assets/sprites/ui/icon_hud/icon_hud_skill_button.png", 32, 32, "large circular skill button base, deep navy stone disc with bright cyan-blue glowing outline #7CB8FF, slight inner shadow, small star spark glint in the center, ready to overlay a skill icon on top"),
    AssetSpec("IC-SHOP-06", "P1", "godot/assets/sprites/shop_warriors_might.png", 48, 48, "small pixel art crossed sword and axe head emblem on a dark stone medallion, ember gold weapon edges with pale silver center jewel, no text"),
    AssetSpec("IC-REW-01", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_chest_closed.png", 48, 48, "small pixel art closed treasure chest viewed from front-three-quarter angle, dark brown wood with ember gold metal bands and a single round gold lock in the middle, slight moonlight highlight on the lid top"),
    AssetSpec("IC-REW-02", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_chest_open.png", 48, 48, "small pixel art open treasure chest viewed from front-three-quarter angle, dark brown wood with ember gold metal bands, lid tilted back, soft ember gold glow rising from inside the chest, no coins or items visible above the rim"),
    AssetSpec("IC-REW-03", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_sword.png", 48, 48, "small pixel art shortsword pointing diagonally up-right, pale silver blade with pale moonlight rim, dark brown wrapped grip, tiny ember gold pommel jewel, no scabbard"),
    AssetSpec("IC-REW-04", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_potion.png", 48, 48, "small pixel art round-bottomed potion flask, cork stopper on top, glass filled with bright cyan-blue liquid #7CB8FF with a brighter highlight bubble, dark navy outline, no label"),
    AssetSpec("IC-REW-05", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_magic_tome.png", 48, 48, "small pixel art closed spellbook tilted slightly, deep navy leather cover with ember gold corner clasps and a single round gold rune symbol stamped in the center, no text"),
    AssetSpec("IC-REW-06", "P1", "godot/assets/sprites/ui/icon_reward/icon_reward_coins.png", 48, 48, "small pixel art pile of three gold coins stacked at varying angles, ember gold with darker rim, pale highlight on the top coin edge, no text, no numbers"),
    AssetSpec("LG-01", "P1", "godot/assets/logo/logo_nightseed_survivor.png", 600, 240, "horizontal decorative emblem behind a game title, two ornate dark silver vines arching upward from the center with small ember gold leaves, faint pale moonlight halo behind the center, transparent background outside the emblem shape, no text, no letters, suitable as backdrop for centered title text overlay"),
)

P0_IDS = {
    "BG-01", "PN-01", "PN-03", "IC-TOP-01", "IC-TOP-02",
    "IC-NAV-01", "IC-NAV-02", "IC-NAV-03", "IC-NAV-04", "IC-NAV-05", "IC-NAV-06",
}


def get_api_key() -> str:
    key = os.environ.get("OPENAI_API_KEY")
    if key:
        return key
    if os.name == "nt":
        import subprocess

        result = subprocess.run(
            ["powershell", "-NoProfile", "-Command", "[Environment]::GetEnvironmentVariable('OPENAI_API_KEY','User')"],
            capture_output=True,
            text=True,
            check=False,
        )
        key = result.stdout.strip()
        if key:
            return key
    raise RuntimeError("OPENAI_API_KEY is not set in process or user environment.")


def request_image(api_key: str, model: str, spec: AssetSpec) -> bytes:
    prompt = f"{spec.prompt}, {COMMON_SUFFIX}"
    payload = {
        "model": model,
        "prompt": prompt,
        "n": 1,
        "size": choose_generation_size(spec.width, spec.height),
        "background": "transparent",
        "output_format": "png",
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as response:
            body = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI API error for {spec.asset_id}: HTTP {exc.code}: {detail}") from exc

    item = body.get("data", [{}])[0]
    b64 = item.get("b64_json")
    if not b64:
        raise RuntimeError(f"OpenAI API response for {spec.asset_id} did not include b64_json.")
    return base64.b64decode(b64)


def choose_generation_size(width: int, height: int) -> str:
    ratio = width / height
    if ratio >= 1.35:
        return "1536x1024"
    if ratio <= 0.75:
        return "1024x1536"
    return "1024x1024"


def center_crop_to_aspect(image: Image.Image, width: int, height: int) -> Image.Image:
    target_ratio = width / height
    source_ratio = image.width / image.height
    if source_ratio > target_ratio:
        new_width = int(image.height * target_ratio)
        left = (image.width - new_width) // 2
        return image.crop((left, 0, left + new_width, image.height))
    new_height = int(image.width / target_ratio)
    top = (image.height - new_height) // 2
    return image.crop((0, top, image.width, top + new_height))


def save_native_png(raw_png: bytes, spec: AssetSpec) -> None:
    output_path = REPO_ROOT / spec.path
    output_path.parent.mkdir(parents=True, exist_ok=True)

    image = Image.open(BytesIO(raw_png)).convert("RGBA")
    cropped = center_crop_to_aspect(image, spec.width, spec.height)
    resized = cropped.resize((spec.width, spec.height), Image.Resampling.NEAREST)
    resized.save(output_path, "PNG", optimize=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List missing P1/P2 assets without calling the OpenAI API.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    model = os.environ.get("OPENAI_IMAGE_MODEL", DEFAULT_MODEL)
    targets = [
        spec for spec in ASSETS
        if spec.asset_id not in P0_IDS and not (REPO_ROOT / spec.path).exists()
    ]

    if not targets:
        print("No missing P1/P2 assets to generate.")
        return 0

    if args.dry_run:
        print(f"{len(targets)} missing P1/P2 assets would be generated with {model}:")
        for spec in targets:
            print(f"- {spec.asset_id} ({spec.priority}) {spec.width}x{spec.height} -> {spec.path}")
        return 0

    api_key = get_api_key()
    print(f"Generating {len(targets)} missing P1/P2 assets with {model}.")
    for index, spec in enumerate(targets, start=1):
        print(f"[{index}/{len(targets)}] {spec.asset_id} -> {spec.path}")
        raw_png = request_image(api_key, model, spec)
        save_native_png(raw_png, spec)
        time.sleep(0.5)

    print("Done.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
