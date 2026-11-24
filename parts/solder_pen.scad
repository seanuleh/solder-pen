// Solder pen: CONCEPT (2026-11-24), for looking at the idea. Numbers are placeholders, not measured or printed.
//
// Twist the knob at the back to feed solder out of a standard Luer-lock blunt needle (20G shown).
//  - Knob + core are one part. The core has a V-groove (a lead screw) and the solder is wound into it.
//    Left-hand groove. The core only turns; it never moves along the pen, so nothing sticks out and the pen is one length.
//  - A small nut rides the groove like a lead-screw nut. A fin on it runs in a slot in the housing wall, so
//    it can't turn: each turn of the knob walks it one groove FORWARD, from the back of the coil toward the tip.
//    Its tooth sits in the empty groove just behind the coil and lifts the wire out (the peel point); a curved
//    ramp turns the wire from sideways (the way the core carries it) to along the pen, into a channel at the
//    bottom of the slot, then straight out through the needle, which sits off-centre in line with the channel.
//  - What pushes: the coil's grip on the core (wire wound snug grips harder with every wrap) carries the wire
//    into the tooth. The tail is hooked into an anchor hole at the FRONT end of the groove, so the last turn is
//    driven too, and what's left when empty is only the nose + needle (~30 mm).
//  - Reverse the knob to retract: the strand is pulled back and the tooth lays it back into the groove.
//  - End stops: the groove runs out into plain collars at both ends; the tooth bottoms on them.
//  - Feed per turn = ~33 mm; a detent every 1/8 turn = ~4 mm per click.
//
// Frame: pen axis = Z (z = 0 at the housing's back face, the needle toward +Z); drawn lying along X.
// part = "cutaway" (half the housing cut away) | "exploded" (full coil, parts apart)
// Animation: ./renders/solder_pen_anim.sh (drives `used` and `out_l`).

part  = "cutaway";
used  = 0.4;           // fraction of the coil dispensed; sets the nut's position AND the core's rotation
out_l = 6;             // wire showing past the needle tip

/* ---------- Wire + needle ---------- */
wire_d   = 0.5;        // 20G blunt tip: bore ~0.6, OD 0.91
ndl_od   = 0.91;
ndl_l    = 12.7;       // 1/2" tip
hub_d    = 7.0;        // needle's female Luer hub
hub_l    = 11;

/* ---------- Core (lead screw) ---------- */
pitch    = 1.4;        // groove pitch: sized for wire up to ~1.0
root_d   = 10;         // groove bottom; the wire wraps here
crest_d  = 11.8;
coil_l   = 40;         // ~28 turns = ~0.9 m of 0.5 mm wire
z_coil0  = 4;          // groove starts (back collar behind it = back end stop)
z_coil1  = z_coil0 + coil_l;   // groove ends (front collar = front end stop, anchor hole here)

/* ---------- Nut / peeler ---------- */
nut_id   = 12.2;
nut_od   = 15;
nut_l    = 4;

/* ---------- Housing ---------- */
bore_d   = 15.4;
wall     = 2.3;
od       = bore_d + 2*wall;          // 20
slot_w   = 3;          // key slot in the bore wall (at +Y)
slot_dp  = 1.2;
ch_d     = 0.8;        // wire channel at the bottom of the slot (wire + ~0.3)
ch_x     = -1.0;        // channel sits to one side of the slot: the side the wire leaves the core toward
body_l   = z_coil1 + 3.5;
nose_l   = 6;         // short taper from the barrel to the off-centre Luer
luer_l   = 7.5;        // male Luer tip, 6 % taper
lock_id  = 7;
lock_od  = 10;
knob_d   = 20;
knob_l   = 12;

R_w  = root_d/2 + wire_d/2 + 0.1;            // wire centre in the groove
R_ch = bore_d/2 + slot_dp + ch_d/2;          // wire channel centre
z_l0 = body_l + nose_l;                      // Luer base
N    = [ch_x, R_ch];                         // needle axis: in line with the wire channel (off-centre)
z_nut = z_coil0 + 1 + used * (coil_l - 2);   // peel point: walks forward as solder is used
rot   = 360 * (z_nut - z_coil0) / pitch;         // core + knob rotation that goes with it
z_tip = z_l0 + 1 + hub_l + ndl_l;            // needle tip

$fn = 48;
c_house = "#d0393b"; c_core = "#f0b429"; c_nut = "#3b82c4"; c_wire = "#8d949c"; c_hub = "#e879b0";

// Sweep an (r, z) profile along the groove helix (left-hand); angle a0 at z0.
module helix_sweep(prof, z0, len, a0, spt = 40) {
  n = len(prof); steps = max(2, ceil(len / pitch * spt));
  pts = [for (i = [0:steps]) let(t = i / steps * len, a = a0 - 360 * t / pitch)
           for (p = prof) [p[0] * cos(a), p[0] * sin(a), z0 + t + p[1]]];
  side = [for (i = [0:steps-1]) for (j = [0:n-1])
            [(i+1)*n + j, (i+1)*n + (j+1)%n, i*n + (j+1)%n, i*n + j]];   // wound for the left-hand sweep
  polyhedron(pts, concat(side, [[for (j = [0:n-1]) j], [for (j = [n-1:-1:0]) steps*n + j]]));
}
function circ(r, d, k = 10) = [for (i = [0:k-1]) [r + d/2*cos(360*i/k), d/2*sin(360*i/k)]];
// Groove angle at height z, in the housing frame: the groove passes angle 90 (the slot) at z_nut.
function gang(z) = 90 - 360 * (z - z_nut) / pitch;   // left-hand thread
function pol(r, a, z) = [r * cos(a), r * sin(a), z];

module chain(pts, d) { for (i = [0:len(pts)-2]) hull() { translate(pts[i]) sphere(d = d, $fn = 12);
                                                            translate(pts[i+1]) sphere(d = d, $fn = 12); } }

// The wire's path from the peel point to past the needle tip (also cut as the housing's channel).
// Left-hand groove, core turns anticlockwise seen from the tip, so at the slot (angle 90) the wire leaves toward -X: the ramp
// carries it on round and outward, then bends it forward into the channel.
function exit_path(zn) = [pol(R_w, 90, zn), pol(R_w + 0.35, 100, zn + 0.25), pol(R_w + 1.2, 108, zn + 0.9),
                          [ch_x, R_ch - 0.9, zn + 2.2], [ch_x, R_ch, zn + 4]];
function nose_path() = [[N[0], N[1], body_l - 1], [N[0], N[1], z_l0 - 1]];   // dead straight

/* ---------- Parts ---------- */
module knob_core() {
  color(c_core) difference() {
    union() {
      // knurled knob behind the housing, with a pointer bump so the turning shows
      rotate(rot) translate([0, 0, -knob_l]) difference() {
        union() {
          cylinder(d = knob_d, h = knob_l - 0.5);
          translate([0, knob_d/2 - 0.6, 0]) cylinder(d = 3, h = knob_l - 0.5, $fn = 16);
        }
        for (i = [0:23]) rotate(i * 15 + 7.5) translate([knob_d/2 + 0.2, 0, 1.5]) cylinder(d = 1.6, h = knob_l, $fn = 8);
      }
      translate([0, 0, -0.5]) cylinder(d = bore_d - 0.4, h = 3);              // journal in the housing's back
      translate([0, 0, 2.5]) cylinder(d = crest_d, h = z_coil0 - 2.5 - 0.3);  // back collar: end stop
      cylinder(d = root_d + 0.02, h = z_coil1 + 0.6);                         // groove root
      translate([0, 0, z_coil1 + 0.3]) cylinder(d = crest_d, h = 1.5);        // front collar: end stop
      translate([0, 0, z_coil1 + 1.7]) cylinder(d = 4, h = 2.5);              // front pin into the housing's front wall
      // thread ridge between the wire turns (half a pitch off the wire)
      w = pitch * 0.55; f = 0.3;
      helix_sweep([[root_d/2 - 0.01, -w/2], [crest_d/2, -f/2], [crest_d/2, f/2], [root_d/2 - 0.01, w/2]],
                  z_coil0 - pitch/2, coil_l + pitch/2, gang(z_coil0 - pitch/2) + 180);
    }
    // tail anchor: a radial hole at the front end of the groove
    za = z_coil1 - 0.6;
    rotate(gang(za)) translate([R_w - 3, 0, za]) rotate([0, 90, 0]) cylinder(d = 0.9, h = 4, $fn = 12);
  }
}

module wire(full = false) {
  zn = full ? z_coil0 + 1 : z_nut;
  za = z_coil1 - 0.6;
  color(c_wire) {
    // the coil, from the peel point forward to the anchor at the front of the groove
    helix_sweep(circ(R_w, wire_d), zn, za - zn, gang(zn));
    chain([pol(R_w, gang(za), za), pol(R_w - 2.5, gang(za), za)], wire_d);   // tail hooked into the anchor
    if (!full)
      chain(concat(exit_path(z_nut), nose_path(), [[N[0], N[1], z_tip + out_l], [N[0], N[1] - 1.2, z_tip + out_l + 1.5]]), wire_d);
  }
}

module nut() {
  color(c_nut) {
    // ring sits over the start of the coil; it clears the wire (wire top 11.2, ring bore 12.2)
    translate([0, 0, z_nut - 1.5]) difference() {
      cylinder(d = nut_od, h = nut_l);
      translate([0, 0, -1]) cylinder(d = nut_id, h = nut_l + 2);
      chain(exit_path(1.5), 1.1);                                             // curved exit ramp
    }
    // key fin in the housing slot (wire path cut through it)
    difference() {
      translate([-(slot_w - 0.4)/2, nut_od/2 - 0.5, z_nut - 1.5])
        cube([slot_w - 0.4, bore_d/2 + slot_dp - 0.2 - nut_od/2 + 0.5, nut_l]);
      chain(exit_path(z_nut), 1.1);
    }
    // tooth: rides the empty groove just behind the peel point
    tl = pitch * 0.4;
    helix_sweep([[R_w - 0.15, -0.3], [nut_id/2 + 0.05, -0.55], [nut_id/2 + 0.05, 0.55], [R_w - 0.15, 0.3]],
                z_nut - 0.15 - tl, tl, gang(z_nut - 0.15 - tl));
  }
}

module housing(cut = false) {
  color(c_house) difference() {
    union() {
      cylinder(d = od, h = body_l);
      hull() {                                                                  // chisel nose: barrel -> off-centre Luer
        translate([0, 0, body_l - 0.01]) cylinder(d = od, h = 0.01);
        translate([N[0], N[1], z_l0 - 0.01]) cylinder(d = lock_od + 1, h = 0.01);
      }
      // Luer-lock collar around the male taper
      translate([N[0], N[1], z_l0]) difference() {
        cylinder(d = lock_od, h = luer_l);
        translate([0, 0, 1]) cylinder(d = lock_id, h = luer_l);
        for (k = [0:5]) translate([0, 0, 2 + k]) rotate_extrude($fn = 32) translate([lock_id/2 - 0.1, 0]) circle(d = 0.6, $fn = 8);
      }
      translate([N[0], N[1], z_l0]) cylinder(d1 = 4.0, d2 = 3.92 - 0.45, h = luer_l);    // male Luer taper (6 %)
    }
    translate([0, 0, -1]) cylinder(d = bore_d, h = z_coil1 + 2);                  // bore
    translate([0, 0, z_coil1 + 1]) cylinder(d = 4.3, h = 3.5);                     // front pin hole
    translate([-slot_w/2, 0, -1]) cube([slot_w, bore_d/2 + slot_dp, z_coil1 + 2]);  // key slot
    // wire channel: along the slot bottom, then curving into the nose and the Luer tip
    chain(concat([[ch_x, R_ch, -0.5]], nose_path(), [[N[0], N[1], z_l0 + luer_l + 1]]), ch_d);
    if (cut) translate([-50, -50, -50]) cube([50, 100, 200]);                       // cutaway: drop the x < 0 half
  }
}

module needle() {
  color(c_hub) translate([N[0], N[1], z_l0 + 1]) difference() {
    union() {
      cylinder(d = hub_d - 0.6, h = hub_l - 2);
      translate([0, 0, hub_l - 2]) cylinder(d1 = hub_d - 0.6, d2 = 2.5, h = 3);
      for (s = [-1, 1]) translate([s * (hub_d/2 - 0.1) - 0.6, -0.6, 0]) cube([1.2, 1.2, 1.2]);   // lock lugs
      for (a = [0, 90]) rotate(a) translate([-0.4, -(hub_d + 1)/2, 3]) cube([0.8, hub_d + 1, hub_l - 5]); // grip fins
    }
    translate([0, 0, -0.01]) cylinder(d1 = 4.1, d2 = 3.6, h = luer_l);
  }
  color(c_wire) translate([N[0], N[1], z_l0 + hub_l]) difference() {
    cylinder(d = ndl_od, h = z_tip - z_l0 - hub_l, $fn = 16);
    translate([0, 0, -1]) cylinder(d = 0.6, h = ndl_l + 3, $fn = 16);
  }
}

/* ---------- Views ---------- */
rotate([0, 90, 0]) rotate([0, 0, 90]) {
  if (part == "cutaway") {
    housing(cut = true); knob_core(); nut(); wire(); needle();
  } else {
    translate([0, 0, -body_l - 22]) { knob_core(); wire(full = true); }
    translate([0, 0, -14 - z_nut]) nut();
    housing();
    translate([0, 0, 14]) needle();
  }
}
