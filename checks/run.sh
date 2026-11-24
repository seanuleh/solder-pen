#!/bin/sh
# Geometry checks. Each test counts the separate bodies an export produces:
#   one_piece          a printed part must be ONE connected solid (a cut that slices it leaves a floating piece)
#   plate_parts_apart  a print plate must have exactly its part count of bodies (parts laid out touching
#                      or overlapping fuse in the slicer; the 2026-11-24 rig plate fused its rings onto the nose)
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); fail=0
count() { python3 - "$1" <<'PY'
import sys
par={}
def find(a):
    while par.setdefault(a,a)!=a: par[a]=par[par[a]]; a=par[a]
    return a
cur=[]
for l in open(sys.argv[1]):
    l=l.split()
    if l and l[0]=='vertex':
        cur.append(tuple(round(float(x),4) for x in l[1:]))
        if len(cur)==3:
            for v in cur[1:]: par[find(v)]=find(cur[0])
            cur=[]
print(len({find(v) for v in list(par)}))
PY
}
# file:defines:expected bodies:label
while IFS='|' read -r f d want label; do
  [ -z "$f" ] && continue
  out=$(eval openscad -o "$tmp/p.stl" $d "parts/$f" 2>&1)
  if echo "$out" | grep -qE "WARNING|ERROR"; then echo "FAIL  $label: OpenSCAD warnings/errors"; echo "$out" | grep -E "WARNING|ERROR" | sed 's/^/      /'; fail=1; continue; fi
  n=$(count "$tmp/p.stl")
  if [ "$n" = "$want" ]; then echo "PASS  $label"; else echo "FAIL  $label: $n separate bodies, want $want"; fail=1; fi
done <<'LIST'
solder_pen_drive_test.scad|-D 'part="sled"'|1|one_piece drive_test sled
solder_pen_drive_test.scad|-D 'part="wheel"'|1|one_piece drive_test wheel
solder_pen_drive_test.scad|-D 'part="idler"'|1|one_piece drive_test idler
solder_pen_drive_test.scad|-D 'part="idler"' -D toothed=false|1|one_piece drive_test idler_smooth
solder_pen_drive_test.scad|-D 'part="nose"'|1|one_piece drive_test nose
solder_pen_rig.scad|-D 'part="bottom"'|1|one_piece rig bottom
solder_pen_rig.scad|-D 'part="cover"'|1|one_piece rig cover
solder_pen_rig.scad|-D 'part="spool"'|1|one_piece rig spool
solder_pen_rig.scad|-D 'part="wheel"'|1|one_piece rig wheel
solder_pen_rig.scad|-D 'part="idler"'|1|one_piece rig idler
solder_pen_rig.scad|-D 'part="idler_smooth"'|1|one_piece rig idler_smooth
solder_pen_rig.scad|-D 'part="nose"'|1|one_piece rig nose
solder_pen_rig.scad|-D 'part="ring"'|1|one_piece rig ring
solder_pen_rig.scad|-D 'part="arm"' -D arm_t=0.9|1|one_piece rig arm0.9
solder_pen_rig.scad|-D 'part="arm"' -D arm_t=1.8|1|one_piece rig arm1.8
solder_pen_drive_test.scad|-D 'part="plate"'|5|plate_parts_apart drive_test (5 parts)
solder_pen_rig.scad|-D 'part="plate"'|13|plate_parts_apart rig (13 parts)
LIST
rm -r "$tmp"
exit $fail
