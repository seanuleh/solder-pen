# Solder Pen

A one-handed solder-wire pen: roll a thumbwheel and fine solder feeds straight out of a standard blunt Luer
needle, right where the iron is. Roll it back to retract. Fully parametric OpenSCAD, printed in PETG.

![Solder pen, concept B: cutaway](renders/hero.png)

- **The coil never turns.** Solder sits in a helical groove on a fixed spool, one layer deep, so it can't
  tangle, stack or dig in. The drive always peels the front turn.
- **Pull, don't push.** A thumbwheel-driven toothed wheel pinches the wire against an idler and pulls it off
  the spool. Only the last ~15 mm, from the wheel to the tip, is pushed.
- **Centred needle.** The wire runs dead straight on the pen's axis through an ISO 594 Luer taper, so any
  blunt dispensing needle fits.
- **Tunable grip.** The idler rides on a printed flexure arm. Swap arms (0.9–1.8 mm) to set the pinch from ~1 to ~8 N.

## How it works

![The wire path](renders/how_it_works.png)

![How it grips](renders/pinch.png)

## Assembly

The pen-scale test rig goes together in seven steps: **[assembly guide](docs/assembly.md)**. It also lists
every fit and its designed clearance.

![Exploded](renders/rig_step0.png)

## Status

Early prototype (2026-11). The pen-scale rig is printed and being tested. See [docs/status.md](docs/status.md).

| | |
|---|---|
| [docs/design.md](docs/design.md) | Concepts A and B, the test rigs, every part, print settings |
| [docs/assembly.md](docs/assembly.md) | Step-by-step assembly and the fits table |
| [docs/decisions.md](docs/decisions.md) | Why it's built this way; rejected ideas |
| [docs/status.md](docs/status.md) | Where it is, what's next, measurements |

Ready-to-slice files are in [`stl/`](stl/). Rebuild everything with `./stl/export.sh`, `./renders/render.sh`
and `./checks/run.sh` (OpenSCAD, Python 3 with Pillow, `rsvg-convert`).
