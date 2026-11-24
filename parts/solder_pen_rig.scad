// Solder pen concept B: PEN-SCALE RIG v2 (2026-11-24). Pen B's real insides at real size.
//
//   fixed spool (coil) -> wire peels over the spool's front lip -> funnel -> channel on the axis
//   -> toothed drive wheel (ø7) / idler (ø6) on a printed flexure arm -> channel -> male Luer nose -> needle.
//   The ø18 thumbwheel shares the drive wheel's axle and pokes out of one side of the body.
//
// v2 = a SANDWICH: a hex body (20 across flats) in three flat layers, so nothing prints with a ceiling.
//   base  z -10 .. -2.3   prints on its bottom flat; every pocket opens upward
//   mid   z -2.3 .. 2.3   a frame: the rollers' layer; through-cuts with near-vertical walls
//   lid   z  2.3 .. 10    prints upside down on its top flat; every pocket opens toward the mid (= upward)
// Three pegs on the base pass through the mid into the lid; two hex rings slide over the ends to clamp it.
// (v1 split a round body in two at the wire; the cover's thumbwheel pocket printed as a ø19 ceiling of spaghetti.)
//
// Clearances are for FDM (v1's were modelled tight and bound): 0.5 on the diameter for anything that spins,
// 0.3 axial gap each side of a roller, 0.2-0.25 a side for drop-in slots and flanges, +0.4 on peg holes.
//
// Pinch: the idler is on a separate printed flexure arm slotted into the body. Four arms differ only in
// thickness (0.9 / 1.1 / 1.3 / 1.6 = 1-4 notches on the anchor; ~1 / 2 / 3 / 5.5 N). The arm is printed
// straight with the idler 1.5 mm past where the wire puts it, so the wire bends the arm 1.5 mm: big next to
// print error, so the force barely depends on it. The anchor is held by crush ribs (no play: v1's 0.12 mm
// slot play let the anchor swivel more than v1's whole 0.6 mm preload, so it pushed almost nothing), and the
// idler's pin stands on a 2.1 mm plate (v1's 0.8 mm plate bent and let the idler tip away).
//
// Frame: X = pen axis toward the needle, Y across (thumbwheel pokes out at -Y), Z up; the wire runs along
// the axis (y = 0, z = 0). Measured wire 2026-11-24: 0.86-0.88.   Export: ./stl/export.sh solder_pen_rig

part  = "plate";   // plate | base | mid | lid | spool | wheel | idler | idler_smooth | arm | nose | ring
                   // views: assembly | open | nip | step (with step = 0..8)
arm_t = 1.3;
arm_ts = [0.9, 1.1, 1.3, 1.6];

/* ---------- Fits (FDM) ---------- */
spin   = 0.5;            // diametral clearance, spinning on a pin
ax     = 0.3;            // axial gap each side of a roller
slot   = 0.2;            // a side, drop-in slots (arm anchor)
grv    = 0.25;           // a side, flange grooves (spool, nose)
peg_c  = 0.4;            // diametral, pegs in holes

/* ---------- Body ---------- */
F    = 20;               // hex across flats (flats top and bottom)
R    = F / sqrt(3);      // across corners / 2
rc   = 1.0;              // corner rounding
z_b  = -2.3;  z_t = 2.3; // layer interfaces
wire = 0.87;
chan = 1.1;              // wire channel: diamond, half-diagonal (2.2 across); self-supporting either way up

/* ---------- Spool ---------- */
fl_x0 = 1.5; fl_t = 2.3; fl_r = 7; fl_flat = -6;    // flange, keyed by a flat (down), in a groove
core_d = 10; core_x1 = 30.5;
grv_pitch = 1.2; grv_d = 0.95; grv_depth = 0.4;      // helical groove: single-layer coil
grv_z0 = 0.8; grv_z1 = 0.4;
lip_d  = 11.6; lip_x1 = 33.25;
ch_r   = 7.5; ch_x1 = 34;                            // spool chamber
eye_x  = 39;                                         // funnel ch_x1 -> eye_x, then the channel

/* ---------- Drive ---------- */
x_n    = 56;                                         // nip
drv_d  = 7;  drv_n = 14; drv_tooth = 0.8;
idl_d  = 6;  idl_n = 12; idl_tooth = 0.5;            // ø6 so a ø3 pin + 0.5 clearance leaves a 0.75 wall
roll_h = 4;  idl_h = 3.4;                            // drive z -2..2, idler z -1.7..1.7
bite   = 0.25;                                       // drive tips this far into the wire's path
pre    = 1.5;                                        // arm preload: the wire bends the arm this far
drv_c  = [x_n, -(wire/2 - bite) - drv_d/2];
idl_c  = [x_n,  wire/2 - 0.1 + idl_d/2];             // idler WORKING position (wire in, arm bent by pre)
idl_cf = idl_c - [0, pre];                           // idler as printed (arm straight); rests on the drive with no wire
pin_d  = 3;                                          // both pins
thumb_d = 18; thumb_t = 2.5; thumb_z0 = z_t + 0.4;   // thumbwheel clears the mid by 0.4
cav_z1 = thumb_z0 + thumb_t + 0.4;                   // lid pocket top
pin_top = cav_z1 + 1.6;                              // drive pin ends in a socket in the lid

/* ---------- Idler arm ---------- */
arm_y0 = idl_cf[1] + idl_d/2 + 0.6;                  // inner face of the flexure (straight), clear of the idler
arm_z0 = -2.0; arm_z1 = 2.0;                         // flexure: in the mid, 0.3 off each face
brk_z0 = -4.4;                                       // bracket plate (under the idler) and anchor bottoms, in the base
brk_z1 = z_b;                                        // bracket plate top: 0.3 below the drive roller, which overhangs it
anc_x0 = 39; anc_x1 = 43;                            // anchor; free length to the idler = x_n - anc_x1 = 13
anc_y0 = arm_y0 - 1.0; anc_y1 = arm_y0 + max(arm_ts) + 0.3;
post_w = 0.9;                                        // tip post under the flexure (narrow: keeps the base's side wall)
slot_a = 0.15; rib = 0.45;                           // anchor slot a side; crush ribs stand 0.45 proud (0.3 interference)
pocket_y1 = arm_y0 + max(arm_ts) + pre + 0.6;        // room for the thickest arm bent 1.5 + 0.6
th_pre = atan(pre / (x_n - anc_x1));                 // bend, modelled as a swing about the root

/* ---------- Nose ---------- */
ns_x  = x_n + thumb_d/2 + 1;
ns_d  = 13; ns_t = 2.5;
luer_l = 8.5; luer_tip = 3.925;                      // ISO 594 6 % taper
x_front = ns_x + ns_t + 2*grv + 1.5;                // 1.5 front wall

ring_w = 4; ring_c = 0.3; ring_wall = 1.6;
pegs = [[36.5, 7.2], [38.5, -6.5], [63, 6.5]];  peg_d = 2.5;  peg_top = z_t + 1.2;

$fn = 64;

/* ---------- 2D helpers (in the Y-Z plane) ---------- */
// Hex, flats top and bottom. The two side corners are rounded; the corners at the flats stay sharp so the
// base and lid have no curl-under at the bed.
module hex2d(o = 0) offset(delta = o) hull() {
  offset(r = rc) offset(delta = -rc) polygon([[R, 0], [R/2, F/2], [-R/2, F/2], [-R, 0], [-R/2, -F/2], [R/2, -F/2]]);
  square([R, F], center = true);
}
module along_x(x0, l) translate([x0, 0, 0]) rotate([0, 90, 0]) linear_extrude(l) rotate(90) children();   // 2D (y, z)
module teeth2d(d, n, dp) polygon([for (i = [0:2*n-1]) let(a = 180 * i / n, r = (i % 2 == 0) ? d/2 : d/2 - dp) [r*cos(a), r*sin(a)]]);
module diamond(h) rotate(45) square(h * sqrt(2), center = true);
module flange2d(o = 0) offset(delta = o) intersection() { circle(r = fl_r); translate([-10, fl_flat]) square(20); }

module pockets() {
  along_x(fl_x0 - grv, fl_t + 2*grv) flange2d(grv);                               // spool flange groove
  along_x(fl_x0 + fl_t, ch_x1 - fl_x0 - fl_t) circle(r = ch_r);                   // spool chamber
  hull() { along_x(ch_x1 - 0.01, 0.01) circle(r = ch_r); along_x(eye_x - 0.01, 0.01) diamond(chan + 0.4); }  // funnel
  along_x(eye_x - 0.1, ns_x - eye_x + 0.2) diamond(chan);                         // channel
  // arm: anchor slot, flexure pocket, bracket + idler pocket
  translate([anc_x0 - slot_a, anc_y0 - slot_a, brk_z0 - 0.3]) cube([anc_x1 - anc_x0 + slot_a + 0.01, anc_y1 - anc_y0 + 2*slot_a, z_t + 0.01 - (brk_z0 - 0.3)]);   // anchor slot, through the mid
  translate([anc_x1, arm_y0 - 0.4, z_b - 0.01]) cube([x_n + 3.2 - anc_x1, pocket_y1 - arm_y0 + 0.4, z_t - z_b + 0.02]);   // flexure, through the mid
  translate([0, 0, z_b - 0.01]) linear_extrude(z_t - z_b + 0.02) hull() {                 // idler + arm tip (mid), straight and bent
    for (c = [idl_c, idl_cf]) translate(c) circle(r = idl_d/2 + 0.6);
    translate([x_n - 3.6, arm_y0 - 0.4]) square([7.2, pocket_y1 - arm_y0 + 0.4]);
  }
  translate([0, 0, brk_z0 - 0.4]) linear_extrude(z_b - brk_z0 + 0.41) hull() {            // bracket plate + tip post (base), straight and bent
    for (c = [idl_c, idl_cf]) translate(c) circle(r = pin_d/2 + 1.2 + 0.4);
    for (dy = [0, pre]) translate([x_n - 2.9, arm_y0 - 0.4 + dy]) square([5.8, post_w + 0.8]);
  }
  translate([drv_c[0], drv_c[1], z_b - 0.01]) cylinder(r = drv_d/2 + 0.5, h = z_t - z_b + 0.02);     // drive roller (mid)
  translate([drv_c[0], drv_c[1], z_t - 0.01]) cylinder(r = thumb_d/2 + 0.5, h = cav_z1 - z_t);      // thumbwheel (lid; breaks out the side)
  translate([drv_c[0], drv_c[1], z_t]) cylinder(d = pin_d + spin, h = pin_top + 0.4 - z_t, $fn = 32); // pin socket (lid)
  along_x(ns_x - grv, ns_t + 2*grv) circle(d = ns_d + 2*grv);                    // nose flange groove
  along_x(ns_x, x_front - ns_x + 1) circle(d = luer_tip + 0.06 * luer_l + 0.6);   // taper exit hole
  for (p = pegs) translate([p[0], p[1], z_b - 0.01]) cylinder(d = peg_d + peg_c, h = peg_top + 0.4 - z_b, $fn = 24);
}

module body() difference() { along_x(0, x_front) hex2d(); pockets(); }
module layer(z0, z1) intersection() { body(); translate([-1, -20, z0]) cube([x_front + 2, 40, z1 - z0]); }

module base() {
  layer(-F, z_b);
  translate([drv_c[0], drv_c[1], z_b - 0.01]) cylinder(d = pin_d, h = pin_top - z_b, $fn = 32);    // drive pin
  for (p = pegs) translate([p[0], p[1], z_b - 0.01]) cylinder(d = peg_d, h = peg_top - z_b, $fn = 24);
}
// Everything drops into the mid from above, so any round pocket must not narrow above the wire's line:
// in the mid, each one is extended straight up from its widest point (checked by assembly_paths_clear).
module up2d(w) translate([-w/2, 0]) square([w, F]);
module drop_slots() {
  along_x(fl_x0 - grv, fl_t + 2*grv) up2d(2 * (fl_r + grv));                    // spool flange
  along_x(fl_x0 + fl_t, ch_x1 - fl_x0 - fl_t) up2d(lip_d + 1);                  // spool core + lip
  along_x(eye_x - 0.1, ns_x - eye_x + 0.2) up2d(1.3);                           // lay the wire in from above
  along_x(ns_x - grv, ns_t + 2*grv) up2d(ns_d + 2*grv);                         // nose flange
  along_x(ns_x, x_front - ns_x + 1) up2d(luer_tip + 0.06 * luer_l + 0.6);       // nose taper
}
module mid() difference() { layer(z_b, z_t); drop_slots(); }
module lid() layer(z_t, F);

// Spool: a swept round groove along a helix (polyhedron: a twisted extrude can't cut a fine-pitch groove)
// Groove profile (dr, dz): round where the wire sits, a 45° roof on top (teardrop) so it prints with the
// spool standing up and no face pointing down more than 45°.
function groove_prof(d) = concat([for (t = [-180:30:30]) [d/2 * cos(t), d/2 * sin(t)]], [[d/2 * cos(45), d/2 * sin(45)], [0, d/2 * sqrt(2)], [-d/2 * cos(45), d/2 * sin(45)]]);
module helix_groove(r, d, pitch, turns, seg = 32, pf = len(groove_prof(1))) {
  n = ceil(turns * seg);
  pts = [for (i = [0:n]) let(a = 360 * i / seg, z = pitch * i / seg)
           for (q = groove_prof(d)) let(rr = r + q[0]) [rr * cos(a), rr * sin(a), z + q[1]]];
  faces = concat(
    [for (i = [0:n-1]) for (j = [0:pf-1]) let(k = (j + 1) % pf) [i*pf + j, i*pf + k, (i+1)*pf + k, (i+1)*pf + j]],
    [[for (j = [pf-1:-1:0]) j]], [[for (j = [0:pf-1]) n*pf + j]]);
  polyhedron(pts, faces, convexity = 10);
}
spool_l = core_x1 - fl_x0 - fl_t;
grv_turns = (spool_l - grv_z0 - grv_z1 - grv_d) / grv_pitch;
grv_r = core_d/2 - grv_depth + grv_d/2;
module spool() translate([fl_x0, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, 90]) spool_local();
module spool_local() difference() {    // along +Z from the flange's back face
  union() {
    linear_extrude(fl_t) flange2d();
    translate([0, 0, fl_t - 0.01]) cylinder(d = core_d, h = spool_l + 0.01);
    translate([0, 0, fl_t + spool_l - 0.01]) cylinder(d1 = core_d, d2 = lip_d, h = (lip_d - core_d)/2 + 0.01);
    translate([0, 0, fl_t + spool_l + (lip_d - core_d)/2 - 0.01]) cylinder(d1 = lip_d, d2 = lip_d - 1, h = lip_x1 - core_x1 - (lip_d - core_d)/2 + 0.01);
  }
  translate([0, 0, fl_t + grv_z0 + grv_d/2]) helix_groove(grv_r, grv_d, grv_pitch, grv_turns);
  translate([grv_r - 0.2, 0, fl_t + grv_z0 + grv_d/2]) rotate([0, 90, 0]) cylinder(d = 1.3, h = 10, center = true, $fn = 16);  // tail hole
}

module wheel() difference() {      // assembly position, centred on its axle
  union() {
    translate([0, 0, -roll_h/2]) linear_extrude(roll_h) teeth2d(drv_d, drv_n, drv_tooth);
    translate([0, 0, roll_h/2 - 0.01]) cylinder(d = 5, h = thumb_z0 - roll_h/2 + 0.02);
    translate([0, 0, thumb_z0]) difference() {
      cylinder(d = thumb_d, h = thumb_t);
      for (i = [0:29]) rotate(i * 12) translate([thumb_d/2 + 0.3, 0, -1]) cylinder(d = 1.4, h = thumb_t + 2, $fn = 8);
    }
  }
  translate([0, 0, -5]) cylinder(d = pin_d + spin, h = 15, $fn = 32);
}

module idler(toothed = true) difference() {
  translate([0, 0, -idl_h/2]) if (toothed) linear_extrude(idl_h) teeth2d(idl_d, idl_n, idl_tooth); else cylinder(d = idl_d, h = idl_h);
  translate([0, 0, -5]) cylinder(d = pin_d + spin, h = 10, $fn = 32);
  if (!toothed) translate([0, 0, idl_h/2 - 0.3]) difference() { cylinder(d = idl_d - 0.8, h = 1); cylinder(d = pin_d + spin + 1.2, h = 1); }  // marks the smooth one
}

// The arm as printed (straight). ribs = false models them crushed (for the assembly-path check).
module arm_anchor(t = arm_t, ribs = true) {
  notches = search(t, arm_ts)[0] + 1;
  difference() {
    translate([anc_x0, anc_y0, brk_z0]) cube([anc_x1 - anc_x0, anc_y1 - anc_y0, arm_z1 - brk_z0]);
    for (i = [1:notches]) translate([anc_x0 + 0.8 * i - 0.2, anc_y0 - 1, arm_z1 - 0.5]) cube([0.4, anc_y1 - anc_y0 + 2, 1]);
  }
  if (ribs) for (x = [anc_x0 + 0.7, anc_x1 - 0.7], side = [0, 1])          // crush ribs: two each side, full height
    translate([x, side ? anc_y1 : anc_y0, brk_z0]) linear_extrude(arm_z1 - brk_z0)
      polygon(side ? [[-0.5, -0.01], [0.5, -0.01], [0, rib]] : [[-0.5, 0.01], [0, -rib], [0.5, 0.01]]);
}
module arm_swing(t = arm_t) {     // everything past the root: flexure, tip post, bracket plate, idler pin
  translate([anc_x1 - 0.01, arm_y0, arm_z0]) cube([x_n + 2.5 - anc_x1, t, arm_z1 - arm_z0]);   // flexure
  translate([x_n - 2.5, arm_y0, brk_z0]) cube([5, post_w, arm_z0 - brk_z0 + 0.01]);             // tip post down to the plate
  translate([0, 0, brk_z0]) linear_extrude(brk_z1 - brk_z0) hull() {                             // bracket plate, 2.1 thick
    translate(idl_cf) circle(d = pin_d + 2.4);
    translate([x_n - 2.5, arm_y0]) square([5, post_w]);
  }
  translate([idl_cf[0], idl_cf[1], brk_z1 - 0.01]) cylinder(d = pin_d, h = idl_h/2 - brk_z1, $fn = 32);   // idler pin
}
module arm(t = arm_t, ribs = true) { arm_anchor(t, ribs); arm_swing(t); }
// Working position: wire in, the flexure bent so the idler sits at idl_c (a swing about the root: close enough
// to the real bend for pockets and checks; the arm pocket leaves 0.6 mm round it).
module arm_bent(t = arm_t, ribs = false) {
  arm_anchor(t, ribs);
  translate([anc_x1, arm_y0 + t/2, 0]) rotate(th_pre) translate([-anc_x1, -(arm_y0 + t/2), 0]) arm_swing(t);
}

module nose() difference() {       // assembly position
  union() {
    along_x(ns_x, ns_t) circle(d = ns_d);
    translate([ns_x + ns_t - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = luer_tip + 0.06 * luer_l, d2 = luer_tip, h = luer_l);
  }
  along_x(ns_x - 1, 30) circle(d = 2.0, $fn = 24);
  translate([ns_x - 0.01, 0, 0]) rotate([0, 90, 0]) cylinder(d1 = 3, d2 = 2.0, h = 1);   // lead-in
}

module ring() linear_extrude(ring_w) difference() { hex2d(ring_c + ring_wall); hex2d(ring_c); }  // XY, axis = Z

/* ---------- Print orientations ---------- */
module p_base() translate([0, 0, F/2]) base();
module p_mid()  translate([0, 0, -z_b]) mid();
module p_lid()  translate([0, 0, F/2]) rotate([180, 0, 0]) lid();       // top flat on the bed
module p_spool() spool_local();                                          // flange down
module p_wheel() rotate([180, 0, 0]) translate([0, 0, -(thumb_z0 + thumb_t)]) wheel();   // thumbwheel down
module p_idler(t = true) translate([0, 0, idl_h/2]) idler(t);
module p_arm(t) translate([-anc_x0, -(idl_cf[1] - pin_d/2 - 1.2), -brk_z0]) arm(t);   // as printed: straight
module p_nose() translate([0, 0, -ns_x]) rotate([0, -90, 0]) nose();   // flange down

L = x_front;
module plate() {
  p_base();
  translate([0, 25, 0]) p_mid();
  translate([0, 50, 0]) p_lid();
  translate([L + 12, 0, 0]) p_spool();
  translate([L + 15, 22, 0]) p_wheel();
  translate([L + 13, 43, 0]) p_nose();
  translate([L + 30, -4, 0]) p_idler(true);
  translate([L + 30, 5, 0]) p_idler(false);
  for (i = [0:3]) translate([L + 38, -9 + i * 11, 0]) p_arm(arm_ts[i]);
  for (i = [0:1]) translate([L + 26 + i * 28, 66, 0]) ring();
}

/* ---------- Views ---------- */
module wire_path() color("#8d949c") {
  along_x(eye_x - 2, x_front + luer_l - eye_x + 2) circle(d = wire, $fn = 12);
  hull() { translate([lip_x1, 0, lip_d/2]) sphere(d = wire, $fn = 12); translate([eye_x - 2, 0, 0]) sphere(d = wire, $fn = 12); }
  translate([fl_x0 + fl_t + grv_z0 + grv_d/2, 0, 0]) rotate([0, 90, 0])
    for (i = [0:floor(grv_turns/2)]) translate([0, 0, i * grv_pitch]) rotate_extrude($fn = 32) translate([grv_r, 0]) circle(d = wire, $fn = 8);
}
C_BASE = "#7f8a96"; C_MID = "#a7b1bc"; C_LID = "#c9d1d9";
module s_arm(l = 0, bent = true) translate([0, 0, l]) color("#6bbf59") if (bent) arm_bent(); else arm();
module s_idler(l = 0, bent = true) let(c = bent ? idl_c : idl_cf) translate([c[0], c[1], l]) color("#e8e8e8") idler();
module s_wheel(l = 0) translate([drv_c[0], drv_c[1], l]) color("#3b82c4") wheel();
module s_spool(l = 0) translate([0, 0, l]) { color("#f0b429") spool(); wire_path(); }
module s_nose(l = 0)  translate([0, 0, l]) color("#e879b0") nose();
module s_mid(l = 0)   translate([0, 0, l]) color(C_MID) mid();
module s_lid(l = 0)   translate([0, 0, l]) color(C_LID) lid();
module s_rings(l = 0) color("#444") {
  translate([-0.05 - l, 0, 0]) rotate([0, 90, 0]) rotate(-90) ring();
  translate([x_front - ring_w + 0.05 + l, 0, 0]) rotate([0, 90, 0]) rotate(-90) ring();
}
module insides() { s_arm(); s_idler(); s_wheel(); s_spool(); s_nose(); }

if (part == "base") p_base();
if (part == "mid") p_mid();
if (part == "lid") p_lid();
if (part == "spool") p_spool();
if (part == "wheel") p_wheel();
if (part == "idler") p_idler(true);
if (part == "idler_smooth") p_idler(false);
if (part == "arm") p_arm(arm_t);
if (part == "nose") p_nose();
if (part == "ring") ring();
if (part == "plate") plate();
if (part == "assembly") { color(C_BASE) base(); s_mid(); s_lid(); insides(); s_rings(); }
if (part == "open") { color(C_BASE) base(); s_mid(); insides(); }
if (part == "nip") {     // top view of the drive, thumbwheel cut off so the nip shows
  color(C_BASE) base(); s_mid();
  color("#3b82c4") translate([drv_c[0], drv_c[1], 0]) intersection() { wheel(); translate([0, 0, -5]) cylinder(d = 30, h = 5 + roll_h/2); }
  s_idler(); s_arm(); s_nose(); wire_path();
}

// Assembly guide (docs/assembly.md): step N shows steps 1..N-1 in place and step N's part lifted above
// where it goes (dashed drop line). step 0 = everything exploded.
step = 1;
lift = 14;
module drop(p, h) color("#222") for (z = [1:3:h - 1]) translate([p[0], p[1], p[2] + z]) cylinder(d = 0.5, h = 1.6, $fn = 8);
if (part == "step") {
  color(C_BASE) base();
  if (step == 0) {
    s_mid(12); s_arm(24, false); s_idler(34, false); s_wheel(44); s_spool(30); s_nose(30); s_lid(64); s_rings(16);
  } else {
    if (step > 1) s_mid(); else if (step == 1) { s_mid(lift); }
    // arm + idler go in straight; from step 4 on they're shown pushed back (as when you hold the arm back to
    // drop the wheel in, and as the wire holds it once threaded)
    if (step > 3) s_arm(); else if (step == 3) s_arm(0, false); else if (step == 2) { s_arm(lift, false); drop([anc_x0 + 2, (anc_y0 + anc_y1)/2, arm_z1], lift - 2); }
    if (step > 3) s_idler(); else if (step == 3) { s_idler(lift, false); drop([idl_cf[0], idl_cf[1], idl_h/2], lift - 4); }
    if (step > 4) s_wheel(); else if (step == 4) { s_wheel(lift); drop([drv_c[0], drv_c[1], pin_top], lift - 8); }
    if (step > 5) s_spool(); else if (step == 5) { s_spool(lift); drop([16, 0, 5], lift - 5); }
    if (step > 6) s_nose(); else if (step == 6) { s_nose(lift); drop([ns_x + 1, 0, 6.5], lift - 6); }
    if (step > 7) s_lid(); else if (step == 7) s_lid(lift + 10);
    if (step == 8) s_rings(12);
  }
}

// One part in its assembled position, for the assembly-path check (checks/assembly_paths.py).
// Order and direction of assembly: mid, arm, idler, wheel, spool, nose, lid all drop in from above (-Z);
// the rings slide on along X from each end.
which = "base";
module ring_back()  translate([-0.05, 0, 0]) rotate([0, 90, 0]) rotate(-90) ring();
module ring_front() translate([x_front - ring_w + 0.05, 0, 0]) rotate([0, 90, 0]) rotate(-90) ring();
if (part == "at") {
  if (which == "base") base();
  if (which == "mid") mid();
  if (which == "lid") lid();
  if (which == "arm") arm(ribs = false);                                   // goes in straight (ribs crushed)
  if (which == "idler") translate([idl_cf[0], idl_cf[1], 0]) idler();
  if (which == "arm_bent") arm_bent();                                     // held back from the wheel step on
  if (which == "idler_bent") translate([idl_c[0], idl_c[1], 0]) idler();
  if (which == "wheel") translate([drv_c[0], drv_c[1], 0]) wheel();
  if (which == "spool") spool();
  if (which == "nose") nose();
  if (which == "ring_back") ring_back();
  if (which == "ring_front") ring_front();
}

// Pinch numbers for checks/pinch.py (part = "pinch"): how much idler travel the play in the force path can eat
// (anchor swivel in its slot, magnified out to the idler, plus the idler's bore clearance) against the preload,
// and the spring force of each arm (cantilever, tip load at the idler: F = 3 E I d / L^3, E ~ 2000 MPa PETG).
if (part == "pinch") {
  anc_play = rib > slot_a ? 0 : 2 * slot_a;                         // crush ribs take up the slot play
  L_idl = x_n - anc_x1;
  swivel = anc_play / (anc_x1 - anc_x0) * (L_idl + (anc_x1 - anc_x0) / 2);
  lost = swivel + spin / 2;
  for (t = arm_ts) echo(str("ARM t=", t, " F=", 3 * 2000 * (arm_z1 - arm_z0) * pow(t, 3) / 12 * pre / pow(L_idl, 3)));
  echo(str("PINCH pre=", pre, " lost=", lost, " plate=", brk_z1 - brk_z0, " force_x_offset=", abs(idl_c[0] - drv_c[0])));
  cube(1);
}
