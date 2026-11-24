#!/bin/sh
# Re-export the printed-part STLs. Usage: ./stl/export.sh [solder_pen_c|solder_pen_a_test|solder_pen_drive_test|solder_pen_rig ...]   (no args: all)
# 3MFs carry no colours/materials (color-mode=none): Bambu Studio would import OpenSCAD's colours as new
# filaments and overwrite the ones loaded in the AMS. Opened with no materials, it keeps the user's filaments.
cd "$(dirname "$0")/.."
ARGS="$*"
want() { [ -z "$ARGS" ] || echo " $ARGS " | grep -q " $1 "; }
go() { case "$1" in *.3mf) f=$1; shift; set -- "$f" -O export-3mf/color-mode=none "$@";; esac; out=$(openscad -o "$@" 2>&1); echo "$out" | grep -E "WARNING|ERROR" && exit 1; echo "exported $1"; }

if want solder_pen_drive_test; then
  mkdir -p stl/solder_pen_drive_test
  go stl/solder_pen_drive_test/sled.stl -D 'part="sled"' parts/solder_pen_drive_test.scad
  go stl/solder_pen_drive_test/idler_smooth.stl -D 'part="idler"' -D toothed=false parts/solder_pen_drive_test.scad
  for p in wheel idler nose; do go stl/solder_pen_drive_test/$p.stl -D "part=\"$p\"" parts/solder_pen_drive_test.scad; done
  go stl/solder_pen_drive_test/solder_pen_drive_test.3mf -D 'part="plate"' parts/solder_pen_drive_test.scad   # sled + wheel + 2 idlers + nose
fi
if want solder_pen_c; then
  mkdir -p stl/solder_pen_c
  for p in body bobbin gear_fixed gear_arm ring clip nose; do go stl/solder_pen_c/$p.stl -D "part=\"$p\"" parts/solder_pen_c.scad; done
  go stl/solder_pen_c/solder_pen_c.3mf -D 'part="plate"' parts/solder_pen_c.scad   # all 8 (2 clips)
fi
if want solder_pen_a_test; then
  mkdir -p stl/solder_pen_a_test
  for p in barrel core nut nose_straight nose_s; do go stl/solder_pen_a_test/$p.stl -D "part=\"$p\"" parts/solder_pen_a_test.scad; done
  go stl/solder_pen_a_test/solder_pen_a_test.3mf -D 'part="plate"' parts/solder_pen_a_test.scad   # all 5 parts
fi
if want solder_pen_rig; then
  mkdir -p stl/solder_pen_rig
  for p in base mid lid spool wheel idler idler_smooth nose ring; do go stl/solder_pen_rig/$p.stl -D "part=\"$p\"" parts/solder_pen_rig.scad; done
  for t in 0.9 1.1 1.3 1.6; do go stl/solder_pen_rig/arm$t.stl -D 'part="arm"' -D arm_t=$t parts/solder_pen_rig.scad; done
  go stl/solder_pen_rig/solder_pen_rig.3mf -D 'part="plate"' parts/solder_pen_rig.scad   # everything: 3 layers, 4 arms, 2 rings
fi
