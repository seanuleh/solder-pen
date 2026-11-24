// Solder pen, concept B "spinning reel" (2026-11-24): ROUGH SKETCH for comparison, nothing sized or checked.
//
// The coil never turns. Solder is wound on a fixed spool (part of the back cap). A drive wheel near the tip
// PULLS the wire: it comes off over the spool's rounded front lip (like line off a spinning reel), through a
// guide eyelet on the axis, between the drive wheel and an idler bearing, and straight out of a CENTRED
// Luer needle. You roll a thumbwheel on top with the thumb of the hand holding the pen; roll it back to retract.
//  - Only the last ~15 mm (wheel to needle tip) is pushed; everything behind the wheel is pulled.
//  - Wire coming off a fixed spool picks up one twist per wrap: harmless for soft solder (no spring-back).
//  - Drive wheel could be an off-the-shelf MK8 extruder gear; idler a small bearing on a printed flexure arm
//    (no spring encapsulated). Back cap unscrews to swap / reload the spool.
// Frame: pen axis = Z (needle toward +Z); drawn lying along X, thumbwheel up.

wire_d = 0.5;
od = 20; bore_d = 16;
spool_d = 10; spool_z0 = 2; spool_l = 38;
z_lip = spool_z0 + spool_l;           // rounded front lip
z_eye = z_lip + 7;                    // guide eyelet on the axis
z_drv = z_eye + 10;                   // drive wheel centre
gear_d = 9; gear_w = 4;               // MK8-style knurled drive gear
thumb_d = 18; thumb_w = 4;            // thumbwheel on the same axle, beside the gear
idl_d = 10; idl_w = 4;                // idler bearing
body_l = z_drv + 9;
nose_l = 10; luer_l = 7.5; lock_id = 7; lock_od = 10;
z_l0 = body_l + nose_l;
hub_d = 7; hub_l = 11; ndl_l = 12.7;
z_tip = z_l0 + 1 + hub_l + ndl_l;
out_l = 8;
pitch = wire_d + 0.05;
R_w = spool_d/2 + wire_d/2;
$fn = 48;
c_house = "#d0393b"; c_spool = "#f0b429"; c_wire = "#8d949c"; c_hub = "#e879b0"; c_thumb = "#3b82c4"; c_brass = "#c9a227";

module helix_sweep(prof, z0, len, a0, spt = 24) {
  n = len(prof); steps = max(2, ceil(len / pitch * spt));
  pts = [for (i = [0:steps]) let(t = i / steps * len, a = a0 + 360 * t / pitch)
           for (p = prof) [p[0] * cos(a), p[0] * sin(a), z0 + t + p[1]]];
  side = [for (i = [0:steps-1]) for (j = [0:n-1]) [i*n + j, i*n + (j+1)%n, (i+1)*n + (j+1)%n, (i+1)*n + j]];
  polyhedron(pts, concat(side, [[for (j = [n-1:-1:0]) j], [for (j = [0:n-1]) steps*n + j]]));
}
function circ(r, d, k = 8) = [for (i = [0:k-1]) [r + d/2*cos(360*i/k), d/2*sin(360*i/k)]];
function pol(r, a, z) = [r * cos(a), r * sin(a), z];
module chain(pts, d) { for (i = [0:len(pts)-2]) hull() { translate(pts[i]) sphere(d = d, $fn = 10);
                                                            translate(pts[i+1]) sphere(d = d, $fn = 10); } }
module knurl(d, w, n = 30) difference() {
  cylinder(d = d, h = w, center = true);
  for (i = [0:n-1]) rotate(i * 360/n) translate([d/2 + 0.15, 0, 0]) cylinder(d = 0.9, h = w + 1, center = true, $fn = 6);
}

// back cap + fixed spool (one part)
module spool() color(c_spool) {
  translate([0, 0, -3]) knurl(od, 6, 36);
  translate([0, 0, -3]) cylinder(d = od, h = 0.01);
  translate([0, 0, 0]) cylinder(d = bore_d - 0.4, h = spool_z0);           // back flange, sits in the barrel
  cylinder(d = spool_d, h = z_lip);
  translate([0, 0, z_lip]) rotate_extrude() hull() {                       // rounded front lip
    translate([spool_d/2 - 1.5, 0]) circle(r = 1.5);
    square([0.01, 3]);
  }
}

module wire() color(c_wire) {
  zc0 = spool_z0 + 0.5; zc1 = z_lip - 6;                                   // part-used coil
  helix_sweep(circ(R_w, wire_d), zc0, zc1 - zc0, 0);
  a1 = 360 * (zc1 - zc0) / pitch;
  chain([pol(R_w, a1, zc1), pol(R_w + 0.3, a1 + 40, z_lip), pol(spool_d/2 - 1, a1 + 80, z_lip + 2.7),
         [0, 0, z_eye], [0, 0, z_tip + out_l], [0, -1.2, z_tip + out_l + 1.5]], wire_d);
}

module drive() {
  // axle across the pen (X); gear and thumbwheel above the wire, idler below
  translate([0, gear_d/2 + wire_d/2 - 0.1, z_drv]) rotate([0, 90, 0]) {
    color(c_brass) knurl(gear_d, gear_w, 24);
    color(c_thumb) translate([0, 0, gear_w/2 + 0.5 + thumb_w/2]) knurl(thumb_d, thumb_w, 32);
    color("#777") cylinder(d = 3, h = 13, center = true);
  }
  translate([0, -(idl_d/2 + wire_d/2 - 0.1), z_drv]) rotate([0, 90, 0]) {
    color("#aab") difference() { cylinder(d = idl_d, h = idl_w, center = true); cylinder(d = 3, h = idl_w + 1, center = true); }
  }
  // printed flexure arm holding the idler against the wire
  color(c_house) translate([-2.5, -bore_d/2 + 0.2, z_drv - 12]) cube([1.2, 1.6, 14]);
  color(c_house) translate([-2.5, -(idl_d/2 + 0.15), z_drv - 1]) cube([1.2, idl_d/2 - 2.6, 2]);
}

module housing(cut = true) color(c_house) difference() {
  union() {
    cylinder(d = od, h = body_l);
    translate([0, 0, body_l]) cylinder(d1 = od, d2 = lock_od + 1, h = nose_l);
    translate([0, 0, z_l0]) difference() {
      cylinder(d = lock_od, h = luer_l);
      translate([0, 0, 1]) cylinder(d = lock_id, h = luer_l);
    }
    translate([0, 0, z_l0]) cylinder(d1 = 4.0, d2 = 3.5, h = luer_l);
    translate([0, 0, z_eye - 1]) cylinder(d = od, h = 2);                  // eyelet wall
  }
  translate([0, 0, -1]) cylinder(d = bore_d, h = z_eye - 1);               // spool chamber
  translate([0, 0, z_eye + 1]) cylinder(d = bore_d, h = body_l - z_eye - 2);  // drive chamber
  translate([0, 0, z_eye - 2]) cylinder(d1 = 4, d2 = 0.8, h = 2.5);         // eyelet funnel
  translate([0, 0, z_eye]) cylinder(d = 0.8, h = 2);
  translate([0, 0, body_l - 1.5]) cylinder(d1 = 3, d2 = 0.8, h = 2);       // funnel into the nose
  cylinder(d = 0.8, h = z_l0 + luer_l + 1, $fn = 12);
  translate([gear_w/2 + 0.1, 0, z_drv - thumb_d/2 - 1]) cube([thumb_w + 0.8, od, thumb_d + 2]);  // thumbwheel window
  if (cut) translate([-50, -50, -50]) cube([50, 100, 250]);
}

module needle() {
  color(c_hub) translate([0, 0, z_l0 + 1]) difference() {
    union() { cylinder(d = hub_d - 0.6, h = hub_l - 2); translate([0, 0, hub_l - 2]) cylinder(d1 = hub_d - 0.6, d2 = 2.5, h = 3); }
    translate([0, 0, -0.01]) cylinder(d1 = 4.1, d2 = 3.6, h = luer_l);
  }
  color(c_wire) translate([0, 0, z_l0 + hub_l]) cylinder(d = 0.91, h = z_tip - z_l0 - hub_l, $fn = 16);
}

part = "cutaway";
rotate([0, 90, 0]) rotate([0, 0, 90]) {
  housing(cut = part == "cutaway"); spool(); wire(); drive(); needle();
}
