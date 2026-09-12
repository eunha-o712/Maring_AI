"""렌더 결과에 부드러운 발광을 입히고 레퍼런스와 나란히 비교 시트를 만든다.

Blender 5.x 는 컴포지터 API가 바뀌어 씬 안에서 Glare 를 걸기 번거롭다.
발광은 실제 지오메트리가 아니라 '보여주기'용 효과이므로 여기서 후처리한다.
(GLB 에는 emission 값이 그대로 들어가므로 앱 렌더러가 알아서 처리한다.)
"""
from PIL import Image, ImageFilter, ImageChops
import os
import sys

REF_DIR = "../maring_img"
OUT_DIR = "output"
S = 340
BG = (250, 249, 253, 255)


def bloom(im, threshold=238, radius=7, strength=0.45):
    """밝은 부분만 뽑아 흐린 뒤 스크린 합성 — 레퍼런스의 몽글한 발광."""
    rgb = im.convert("RGB")
    bright = rgb.point(lambda v: max(0, v - threshold) * 255 // max(1, 255 - threshold))
    blurred = bright.filter(ImageFilter.GaussianBlur(radius))
    if strength != 1.0:
        blurred = blurred.point(lambda v: int(v * strength))
    glowed = ImageChops.screen(rgb, blurred)
    out = glowed.convert("RGBA")
    out.putalpha(im.getchannel("A"))
    return out


def load(path, size=S, glow=False):
    im = Image.open(path).convert("RGBA")
    if glow:
        im = bloom(im)
    im = Image.alpha_composite(Image.new("RGBA", im.size, BG), im)
    return im.resize((size, size), Image.LANCZOS)


def main():
    # 발광 입힌 개별 렌더도 저장
    for name in ("front", "q34", "side", "back"):
        src = os.path.join(OUT_DIR, f"view_{name}.png")
        if os.path.exists(src):
            bloom(Image.open(src).convert("RGBA")).save(
                os.path.join(OUT_DIR, f"glow_{name}.png"))

    refs = ["maring_front.png", "maring_side.png", "maring_back.png", "maring_top.png"]
    mine = ["glow_front.png", "glow_q34.png", "glow_side.png", "glow_back.png"]

    sheet = Image.new("RGBA", (S * 4, S * 2), BG)
    for i, f in enumerate(refs):
        sheet.paste(load(os.path.join(REF_DIR, f)), (i * S, 0))
    for i, f in enumerate(mine):
        sheet.paste(load(os.path.join(OUT_DIR, f)), (i * S, S))
    sheet.convert("RGB").save(os.path.join(OUT_DIR, "comparison.png"), quality=95)

    # 대표 프리뷰(정면)
    load(os.path.join(OUT_DIR, "glow_front.png"), 900).convert("RGB").save(
        os.path.join(OUT_DIR, "maring_preview.png"), quality=95)
    print("[OK] comparison.png / maring_preview.png")


if __name__ == "__main__":
    main()
