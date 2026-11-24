// Solder pen concept B: PEN-SCALE RIG (2026-11-24). The real pen's insides at real size, in a ø20 body split
// lengthwise into two halves so it can be opened while testing.
//
//   fixed spool (coil) -> wire peels over the spool's front lip -> funnel -> eyelet on the axis
//   -> toothed drive wheel (ø7) / idler (ø5) on a printed flexure arm -> channel -> male Luer nose -> needle.
//   The ø18 thumbwheel shares the drive wheel's axle and pokes out of one side of the body.
//
// What it answers that the flat rig (solder_pen_drive_test.scad) can't: do pen-sized rollers (14 teeth) grip;
// how much drag the coil adds (peeling over the lip); does the thumbwheel work in the hand; does the pinch hold
// up after days under load (leave it loaded, retest).
//
// Pinch: the idler arm is a separate part, slotted into the body. Four arms differ only in thickness
// (0.9 / 1.2 / 1.5 / 1.8 = 1 / 2 / 3 / 4 notches on the anchor; ~1 / 2.5 / 5 / 8 N). Swap by opening the body.
// The idler is built to sit 0.6 mm into the wire's path, so the wire bends the arm ~0.6 mm.
//
// Parts (all print as modelled, no supports):
//   bottom  (flat underside on the bed)  |  cover (split face on the bed)  |  spool (flange down)
//   wheel (thumbwheel down)  |  idler, idler_smooth  |  arm (arm_t = 0.9/1.2/1.5/1.8)  |  nose (flange down)
//   ring x2 (slide over the ends to hold the halves; tape works too)
// Frame: X = pen axis toward the needle, Y across (thumbwheel pokes out at -Y), Z up; the wire runs along
// the axis (y = 0, z = 0), which is also the split plane. Measured wire 2026-11-24: 0.86-0.88.
// Export: ./stl/export.sh solder_pen_rig

part  = "plate";   // plate | bottom | cover | spool | wheel | idler | idler_smooth | arm | nose | ring | assembly | open | nip
arm_t = 1.5;

/* ---------- Body ---------- */
od      = 20;
flat_z  = -8.5;          // flat underside: prints on it, stops the pen rolling
wire    = 0.87;
chan_d  = 2.0;           // wire channel
clr     = 0.25;          // pin / bore clearance
fit     = 0.12;          // slots for the arm anchor (snug)

/* ---------- Spool ---------- */
fl_x0 = 0.85; fl_t = 2.3; fl_r = 7; fl_flat = -6;   // flange, keyed by a flat, clamped in a groove
core_d = 10; core_x1 = 30.5;                         // core from the flange to here
// Single-layer coil in a helical groove: turns can't stack, dig in or cross. Wound from the back (tail through
// the hole at the groove's start) forward; the drive always peels the FRONT turn, so the wire leaving never
// passes over the turns still on the core. ~21 turns = ~0.65 m of 0.8 solder (~3 g), then rewind.
grv_pitch = 1.2; grv_d = 0.95; grv_depth = 0.4;      // groove: round, sized for 0.86-0.88 wire; ~0.25 ridges between turns
grv_z0 = 0.8; grv_z1 = 0.4;                          // groove starts this far past the flange, stops this short of the lip
lip_d  = 11.6; lip_x1 = 33.25;                       // front lip: just over the coil OD (~10.9); wire + lip clear the chamber
ch_r   = 7.5; ch_x1 = 34;                            // spool chamber
eye_x  = 39;                                         // funnel ch_x1 -> eye_x, then the eyelet / channel

/* ---------- Drive ---------- */
anc_x0 = 41; anc_x1 = 45;                            // arm anchor slot
x_n    = 56;                                         // nip (arm free length 45 -> 56 = 11)
drv_d  = 7;  idl_d = 5;  tooth_dp = 0.8;
drv_n  = 14; idl_n = 10;
roll_h = 4;                                          // rollers z -2..2
bite   = 0.25;                                       // drive tips this far into the wire's path
idl_bite = 0.6;                                      // idler tips this far in with no wire (= arm preload travel)
drv_c  = [x_n, -(wire/2 - bite) - drv_d/2];
idl_c  = [x_n,  (wire/2 - idl_bite) + idl_d/2];
drv_pin = 3; idl_pin = 2.5;
thumb_d = 18; thumb_t = 2.5; thumb_z0 = 2.4;         // thumbwheel z 2.4..4.9, pokes ~3.5 out of the body

/* ---------- Idler arm ---------- */
arm_y0 = 5.6;                                        // inner face of the arm
arm_z0 = -3.2; arm_z1 = 3.0;
anc_y0 = 5.0; anc_y1 = 8.0;
pocket_y1 = 8.2;                                     // outer side of the arm pocket (room to bend 0.6+)

/* ---------- Nose ---------- */
ns_x  = x_n + thumb_d/2 + 1;                         // nose flange groove start
ns_d  = 13; ns_t = 2.5;
luer_l = 8.5; luer_tip = 3.925;                      // ISO 594 6 % taper, ø3.925 at the tip
front_t = 1.0;
x_front = ns_x + ns_t + 0.15 + front_t;

ring_w = 4; ring_id = od + 0.4;
pegs = [[10, 8.75], [10, -8.75], [ns_x + 1.3, 8.75], [ns_x + 1.3, -8.75]];

$fn = 64;

module along_x(x0, l) translate([x0, 0, 0]) rotate([0, 90, 0]) linear_extrude(l) rotate(90) children();   // 2D (y, z)
module teeth2d(d, n) polygon([for (i = [0:2*n-1]) let(a = 180 * i / n, r = (i % 2 == 0) ? d/2 : d/2 - tooth_dp) [r*cos(a), r*sin(a)]]);
module chamber2d() intersection() {      // teardrop, point up and cut flat: prints without support in the cover
  union() { circle(r = ch_r); rotate(45) square(ch_r); }
  translate([-10, -10]) square([20, 18.5]);
}
module flange2d(o = 0) offset(delta = o) intersection() { circle(r = fl_r); translate([-10, fl_flat]) square(20); }

module body_outer() difference() {
  along_x(0, x_front) circle(d = od, $fn = 96);
  translate([-1, -20, -20]) cube([x_front + 2, 40, 20 + flat_z]);
}

module pockets() {
  along_x(fl_x0 - 0.15, fl_t + 0.3) flange2d(0.15);                               // spool flange groove
  along_x(fl_x0 + fl_t, ch_x1 - fl_x0 - fl_t) chamber2d();                        // spool chamber
  hull() { along_x(ch_x1 - 0.01, 0.01) chamber2d(); along_x(eye_x - 0.01, 0.01) circle(r = 1.5); }   // funnel
  along_x(eye_x - 0.1, ns_x - eye_x + 0.2) circle(d = chan_d, $fn = 24);          // eyelet + wire channel
  translate([anc_x0 - fit, anc_y0 - fit, arm_z0 - fit]) cube([anc_x1 - anc_x0 + fit + 0.01, anc_y1 - anc_y0 + 2*fit, arm_z1 - arm_z0 + 2*fit]);
  translate([anc_x1, arm_y0 - 0.4, arm_z0 - 0.4]) cube([x_n + 3.2 - anc_x1, pocket_y1 - arm_y0 + 0.4, arm_z1 - arm_z0 + 0.8]);  // arm
  translate([0, 0, arm_z0 - 0.4]) linear_extrude(arm_z1 - arm_z0 + 0.4) hull() {  // bracket + idler
    translate(idl_c) circle(r = idl_d/2 + 0.6);
    translate([x_n - 3.6, arm_y0 - 0.4]) square([7.2, pocket_y1 - arm_y0 + 0.4]);
  }
  translate([drv_c[0], drv_c[1], -roll_h/2 - 0.4]) cylinder(r = drv_d/2 + 0.4, h = roll_h + 0.8);   // drive
  translate([drv_c[0], drv_c[1], roll_h/2]) cylinder(r = thumb_d/2 + 0.4, h = thumb_z0 + thumb_t + 0.4 - roll_h/2);  // thumbwheel (cuts the side slot)
  translate([ns_x - 0.15, 0, 0]) along_x(0, ns_t + 0.3) circle(d = ns_d + 0.3);   // nose flange groove
  along_x(ns_x, x_front - ns_x + 1) circle(d = luer_tip + 0.06 * luer_l + 0.5);    // taper exit hole
}

module body() difference() { body_outer(); pockets(); }

module bottom() {
  intersection() { body(); translate([-1, -20, -20]) cube([x_front + 2, 40, 20]); }
  translate([drv_c[0], drv_c[1], -roll_h/2 - 0.4]) {
    cylinder(d = 4.5, h = 0.4);
    cylinder(d = drv_pin, h = roll_h + 0.4 + thumb_z0 - roll_h/2 + thumb_t + 0.9, $fn = 32);
  }
  for (p = pegs) translate([p[0], p[1], -0.01]) cylinder(d = 2, h = 1.2, $fn = 24);
}

module cover() difference() {
  intersection() { body(); translate([-1, -20, 0]) cube([x_front + 2, 40, 20]); }
  for (p = pegs) translate([p[0], p[1], -1]) cylinder(d = 2.3, h = 2.6, $fn = 24);
  translate([drv_c[0], drv_c[1], -1]) cylinder(d = drv_pin + 0.3, h = thumb_z0 + thumb_t + 2.4, $fn = 32);  // pin socket
}

// Swept round groove along a helix (polyhedron: OpenSCAD's twisted extrude can't cut a fine-pitch groove)
module helix_groove(r, d, pitch, turns, seg = 32, pf = 10) {
  n = ceil(turns * seg);
  pts = [for (i = [0:n]) let(a = 360 * i / seg, z = pitch * i / seg)
           for (j = [0:pf-1]) let(t = 360 * j / pf, rr = r + d/2 * cos(t))
             [rr * cos(a), rr * sin(a), z + d/2 * sin(t)]];
  faces = concat(
    [for (i = [0:n-1]) for (j = [0:pf-1]) let(k = (j + 1) % pf)
       [i*pf + j, i*pf + k, (i+1)*pf + k, (i+1)*pf + j]],
    [[for (j = [pf-1:-1:0]) j]],
    [[for (j = [0:pf-1]) n*pf + j]]);
  polyhedron(pts, faces, convexity = 10);
}
spool_l = core_x1 - fl_x0 - fl_t;                    // core length
grv_turns = (spool_l - grv_z0 - grv_z1 - grv_d) / grv_pitch;
grv_r = core_d/2 - grv_depth + grv_d/2;              // groove centre radius
module spool() translate([fl_x0, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, 90]) spool_local();
module spool_local() difference() {    // along +Z from the flange's back face
  union() {
    linear_extrude(fl_t) flange2d();
    translate([0, 0, fl_t - 0.01]) cylinder(d = core_d, h = spool_l + 0.01);
    translate([0, 0, fl_t + spool_l - 0.01]) cylinder(d1 = core_d, d2 = lip_d, h = (lip_d - core_d)/2 + 0.01);
    translate([0, 0, fl_t + spool_l + (lip_d - core_d)/2 - 0.01]) cylinder(d1 = lip_d, d2 = lip_d - 1, h = lip_x1 - core_x1 - (lip_d - core_d)/2 + 0.01);
  }
  translate([0, 0, fl_t + grv_z0 + grv_d/2]) helix_groove(grv_r, grv_d, grv_pitch, grv_turns);
  translate([grv_r - 0.2, 0, fl_t + grv_z0 + grv_d/2]) rotate([0, 90, 0]) cylinder(d = 1.3, h = 10, center = true, $fn = 16);  // tail hole at the groove's start
}

module wheel() difference() {      // assembly position, centred on its axle
  union() {
    translate([0, 0, -roll_h/2]) linear_extrude(roll_h) teeth2d(drv_d, drv_n);
    translate([0, 0, roll_h/2 - 0.01]) cylinder(d = 5, h = thumb_z0 - roll_h/2 + 0.02);
    translate([0, 0, thumb_z0]) difference() {
      cylinder(d = thumb_d, h = thumb_t);
      for (i = [0:29]) rotate(i * 12) translate([thumb_d/2 + 0.3, 0, -1]) cylinder(d = 1.4, h = thumb_t + 2, $fn = 8);
    }
  }
  translate([0, 0, -5]) cylinder(d = drv_pin + clr, h = 15, $fn = 32);
}

module idler(toothed = true) difference() {
  translate([0, 0, -roll_h/2]) if (toothed) linear_extrude(roll_h) teeth2d(idl_d, idl_n); else cylinder(d = idl_d, h = roll_h);
  translate([0, 0, -5]) cylinder(d = idl_pin + clr, h = 10, $fn = 24);
  if (!toothed) translate([0, 0, roll_h/2 - 0.3]) cylinder(d = 3.8, h = 1);       // recess marks the smooth one
}

module arm(t = arm_t) {
  notches = round((t - 0.6) / 0.3);
  difference() {
    translate([anc_x0, anc_y0, arm_z0]) cube([anc_x1 - anc_x0, anc_y1 - anc_y0, arm_z1 - arm_z0]);
    for (i = [1:notches]) translate([anc_x0 + 0.8 * i - 0.2, anc_y0 - 1, arm_z1 - 0.5]) cube([0.4, 5, 1]);
  }
  translate([anc_x1 - 0.01, arm_y0, arm_z0]) cube([x_n + 2.5 - anc_x1, t, arm_z1 - arm_z0]);
  translate([0, 0, arm_z0]) linear_extrude(0.8) hull() {
    translate(idl_c) circle(d = 4.5);
    translate([x_n - 2.5, arm_y0]) square([5, t]);
  }
  translate([idl_c[0], idl_c[1], arm_z0]) {
    cylinder(d = 4, h = -roll_h/2 - arm_z0);
    cylinder(d = idl_pin, h = -arm_z0 + roll_h/2 + 0.2, $fn = 24);   // stops under the thumbwheel
  }
}

module nose() difference() {       // assembly position
  union() {
    along_x(ns_x, ns_t) circle(d = ns_d);
    translate([ns_x + ns_t - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = luer_tip + 0.06 * luer_l, d2 = luer_tip, h = luer_l);
  }
  along_x(ns_x - 1, 30) circle(d = chan_d, $fn = 24);
  translate([ns_x - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = 3, d2 = chan_d, h = 1);   // lead-in
}

module ring() difference() { cylinder(d = ring_id + 3, h = ring_w); translate([0, 0, -1]) cylinder(d = ring_id, h = ring_w + 2, $fn = 96); }

/* ---------- Print orientations ---------- */
module p_bottom() translate([0, 0, -flat_z]) bottom();
module p_cover() cover();
module p_spool() spool_local();                                                   // flange down
module p_wheel() rotate([180, 0, 0]) translate([0, 0, -(thumb_z0 + thumb_t)]) wheel();
module p_idler(t = true) translate([0, 0, roll_h/2]) idler(t);
module p_arm(t) translate([-anc_x0, -anc_y0, -arm_z0]) arm(t);
module p_nose() translate([0, 0, -ns_x]) rotate([0, -90, 0]) nose();       // flange down

module plate() {
  p_bottom();
  translate([0, 26, 0]) p_cover();
  translate([x_front + 14, 10, 0]) p_spool();
  translate([x_front + 14, 32, 0]) p_wheel();
  translate([x_front + 30, 0, 0]) p_idler(true);
  translate([x_front + 30, 9, 0]) p_idler(false);
  for (i = [0:3]) translate([x_front + 36, -8 + i * 9, 0]) p_arm([0.9, 1.2, 1.5, 1.8][i]);
  translate([x_front + 30, 30, 0]) p_nose();                  // clear of the wheel, arms and rings
  for (i = [0:1]) translate([x_front + 14 + i * 26, 56, 0]) ring();
}

/* ---------- Views ---------- */
module wire_path() color("#8d949c") {
  along_x(eye_x - 2, x_front + luer_l - eye_x + 2) circle(d = wire, $fn = 12);
  hull() { translate([lip_x1, 0, lip_d/2]) sphere(d = wire, $fn = 12); translate([eye_x - 2, 0, 0]) sphere(d = wire, $fn = 12); }
  translate([fl_x0 + fl_t + grv_z0 + grv_d/2, 0, 0]) rotate([0, 90, 0])      // the coil, half wound (back half)
    for (i = [0:floor(grv_turns/2)]) translate([0, 0, i * grv_pitch]) rotate_extrude($fn = 32) translate([grv_r, 0]) circle(d = wire, $fn = 8);
}
module insides() {
  color("#f0b429") spool();
  color("#3b82c4") translate([drv_c[0], drv_c[1], 0]) wheel();
  color("#cccccc") translate([idl_c[0], idl_c[1], 0]) idler();
  color("#6bbf59") arm();
  color("#e879b0") nose();
  wire_path();
}

if (part == "bottom") p_bottom();
if (part == "cover") p_cover();
if (part == "spool") p_spool();
if (part == "wheel") p_wheel();
if (part == "idler") p_idler(true);
if (part == "idler_smooth") p_idler(false);
if (part == "arm") p_arm(arm_t);
if (part == "nose") p_nose();
if (part == "ring") ring();
if (part == "plate") plate();
if (part == "assembly") {
  color("#d0393b") bottom();
  color("#e0574f") cover();
  insides();
  color("#555") for (x = [-0.05, x_front - ring_w + 0.05]) translate([x, 0, 0]) rotate([0, 90, 0]) ring();
}
if (part == "open") { color("#d0393b") bottom(); insides(); }

// Assembly guide (docs/assembly.md): step N shows steps 1..N-1 in place and step N's part lifted above
// where it goes (dashed drop line), so the order and direction are clear. step 0 = everything exploded.
step = 1;
lift = 14;
module drop(p, h) color("#222") for (z = [1:3:h - 1]) translate([p[0], p[1], p[2] + z]) cylinder(d = 0.5, h = 1.6, $fn = 8);
module s_arm(l = 0)   translate([0, 0, l]) color("#6bbf59") arm();
module s_idler(l = 0) translate([idl_c[0], idl_c[1], l]) color("#cccccc") idler();
module s_wheel(l = 0) translate([drv_c[0], drv_c[1], l]) color("#3b82c4") wheel();
module s_spool(l = 0) translate([0, 0, l]) { color("#f0b429") spool(); wire_path(); }
module s_nose(l = 0)  translate([0, 0, l]) color("#e879b0") nose();
module s_cover(l = 0) translate([0, 0, l]) color("#e0574f", l > 0 ? 0.85 : 1) cover();
module s_rings(l = 0) color("#555") {
  translate([-0.05 - l, 0, 0]) rotate([0, 90, 0]) ring();
  translate([x_front - ring_w + 0.05 + l, 0, 0]) rotate([0, 90, 0]) ring();
}
if (part == "step") {
  color("#d0393b") bottom();
  if (step == 0) {
    s_arm(10); s_idler(22); s_wheel(32); s_spool(16); s_nose(16); s_cover(50); s_rings(14);
  } else {
    if (step > 1) s_arm(); else { s_arm(lift); drop([anc_x0 + 2, anc_y0 + 1.5, arm_z1], lift); }
    if (step > 2) s_idler(); else if (step == 2) { s_idler(lift); drop([idl_c[0], idl_c[1], 2.2], lift - 4); }
    if (step > 3) s_wheel(); else if (step == 3) { s_wheel(lift); drop([drv_c[0], drv_c[1], 5.8], lift - 6); }
    if (step > 4) s_spool(); else if (step == 4) { s_spool(lift); drop([16, 0, 5], lift - 5); }
    if (step > 5) s_nose(); else if (step == 5) { s_nose(lift); drop([ns_x + 1, 0, 6.5], lift - 6); }
    if (step > 6) s_cover(); else if (step == 6) s_cover(lift + 10);
    if (step == 7) s_rings(12);
  }
}
if (part == "nip") {     // top view of the drive, thumbwheel cut off so the nip shows
  color("#d0393b") bottom();
  color("#3b82c4") translate([drv_c[0], drv_c[1], 0]) intersection() { wheel(); translate([0, 0, -5]) cylinder(d = 30, h = 5 + roll_h/2); }
  color("#cccccc") translate([idl_c[0], idl_c[1], 0]) idler();
  color("#6bbf59") arm(); color("#e879b0") nose(); wire_path();
}
