#!/bin/sh
# Geometry checks.
# Body counts (each export must have the expected number of separate bodies):
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
solder_pen_rig.scad|-D 'part="base"'|1|one_piece rig base
solder_pen_rig.scad|-D 'part="mid"'|1|one_piece rig mid
solder_pen_rig.scad|-D 'part="lid"'|1|one_piece rig lid
solder_pen_rig.scad|-D 'part="spool"'|1|one_piece rig spool
solder_pen_rig.scad|-D 'part="wheel"'|1|one_piece rig wheel
solder_pen_rig.scad|-D 'part="idler"'|1|one_piece rig idler
solder_pen_rig.scad|-D 'part="idler_smooth"'|1|one_piece rig idler_smooth
solder_pen_rig.scad|-D 'part="nose"'|1|one_piece rig nose
solder_pen_rig.scad|-D 'part="ring"'|1|one_piece rig ring
solder_pen_rig.scad|-D 'part="arm"' -D arm_t=0.9|1|one_piece rig arm0.9
solder_pen_rig.scad|-D 'part="arm"' -D arm_t=1.6|1|one_piece rig arm1.6
solder_pen_a_test.scad|-D 'part="barrel"'|1|one_piece a_test barrel
solder_pen_a_test.scad|-D 'part="core"'|1|one_piece a_test core
solder_pen_a_test.scad|-D 'part="nut"'|1|one_piece a_test nut
solder_pen_a_test.scad|-D 'part="nose_straight"'|1|one_piece a_test nose_straight
solder_pen_a_test.scad|-D 'part="nose_s"'|1|one_piece a_test nose_s
solder_pen_a_test.scad|-D 'part="plate"'|5|plate_parts_apart a_test (5 parts)
solder_pen_c.scad|-D 'part="body"'|1|one_piece c body
solder_pen_c.scad|-D 'part="bobbin"'|1|one_piece c bobbin
solder_pen_c.scad|-D 'part="gear_fixed"'|1|one_piece c gear_fixed
solder_pen_c.scad|-D 'part="gear_arm"'|1|one_piece c gear_arm
solder_pen_c.scad|-D 'part="ring"'|1|one_piece c ring
solder_pen_c.scad|-D 'part="clip"'|1|one_piece c clip
solder_pen_c.scad|-D 'part="nose"'|1|one_piece c nose
solder_pen_c.scad|-D 'part="plate"'|8|plate_parts_apart c (8 parts)
solder_pen_drive_test.scad|-D 'part="plate"'|5|plate_parts_apart drive_test (5 parts)
solder_pen_rig.scad|-D 'part="plate"'|14|plate_parts_apart rig (14 parts)
LIST

# no_ceilings: every rig part, as printed, has no unsupported ceiling (checks/printable.py; v1's cover failed)
for p in base mid lid spool wheel idler idler_smooth nose ring arm:0.9 arm:1.6; do
  n=${p%%:*}; t=${p#*:}; [ "$t" = "$p" ] && t=""
  openscad -q -o "$tmp/c.stl" -D "part=\"$n\"" ${t:+-D arm_t=$t} parts/solder_pen_rig.scad 2>/dev/null
  # arms: the flexure's underside is a straight ~10.5 mm bridge from the anchor to the tip post (prints clean)
  python3 checks/printable.py "$tmp/c.stl" "rig $n$t" ${t:+25} || fail=1
done

# pinch_holds: the idler spring's preload survives the play in its force path (checks/pinch.py; v1 failed)
openscad -o "$tmp/pinch.stl" -D 'part="pinch"' parts/solder_pen_rig.scad > "$tmp/pinch.txt" 2>&1
python3 checks/pinch.py "$tmp/pinch.txt" || fail=1

# assembly_paths_clear: each rig part reaches its place along its path (drop in from above, rings slide on
# from the ends) without passing through a part already there (checks/assembly_paths.py; v1's cover failed)
mkdir -p "$tmp/at"
for w in base mid lid arm idler arm_bent idler_bent wheel spool nose ring_back ring_front; do
  openscad -q -o "$tmp/at/$w.stl" -D 'part="at"' -D "which=\"$w\"" parts/solder_pen_rig.scad 2>/dev/null
done
python3 checks/assembly_paths.py "$tmp/at" || fail=1

# Concept A test print: no ceilings, and every fit is clear (OpenSCAD reports an empty intersection) with
# the nut at the back, the middle and the front of its travel: nut on core (the tooth rides the groove), nut
# and core in the barrel, both against the noses, and the wire's path from the peel point out of each nose.
for p in barrel core nut nose_straight nose_s; do
  openscad -q -o "$tmp/c.stl" -D "part=\"$p\"" parts/solder_pen_a_test.scad 2>/dev/null
  python3 checks/printable.py "$tmp/c.stl" "a_test $p" || fail=1
done
bad=""
for u in 0 0.5 1; do for k in nut_core nut_barrel core_barrel core_nose nut_nose wire_path wire_s; do
  openscad -o "$tmp/f.stl" -D "part=\"fit_$k\"" -D used=$u parts/solder_pen_a_test.scad 2>&1 | grep -q "top level object is empty" || bad="$bad $k@$u"
done; done
if [ -z "$bad" ]; then echo "PASS  fits_clear a_test (7 fits x nut at back/middle/front)"; else echo "FAIL  fits_clear a_test:$bad"; fail=1; fi

# Concept C "stick": no ceilings; every fit clear with the ring back (arm at rest) and forward (pinched);
# the spur gears clear through one tooth of turning; the fixed gear's rim keeps the arm gear in (must HIT);
# the ring's pinch at its detents (checks/pinch_c.py).
for p in body bobbin gear_fixed gear_arm ring clip nose; do
  openscad -q -o "$tmp/c.stl" -D "part=\"$p\"" parts/solder_pen_c.scad 2>/dev/null
  python3 checks/printable.py "$tmp/c.stl" "c $p" || fail=1
done
bad=""
for on in true false; do for k in gears_body fixed_gear_arm bobbin_body nose_body clips ring_slide wire_path; do
  openscad -o "$tmp/f.stl" -D "part=\"fit_$k\"" -D pinched=$on -D ribs=false parts/solder_pen_c.scad 2>&1 | grep -q "top level object is empty" || bad="$bad $k@pinched=$on"
done
  openscad -o "$tmp/f.stl" -D 'part="fit_arm_gear_kept"' -D pinched=$on parts/solder_pen_c.scad 2>&1 | grep -q "top level object is empty" && bad="$bad arm_gear_loose@pinched=$on"
done
for ph in 0 3 6 9 12 15 18 21 24 27; do
  openscad -o "$tmp/f.stl" -D 'part="fit_mesh"' -D phase=$ph parts/solder_pen_c.scad 2>&1 | grep -q "top level object is empty" || bad="$bad mesh@$ph"
done
if [ -z "$bad" ]; then echo "PASS  fits_clear c (7 fits x rest/pinched, gear mesh x 10 phases, arm gear kept)"; else echo "FAIL  fits_clear c:$bad"; fail=1; fi
openscad -o "$tmp/i.stl" -D 'part="info"' parts/solder_pen_c.scad > "$tmp/i.txt" 2>&1
python3 checks/pinch_c.py "$tmp/i.txt" || fail=1

rm -r "$tmp"
exit $fail
