#!/usr/bin/env python3
"""Generate a deep-gray keyboard app icon (no blue tint)."""
from PIL import Image, ImageDraw

S = 1024
radius = 224

def lerp(a, b, t):
    return int(a + (b - a) * t)

# 深灰渐变背景（上浅下深）
top = (76, 76, 82)
bot = (46, 46, 52)
bg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
px = bg.load()
for y in range(S):
    t = y / (S - 1)
    r = lerp(top[0], bot[0], t)
    g = lerp(top[1], bot[1], t)
    b = lerp(top[2], bot[2], t)
    for x in range(S):
        px[x, y] = (r, g, b, 255)

# 圆角裁剪
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=radius, fill=255)
bg.putalpha(mask)

# 顶部高光
hi = Image.new("RGBA", (S, S), (0, 0, 0, 0))
hd = ImageDraw.Draw(hi)
for y in range(0, int(S * 0.30)):
    a = int(255 * (1 - y / (S * 0.30)) * 0.12)
    hd.line([0, y, S, y], fill=(255, 255, 255, a))
hi.putalpha(mask)
img = Image.alpha_composite(bg, hi)

d = ImageDraw.Draw(img, "RGBA")

# 键盘底板
kw, kh = 600, 400
kx = (S - kw) // 2
ky = (S - kh) // 2 + 10
d.rounded_rectangle([kx, ky, kx + kw, ky + kh], radius=48,
                    fill=(255, 255, 255, 22), outline=(255, 255, 255, 42), width=3)

# 键帽网格
cols, rows = 10, 4
pad_x, pad_y, gap = 40, 36, 14
inner_w = kw - pad_x * 2
inner_h = kh - pad_y * 2
key_w = (inner_w - gap * (cols - 1)) / cols
key_h = (inner_h - gap * (rows - 1)) / rows
kr = int(key_h * 0.32)
white = (243, 243, 246, 240)

def draw_key(cx, cy, w, h):
    d.rounded_rectangle([cx + 3, cy + 5, cx + w + 3, cy + h + 5], radius=kr, fill=(0, 0, 0, 55))
    d.rounded_rectangle([cx, cy, cx + w, cy + h], radius=kr, fill=white)

for r in range(rows):
    cy = ky + pad_y + r * (key_h + gap)
    if r == rows - 1:
        draw_key(kx + pad_x, cy, inner_w, key_h)  # 空格长条
    else:
        for c in range(cols):
            cx = kx + pad_x + c * (key_w + gap)
            draw_key(cx, cy, key_w, key_h)

out = "/Users/allen/WorkBuddy/自动切换输入法/Resources/icon_src/keyboard_deepgray.png"
img.save(out)
print("saved", out)
