// Solder pen concept A: TEST PRINT (2026-11-24). Proves the one risky thing: can a turning lead-screw core
// PUSH solder out through a channel and a Luer needle, and pull it back?
//
//   core (knob + journal + grooved lead screw + front pin, one part) turns inside a round ø15 barrel.
//   The solder is wound one layer deep in the core's helical groove, its tail hooked into a hole at the front.
//   The nut is keyed to a rib in the barrel so it can't turn: a tooth on it rides the EMPTY groove just
//   behind the coil, so each turn walks it forward one pitch, and the wire (the rearmost coil turn) leaves the
//   groove along a straight tangent, out through a tunnel in the nut that curves forward into a channel in
//   the barrel wall, then out through the nose and the needle.
//   Turn the knob one way: the core carries the coil round and pushes the wire out. Turn it back: winding the
//   wire back on puts it under tension, so it is pulled back in.
//   Two noses: STRAIGHT (needle off-centre, in line with the channel) and S (an S-bend brings the wire to a
//   centred needle). Swap them to see whether the bend costs too much push.
//
// Frame: pen axis = Z (z = 0 at the barrel's back face; the needle toward +Z). Angles seen from the front.
// Fits as in rig v2 (printed and fitted 2026-11-24): 0.5 on the diameter for spinning fits, 0.2-0.25 a side
// for slots, crush ribs where a part must not move.   Export: ./stl/export.sh solder_pen_a_test

part = "plate";   // plate | barrel | core | nut | nose_straight | nose_s | assembly | cutaway | fit_* (checks)
used = 0.3;       // fraction of the coil dispensed (sets the nut's position and the core's rotation, views)

/* ---------- Fits ---------- */
spin = 0.5;        // diametral, spinning
rad  = 0.25;       // radial, nut in the barrel / on the core
slot = 0.2;        // a side, rib in the nut's notch
rib  = 0.2;        // crush ribs on the nose spigot: 0.2 proud over a 0.15 gap = 0.05 nominal interference
                   // (rig v2's 0.3 interference arm anchor had to be sanded to fit, 2026-11-24)

/* ---------- Wire ---------- */
wire = 0.87;       // measured 0.86-0.88
ch_d = 1.3;        // wire channels and tunnels

/* ---------- Barrel ---------- */
OD   = 15;
bore = 10.8;
L_b  = 42;
key_a = 270; key_w = 1.6; key_r = 4.95;     // key rib along the bore (inner face at r 4.95)
r_ch = 6.1;                                  // wire channel centre radius (in the bore wall, open to the bore)

/* ---------- Core ---------- */
pitch = 1.4;
grv_d = 1.05;                // round groove (teardrop roof, prints standing)
root_r = 3.0;                // groove bottom
crest_r = 3.9;               // ø7.8 over the ridges
r_g = root_r + grv_d/2;      // groove centre = wire centre (3.525)
knob_l = 8; knob_gap = 0.3;
jr_z1 = 2;                   // journal z 0..2 in the bore
spg_l = 4;                   // nose spigot length inside the bore
core_z1 = L_b - spg_l - 0.3; // core's front shoulder, 0.3 behind the spigot
pin_d = 4; pin_l = 3;        // front pin into the spigot's socket

/* ---------- Nut ---------- */
nut_l = 7;
nut_id = 2 * (crest_r + rad);           // 8.3
nut_od = bore - 2 * rad;                // 10.3
pe = 1.5;                               // peel point this far in front of the nut's back face
tooth_d = 0.65;                         // follower in the groove (0.2 a side)
web_t = 0.4;
tooth_a0 = 45; tooth_a1 = 165;          // follower spans 45..165 deg behind the peel point
phi0 = 90;                              // peel point angle (nut frame)
rise = 4.5;                             // the wire turns from tangential to axial over this length
zn0 = jr_z1 + 0.3;                      // nut at the back (against the journal)
zn1 = core_z1 - nut_l;                  // nut at the front (against the spigot), less the shoulder gap
coil_l = zn1 - zn0;                     // peel point travel = wound length
turns = floor(coil_l / pitch);
coil_mm = turns * 2 * PI * r_g;         // ~0.44 m
anc_z = zn1 + pe + 0.7;                 // tail anchor: half a turn past the last peel point (little waste)

/* ---------- Nose ---------- */
nose_t = 3;                              // flange/body behind the taper
cs_h = 1.6;                              // 45 deg countersink at the barrel's mouth: the nose's cone sits in it (no overhang)
luer_l = 7.5; luer_tip = 3.925;          // ISO 594 6 % taper
s_len = 13;                              // S-bend length to the centred needle

$fn = 64;

/* ---------- Geometry helpers ---------- */
T  = [sqrt(r_ch*r_ch - r_g*r_g), r_g];   // where the tangent from the peel point (angle 90) reaches r_ch
phi_ch = atan2(T[1], T[0]);              // channel angle (35.3)
function bez2(a, b, c, t) = (1-t)*(1-t)*a + 2*t*(1-t)*b + t*t*c;
function bez3(a, b, c, d, t) = pow(1-t,3)*a + 3*t*pow(1-t,2)*b + 3*t*t*(1-t)*c + pow(t,3)*d;
// Wire path from the peel point (z = zp) out to the channel: in plan it is the straight tangent; it rises
// forward as it goes (quadratic Bezier with its corner at the channel).
// Flat until it is clear of the ridges (r = crest + 0.5), then it turns forward.
C_x = sqrt(pow(crest_r + 0.5, 2) - r_g*r_g);
C_dz = -pitch * (phi0 - atan2(r_g, C_x)) / 360;     // it keeps dropping with the groove until then
function exit_pts(zp, n = 16) = concat([[0, r_g, zp]], [for (i = [0:n]) let(t = i/n) bez2([C_x, r_g, zp + C_dz], [T[0], T[1], zp + C_dz], [T[0], T[1], zp + rise], t)]);
// Channel slot in plan: the tangent from where it crosses the bore out to the channel, so the wire never
// meets the bore wall on its way out.
module chan2d() hull() { translate(T) circle(d = ch_d, $fn = 24); translate([sqrt(pow(bore/2 - 0.4, 2) - r_g*r_g), r_g]) circle(d = ch_d, $fn = 24); }
function s_pts(n = 20) = [for (i = [0:n]) let(t = i/n) bez3([T[0], T[1], L_b], [T[0], T[1], L_b + s_len*0.45], [0, 0, L_b + s_len*0.55], [0, 0, L_b + s_len], t)];
module chain(pts, d, fn = 12) for (i = [0:len(pts)-2]) hull() { translate(pts[i]) sphere(d = d, $fn = fn); translate(pts[i+1]) sphere(d = d, $fn = fn); }

// Sweep an (dr, dz) profile along a right-hand helix of radius r: angle a (deg) at z = z0 + pitch * a / 360.
module helix(prof, r, a0, a1, z0, seg = 36) {
  n = max(2, ceil(abs(a1 - a0) / 360 * seg)); pf = len(prof);
  pts = [for (i = [0:n]) let(a = a0 + (a1 - a0) * i / n, z = z0 + pitch * a / 360)
           for (q = prof) [(r + q[0]) * cos(a), (r + q[0]) * sin(a), z + q[1]]];
  faces = concat(
    [for (i = [0:n-1]) for (j = [0:pf-1]) let(k = (j + 1) % pf) [i*pf + j, i*pf + k, (i+1)*pf + k, (i+1)*pf + j]],
    [[for (j = [pf-1:-1:0]) j]], [[for (j = [0:pf-1]) n*pf + j]]);
  if (a1 > a0) polyhedron(pts, faces, convexity = 10);
  else polyhedron(pts, [for (f = faces) [for (j = [len(f)-1:-1:0]) f[j]]], convexity = 10);
}
// teardrop: round where the wire sits, 45 deg roof toward +z (prints standing)
function tear(d) = concat([for (t = [-180:20:40]) [d/2 * cos(t), d/2 * sin(t)]], [[0, d/2 * sqrt(2)]], [[-d/2 * cos(45), d/2 * sin(45)]]);

/* ---------- State (views and fit checks) ---------- */
zn  = zn0 + used * coil_l;                       // nut back face
zp  = zn + pe;                                   // peel point
g0  = zn0 + pe;                                  // core frame: the groove passes angle 0 at z = g0
rot = phi0 - 360 * (zp - g0) / pitch;            // core rotation that puts the groove at the peel point

/* ---------- Parts (assembly position) ---------- */
module barrel() difference() {
  cylinder(d = OD, h = L_b);
  translate([0, 0, -1]) difference() {
    cylinder(d = bore, h = L_b + 2);
    rotate(key_a) translate([key_r, -key_w/2, jr_z1 + 0.3 + 1]) cube([3, key_w, L_b - cs_h - 0.3 - (jr_z1 + 0.3)]);     // key rib (left standing): from in front of the journal to behind the mouth
  }
  translate([0, 0, -1]) linear_extrude(L_b + 2) chan2d();   // channel, open to the bore
  translate([0, 0, L_b - cs_h]) cylinder(r1 = bore/2, r2 = bore/2 + cs_h, h = cs_h + 0.01);   // 45 deg mouth for the nose's cone
}

module core() rotate(rot) difference() {
  union() {
    translate([0, 0, -knob_l - knob_gap]) difference() {          // knob, knurled, with a pointer bump
      cylinder(d = OD, h = knob_l);
      for (i = [0:23]) rotate(i * 15) translate([OD/2 + 0.2, 0, -1]) cylinder(d = 1.6, h = knob_l + 2, $fn = 8);
    }
    translate([0, 0, -knob_gap - 0.01]) cylinder(d = bore - spin, h = jr_z1 + knob_gap + 0.01);   // journal
    translate([0, 0, jr_z1 - 0.01]) cylinder(r = crest_r, h = core_z1 - jr_z1 + 0.01);        // lead screw
    translate([0, 0, core_z1 - 0.01]) cylinder(d = pin_d, h = pin_l + 0.01);                 // front pin
  }
  // groove: from behind the first peel point to past the anchor
  helix(tear(grv_d), r_g, 360 * (jr_z1 + 0.6 - g0) / pitch, 360 * (core_z1 - 0.8 - g0) / pitch, g0);
  // tail anchor: radial hole into the groove at anc_z
  let(a = 360 * (anc_z - g0) / pitch) rotate(a) translate([0, 0, anc_z]) rotate([0, 90, 0]) cylinder(d = 1.0, h = 2 * crest_r + 1, center = false, $fn = 12);
}

module nut() difference() {
  union() {
    translate([0, 0, zn]) difference() {
      cylinder(d = nut_od, h = nut_l);
      translate([0, 0, -1]) cylinder(d = nut_id, h = nut_l + 2);
      rotate(key_a) translate([key_r - 0.3, -(key_w/2 + slot), -1]) cube([3, key_w + 2*slot, nut_l + 2]);   // notch for the key rib
    }
    // follower tooth + web, on the groove's helix (nut frame: groove at angle phi0 is at z = zp)
    helix(tear(tooth_d), r_g, phi0 - tooth_a1, phi0 - tooth_a0, zp - pitch * phi0 / 360);
    helix([[0, -web_t/2], [nut_id/2 - r_g + 0.3, -web_t/2], [nut_id/2 - r_g + 0.3, web_t/2], [0, web_t/2]], r_g + 0.1, phi0 - tooth_a1, phi0 - tooth_a0, zp - pitch * phi0 / 360);
  }
  chain(exit_pts(zp), ch_d);                                                      // exit tunnel
}

module luer() cylinder(d1 = luer_tip + 0.06 * luer_l, d2 = luer_tip, h = luer_l);
module spigot() union() {       // goes into the barrel's front, keyed by the rib, held by crush ribs
  translate([0, 0, L_b - spg_l]) cylinder(d = bore - 2*0.15, h = spg_l + 0.01);
  for (a = [30, 150]) rotate(a) translate([bore/2 - 0.15, 0, L_b - spg_l]) linear_extrude(spg_l) polygon([[-0.1, -0.6], [rib, 0], [-0.1, 0.6]]);
}
module nose_cuts() {           // applied to the whole nose (spigot + cone + body)
  rotate(key_a) translate([key_r - 0.3, -(key_w/2 + slot), L_b - spg_l - 1]) cube([3, key_w + 2*slot, spg_l + 1 - cs_h]);
  translate([0, 0, L_b - spg_l - 1]) cylinder(d = pin_d + spin, h = pin_l + 0.3 + 1);   // core's front pin
  translate([0, 0, L_b - spg_l + pin_l + 0.3 - 0.01]) cylinder(d1 = pin_d + spin, d2 = 0, h = (pin_d + spin)/2);   // 45 deg roof (no ceiling)
  translate([0, 0, L_b - spg_l - 1]) linear_extrude(spg_l + 1) chan2d();                  // channel slot, to the barrel's face
}
module nose_body() {     // 45 deg cone in the barrel's mouth, 45 deg out to the full OD, then the body
  translate([0, 0, L_b - cs_h]) cylinder(r1 = bore/2 - 0.15, r2 = bore/2 + cs_h - 0.15, h = cs_h);
  translate([0, 0, L_b - 0.01]) cylinder(r1 = bore/2 + cs_h - 0.15, r2 = OD/2, h = OD/2 - (bore/2 + cs_h - 0.15) + 0.01);
  translate([0, 0, L_b + OD/2 - (bore/2 + cs_h - 0.15)]) cylinder(d = OD, h = nose_t - (OD/2 - (bore/2 + cs_h - 0.15)));
}
module nose_straight() difference() {
  union() {
    spigot();
    nose_body();
    translate([T[0], T[1], L_b + nose_t - 0.01]) luer();
  }
  nose_cuts();
  translate([T[0], T[1], L_b - 1]) cylinder(d = ch_d + 0.3, h = nose_t + luer_l + 2, $fn = 24);
}
module nose_s() difference() {
  union() {
    spigot();
    nose_body();
    translate([0, 0, L_b + nose_t - 0.01]) cylinder(d1 = OD, d2 = luer_tip + 0.06 * luer_l + 2, h = s_len - nose_t + 0.01);
    translate([0, 0, L_b + s_len - 0.01]) luer();
  }
  nose_cuts();
  translate([T[0], T[1], L_b - 1]) cylinder(d = ch_d + 0.3, h = 1.01, $fn = 24);
  chain(s_pts(), ch_d + 0.3);
  translate([0, 0, L_b + s_len - 0.5]) cylinder(d = ch_d + 0.3, h = luer_l + 1, $fn = 24);
}

/* ---------- Print orientations ---------- */
module p_barrel() barrel();                                                       // back face down
module p_core() translate([0, 0, knob_l + knob_gap]) rotate(-rot) core();         // knob down
module p_nut() translate([0, 0, zn + nut_l]) rotate([180, 0, 0]) nut();          // front face down: the tooth's roof faces down at 45
module p_nose(s) translate([0, 0, -(L_b - spg_l)]) if (s) nose_s(); else nose_straight();   // spigot down
module plate() {
  p_barrel();
  translate([22, 0, 0]) p_core();
  translate([0, 22, 0]) p_nut();
  translate([22, 22, 0]) p_nose(false);
  translate([44, 11, 0]) p_nose(true);
}

/* ---------- Views ---------- */
module wire_view(out = 6) color("#8d949c") {
  helix(circ_prof(wire), r_g, phi0, 360 * (anc_z - zp) / pitch + phi0, zp - pitch * phi0 / 360);
  chain(exit_pts(zp), wire, 8);
  chain([[T[0], T[1], zp + rise], [T[0], T[1], L_b + nose_t + luer_l + 20 + out]], wire, 8);
}
function circ_prof(d) = [for (i = [0:7]) [d/2 * cos(45 * i), d/2 * sin(45 * i)]];
module assembly(s = false, cut = true) {
  difference() {
    union() { color("#c9d1d9") barrel(); color("#e879b0") if (s) nose_s(); else nose_straight(); }
    if (cut) rotate(phi_ch) translate([-20, 0, -20]) cube([40, 20, 120]);   // cut on the plane through the channel
  }
  color("#f0b429") core(); color("#3b82c4") nut(); if (!s) wire_view();
}
// exploded: one row per part, each lying along +X and cut on the channel plane (front to the right)
module row(y) translate([0, 0, y]) rotate([0, 90, 0]) rotate(-phi_ch - 180) children();
module cut_half() difference() { children(); rotate(phi_ch) translate([-20, 0, -20]) cube([40, 20, 120]); }
module exploded() {
  row(0)   cut_half() color("#c9d1d9") barrel();
  row(-20) { color("#f0b429") core(); wire_view(); }
  row(-40) color("#3b82c4") nut();
  row(-60) cut_half() color("#e879b0") nose_straight();
  row(-80) cut_half() color("#e879b0") nose_s();
}
if (part == "exploded") exploded();
// wound: core + nut + wire, nut at the back (use = 0), anchor hole turned toward the viewer (-y). Axis along +X.
hole_abs = 360 * (anc_z - g0) / pitch + rot;
if (part == "wound") rotate([0, 90, 0]) rotate(270 - hole_abs) { color("#f0b429") core(); color("#3b82c4") nut(); wire_view(0); }
if (part == "barrel") p_barrel();
if (part == "core") p_core();
if (part == "nut") p_nut();
if (part == "nose_straight") p_nose(false);
if (part == "nose_s") p_nose(true);
if (part == "plate") plate();
if (part == "assembly") assembly(false, false);
// lying along +X, cut on the plane through the channel (channel along the top edge), seen from the cut side
if (part == "cutaway") rotate([0, 90, 0]) rotate(-phi_ch - 180) assembly(false, true);

/* ---------- Fit checks (checks/run.sh): each must come out EMPTY ---------- */
// used = 0 and 1 are both checked, so the nut is clear at both ends of its travel.
if (part == "fit_nut_core")   intersection() { nut(); core(); }
if (part == "fit_nut_barrel") intersection() { nut(); barrel(); }
if (part == "fit_core_barrel") intersection() { core(); barrel(); }
if (part == "fit_core_nose")  intersection() { core(); union() { nose_straight(); nose_s(); } }
if (part == "fit_nut_nose")   intersection() { nut(); union() { nose_straight(); nose_s(); } }
if (part == "fit_wire_path")  intersection() {     // the wire's path from the peel point to the needle is clear
  union() { chain(exit_pts(zp), wire - 0.15, 8); chain([[T[0], T[1], zp + rise], [T[0], T[1], L_b + nose_t + luer_l + 1]], wire - 0.15, 8); }
  union() { nut(); barrel(); core(); nose_straight(); }
}
// dbg_<part>: which part blocks the wire path, when fit_wire_path fails
for (k = ["nut", "barrel", "core", "nose"]) if (part == str("dbg_", k)) intersection() {
  union() { chain(exit_pts(zp), wire - 0.15, 8); chain([[T[0], T[1], zp + rise], [T[0], T[1], L_b + nose_t + luer_l + 1]], wire - 0.15, 8); }
  if (k == "nut") nut(); if (k == "barrel") barrel(); if (k == "core") core(); if (k == "nose") nose_straight();
}
if (part == "fit_wire_s") intersection() { chain(s_pts(), wire - 0.15, 8); nose_s(); }
if (part == "info") { echo(str("INFO turns=", turns, " coil_mm=", coil_mm, " coil_l=", coil_l, " phi_ch=", phi_ch, " len=", knob_l + knob_gap + L_b + nose_t + luer_l)); cube(1); }
