#!/bin/sh
# Re-render every image in renders/ from the current model. Usage: ./renders/render.sh [name ...]
# Cameras: eye x,y,z,centre x,y,z (perspective) or translate,rotate,distance (gimbal, used for ortho views).
# The concept A animation has its own script: ./renders/solder_pen_anim.sh
cd "$(dirname "$0")/.."
R="openscad --colorscheme=Tomorrow"
ARGS="$*"
go() { name=$1; shift; if [ -z "$ARGS" ] || echo " $ARGS " | grep -q " $name "; then
  out=$($R -o "renders/$name.png" "$@" 2>&1); echo "$out" | grep -E "WARNING|ERROR" && exit 1; echo "rendered $name"; fi; }

go hero        --imgsize=3200,1400 --camera=48,0,4,60,0,-12,150 parts/solder_pen_reel.scad && python3 renders/trim.py renders/hero.png >/dev/null
go solder_pen    --imgsize=2000,900 --camera=38,0,0,60,0,-12,135 -D 'part="cutaway"' parts/solder_pen.scad
go solder_pen_exploded --imgsize=2400,800 --camera=5,0,0,62,0,0,230 -D 'part="exploded"' parts/solder_pen.scad
go solder_pen_reel --imgsize=2000,900 --camera=48,0,4,60,0,-12,165 parts/solder_pen_reel.scad
go solder_pen_reel_outside --imgsize=2000,900 --camera=48,0,4,55,0,20,165 -D 'part="outside"' parts/solder_pen_reel.scad
go solder_pen_drive_test --imgsize=1600,1100 --camera=25,18,5,50,0,-30,125 -D 'part="assembly"' parts/solder_pen_drive_test.scad
go solder_pen_drive_nip --imgsize=1600,900 --projection=o --camera=30,20,0,0,0,0,110 -D 'part="nip"' parts/solder_pen_drive_test.scad
go solder_pen_rig --imgsize=1800,900 --camera=40,0,0,60,0,330,140 -D 'part="assembly"' parts/solder_pen_rig.scad
go solder_pen_rig_open --imgsize=1800,900 --camera=36,0,0,55,0,25,135 -D 'part="open"' parts/solder_pen_rig.scad
go solder_pen_rig_nip --imgsize=1600,900 --projection=o --camera=50,0,0,0,0,0,60 -D 'part="nip"' parts/solder_pen_rig.scad

# Assembly guide steps (docs/assembly.md): 0 = exploded, 1-8 = one part going in at a time; trimmed to the part
for s in 0 1 2 3 4 5 6 7 8; do
  go rig_step$s --imgsize=3200,1800 --camera=36,0,10,55,0,25,150 --viewall --autocenter -D 'part="step"' -D step=$s parts/solder_pen_rig.scad
  if [ -z "$ARGS" ] || echo " $ARGS " | grep -q " rig_step$s "; then python3 renders/trim.py renders/rig_step$s.png >/dev/null; fi
done

# Diagrams (hand-drawn SVG in docs/diagrams/) -> PNG
for f in docs/diagrams/*.svg; do [ -e "$f" ] || continue; n=$(basename "$f" .svg)
  if [ -z "$ARGS" ] || echo " $ARGS " | grep -q " $n "; then rsvg-convert -w 1800 -b white -o "renders/$n.png" "$f" && echo "rendered $n"; fi; done
