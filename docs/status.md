# Status

## Now (2026-11-24)

- **Direction: concept A (lead-screw core), slim pen ≤ ø15, ~0.5 m.** See decisions.md.
- **A test print is printing** (2026-11-24; `stl/solder_pen_a_test/solder_pen_a_test.3mf`, 5 parts, grey Bambu PETG HF slot 1,
  0.16 mm Optimal, ~61 min, 9 g; overhangs are all 45°, the thread undersides are the ones to watch).
  **Next:** print it, wind ~0.4 m (tail in the front hole, wind back to the nut), and check that turning the knob
  pushes the wire steadily through the straight nose and then the S nose with the needle on, that reversing
  pulls it back, and that the nut peels cleanly without the coil loosening.
- **Rig v2** (hex sandwich, concept B) printed 2026-11-24 and retired: its fixed spool couldn't pay out and its arm
  barely gripped; its arm anchor's crush ribs were too tight (sanded). An unbuilt "v3" bobbin rig is in `git stash`.
- Drive test rig v2 (the flat sled) is designed but not printed, and still has v1-style tight fits.

## History

2026-11-24 (in solder-desk): **solder pen concept** (`parts/solder_pen.scad`, animation `renders/solder_pen.mp4`; see printed-parts.md). Nut walks back to front (less leftover wire). Then concept B (fixed spool + thumbwheel pinch drive, centred needle) was preferred; its **drive test rig** v1 printed: wire holes too small, grip slips (finger pressure on the idler half-works). **v2 is ready to print** (`stl/solder_pen_drive_test/`): ø2 holes, screw-adjusted stiff flexure, deeper teeth, toothed + smooth idlers. Next: print v2, find the screw setting that feeds and retracts without slipping, test the Luer fit. A **pen-scale rig** (`parts/solder_pen_rig.scad`, `stl/solder_pen_rig/`) is **printing (2026-11-24, white SUNLU PETG, 0.16mm Optimal, ~77 min, 17 g; v2 skipped for now)**. The first print fused the rings onto the nose and three arms together (plate layout bug, fixed 2026-11-24, new check `plate_parts_apart`): reprint those from the fixed 3MF: real roller sizes, thumbwheel through the side, fixed spool, swappable arms. Test there: grip with ø7/ø5 rollers, coil drag, thumbwheel feel, and whether the pinch holds after a few days loaded. Measured: solder 0.86–0.88 (0.8 nominal); the user's blunt needle OD 1.97, 31.69 long, 14 mm shaft (≈14G, gauge unconfirmed).

## Measurements

- Solder: 0.86–0.88 mm (0.8 nominal).
- The user's blunt needle: OD 1.97, 31.69 long, 14 mm shaft (≈14G, gauge unconfirmed).
- Owned, for later: ø6 micro gearmotors "Model C", 1:26.45, 16.5 mm long + 2.8 mm shaft (ø1.95, 1.5 flat).
  3 V: 1200 rpm, 45 mA, 25 g·cm (stall 55 g·cm, 200 mA). Candidate for a motorised pen via a ~20:1 worm.
- Borrowed: one M4 × 12 wood screw (drive test rig v2's pinch screw), from the solder-desk stock.
