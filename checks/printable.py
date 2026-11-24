#!/usr/bin/env python3
"""no_ceilings: a part, in its print orientation, must not have unsupported ceilings.

Usage: printable.py PART.stl LABEL [MAX_MM2]
Counts the area of faces that point down more steeply than 45 degrees (normal z < -0.72) and are not on the
bed. Short bridges between two supports print fine and are allowed up to MAX_MM2 (default 20); v1's cover had a
~290 mm2 round ceiling over the thumbwheel that printed as spaghetti.
"""
import sys
import numpy as np
tri, cur = [], []
for l in open(sys.argv[1]):
    l = l.split()
    if l and l[0] == "vertex":
        cur.append([float(x) for x in l[1:]])
        if len(cur) == 3: tri.append(cur); cur = []
t = np.array(tri)
n = np.cross(t[:, 1] - t[:, 0], t[:, 2] - t[:, 0])
area = np.linalg.norm(n, axis=1) / 2
nz = n[:, 2] / np.maximum(np.linalg.norm(n, axis=1), 1e-12)
zmin = t[:, :, 2].min()
down = (nz < -0.72) & (t[:, :, 2].min(axis=1) > zmin + 0.05) & (area > 0)
a = area[down].sum()
lim = float(sys.argv[3]) if len(sys.argv) > 3 else 20
label = sys.argv[2]
if a <= lim:
    print("PASS  no_ceilings %s (%.1f mm2 of bridges)" % (label, a))
else:
    p = t[down].reshape(-1, 3)
    print("FAIL  no_ceilings %s: %.0f mm2 of unsupported ceiling around x %.0f-%.0f y %.0f-%.0f z %.1f-%.1f"
          % (label, a, p[:, 0].min(), p[:, 0].max(), p[:, 1].min(), p[:, 1].max(), p[:, 2].min(), p[:, 2].max()))
    sys.exit(1)
