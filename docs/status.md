# Status

## Now (2026-11-24)

- **Pen-scale rig printed** (white SUNLU PETG, 0.16 mm Optimal). The plate layout was wrong: the two rings
  fused onto the nose and three of the four arms fused together. Fixed in the model the same day (check
  `plate_parts_apart`). **Reprint of nose + 2 rings + 4 arms is sliced and on hold** (~24 min, 2.6 g).
- The user, assembling it, found **the tolerances seem off** and how the parts go together unclear →
  [assembly.md](assembly.md) (steps + fits table). **Next:** find which fits are wrong (the fits table lists the
  likely ones: pin bores, arm anchor slot), adjust, reprint those parts.
- Then test on the rig: grip with ø7/ø5 rollers, coil drag, thumbwheel feel, whether the pinch holds after a few
  days loaded.
- Drive test rig **v2** is designed but not printed (skipped in favour of the pen-scale rig).

## History

2026-11-24 (in solder-desk): **solder pen concept** (`parts/solder_pen.scad`, animation `renders/solder_pen.mp4`; see printed-parts.md). Nut walks back to front (less leftover wire). Then concept B (fixed spool + thumbwheel pinch drive, centred needle) was preferred; its **drive test rig** v1 printed: wire holes too small, grip slips (finger pressure on the idler half-works). **v2 is ready to print** (`stl/solder_pen_drive_test/`): ø2 holes, screw-adjusted stiff flexure, deeper teeth, toothed + smooth idlers. Next: print v2, find the screw setting that feeds and retracts without slipping, test the Luer fit. A **pen-scale rig** (`parts/solder_pen_rig.scad`, `stl/solder_pen_rig/`) is **printing (2026-11-24, white SUNLU PETG, 0.16mm Optimal, ~77 min, 17 g; v2 skipped for now)**. The first print fused the rings onto the nose and three arms together (plate layout bug, fixed 2026-11-24, new check `plate_parts_apart`): reprint those from the fixed 3MF: real roller sizes, thumbwheel through the side, fixed spool, swappable arms. Test there: grip with ø7/ø5 rollers, coil drag, thumbwheel feel, and whether the pinch holds after a few days loaded. Measured: solder 0.86–0.88 (0.8 nominal); the user's blunt needle OD 1.97, 31.69 long, 14 mm shaft (≈14G, gauge unconfirmed).

## Measurements

- Solder: 0.86–0.88 mm (0.8 nominal).
- The user's blunt needle: OD 1.97, 31.69 long, 14 mm shaft (≈14G, gauge unconfirmed).
- Owned, for later: ø6 micro gearmotors "Model C", 1:26.45, 16.5 mm long + 2.8 mm shaft (ø1.95, 1.5 flat).
  3 V: 1200 rpm, 45 mA, 25 g·cm (stall 55 g·cm, 200 mA). Candidate for a motorised pen via a ~20:1 worm.
- Borrowed: one M4 × 12 wood screw (drive test rig v2's pinch screw), from the solder-desk stock.
