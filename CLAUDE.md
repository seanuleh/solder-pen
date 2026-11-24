# Solder Pen: guide for agents

A one-handed solder-wire pen (thumbwheel pinch drive, fixed spool, Luer needle). Parametric OpenSCAD in
`parts/`; STLs, 3MFs and renders are generated. The user is in Australia, prints on a Bambu X1C (PETG).

| Doc | Read it when |
|---|---|
| [`README.md`](README.md) | Changing what the project is or its headline images. Keep it a short showcase. |
| [`docs/design.md`](docs/design.md) | Any part: concepts, rigs, every part, print notes, commands |
| [`docs/assembly.md`](docs/assembly.md) | How the rig goes together; every fit and its clearance |
| [`docs/decisions.md`](docs/decisions.md) | **Before proposing any design change** |
| [`docs/status.md`](docs/status.md) | Starting a session; planning; measurements |

## Rules

- **Keep the docs true** in the same piece of work: parts → design.md (+ STL); fits or assembly → assembly.md;
  decisions (dated, absolute) → decisions.md; progress → status.md.
- **Verify, don't eyeball:** `./checks/run.sh` must all PASS (a new kind of risk gets a new check, proven to
  fail); re-export the STLs; `./renders/render.sh`; look at every changed PNG.
- The diagrams' numbers live in `docs/diagrams/make.py`, copied from `parts/solder_pen_rig.scad`: change both.
- Never encapsulate a spring; prefer what the user owns. Don't reopen rejected ideas.
- **Git:** commit and push only when the user asks.
