#!/usr/bin/env python3
"""Generate the how-it-works diagrams (SVG) from the pen-scale rig's dimensions (parts/solder_pen_rig.scad).
Run: python3 docs/diagrams/make.py   (renders/render.sh then converts them to PNG)."""
import math, os
D = os.path.dirname(os.path.abspath(__file__))

# --- numbers copied from parts/solder_pen_rig.scad (keep in sync) ---
wire, bite, idl_bite = 0.87, 0.25, 0.6
drv_d, idl_d, thumb_d, tooth = 7, 5, 18, 0.8
x_n = 56
drv_c = (x_n, -(wire/2 - bite) - drv_d/2)
idl_c = (x_n, (wire/2 - idl_bite) + idl_d/2)
fl_x0, fl_t, fl_r, core_d, core_x1, lip_d, lip_x1 = 0.85, 2.3, 7, 10, 30.5, 11.6, 33.25
ch_r, ch_x1, eye_x = 7.5, 34, 39
anc_x0, anc_x1, anc_y0, anc_y1, arm_y0, arm_t = 41, 45, 5.0, 8.0, 5.6, 1.5
ns_x = x_n + thumb_d/2 + 1; ns_d, ns_t, luer_l = 13, 2.5, 8.5
x_front = ns_x + ns_t + 0.15 + 1.0

INK, MUTED, WIRE = "#222", "#777", "#5b6570"
BOLD = 'font-weight="bold"'
FONT = 'font-family="Helvetica, Arial, sans-serif"'

def svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
            f'<defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
            f'<path d="M0,0 L10,5 L0,10 z" fill="{INK}"/></marker>'
            f'<marker id="r" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">'
            f'<path d="M0,0 L10,5 L0,10 z" fill="#c0392b"/></marker></defs>\n'
            f'<rect width="{w}" height="{h}" fill="white"/>\n{body}</svg>\n')

def teeth(cx, cy, d, n, P):
    pts = []
    for i in range(2*n):
        a = math.pi * i / n; r = d/2 if i % 2 == 0 else d/2 - tooth
        pts.append(P(cx + r*math.cos(a), cy + r*math.sin(a)))
    return " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)

def label(x, y, tx, ty, text, anchor="start", sub=None):
    s = f'<line x1="{x:.1f}" y1="{y:.1f}" x2="{tx:.1f}" y2="{ty:.1f}" stroke="{MUTED}" stroke-width="1.2"/>\n'
    s += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3" fill="{MUTED}"/>\n'
    dy = -6 if ty < y else 18
    s += f'<text x="{tx:.1f}" y="{ty + dy:.1f}" {FONT} font-size="17" font-weight="bold" fill="{INK}" text-anchor="{anchor}">{text}</text>\n'
    if sub: s += f'<text x="{tx:.1f}" y="{ty + dy + 19:.1f}" {FONT} font-size="14" fill="{MUTED}" text-anchor="{anchor}">{sub}</text>\n'
    return s

# ---------------- 1. how it works: top view of the rig, wire path ----------------
def how():
    S, OX, OY = 15, 70, 330
    P = lambda x, y: (OX + x*S, OY - y*S)
    b = ""
    b += f'<text x="40" y="44" {FONT} font-size="26" font-weight="bold" fill="{INK}">How it works: the wire path (top view, cover off)</text>\n'
    b += f'<text x="40" y="72" {FONT} font-size="16" fill="{MUTED}">Roll the thumbwheel: the drive wheel pulls wire off the fixed spool and pushes it out of the needle. Roll back to retract.</text>\n'
    x, y = P(0, 10); w = x_front*S; h = 20*S
    b += f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="14" fill="#fbe9e7" stroke="#d0393b" stroke-width="2"/>\n'
    # chamber + funnel
    cx0, cy0 = P(fl_x0 + fl_t, ch_r); cx1, cy1 = P(ch_x1, -ch_r); ex, ey = P(eye_x, 1.5); ex2, ey2 = P(eye_x, -1.5)
    b += f'<path d="M{cx0},{cy0} L{cx1},{cy0} L{ex},{ey} L{P(ns_x,0)[0]},{ey} L{P(ns_x,0)[0]},{ey2} L{ex2},{ey2} L{cx1},{cy1} L{cx0},{cy1} Z" fill="white" stroke="#d0393b" stroke-width="1.5" stroke-dasharray="6 4"/>\n'
    # spool
    fx, fy = P(fl_x0, fl_r); b += f'<rect x="{fx}" y="{fy}" width="{fl_t*S}" height="{2*fl_r*S}" fill="#f0b429" stroke="{INK}"/>\n'
    kx, ky = P(fl_x0 + fl_t, core_d/2); b += f'<rect x="{kx}" y="{ky}" width="{(core_x1-fl_x0-fl_t)*S}" height="{core_d*S}" fill="#f0b429" stroke="{INK}"/>\n'
    lx0, ly0 = P(core_x1, core_d/2); lx1, ly1 = P(lip_x1, lip_d/2); lx2, ly2 = P(lip_x1, -lip_d/2); lx3, ly3 = P(core_x1, -core_d/2)
    b += f'<path d="M{lx0},{ly0} L{P(core_x1+0.8,lip_d/2)[0]},{ly1} L{lx1},{ly1} L{lx2},{ly2} L{P(core_x1+0.8,-lip_d/2)[0]},{ly2} L{lx3},{ly3} Z" fill="#f0b429" stroke="{INK}"/>\n'
    for i in range(12):                       # coil turns (back half wound)
        xx = P(fl_x0 + fl_t + 1.3 + i*1.2, 0)[0]
        b += f'<line x1="{xx:.1f}" y1="{P(0,core_d/2+0.3)[1]:.1f}" x2="{xx+4:.1f}" y2="{P(0,-core_d/2-0.3)[1]:.1f}" stroke="{WIRE}" stroke-width="{wire*S:.1f}" stroke-linecap="round"/>\n'
    # wire: front turn -> over lip -> eyelet -> nip -> nose -> needle
    pts = [P(fl_x0 + fl_t + 1.3 + 11*1.2 + 0.3, -lip_d/2 + 0.2), P(lip_x1, -lip_d/2 - 0.4), P(eye_x, 0), P(x_front + luer_l + 22, 0)]
    b += f'<polyline points="{" ".join(f"{a:.1f},{c:.1f}" for a, c in pts)}" fill="none" stroke="{WIRE}" stroke-width="{wire*S:.1f}" stroke-linecap="round" stroke-linejoin="round"/>\n'
    # thumbwheel (dashed, it sits above the drive wheel) + drive + idler
    tx, ty = P(*drv_c); b += f'<circle cx="{tx}" cy="{ty}" r="{thumb_d/2*S}" fill="#3b82c4" fill-opacity="0.12" stroke="#3b82c4" stroke-width="2" stroke-dasharray="8 5"/>\n'
    b += f'<polygon points="{teeth(*drv_c, drv_d, 14, P)}" fill="#3b82c4" stroke="{INK}"/>\n'
    b += f'<circle cx="{tx}" cy="{ty}" r="{1.5*S}" fill="white" stroke="{INK}"/>\n'
    # arm: anchor + flexure + bracket
    ax, ay = P(anc_x0, anc_y1); b += f'<rect x="{ax}" y="{ay}" width="{(anc_x1-anc_x0)*S}" height="{(anc_y1-anc_y0)*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    fx, fy = P(anc_x1, arm_y0 + arm_t); b += f'<rect x="{fx}" y="{fy}" width="{(x_n+2.5-anc_x1)*S}" height="{arm_t*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    bx, by = P(x_n - 2.5, arm_y0); b += f'<rect x="{bx}" y="{by}" width="{5*S}" height="{(arm_y0-idl_c[1])*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    b += f'<polygon points="{teeth(*idl_c, idl_d, 10, P)}" fill="#cccccc" stroke="{INK}"/>\n'
    ix, iy = P(*idl_c); b += f'<circle cx="{ix}" cy="{iy}" r="{1.25*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    # nose
    nx, ny = P(ns_x, ns_d/2); b += f'<rect x="{nx}" y="{ny}" width="{ns_t*S}" height="{ns_d*S}" fill="#e879b0" stroke="{INK}"/>\n'
    t0 = 3.925 + 0.06*luer_l
    b += f'<polygon points="{P(ns_x+ns_t,t0/2)[0]},{P(0,t0/2)[1]} {P(ns_x+ns_t+luer_l,0)[0]},{P(0,3.925/2)[1]} {P(ns_x+ns_t+luer_l,0)[0]},{P(0,-3.925/2)[1]} {P(ns_x+ns_t,0)[0]},{P(0,-t0/2)[1]}" fill="#e879b0" stroke="{INK}"/>\n'
    nd0 = P(x_front + luer_l, 0)[0]
    b += f'<rect x="{nd0}" y="{P(0,1)[1]}" width="{(x_front+luer_l)*0+20*S}" height="{2*S}" fill="#d9d9d9" stroke="{INK}"/>\n'
    b += f'<line x1="{nd0}" y1="{P(0,0)[1]}" x2="{nd0+20*S}" y2="{P(0,0)[1]}" stroke="{WIRE}" stroke-width="{wire*S:.1f}"/>\n'
    # motion arrows
    r = thumb_d/2*S + 18
    a0, a1 = math.radians(250), math.radians(200)     # clockwise on screen: the drive's top moves toward the needle
    b += f'<path d="M{tx + r*math.cos(a0):.1f},{ty - r*math.sin(a0):.1f} A{r},{r} 0 0 1 {tx + r*math.cos(a1):.1f},{ty - r*math.sin(a1):.1f}" fill="none" stroke="#c0392b" stroke-width="3" marker-end="url(#r)"/>\n'
    wx, wy = P(x_front + luer_l + 24, 0)
    b += f'<line x1="{wx}" y1="{wy}" x2="{wx + 60}" y2="{wy}" stroke="#c0392b" stroke-width="3" marker-end="url(#r)"/>\n'
    sx, sy = P(x_n + 1.5, arm_y0 + arm_t + 0.3)
    b += f'<line x1="{sx}" y1="{sy - 40}" x2="{sx}" y2="{sy - 4}" stroke="#c0392b" stroke-width="3" marker-end="url(#r)"/>\n'
    # labels
    b += label(*P(16, 5.5), *P(10, 15.5), "1  Fixed spool", sub="single-layer coil in a helical groove; never turns")
    b += label(*P(lip_x1 - 0.5, -lip_d/2 - 0.3), *P(24, -15.5), "2  Peels over the lip", sub="front turn first, so nothing crosses")
    b += label(*P(eye_x, 0), *P(38, 15.5), "3  Funnel + eyelet", sub="centres the wire on the axis")
    b += label(*P(x_n - 2, drv_c[1] - 2), *P(48, -17.5), "4  Drive wheel + thumbwheel", sub="ø7, 14 teeth; ø18 thumbwheel pokes out the side")
    b += label(*P(x_n + 2.2, idl_c[1]), *P(62, 15.5), "5  Idler on a flexure arm", sub="arm thickness sets the pinch (1-8 N)")
    b += label(*P(ns_x + ns_t + 5, 1.3), *P(84, -9.5), "6  Luer nose + needle", sub="ISO 594 taper; any blunt Luer needle")
    return svg(1660, 640, b)

# ---------------- 2. the pinch: flexure arm as a cantilever ----------------
def pinch():
    S, OX, OY = 26, 120, 338
    P = lambda x, y: (OX + (x - 38)*S, OY - (y - 0)*S)
    b = ""
    b += f'<text x="40" y="44" {FONT} font-size="26" font-weight="bold" fill="{INK}">How it grips: the idler is preloaded into the wire\'s path</text>\n'
    b += f'<text x="40" y="72" {FONT} font-size="16" fill="{MUTED}">With no wire, the idler sits 0.6 mm past the wire line. Loading the wire bends the arm back ~0.6 mm, and the bent arm is the spring.</text>\n'
    # wire line
    b += f'<line x1="{P(38,0)[0]}" y1="{P(0,0)[1]}" x2="{P(68,0)[0]}" y2="{P(0,0)[1]}" stroke="{WIRE}" stroke-width="{wire*S:.1f}" stroke-linecap="round"/>\n'
    b += f'<text x="{P(38.3,0)[0]}" y="{P(0,-1.1)[1]}" {FONT} font-size="15" fill="{MUTED}">wire ø0.87 (0.8 nominal)</text>\n'
    # drive
    dx, dy = P(*drv_c)
    b += f'<polygon points="{teeth(*drv_c, drv_d, 14, P)}" fill="#3b82c4" stroke="{INK}"/>\n<circle cx="{dx}" cy="{dy}" r="{1.5*S}" fill="white" stroke="{INK}"/>\n'
    # anchor (fixed, hatched) + bent arm (solid) + unloaded arm (ghost)
    ax, ay = P(anc_x0, anc_y1)
    b += f'<rect x="{ax}" y="{ay}" width="{(anc_x1-anc_x0)*S}" height="{(anc_y1-anc_y0)*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    b += f'<text x="{ax}" y="{ay + (anc_y1-anc_y0)*S + 22}" {FONT} font-size="15" fill="{MUTED}">anchor, slotted into the body (fixed)</text>\n'
    L = x_n + 2.5 - anc_x1
    def arm_path(defl, style):
        n = 24; top, bot = [], []
        for i in range(n + 1):
            s = i / n; xx = anc_x1 + s*L; d = defl * s*s*(3 - s)/2      # cantilever end-load shape
            top.append(P(xx, arm_y0 + arm_t + d)); bot.append(P(xx, arm_y0 + d))
        pts = top + bot[::-1]
        return f'<polygon points="{" ".join(f"{a:.1f},{c:.1f}" for a, c in pts)}" {style}/>\n'
    b += arm_path(0, f'fill="none" stroke="{MUTED}" stroke-width="1.5" stroke-dasharray="6 4"')
    b += arm_path(0.6, f'fill="#6bbf59" stroke="{INK}"')
    ic = (idl_c[0], idl_c[1] + 0.6)
    b += f'<polygon points="{teeth(*idl_c, idl_d, 10, P)}" fill="none" stroke="{MUTED}" stroke-width="1.5" stroke-dasharray="6 4"/>\n'
    b += f'<rect x="{P(x_n-2.5,0)[0]}" y="{P(0,arm_y0+0.6)[1]}" width="{5*S}" height="{(arm_y0-ic[1])*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    b += f'<polygon points="{teeth(*ic, idl_d, 10, P)}" fill="#cccccc" stroke="{INK}"/>\n'
    cx, cy = P(*ic); b += f'<circle cx="{cx}" cy="{cy}" r="{1.25*S}" fill="#6bbf59" stroke="{INK}"/>\n'
    # dimensions
    yL = P(0, arm_y0 + arm_t + 1.6)[1]
    b += f'<line x1="{P(anc_x1,0)[0]}" y1="{yL}" x2="{P(x_n,0)[0]}" y2="{yL}" stroke="{INK}" marker-start="url(#a)" marker-end="url(#a)"/>\n'
    b += f'<text x="{(P(anc_x1,0)[0]+P(x_n,0)[0])/2}" y="{yL - 8}" {FONT} font-size="16" fill="{INK}" text-anchor="middle">free length 11 mm, 6.2 mm tall</text>\n'
    xr = P(x_n + 4.5, 0)[0]
    b += f'<line x1="{xr}" y1="{P(0,arm_y0)[1]}" x2="{xr}" y2="{P(0,arm_y0+0.6)[1]}" stroke="#c0392b" stroke-width="2" marker-start="url(#r)" marker-end="url(#r)"/>\n'
    b += f'<text x="{xr + 10}" y="{P(0,arm_y0+0.3)[1] + 5}" {FONT} font-size="16" fill="#c0392b">0.6 mm bend = the preload</text>\n'
    b += f'<line x1="{cx}" y1="{cy - 2.6*S - 40}" x2="{cx}" y2="{cy - 2.6*S + 2}" stroke="#c0392b" stroke-width="3" marker-end="url(#r)"/>\n'
    b += f'<text x="{cx + 10}" y="{cy - 2.6*S - 30}" {FONT} font-size="16" fill="#c0392b">pinch force</text>\n'
    b += f'<text x="{dx - 2.6*S}" y="{dy + 4.8*S}" {FONT} font-size="16" fill="{INK}">drive wheel: its teeth bite 0.25 mm into the wire</text>\n'
    # table
    tx, ty = 1000, 470
    rows = [("arm", "notches", "pinch"), ("0.9 mm", "1", "~1 N"), ("1.2 mm", "2", "~2.5 N"), ("1.5 mm", "3", "~5 N"), ("1.8 mm", "4", "~8 N")]
    b += f'<text x="{tx}" y="{ty - 34}" {FONT} font-size="17" font-weight="bold" fill="{INK}">Swap arms to tune the grip</text>\n'
    for i, r in enumerate(rows):
        for j, c in enumerate(r):
            b += f'<text x="{tx + j*120}" y="{ty + i*24}" {FONT} font-size="15" fill="{INK if i else MUTED}" {BOLD if i == 0 else ""}>{c}</text>\n'
    return svg(1660, 620, b)

open(os.path.join(D, "how_it_works.svg"), "w").write(how())
open(os.path.join(D, "pinch.svg"), "w").write(pinch())
print("wrote how_it_works.svg, pinch.svg")
