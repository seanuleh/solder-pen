#!/usr/bin/env python3
"""pinch_holds: the idler's spring must survive the play in its force path, and push straight at the drive.

Usage: pinch.py ECHO_OUTPUT_FILE   (OpenSCAD's output for part = "pinch")
Fails if the travel the play can eat is more than a third of the preload, if the plate under the idler's pin is
thinner than 2 mm (v1's 0.8 mm plate bent and tipped the idler away), or if the idler and drive centres aren't
in line with the push. v1: 0.6 preload, ~0.9 lost to slot play and bore clearance, so it pushed ~nothing.
"""
import re, sys
out = open(sys.argv[1]).read()
m = re.search(r"PINCH pre=([\d.]+) lost=([\d.]+) plate=([\d.]+) force_x_offset=([\d.e-]+)", out)
if not m: print("FAIL  pinch_holds: no PINCH line from OpenSCAD"); sys.exit(1)
pre, lost, plate, off = map(float, m.groups())
arms = re.findall(r"ARM t=([\d.]+) F=([\d.]+)", out)
probs = []
if lost > pre / 3: probs.append(f"play eats {lost:.2f} of the {pre} mm preload")
if plate < 2.0: probs.append(f"pin plate only {plate:.1f} mm")
if off > 0.05: probs.append(f"idler {off:.2f} mm off the drive's line")
forces = ", ".join(f"{t}: {float(f):.1f} N" for t, f in arms)
if probs: print("FAIL  pinch_holds: " + "; ".join(probs)); sys.exit(1)
print(f"PASS  pinch_holds (preload {pre}, play eats {lost:.2f}; plate {plate:.1f}; arms {forces})")
