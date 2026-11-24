// Solder pen concept C: "stick" (2026-11-24). A flat 16 x 11 stick, ~124 long plus the needle.
// Learnt from a working MakerWorld solder dispenser the user printed (studied 2026-11-24), then slimmed:
//   - the wire lies in an OPEN groove you drop it into; no tunnels to thread
//   - the pinch spring is the body itself: a slit splits off a long (76 mm) arm, soft enough to forgive FDM
//   - a ring slides along the body; the arm's outer edge flares, so sliding the ring forward squeezes the arm
//     in (pinch on), sliding it back lets it spring open (1.6 mm gap: lay the wire in). Ridges = detents.
//   - both rollers are driven: knurled rims grip the wire, spur gears under them mesh with each other
//   - the spool turns on a peg (a bobbin in a window at the back, inside the body's outline)
//   - nothing finer than ~0.6 mm (gear module 0.63, knurl 0.5 deep)
//
// Frame: pen axis = X (x = 0 at the back, the needle toward +X), Y across the width, Z up = print bed up.
// The body prints flat as modelled; every pocket opens upward. Thumb rim pokes out of the -Y side.
// Export: ./stl/export.sh solder_pen_c

part = "assembly";   // plate | body | bobbin | gear_fixed | gear_arm | ring | clip | nose | assembly | open |
                     // exploded | top | fit_* (checks) | info
pinched = true;      // views/fits: ring forward, arm in (true) or ring back, arm at rest (false)
ring_x = 84;         // views: ring's front edge (pinch on). Open: 50
phase = 0;           // fit_mesh: fixed gear rotation (deg)

/* ---------- Fits (as rig v2, printed 2026-11-24) ---------- */
spin = 0.5;          // diametral, gears and bobbin on their pegs
cl = 0.4;            // radial, gears in their pockets
ax = 0.3;            // axial gaps between layers
nfit = 0.15;         // nose block in its pocket, a side; crush ribs 0.2 proud
rfit = 0.15;         // ring over the body

/* ---------- Wire ---------- */
wire = 0.87;         // measured 0.86-0.88
grv_w = 1.6;         // open groove width

/* ---------- Body ---------- */
W = 16; H = 11; ch = 1.0;           // section, 45 deg chamfers on all four long edges
L = 116;                            // body length (the Luer sticks out past it)
x_r = 24;                           // arm root (back end of the slit)
x_g = 100;                          // gears' axis
arm_b = 2.6;                        // arm width (bends in Y; full height)
sA_w = 2.4; sA_y = 4.2;             // long slit: y 3.0-5.4
flare0 = 52; flare1 = 92; flare = 2.0;   // arm edge flares out from y=8 to y=10 between these x
det0 = 56; det1 = 87; det_p = 3; det_h = 0.35;   // detent ridges on the -Y edge
fl = 3.0;                           // floor under the gears
bfl = 1.5;                          // floor under the bobbin

/* ---------- Gears ---------- */
kn_r = 3.5; kn_n = 16; kn_d = 0.5;  // knurl rim radius, teeth, depth
bite = 0.15;                        // each knurl sinks this far into the wire when pinched
c_p = 2*kn_r + wire - 2*bite;       // centre distance, pinched (7.57)
gap_rest = 1.6;                     // knurl gap at rest: lay the wire in
c_r = 2*kn_r + gap_rest;            // centre distance at rest (8.6)
z_n = 12; m = c_p / z_n;            // 12 teeth, module 0.631
pa = 20; add = 0.95; ded = 1.25; blash = 0.15;
rp = c_p / 2; rb = rp * cos(pa); ra = rp + add*m; rr = rp - ded*m;
peg_d = 3.0; bore = peg_d + spin;
rim_r = 6.0; rim_n = 14;            // thumb rim on the fixed gear
z_kn = fl + ax;                     // knurl layer bottom (3.3)
kn_h = 2.0; sp_h = 2.0; rim_h = 2.0;
z_sp = z_kn + kn_h;                 // spur layer (5.3)
z_rim = z_sp + sp_h + ax;           // rim (7.6); the fixed gear's spur runs up to it
z_w = z_kn + kn_h/2;                // wire height (4.3)
y_f = -rp;                          // fixed gear centre
y_a0 = y_f + c_r;                   // arm gear centre at rest (4.815)
y_ap = y_f + c_p;                   // arm gear centre pinched (3.785)
d_w = y_a0 - y_ap;                  // arm travel at the gear to pinch (1.03)

/* ---------- Pegs, clip ---------- */
z_top = z_rim + rim_h;              // stack top (9.6), gears and bobbin
nk0 = z_top + 0.15; nk_h = 0.8; nk_d = 2.2;   // neck for the clip
peg_top = nk0 + nk_h + 0.25;        // 10.8
clip_t = 0.7; clip_ro = 3.3;

/* ---------- Bobbin ---------- */
xb = 8;                             // bobbin axis (the back end is a half-circle round it)
win_r = 6.8;
bb_r = 6.3; bc_r = 3.5;             // flange, core
bb_z0 = bfl + ax;                   // 1.8
bb_fl = 0.9;                        // bottom flange; the top flange is a 45 deg cone (prints without support)
bb_h = z_top - bb_z0;

/* ---------- Nose ---------- */
nx0 = 108; nx1 = 113;               // block in its pocket
nb_w = 8; nb_z0 = 1.0;
luer_l = 7.5; luer_tip = 3.925; neck_r = 2.2;
bore_n = 1.6;

/* ---------- Ring ---------- */
ring_l = 7; ring_t = 1.6;
ry0 = -W/2 - det_h - 0.05;          // ring's inside face on the ridge side (clears the ridge tips)
ry1 = -W/2 + W + rfit;              // inside face on the arm side when its bump sits on the flat (8.15)
bump = det_h + 0.05;                // the bump reaches the body's flat between ridges

$fn = 48;

/* ---------- 2D helpers ---------- */
module seg(p, q, w) hull() { translate(p) square(w, center = true); translate(q) square(w, center = true); }
function arm_y(x) = x <= flare0 ? W/2 : x >= flare1 ? W/2 + flare : W/2 + flare * (x - flare0) / (flare1 - flare0);
module outline() {
  translate([xb, 0]) circle(r = W/2, $fn = 96);
  translate([xb, -W/2]) square([L - 3 - xb, W]);
  polygon([[L - 3, -W/2], [L, -W/2 + 3], [L, W/2 - 3], [L - 3, W/2]]);            // front corners
  polygon([[flare0, 0], [flare0, W/2], [flare1, W/2 + flare], [x_g + 4.1, W/2 + flare], [x_g + 4.1, 0]]);
}
module slits2d() {
  seg([x_r, sA_y], [x_g - 6, sA_y], sA_w);
  seg([x_g - 6, sA_y], [x_g - 3, 0], 1.4);
  seg([x_g - 3, 0], [x_g + 4.1, 0], 1.6);
  seg([x_g + 4.1, 0], [x_g + 4.1, 14], 1.2);
}
module arm2d() polygon([[x_r, sA_y], [x_g - 6, sA_y], [x_g - 3, 0], [x_g + 4.1, 0], [x_g + 4.1, 14], [x_r, 14]]);
// arm deflection for views: rotate about its root by the angle that brings the gear in by d_w
arm_rot = -atan(d_w / (x_g - x_r));
module arm_move(on) if (on) translate([x_r, sA_y]) rotate(arm_rot) translate([-x_r, -sA_y]) children(); else children();

/* ---------- Gears ---------- */
function inv_pt(t) = rb * [cos(t * 180/PI) + t * sin(t * 180/PI), sin(t * 180/PI) - t * cos(t * 180/PI)];
function inv_ang(r) = let(t = sqrt(max(0, (r/rb)*(r/rb) - 1))) (t - atan(t) * PI/180) * 180/PI;   // deg
module spur2d() {
  hw = ((PI * m / 2 - blash) / (2 * rp)) * 180/PI + inv_ang(rp);   // half tooth angle at the base circle
  r0 = max(rb, rr);
  rs = [for (i = [0:8]) r0 + (ra - r0) * i / 8];
  circle(r = rr + 0.01, $fn = 60);
  for (k = [0:z_n-1]) rotate(k * 360 / z_n) polygon(concat(
    [[0, 0]], [[rr * cos(-hw), rr * sin(-hw)]],
    [for (r = rs) let(a = -hw + inv_ang(r)) [r * cos(a), r * sin(a)]],
    [for (i = [8:-1:0]) let(r = rs[i], a = hw - inv_ang(r)) [r * cos(a), r * sin(a)]],
    [[rr * cos(hw), rr * sin(hw)]]));
}
module knurl2d() difference() {
  circle(r = kn_r, $fn = 64);
  for (k = [0:kn_n-1]) rotate(k * 360 / kn_n) translate([kn_r, 0]) rotate(45) square(kn_d * sqrt(2), center = true);
}
module rim2d() difference() {
  circle(r = rim_r, $fn = 96);
  for (k = [0:rim_n-1]) rotate(k * 360 / rim_n) translate([rim_r + 0.35, 0]) circle(r = 0.9, $fn = 16);
}
// installed position, axis at origin, z as in the pen
module gear_fixed_at() difference() {
  union() {
    translate([0, 0, z_kn]) linear_extrude(kn_h) knurl2d();
    translate([0, 0, z_sp - 0.01]) linear_extrude(z_rim - z_sp + 0.01) spur2d();
    translate([0, 0, z_rim - 0.01]) linear_extrude(rim_h + 0.01) rim2d();
  }
  translate([0, 0, -1]) cylinder(d = bore, h = 20);
}
// the arm gear sits half a tooth round, so its gap faces the fixed gear's tooth at 90 deg
module gear_arm_at() rotate(180 / z_n) difference() {
  union() {
    translate([0, 0, z_kn]) linear_extrude(kn_h) knurl2d();
    translate([0, 0, z_sp - 0.01]) linear_extrude(sp_h + 0.01) spur2d();
  }
  translate([0, 0, -1]) cylinder(d = bore, h = 20);
}

/* ---------- Body ---------- */
module peg(z0, top) {
  translate([0, 0, z0 - 0.01]) cylinder(r = peg_d/2 + 0.7, h = ax + 0.01);            // collar the part rides on
  difference() {
    union() {
      translate([0, 0, z0 - 0.01]) cylinder(d = peg_d, h = top - z0 - 0.4 + 0.01);
      translate([0, 0, top - 0.4]) cylinder(d1 = peg_d, d2 = peg_d - 0.8, h = 0.4);
    }
    if (top > nk0 + nk_h) translate([0, 0, nk0]) difference() { cylinder(d = peg_d + 1, h = nk_h); translate([0, 0, -1]) cylinder(d = nk_d, h = nk_h + 2); }
  }
}
module body_shell() minkowski() {
  translate([0, 0, ch]) linear_extrude(H - 2*ch) offset(delta = -ch) outline();
  polyhedron([[ch, 0, 0], [0, ch, 0], [-ch, 0, 0], [0, -ch, 0], [0, 0, ch], [0, 0, -ch]],
             [[0, 1, 4], [1, 2, 4], [2, 3, 4], [3, 0, 4], [1, 0, 5], [2, 1, 5], [3, 2, 5], [0, 3, 5]]);   // octahedron: 45 deg chamfers
}
module ridges() for (x = [det0 : det_p : det1])
  translate([x, -W/2, ch]) linear_extrude(H - 2*ch) polygon([[-0.8, 0.01], [0, -det_h], [0.8, 0.01]]);
module body_pockets() {
  // bobbin window
  translate([xb, 0, bfl]) cylinder(r = win_r, h = H);
  // wire: funnel from the window down to the groove, groove to the gears, groove to the nose
  hull() { translate([xb + win_r - 1, -5, bfl + 0.3]) cube([0.1, 10, H]); translate([26, -grv_w/2, z_w - wire/2 - 0.15]) cube([0.1, grv_w, H]); }
  translate([26, -grv_w/2, z_w - wire/2 - 0.15]) cube([nx0 - 26 + 0.1, grv_w, H]);
  // gear pockets
  translate([x_g, y_f, fl]) cylinder(r = ra + cl, h = H);
  translate([x_g, y_f, z_rim - ax/2]) cylinder(r = rim_r + cl, h = H);
  hull() for (y = [y_ap, y_a0]) translate([x_g, y, fl]) cylinder(r = ra + cl, h = H);
  // nose pocket + the slot its neck passes through
  translate([nx0 - nfit, -nb_w/2 - nfit, nb_z0]) cube([nx1 - nx0 + 2*nfit, nb_w + 2*nfit, H]);
  hull() { translate([nx1 - 1, 0, z_w]) rotate([0, 90, 0]) cylinder(r = neck_r + 0.2, h = L); translate([nx1 - 1, -neck_r - 0.2, H]) cube([L, 2*neck_r + 0.4, 1]); }
}
module body() difference() {
  union() {
    difference() { union() { body_shell(); ridges(); } body_pockets(); }
    translate([xb, 0, 0]) peg(bfl, peg_top);
    translate([x_g, y_f, 0]) peg(fl, peg_top);
    translate([x_g, y_a0, 0]) peg(fl, z_sp + sp_h - 0.3);
  }
  translate([0, 0, -1]) linear_extrude(H + 2) slits2d();
}
module body_fixed() difference() { body(); translate([0, 0, -1]) linear_extrude(H + 2) arm2d(); }
module body_arm() intersection() { body(); translate([0, 0, -1]) linear_extrude(H + 2) arm2d(); }

/* ---------- Bobbin ---------- */
module bobbin_at() difference() {
  rotate_extrude($fn = 96) polygon([[bore/2, bb_z0], [bb_r, bb_z0], [bb_r, bb_z0 + bb_fl], [bc_r, bb_z0 + bb_fl],
    [bc_r, z_top - (bb_r - bc_r)], [bb_r, z_top], [bore/2, z_top]]);
  // tail slot: bend the first 3 mm of the wire down into it, then wind
  translate([bc_r - 1.2, -0.5, bb_z0 + bb_fl]) cube([bb_r, 1.0, H]);
}

/* ---------- Clip (one for the bobbin's peg, one for the fixed gear's) ---------- */
module clip2d() difference() {
  union() { circle(r = clip_ro); translate([-clip_ro - 2.5, -1.4]) square([3, 2.8]); }   // tab to push it on
  circle(d = nk_d + 0.1);
  translate([0, -(nk_d - 0.4)/2]) square([clip_ro + 1, nk_d - 0.4]);   // mouth snaps over the neck
}

/* ---------- Nose: male Luer-lock (ISO 80369-7), printed standing (back face down) ----------
   The user's blunt needle has a standard female Luer-lock hub (clear, two lugs; 31.69 long overall, 14 mm
   shaft, OD 1.97). It pushes onto the 6 % taper and its lugs screw into the collar's double-start thread
   (lead 5), as on a syringe. Collar thread: minor 7.0 / major 8.0 per the standard, + lk_fit for print. */
ribs = true;         // fit_nose_body leaves out the crush ribs (they are meant to bite)
lk_minor = 7.0; lk_major = 8.0; lk_lead = 5.0; lk_fit = 0.3;
lk_wall = 1.2;
lk_ro = lk_major/2 + lk_fit/2 + lk_wall;     // collar outside radius (5.35)
x_cone = L;                                  // the neck flares out at 45 deg in front of the body...
x_col = x_cone + (lk_ro - neck_r);           // ...to the collar (no overhang standing up)
x_tip = x_col + luer_l;                      // taper tip
module lock_thread(r_in, depth, len) {       // two 45 deg grooves, right-hand, cut into the collar's bore
  for (s = [0, 180]) helix_x(s, r_in, depth, len);
}
module helix_x(a0, r_in, depth, len) {       // groove along +x (axis at the origin), profile w at r_in -> 45 deg
  n = ceil(len / lk_lead * 48); w = 1.6;
  prof = [[r_in - 0.3, -w/2 - 0.3], [r_in + depth, -w/2 + depth], [r_in + depth, w/2 - depth], [r_in - 0.3, w/2 + 0.3]];
  pts = [for (i = [0:n]) let(t = i / n * len, a = a0 + 360 * t / lk_lead) for (q = prof) [t + q[1], q[0] * cos(a), q[0] * sin(a)]];
  pf = len(prof);
  faces = concat([for (i = [0:n-1]) for (j = [0:pf-1]) let(k = (j + 1) % pf) [i*pf + j, (i+1)*pf + j, (i+1)*pf + k, i*pf + k]],
                 [[for (j = [0:pf-1]) j]], [[for (j = [pf-1:-1:0]) n*pf + j]]);
  polyhedron(pts, faces, convexity = 10);
}
module nose_at() difference() {
  union() {
    translate([nx0, -nb_w/2, nb_z0]) cube([nx1 - nx0, nb_w, H - nb_z0]);
    if (ribs) for (s = [-1, 1], z = [nb_z0 + 2, H - 2]) translate([nx0, s * nb_w/2, z]) rotate([0, 90, 0]) linear_extrude(nx1 - nx0) polygon([[-0.6, 0], [0, s * (nfit + 0.2)], [0.6, 0]]);
    translate([0, 0, z_w]) rotate([0, 90, 0]) {
      translate([0, 0, nx1 - 0.01]) cylinder(r = neck_r, h = x_cone - nx1 + 0.02);
      translate([0, 0, x_cone]) cylinder(r1 = neck_r, r2 = lk_ro, h = x_col - x_cone);                 // 45 deg flare
      translate([0, 0, x_col - 0.01]) difference() {                                                    // lock collar
        cylinder(r = lk_ro, h = luer_l - 0.5);
        translate([0, 0, -0.01]) cylinder(d = lk_minor + lk_fit, h = luer_l);
      }
      translate([0, 0, x_col - 0.01]) cylinder(d1 = luer_tip + 0.06 * luer_l, d2 = luer_tip, h = luer_l + 0.01);   // 6 % taper
    }
  }
  translate([x_col, 0, z_w]) intersection() {                                   // lock thread in the collar's bore
    lock_thread((lk_minor + lk_fit)/2, (lk_major - lk_minor)/2, luer_l);
    rotate([0, 90, 0]) difference() { cylinder(r = lk_ro - 0.6, h = luer_l); cylinder(r = luer_tip/2 + 0.06 * luer_l/2 + 0.3, h = luer_l); }
  }
  translate([nx0 - 1, 0, z_w]) rotate([0, 90, 0]) cylinder(d = bore_n, h = 40, $fn = 24);
  translate([nx0 - 0.01, 0, z_w]) rotate([0, 90, 0]) cylinder(d1 = 3.2, d2 = bore_n, h = (3.2 - bore_n)/2, $fn = 24);   // 45 deg funnel
}

/* ---------- Ring (slides on from the back) ---------- */
module ring_in2d() offset(delta = 0) polygon([[ry0, -rfit + ch], [ry0 + ch, -rfit], [ry1 - ch, -rfit], [ry1, -rfit + ch],
  [ry1, H + rfit - ch], [ry1 - ch, H + rfit], [ry0 + ch, H + rfit], [ry0, H + rfit - ch]]);
// in its own frame: profile in (y, z), length along +x from 0
module ring_local() difference() {
  rotate([90, 0, 90]) linear_extrude(ring_l) offset(r = ring_t) ring_in2d();
  translate([-1, 0, 0]) rotate([90, 0, 90]) linear_extrude(ring_l + 2) ring_in2d();
  // the detent bump is added back inside, on the ridge side
}
module ring_bump() translate([ring_l/2, ry0, ch + 0.5]) linear_extrude(H - 2*ch - 1) polygon([[-0.8, -0.01], [0, bump], [0.8, -0.01]]);
module ring_at(xf) translate([xf - ring_l, 0, 0]) union() { ring_local(); ring_bump(); }

/* ---------- Print orientations ---------- */
module p_body() body();
module p_bobbin() translate([0, 0, -bb_z0]) bobbin_at();
module p_gear_fixed() translate([0, 0, z_top]) rotate([180, 0, 0]) gear_fixed_at();     // rim down
module p_gear_arm() translate([0, 0, z_sp + sp_h]) rotate([180, 0, 0]) gear_arm_at();   // spur down
module p_ring() rotate([0, -90, 0]) translate([-ring_l, 0, 0]) union() { ring_local(); ring_bump(); }
module p_clip() linear_extrude(clip_t) clip2d();
module p_nose() translate([0, 0, 0]) rotate([0, -90, 0]) translate([-nx0, 0, -z_w]) nose_at();   // back face down
module plate() {
  p_body();
  translate([30, -22, 0]) p_bobbin();
  translate([50, -22, 0]) p_gear_fixed();
  translate([66, -22, 0]) p_gear_arm();
  translate([90, -24, 0]) p_ring();
  translate([10, -22, 0]) p_clip();
  translate([10, -32, 0]) p_clip();
  translate([118, -22, 0]) p_nose();
}

/* ---------- Views ---------- */
module wire_view() color("#8d949c") {
  // coil on the bobbin (a few turns shown as rings), then the straight run out of the needle
  for (z = [bb_z0 + bb_fl + wire/2 : wire : z_top - (bb_r - bc_r) - wire/2]) translate([xb, 0, z]) rotate_extrude($fn = 48) translate([5.2, 0]) circle(d = wire, $fn = 8);
  hull() { translate([xb + 2, 5.2, 5]) sphere(d = wire, $fn = 8); translate([28, 0, z_w]) sphere(d = wire, $fn = 8); }
  translate([28, 0, z_w]) rotate([0, 90, 0]) cylinder(d = wire, h = x_tip + 34 - 28, $fn = 8);
}
module needle() color("#c0c6cc") translate([x_tip - 6, 0, z_w]) rotate([0, 90, 0]) difference() {
  union() { cylinder(d = 7, h = 12); translate([0, 0, 11.99]) cylinder(d = 1.97, h = 20); }
  translate([0, 0, -1]) cylinder(d = 1.2, h = 40);
}
module pen(on = true, rx = 84, wires = true, ring = true) {
  color("#c9d1d9") body_fixed();
  color("#c9d1d9") arm_move(on) body_arm();
  color("#f0b429") translate([x_g, y_f, 0]) gear_fixed_at();
  color("#3b82c4") arm_move(on) translate([x_g, y_a0, 0]) gear_arm_at();
  color("#7c5cbf") translate([xb, 0, 0]) bobbin_at();
  color("#e879b0") nose_at();
  if (ring) color("#2bb673") ring_at(rx);
  color("#f97316") for (p = [[xb, 0], [x_g, y_f]]) translate([p[0], p[1], nk0 + 0.05]) linear_extrude(clip_t) clip2d();
  if (wires) wire_view();
}
if (part == "assembly") pen(true, ring_x);
if (part == "open") pen(false, 50, false);
if (part == "top") pen(pinched, ring_x);
if (part == "exploded") {
  color("#c9d1d9") body();
  color("#7c5cbf") translate([xb, 0, 14]) bobbin_at();
  color("#f97316") for (p = [[xb, 0, 26], [x_g, y_f, 26]]) translate(p) linear_extrude(clip_t) clip2d();
  color("#3b82c4") translate([x_g, y_a0, 10]) gear_arm_at();
  color("#f0b429") translate([x_g, y_f, 16]) gear_fixed_at();
  color("#e879b0") translate([0, 0, 16]) nose_at();
  color("#2bb673") translate([-20, 0, 0]) ring_at(0);
}
if (part == "body") p_body();
if (part == "bobbin") p_bobbin();
if (part == "gear_fixed") p_gear_fixed();
if (part == "gear_arm") p_gear_arm();
if (part == "ring") p_ring();
if (part == "clip") p_clip();
if (part == "nose") p_nose();
if (part == "plate") plate();

/* ---------- Fit checks (checks/run.sh): each must come out EMPTY ---------- */
// fit_mesh: the spur gears at the pinched centre distance, turned through one tooth (phase = 0..30 deg)
if (part == "fit_mesh") intersection() {
  rotate(phase) linear_extrude(1) spur2d();
  translate([0, c_p]) rotate(180 / z_n - phase) linear_extrude(1) spur2d();
}
module gears_now(on) { translate([x_g, y_f, 0]) gear_fixed_at(); arm_move(on) translate([x_g, y_a0, 0]) gear_arm_at(); }
// parts rest ON their peg collars (face contact), so they are lifted 0.01 for the checks
if (part == "fit_gears_body") intersection() { translate([0, 0, 0.01]) gears_now(pinched); union() { body_fixed(); arm_move(pinched) body_arm(); } }
if (part == "fit_fixed_gear_arm") intersection() { translate([x_g, y_f, 0]) gear_fixed_at(); arm_move(pinched) body_arm(); }
if (part == "fit_bobbin_body") intersection() { translate([xb, 0, 0.01]) bobbin_at(); body(); }
if (part == "fit_nose_body") intersection() { translate([0, 0, 0.01]) nose_at(); body(); }   // run with -D ribs=false; it rests on its floor
if (part == "fit_clips") intersection() { for (p = [[xb, 0], [x_g, y_f]]) translate([p[0], p[1], nk0 + 0.05]) linear_extrude(clip_t) clip2d(); union() { body(); gears_now(pinched); translate([xb, 0, 0]) bobbin_at(); } }
// the ring slides on from the back: clear of the body all the way to where the flare starts
if (part == "fit_ring_slide") intersection() { union() for (x = [ring_l : 4 : flare0]) ring_at(x); body(); }
// wire path: from the groove's start to the Luer tip, clear of the body, the arm and the nose (the knurls are
// meant to bite it, 0.15 each; their gap is checked by numbers in checks/pinch_c.py)
if (part == "fit_wire_path") intersection() {
  translate([26, 0, z_w]) rotate([0, 90, 0]) cylinder(d = wire - 0.15, h = x_tip - 26 + 1, $fn = 12);
  union() { body_fixed(); arm_move(pinched) body_arm(); nose_at(); }
}
// arm_gear_kept: the fixed gear's rim overlaps the arm gear from above (must be NOT empty)
if (part == "fit_arm_gear_kept") intersection() {
  translate([x_g, y_f, 0]) linear_extrude(H) rim2d();
  arm_move(pinched) translate([x_g, y_a0, 0]) gear_arm_at();
}
if (part == "info") {
  vol = PI * (pow(5.9, 2) - bc_r*bc_r) * ((z_top - (bb_r - bc_r)) - (bb_z0 + bb_fl)) + PI * (7 * 2.4*2.4/2 + pow(2.4, 3)/3);
  echo(str("INFO c_p=", c_p, " c_r=", c_r, " m=", m, " ra=", ra, " d_w=", d_w, " coil_m=", vol / (wire*wire) / 1000, " len=", x_tip));
  echo(str("PINCHC E=1800 b=", arm_b, " h=", H, " x_r=", x_r, " x_g=", x_g, " d_w=", d_w, " flare0=", flare0, " flare1=", flare1,
           " flare=", flare, " ry1=", ry1, " half=", W/2, " slitA=", sA_w, " det0=", det0, " det1=", det1, " det_p=", det_p, " ring_l=", ring_l, " slitC=", 1.6, " gap_rest=", gap_rest, " wire=", wire, " fl=", fl, " peg_d=", peg_d));
  cube(1);
}
