#!/usr/bin/env python3
"""Trim the flat background off renders and leave an even margin. Usage: renders/trim.py FILE.png ..."""
import sys
from PIL import Image, ImageChops
for f in sys.argv[1:]:
    im = Image.open(f).convert("RGB")
    bg = Image.new("RGB", im.size, im.getpixel((0, 0)))
    box = ImageChops.difference(im, bg).getbbox()
    if not box: continue
    m = 40
    box = (max(box[0] - m, 0), max(box[1] - m, 0), min(box[2] + m, im.width), min(box[3] + m, im.height))
    im.crop(box).save(f)
    print("trimmed", f, im.crop(box).size)
