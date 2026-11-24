# Decisions

Why the pen is the way it is, newest first. Read this before proposing a change, so settled questions
aren't reopened. Moved here from the solder-desk repo on 2026-11-24, when the pen got its own repo.

## Design rules (the user's)

- Never print around or encapsulate a spring; flexures are printed instead.
- Prefer what the user already owns over buying hardware (they skipped an MK8 steel drive gear).
- Measure the real item (wire, needle) before sizing a fit.

## Current decisions

- **Own repo** (2026-11-24). The pen started inside the solder-desk project but has nothing to do with the
  board; it moved to this repo with its renders, STLs and history notes.
- **Assembly guide + fits table** (2026-11-24). The user, holding the printed rig, found it unclear how the parts
  interact and suspected the tolerances. [assembly.md](assembly.md) shows each step and lists every designed
  clearance and its risk, so a bad fit can be named and fixed by parameter.
- **Solder pen: concept B (fixed spool + thumbwheel pinch drive) over concept A (twist-to-feed lead screw)** (2026-11-24). The user wants their own take on a MakerWorld solder-wire pen, dispensing through a standard blunt Luer needle. Concept A (`parts/solder_pen.scad`): a twisting knob turns a grooved core, and a keyed nut walks the groove and peels the wire off. It works only with the needle off-centre (the spinning core blocks the middle). Centring the needle needs an S-bend in the nose, and the user found the off-centre version ugly. Concept B (`parts/solder_pen_reel.scad`): the coil stays still, and a thumbwheel-driven knurled wheel pulls the wire off over the spool's lip, through the centre, out of a centred needle. Only ~15 mm is pushed, it's one-handed, and it uses a plain spool. Cost: ~107 mm long against ~90, plus a drive wheel and idler. The user found B cooler and easier to use. The drive is proven first with a flat test rig (`parts/solder_pen_drive_test.scad`). The user's ø6 gearmotors (1:26.45, 600–1200 rpm) could motorise it later via a ~20:1 worm; that's deferred until the manual drive works.
- **Drive test rig v2: screw-adjusted stiff flexure, printed teeth, no steel drive gear** (2026-11-24). v1's ø1.25 wire holes printed too small for 0.87 wire (FDM holes come out 0.2–0.4 under), and its 2.6 mm-tall flexures gave ~1 N and flexed up/down as easily as sideways. Guessing stiffness with three sleds was replaced by one tall, thin flexure (bends only toward the wire) preloaded by an M4 wood screw, so the pinch is tuned rather than guessed. The user prefers not to buy an MK8 steel drive gear; deeper printed teeth (20 × 0.8) are tried first, and a toothed vs smooth idler is compared. Gearing the idler to the drive (dual drive) is the next step if it still slips; it was not done now because a fixed gear mesh fights an adjustable pinch.
- **Pen-scale rig: split body, swappable flexure arms, no screw** (2026-11-24). The user wanted a rig closer to the final pen. In a ø20 body two ø10 rollers don't fit (21 mm across), so the rollers are ø7 drive / ø5 idler, and the thumbwheel (ø18, coaxial) can only poke out through a side slot. There's no wall thick enough for a pinch screw, so the pinch is set by swapping printed arms of different thickness (separate parts, slotted in), which is also how the final pen would carry a fixed preload. The body splits along the wire so the halves print without supports and open for testing.
- **Pen B spool: single-layer coil in a helical groove, not a multi-layer coil** (2026-11-24). The user flagged that a coiled-up wire can tangle and bind the whole mechanism. A plain core with 2–3 layers holds ~2 m but turns can dig in between lower turns, drop into the gap to the chamber wall, and the leaving wire drags over the coil. With one grooved layer wound back to front, the front turn is always the one peeled, so nothing crosses or stacks. Cost: ~0.65 m per fill (ø20 body; the lip + wire must clear the ø15 chamber, which caps the core at ~ø10).
