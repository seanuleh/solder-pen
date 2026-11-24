#!/bin/bash
# Solder pen concept animation -> renders/solder_pen.mp4 + renders/solder_pen.gif
# Three scenes: one turn of the knob feeding wire out, a third of a turn back retracting it, then a
# time-lapse of the whole coil emptying (the nut walks to the front). Needs openscad + ffmpeg.
set -e
cd "$(dirname "$0")/.."
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
CAM="--camera=50,0,4,60,0,-12,172 --imgsize=1200,560"

# Values from parts/solder_pen.scad
pitch=1.4; coil=38; Rw=5.35
per_turn=$(echo "2*3.14159*$Rw" | bc -l)          # wire fed per knob turn
du=$(echo "$pitch/$coil" | bc -l)                  # 'used' per knob turn

frames=()   # "used out_l"
u0=0.03
for i in $(seq 0 35); do                           # scene 1: one turn, feed
  frames+=("$(echo "$u0 + $du*$i/36" | bc -l) $(echo "3 + $per_turn*$i/36" | bc -l)"); done
u1=$(echo "$u0 + $du" | bc -l); o1=$(echo "3 + $per_turn" | bc -l)
for i in $(seq 1 10); do frames+=("$u1 $o1"); done   # hold
for i in $(seq 0 11); do                           # scene 2: a third of a turn back, retract
  frames+=("$(echo "$u1 - $du/3*$i/12" | bc -l) $(echo "$o1 - $per_turn/3*$i/12" | bc -l)"); done
for i in $(seq 1 8); do frames+=("${frames[-1]}"); done   # hold
# scene 3: time-lapse (each frame shown 3x). 1 1/12 turns per frame, so the coil appears to creep round instead of strobing.
for i in $(seq 0 23); do
  f="$(echo "0.05 + $du*13/12*$i" | bc -l) 6"; frames+=("$f" "$f" "$f"); done

n=0; : > "$W/jobs"
for f in "${frames[@]}"; do set -- $f
  printf '%s\n' "openscad --colorscheme=Tomorrow -o $W/f$(printf %04d $n).png $CAM -D used=$1 -D out_l=$2 parts/solder_pen.scad" >> "$W/jobs"
  n=$((n+1)); done
echo "rendering $n frames"
xargs -P "$(nproc)" -I{} sh -c '{} >/dev/null 2>&1' < "$W/jobs"

# Captions per scene (frame ranges), with holds between scenes
cap="drawtext=fontfile=$FONT:fontsize=25:fontcolor=0x333333:x=40:y=30"
ffmpeg -loglevel error -y -framerate 15 -i "$W/f%04d.png" -vf "
  tpad=stop_mode=clone:stop_duration=1.5,
  $cap:text='1. Twist the knob - the nut walks forward, its tooth peels the wire off':enable='lt(n,46)',
  $cap:text='   one turn = ~33 mm of solder out of the needle':enable='lt(n,46)':y=70,
  $cap:text='2. Twist back - the wire is pulled in and laid back into the groove':enable='between(n,46,65)',
  $cap:text='3. Time-lapse - the coil empties, the nut ends at the front':enable='gte(n,66)',
  $cap:text='   only the nose + needle is left (~30 mm)':enable='gte(n,66)':y=70" \
  -c:v libx264 -pix_fmt yuv420p -movflags +faststart renders/solder_pen.mp4
ffmpeg -loglevel error -y -i renders/solder_pen.mp4 -vf "fps=12,scale=900:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96[p];[b][p]paletteuse" renders/solder_pen.gif
ls -la renders/solder_pen.mp4 renders/solder_pen.gif
