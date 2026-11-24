// Solder pen concept B: DRIVE TEST RIG v2 (2026-11-24). Proves the pinch drive before designing the pen.
//
// A flat sled, laid out like the pen's front section but opened up on a plate:
//   wire in -> entry guide -> drive wheel (toothed) / idler roller -> exit guide -> male Luer nose -> needle.
// Feed it straight from the desk spool. Roll the big thumbwheel (it overhangs the sled's edge) to feed;
// roll it back to retract.
//
// v1 (same day, 3 sleds with 2.0/2.5/3.0 flexures) failed: ø1.25 wire holes printed far too small, the
// flexure was only 2.6 tall (~1 N, as floppy up/down as sideways), bore slop ate most of its travel, and
// 30 x 0.5 mm teeth printed as bumps. v2:
//   - wire holes ø2.0 (guides and nose);
//   - one sled; the idler hangs off a TALL flexure (8.4 high, 2.0 thin) that only bends toward the wire,
//     and an M4 x 12 wood screw (one of the spares) pushes the middle of the arm: screw in = harder pinch.
//     Screw backed out = light touch, so the wire threads easily;
//   - 20 teeth, 0.8 deep (~90 deg points) on the drive wheel;
//   - two idlers to compare: toothed (same teeth) and smooth. Same ø5 pin as the wheel, 0.25 clearance;
//   - Luer taper corrected to ISO 594 (ø3.925 at the tip, 6 %); v1's was ~0.4 under.
//
// Parts (all print flat, no supports):  sled  |  wheel  |  idler (toothed=true/false)  |  nose
//   wheel: thumbwheel down on the bed, teeth up. Push onto the drive pin, teeth down.
//   idler: drop onto the arm's pin.   nose: flange on the bed, taper up; drops into the slot at the front.
//   screw: M4 x 12 wood screw, from outside into the block beside the arm (self-taps the ø3.3 hole).
// Frame (sled): X = wire direction (toward the needle), Y across, Z up. Bed at z = 0.
// Measured wire 2026-11-24: 0.86-0.88 (0.8 nominal).
// Export: ./stl/export.sh solder_pen_drive_test

part    = "plate";   // plate | sled | wheel | idler | nose | assembly | nip (assembly, teeth only)
toothed = true;      // idler: toothed or smooth

/* ---------- Wire + fit ---------- */
wire    = 0.87;
guide_d = 2.0;           // wire holes (FDM prints small holes ~0.2-0.4 under)
clr     = 0.25;          // pin / bore clearance

/* ---------- Heights ---------- */
base_t = 2;
boss_h = 0.4;            // washer boss under the rollers
z_w0   = 2.6;            // bottom of the rollers
knurl_h = 5.6;
zw     = z_w0 + knurl_h/2;                // 5.4: wire height
neck_h = 1.0;
thumb_h = 4;
wall_top = 8.4;          // guides, arm and blocks stay under the thumbwheel (z >= 9.2)

/* ---------- Rollers ---------- */
roll_d  = 10;            // tooth tip diameter (drive and idler)
tooth_n = 20; tooth_dp = 0.8;
pin_d   = 5;
thumb_d = 24;
bite    = 0.25;          // drive tooth tips this far into the wire's path
idl_bite = 0.1;          // idler tips this far into it with the screw backed off

/* ---------- Layout ---------- */
y_w  = 13;               // wire line
x_n  = 24;               // nip
drv_c = [x_n, y_w - wire/2 + bite - roll_d/2];
idl_c = [x_n, y_w + wire/2 - idl_bite + roll_d/2];
sled_l = 50;
x_slot = 43.5; flange_t = 3; flange_w = 12; flange_h = 9;  // nose flange slot (in sled X)

/* ---------- Idler arm (flexure) ---------- */
anchor_x = 4;            // arm is fixed here (entry end), free from the base after this
arm_t    = 2.0;          // thin: bends only toward / away from the wire
arm_y0   = idl_c[1] + roll_d/2 + 0.8;     // inner face, clear of the idler teeth
arm_end  = x_n + 4;
brk_h    = z_w0 - boss_h;                 // bracket from the arm to the idler pin, under the idler
x_scr    = 14;           // screw pushes the arm here
pad_t    = 1.0;          // thicker pad where the screw tip bears
scr_hole = 3.3;          // M4 wood screw self-taps into this
blk_gap  = 1.0;          // arm/pad to screw block
blk_d    = 8;            // screw block depth (Y)
blk_y0   = arm_y0 + arm_t + pad_t + blk_gap;
sled_w   = blk_y0 + blk_d + 1;
win      = 0.9;          // base window clearance around the arm and bracket

$fn = 48;

module teardrop(d, l) {     // horizontal hole along +X, point up (prints without support)
  rotate([0, 90, 0]) linear_extrude(l) rotate(90) union() {
    circle(d = d, $fn = 24);
    rotate(45) square(d/2);
  }
}

module teeth2d() polygon([for (i = [0:2*tooth_n-1]) let(a = 180 * i / tooth_n,
                            r = (i % 2 == 0) ? roll_d/2 : roll_d/2 - tooth_dp) [r*cos(a), r*sin(a)]]);

module guides() {
  wedge = guide_d + 0.8;    // wedge tip width: 0.4 walls round the hole
  // entry: block from the sled's back edge, funnel mouth, wedge into the nip
  difference() {
    hull() {
      translate([0, y_w - 3, base_t - 0.01]) cube([x_n - 8, 6, wall_top - base_t]);
      translate([x_n - 3.9, y_w - wedge/2, base_t - 0.01]) cube([0.1, wedge, wall_top - base_t]);
    }
    translate([-1, y_w, zw]) teardrop(guide_d, x_n + 2);
    translate([-0.01, y_w, zw]) rotate([0, 90, 0]) cylinder(d1 = 4, d2 = guide_d, h = 3);
  }
  // exit: wedge out of the nip, widening to the nose slot
  difference() {
    hull() {
      translate([x_n + 3.8, y_w - wedge/2, base_t - 0.01]) cube([0.1, wedge, wall_top - base_t]);
      translate([x_n + 8, y_w - 3, base_t - 0.01]) cube([x_slot - x_n - 8, 6, wall_top - base_t]);
    }
    translate([x_n, y_w, zw]) teardrop(guide_d, x_slot - x_n + 1);
    translate([x_n + 3.7, y_w, zw]) rotate([0, 90, 0]) cylinder(d1 = 3, d2 = guide_d, h = 1);   // lead-in
  }
  // nose slot walls + front lip with a U-notch for the taper
  difference() {
    translate([x_slot - 1.5, y_w - flange_w/2 - 1.5, base_t - 0.01])
      cube([flange_t + 0.4 + 3, flange_w + 3, flange_h - 0.5]);
    translate([x_slot, y_w - flange_w/2 - 0.2, base_t]) cube([flange_t + 0.4, flange_w + 0.4, 20]);   // slot
    translate([x_slot - 2, y_w, zw]) teardrop(guide_d, 3);
    translate([x_slot + flange_t, y_w - 2.5, zw - 0.2]) cube([5, 5, 20]);                             // U-notch
    translate([x_slot + flange_t, y_w, zw]) rotate([0, 90, 0]) cylinder(d = 5, h = 5);
  }
}

// Footprint of everything that must move: arm, pad, bracket (2D, for the base window)
module arm2d() {
  translate([anchor_x, arm_y0]) square([arm_end - anchor_x, arm_t]);
  translate([x_scr - 3, arm_y0 + arm_t - 0.01]) square([6, pad_t + 0.01]);
  hull() {
    translate(idl_c) circle(d = 7);
    translate([x_n - 3.5, arm_y0]) square([7, 0.01]);
  }
}

module arm() {
  translate([anchor_x, arm_y0, 0]) cube([arm_end - anchor_x, arm_t, wall_top]);                // flexure
  translate([x_scr - 3, arm_y0 + arm_t - 0.01, 0]) cube([6, pad_t + 0.01, wall_top]);         // screw pad
  linear_extrude(brk_h) hull() {                                                              // bracket
    translate(idl_c) circle(d = 7);
    translate([x_n - 3.5, arm_y0]) square([7, arm_t]);
  }
  translate([idl_c[0], idl_c[1], 0]) {
    cylinder(d = 7, h = z_w0);                                                                // boss
    cylinder(d = pin_d, h = wall_top, $fn = 32);                                              // idler pin
  }
  translate([0, arm_y0 - 2, 0]) cube([anchor_x + 0.01, arm_t + 4, wall_top]);                 // anchor
}

module screw_block() difference() {
  translate([x_scr - 5, blk_y0, base_t - 0.01]) cube([10, blk_d, wall_top - base_t]);
  translate([x_scr, blk_y0 + blk_d + 1, 5.2]) rotate(-90) teardrop(scr_hole, blk_d + 2);
}

module sled() {
  difference() {
    cube([sled_l, sled_w, base_t]);
    translate([0, 0, -1]) linear_extrude(base_t + 2) offset(r = win) arm2d();     // arm moves freely
    translate([sled_l - 9, sled_w - 5, base_t - 0.4]) linear_extrude(1)
      text("v2", size = 3, font = "Liberation Sans:style=Bold", halign = "center");
  }
  arm();
  guides();
  screw_block();
  // drive pin + boss
  translate([drv_c[0], drv_c[1], 0]) {
    cylinder(d = 7, h = z_w0);
    cylinder(d = pin_d, h = z_w0 + knurl_h + neck_h + thumb_h + 0.5, $fn = 32);
  }
}

module wheel() {     // modelled teeth-down at its working height; plate() flips it
  translate([0, 0, z_w0]) difference() {
    union() {
      linear_extrude(knurl_h) teeth2d();
      translate([0, 0, knurl_h]) cylinder(d = 7, h = neck_h);
      translate([0, 0, knurl_h + neck_h]) difference() {
        cylinder(d = thumb_d, h = thumb_h);
        for (i = [0:35]) rotate(i * 10) translate([thumb_d/2 + 0.3, 0, -1]) cylinder(d = 1.4, h = thumb_h + 2, $fn = 8);
      }
    }
    translate([0, 0, -1]) cylinder(d = pin_d + clr, h = 20, $fn = 32);
  }
}

module idler(toothed = toothed) translate([0, 0, z_w0]) difference() {
  if (toothed) linear_extrude(knurl_h) teeth2d(); else cylinder(d = roll_d, h = knurl_h);
  translate([0, 0, -1]) cylinder(d = pin_d + clr, h = knurl_h + 2, $fn = 32);
  if (!toothed) translate([0, 0, knurl_h - 0.4]) linear_extrude(1) text("S", size = 3, halign = "center", valign = "center");
}

// Nose: flange (sits in the slot, flat face toward the rollers) + male Luer-slip taper, bore for the wire.
// Taper: ISO 594, 6 %, ø3.925 at the tip. Modelled in print orientation: flange on the bed, taper up (+Z = sled +X).
luer_l = 7.5;
v_hole = zw - base_t;   // hole height above the flange's bottom edge
module nose() difference() {
  union() {
    translate([-flange_w/2, -v_hole, 0]) cube([flange_w, flange_h, flange_t]);
    translate([0, 0, flange_t]) cylinder(d1 = 3.925 + 0.06 * luer_l, d2 = 3.925, h = luer_l);
  }
  translate([0, 0, -1]) cylinder(d = guide_d, h = 20, $fn = 24);
  translate([0, 0, -0.01]) cylinder(d1 = 3, d2 = guide_d, h = 1);     // lead-in from the exit guide
}

module plate() {
  sled();
  translate([sled_l + 18, 14, 0]) rotate([180, 0, 0]) translate([0, 0, -(z_w0 + knurl_h + neck_h + thumb_h)]) wheel();
  translate([sled_l + 10, 34, -z_w0]) idler(true);
  translate([sled_l + 24, 34, -z_w0]) idler(false);
  translate([sled_l + 18, 50, 0]) nose();
}

module wire_rod() color("#8d949c") translate([-15, y_w, zw]) rotate([0, 90, 0]) cylinder(d = wire, h = x_slot + 30, $fn = 12);
module screw_rod() color("#555") translate([x_scr, blk_y0 + blk_d + 2, 5.2]) rotate([90, 0, 0]) {
  cylinder(d = 4, h = 12); translate([0, 0, -0.01]) mirror([0, 0, 1]) cylinder(d1 = 4, d2 = 8, h = 2.2);
}

if (part == "sled") sled();
if (part == "wheel") rotate([180, 0, 0]) translate([0, 0, -(z_w0 + knurl_h + neck_h + thumb_h)]) wheel();
if (part == "idler") translate([0, 0, -z_w0]) idler();
if (part == "nose") nose();
if (part == "assembly") {
  color("#d0393b") sled();
  color("#3b82c4") translate([drv_c[0], drv_c[1], 0]) wheel();
  color("#cccccc") translate([idl_c[0], idl_c[1], 0]) idler();
  color("#e879b0") translate([x_slot + 0.2, y_w, zw]) rotate([90, 0, 90]) nose();
  wire_rod(); screw_rod();
}
if (part == "nip") {     // top view of the drive: thumbwheel cut off so the nip shows
  color("#d0393b") sled();
  color("#3b82c4") translate([drv_c[0], drv_c[1], 0]) intersection() { wheel(); cylinder(d = 50, h = z_w0 + knurl_h); }
  color("#cccccc") translate([idl_c[0], idl_c[1], 0]) idler();
  color("#e879b0") translate([x_slot + 0.2, y_w, zw]) rotate([90, 0, 90]) nose();
  wire_rod(); screw_rod();
}
if (part == "plate") plate();
