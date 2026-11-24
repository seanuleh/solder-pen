#!/usr/bin/env python3
"""pinch_ring: concept C's sliding ring must give a usable pinch at its detents, without closing the slit.

Usage: pinch_c.py ECHO_OUTPUT_FILE   (OpenSCAD's output for solder_pen_c.scad, part = "info")
The arm is a cantilever (root at x_r, full body height, width b). The ring forces the arm's edge in by
(flare at the ring's front edge - the ring's inside face); the wire stops the arm's gear end once it has moved
d_w (knurls touching the wire, plus their bite). Solving that propped beam gives the pinch F at each detent.
Fails if: no detent pinches in 2-5 N (light) or 6-15 N (firm); any detent > 20 N; the ring's back (loading)
position pinches at all; the knurl gap at rest leaves < 0.5 mm round the wire; the arm closes its slit to
< 0.3 mm; the arm's root stress > 20 MPa or the gear peg's > 15 MPa (PETG creeps under steady load).
"""
import re, sys, math
out = open(sys.argv[1]).read()
m = re.search(r"PINCHC (.*)\"", out)
if not m: print("FAIL  pinch_ring: no PINCHC line from OpenSCAD"); sys.exit(1)
P = {k: float(v) for k, v in re.findall(r"(\w+)=([\d.e-]+)", m.group(1))}
E, b, h = P["E"], P["b"], P["h"]
EI = E * h * b**3 / 12
L = P["x_g"] - P["x_r"]

def arm_y(x):
    f0, f1 = P["flare0"], P["flare1"]
    if x <= f0: return P["half"]
    if x >= f1: return P["half"] + P["flare"]
    return P["half"] + P["flare"] * (x - f0) / (f1 - f0)

def y(Pf, a, x):  # cantilever deflection at x for a unit-ish load Pf at a
    return Pf * x * x * (3 * a - x) / (6 * EI) if x <= a else Pf * a * a * (3 * x - a) / (6 * EI)

def solve(xc):
    """ring front edge at xc -> (pinch F, ring force Pc, max arm deflection, root moment)"""
    a = xc - P["x_r"]
    dc = max(0.0, arm_y(xc) - P["ry1"])
    if dc == 0: return 0.0, 0.0, 0.0, 0.0
    # free arm first: if the gear end doesn't reach the wire, no pinch
    Pc = dc / y(1, a, a)
    if y(Pc, a, L) < P["d_w"]: return 0.0, Pc, dc, Pc * a
    a11, a12, a21, a22 = y(1, a, a), -y(1, L, a), y(1, a, L), -y(1, L, L)
    det = a11 * a22 - a12 * a21
    Pc = (dc * a22 - a12 * P["d_w"]) / det
    F = (a11 * P["d_w"] - a21 * dc) / det
    return F, Pc, dc, Pc * a - F * L

valleys = []
x = P["det0"] + P["det_p"] / 2
while x < P["det1"]:
    valleys.append(x + P["ring_l"] / 2); x += P["det_p"]   # ring's front edge when its bump sits in this valley
res = [(xc,) + solve(xc) for xc in valleys]
probs = []
Fs = [r[1] for r in res]
if not any(2 <= F <= 5 for F in Fs): probs.append("no light detent (2-5 N)")
if not any(6 <= F <= 15 for F in Fs): probs.append("no firm detent (6-15 N)")
if max(Fs) > 20: probs.append(f"last detent {max(Fs):.0f} N")
if solve(P["flare0"])[0] > 0: probs.append("pinches with the ring at the back (can't load)")
if P["gap_rest"] - P["wire"] < 0.5: probs.append(f"rest gap leaves {P['gap_rest'] - P['wire']:.2f} round the wire")
dmax = max(r[3] for r in res)
if P["slitA"] - dmax < 0.3: probs.append(f"arm closes its slit to {P['slitA'] - dmax:.2f}")
if P["slitC"] - P["d_w"] < 0.3: probs.append(f"arm foot closes its slit to {P['slitC'] - P['d_w']:.2f}")
root = max(abs(r[4]) for r in res) * (b / 2) / (h * b**3 / 12)
if root > 20: probs.append(f"arm root {root:.0f} MPa")
lever = 1.3 + 1.0   # peg: floor to the knurl's middle, plus the knurl half-height
peg = max(Fs) * lever * 32 / (math.pi * P["peg_d"]**3)
if peg > 15: probs.append(f"gear peg {peg:.0f} MPa")
det = ", ".join(f"{F:.1f}" for F in Fs)
if probs: print("FAIL  pinch_ring: " + "; ".join(probs) + f"  (detents N: {det})"); sys.exit(1)
print(f"PASS  pinch_ring (detents N: {det}; slit left {P['slitA'] - dmax:.2f}; root {root:.0f} MPa; peg {peg:.0f} MPa)")
