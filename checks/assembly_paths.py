#!/usr/bin/env python3
"""assembly_paths_clear: each part must reach its place along its assembly path without passing through any
part already in place.

Usage: assembly_paths.py DIR SCAD   (DIR holds <name>.stl for every part, exported in its assembled position)

Method: cast rays on a 0.1 mm grid along the assembly direction. For each ray, the moving part's leading
point is where it enters the part; anything already placed that the ray hits beyond that point, on the side
the part comes from, lies in the part's path. Point sampling is exact at the grid points (thin gaps between
parts are not mistaken for clashes); clashes thinner than the grid could be missed.
"""
import sys, os
import numpy as np

GRID, TOL = 0.1, 0.02
BENT = {"arm": "arm_bent", "idler": "idler_bent"}
ORDER = [  # (part, direction it comes FROM: +z = lowered from above, -x = slid on from behind, +x = from the front)
    ("mid", "+z"), ("arm", "+z"), ("idler", "+z"), ("wheel", "+z"), ("spool", "+z"), ("nose", "+z"),
    ("lid", "+z"), ("ring_back", "-x"), ("ring_front", "+x")]

def load(path):
    tri, cur = [], []
    for l in open(path):
        l = l.split()
        if l and l[0] == "vertex":
            cur.append([float(x) for x in l[1:]])
            if len(cur) == 3: tri.append(cur); cur = []
    return np.array(tri)

def axes(d):  # (ray axis index, the two cross axes)
    return {"z": (2, 0, 1), "x": (0, 1, 2)}[d[1]]

def hits(tri, d, grid):
    """For each grid point (u, v), every crossing coordinate along the ray axis -> dict index -> sorted list."""
    a, u, v = axes(d)
    out = {}
    for t in tri:
        pu, pv, pa = t[:, u], t[:, v], t[:, a]
        iu0, iu1 = int(np.ceil((pu.min() - grid[0]) / GRID)), int(np.floor((pu.max() - grid[0]) / GRID))
        iv0, iv1 = int(np.ceil((pv.min() - grid[1]) / GRID)), int(np.floor((pv.max() - grid[1]) / GRID))
        if iu1 < iu0 or iv1 < iv0: continue
        U, V = np.meshgrid(np.arange(iu0, iu1 + 1), np.arange(iv0, iv1 + 1), indexing="ij")
        qu, qv = grid[0] + U * GRID + 1e-7, grid[1] + V * GRID + 2e-7   # nudge off shared edges
        (x0, y0), (x1, y1), (x2, y2) = zip(pu, pv)
        den = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
        if abs(den) < 1e-12: continue
        l0 = ((y1 - y2) * (qu - x2) + (x2 - x1) * (qv - y2)) / den
        l1 = ((y2 - y0) * (qu - x2) + (x0 - x2) * (qv - y2)) / den
        l2 = 1 - l0 - l1
        m = (l0 >= 0) & (l1 >= 0) & (l2 >= 0)
        if not m.any(): continue
        za = l0 * pa[0] + l1 * pa[1] + l2 * pa[2]
        for i, j, z in zip(U[m], V[m], za[m]): out.setdefault((i, j), []).append(z)
    return {k: sorted(z) for k, z in out.items()}

def main():
    D = sys.argv[1]
    names = [n for n, _ in ORDER] + ["base"] + list(BENT.values())
    parts = {n: load(os.path.join(D, n + ".stl")) for n in names}
    allp = np.concatenate([p.reshape(-1, 3) for p in parts.values()])
    grid0 = allp.min(axis=0) - 1
    fail = 0
    placed = ["base"]
    for name, d in ORDER:
        if name == "wheel":   # the arm is pushed back (bent) to drop the wheel in, and stays bent once wired
            placed = [BENT.get(p, p) for p in placed]
        a, u, v = axes(d)
        g = (grid0[u], grid0[v])
        mv = hits(parts[name], d, g)
        sign = 1 if d[0] == "+" else -1
        # leading point per ray: the part's extreme on the side it travels toward (opposite where it comes from)
        lead = {k: (min(z) if sign > 0 else max(z)) for k, z in mv.items()}
        bad, where = 0, []
        for o in placed:
            oh = hits(parts[o], d, g)
            for k, zs in oh.items():
                if k not in lead: continue
                ints = list(zip(zs[0::2], zs[1::2]))          # solid intervals along the ray
                for lo, hi in ints:
                    if (sign > 0 and hi > lead[k] + TOL) or (sign < 0 and lo < lead[k] - TOL):
                        bad += 1; where.append((o, g[0] + k[0] * GRID, g[1] + k[1] * GRID)); break
        label = f"assembly_paths_clear {name} (comes from {d})"
        if bad:
            fail = 1
            hit = sorted({w[0] for w in where})
            us = [w[1] for w in where]; vs = [w[2] for w in where]
            ax = "xyz"
            print(f"FAIL  {label}: passes through {', '.join(hit)} at {bad} grid points, "
                  f"{ax[u]} {min(us):.1f}..{max(us):.1f}, {ax[v]} {min(vs):.1f}..{max(vs):.1f}")
        else:
            print(f"PASS  {label}")
        placed.append(name)
    sys.exit(fail)

main()
