# Evolution R255 TBL Zero-Clearance Throat Plate — Specification

Status: **v1.1** (2026-10-21). Interview complete; first OpenSCAD model in `throat_plate.scad`, not yet test-printed.

## 1. Goals

- Zero-clearance throat plate: no pre-cut blade slot, so the blade cuts its own kerf. For 90° cuts only; the blade is never tilted with this plate installed.
- Fits with the riving knife installed. The knife rises and falls with the blade and sits below the table surface when the blade is fully lowered, so the plate drops straight down onto the saw with the blade lowered.
- No extra clearance needed for the blade guard.
- Fixes three problems with the reference model (MakerWorld 1796905, "Woodwork Journey", CC BY-NC-SA):
  1. **Riving knife slot:** pre-cut, so there's no risky slot extension cut on the saw.
  2. **Hold-down screws:** two counterbored screw holes, as on the factory plate.
  3. **Support:** rests on every available surface (ledges and the aluminum rail), not just the leveling screws.
- Also fixes the reference's sideways play: it is 5.2 mm thick over a rail that sits 5 mm below the table.
- The plate body is designed from scratch from these measurements. Only the lock interface and the finger-hole position follow the reference, so the reference's glued two-piece lock can be used. If the result is shared publicly, CC BY-NC-SA applies to those parts.

## 2. Coordinate convention

- **Front** = the operator end, where the lock is. **Back** = the riving knife end. In all photos the front is at the top.
- **Left / right** = as seen by the operator at the front, looking toward the back.
- Plate positions are measured from the plate edges, as on the factory plate: "from back", "from left", and so on.
- Depth = distance below the table surface (top of plate = depth 0).

## 3. Manufacturing

| Item | Value |
|---|---|
| CAD | OpenSCAD, fully parametric (all dimensions below are top-level variables) |
| Printer | Bambu Lab P1S (256 × 256 mm bed) |
| Material | PETG (PLA also possible) |
| Orientation | Top surface face-down on the build plate |
| Split | Two halves. 375 mm won't fit even diagonally on 256 mm (max 362 mm) |
| Joint | Glued puzzle/dovetail across the full width. Default seam 187.5 mm from back (parameter), clear of every hole |
| Suggested slicer settings | 0.2 mm layers, 6 walls, ≥ 25 % infill, plus a 100 % infill modifier along the blade strip so the kerf cuts through solid plastic. The model exports this modifier as a separate STL |

## 4. Table opening (measured)

| Item | Value |
|---|---|
| Length × width (at table surface) | 376 × 94 mm |
| Corner radius | ≈ 9.5 mm (factory plate end flat is 75 mm: (94 − 75) / 2) |
| Back lip | The table edge overhangs at the back; the plate's tab slides under it about 3 mm |
| Ledge depth, left | 8 mm |
| Ledge depth, right | 9 mm |
| Blade top at its lowest | 20 mm depth |

### Ledges (width measured from the opening wall inward)

**Left side:**
- 9 mm wide at the front and middle, 8 mm at the back.
- No ledge from 171 to 233 mm from back.

**Right side, front to back:**
- 8 mm wide from the front to 217 mm from back.
- 4 mm wide from 217 to 173 mm from back.
- No ledge from 173 to 59 mm from back.
- 9 mm wide from 59 mm to the back.

### Aluminum rail (left side)

| Item | Value |
|---|---|
| Across the width | 10.5 mm to 27 mm from the left wall |
| Along the length | 13 mm to 328 mm from back |
| Top | 3 mm above the left ledge = **5 mm depth** |
| Surface | Flat top with 3 mm-deep rectangular indentations (ignored; the plate bears on the flat top) |
| Motion | Moves only when the blade tilts. Stays put when the blade is raised |

### Leveling screws (in the table)
- Four set screws in the ledges, adjusted with a 3 mm hex key from above through holes in the plate.
- The plate needs no threads.

## 5. Factory plate (reference dimensions)

| Item | Value |
|---|---|
| Outline | 375 × 94 mm |
| Thickness | 7.1 mm. Rests only on the 4 leveling screws |
| Back tabs | Two, each 10 wide × 3 long × 2 thick mm, top of tab 4 mm below the top surface |
| Hold-down screws | Pan head (flat underside), Phillips. 8 mm head × 3 mm tall, 5 mm shank (probably M5), 13 mm long. Thread into the table |
| Head counterbore | 10 mm diameter × 4 mm deep |
| Blade | Left face 35 mm from the left edge. Kerf varies (≈ 2.2–3.2 mm) |
| Riving knife | 2 mm thick, centered in its 10 mm opening (knife at 35–37 mm from left) |

## 6. New plate: design

### 6.1 Outline
- Nominal 376 × 94 mm (the opening) minus `fit_clearance` per side. Default 0.25 mm, which gives 375.5 × 93.5 mm. Corner radius 9.5 mm minus the clearance.
- **Back tab (one):** 10 mm wide, center 52 mm from left. Sticks out 3 mm past the back edge, 2 mm thick, top of tab at 4 mm depth (so it spans 4–6 mm depth).

### 6.2 Thickness zones (depth of the underside)

| Zone | Underside depth | Default |
|---|---|---|
| Over the left ledge (except the notch) | `ledge_depth_left − support_gap` | 7.7 mm |
| Over the right ledge (except the notch; 4 mm-wide section included) | `ledge_depth_right − support_gap` | 8.7 mm |
| Over the rail (10.5–27 mm from left, 13–328 mm from back, plus `rail_margin` around it) | `rail_depth − support_gap` | 4.7 mm |
| Everywhere else (main body) | `body_depth` | 7.1 mm |
| Stiffening ribs | up to `rib_depth` | 17 mm |

- `support_gap` (default 0.3 mm) gives the hybrid support. The leveling screws set the plate flush, and the ledges and rail catch it if it flexes. Set `support_gap = 0` to rest directly on the ledges and rail, with the leveling screws backed off. Separate gap parameters for the ledges and the rail are also allowed.
- Because the ledge pads sit lower than the factory plate's underside, the leveling screws are set about 0.3 mm proud of the ledge instead of about 0.9–1.9 mm.
- Where zones meet, the deeper zone stops at the edge of its support surface, so nothing hangs over an open area of the opening deeper than `body_depth`.

### 6.3 Keep-outs for ribs and anything deeper than `body_depth`
- **Blade strip:** 31–42 mm from left, full length (blade ± about 4 mm).
- **Riving knife slot** and a 2 mm margin around it.
- **Rail zone:** never deeper than 4.7 mm (above).
- **Default rib envelope:** limited to the area where the reference model's 18 mm ribs are known to fit, roughly 42–74 mm from left along most of the length. Any extra ribs to the right of 74 mm are a parameter and off by default.

### 6.4 Features

| Feature | Position | Size |
|---|---|---|
| Riving knife slot (through) | 18–90 mm from back, 31–41 mm from left | 10 × 72 mm, small corner radius |
| Hold-down counterbore, left | 85 mm from back, 8 mm from left | Ø10 × 4 mm deep, Ø5.5 through |
| Hold-down counterbore, right | 17 mm from front, 8 mm from right | Ø10 × 4 mm deep, Ø5.5 through |
| Leveling access hole 1 | 70 mm from back, 8 mm from left | Ø5 through |
| Leveling access hole 2 | 27 mm from back, 8 mm from right | Ø5 through |
| Leveling access hole 3 | 55 mm from front, 8 mm from right | Ø5 through |
| Leveling access hole 4 | 55 mm from front, 8 mm from left | Ø5 through |
| Lock hole and glue interface for the reference two-piece lock | Center 22.5 mm from front, 41.6 mm from left (from the reference) | Ø18.6 × 3 mm counterbore for the knob flange (Ø18.0), Ø16.4 through hole for the shaft (Ø15.8), Ø19 tube down to 10 mm depth, r 13.5 mm kept clear below for the cam arm |
| Finger-lift hole | Center ≈ 49.8 mm from front, ≈ 30.3 mm from right (from the reference; matches the factory plate) | Ø17.5 through |
| Dovetail joint | Seam at `seam_from_back` (default 187.5 mm) | 3 tails, `joint_clearance` 0.15 mm, through the full body thickness; ribs butt together at the seam |

- With the left ledge pad, the material under the hold-down screw heads is 3.7 mm instead of the factory 3.1 mm. A 13 mm screw still gets about 9 mm of thread into the table.
- The left hold-down counterbore reaches past the ledge pad into the thinned rail zone. For x > 9 mm the floor under the screw head is only 0.7 mm (from 4.0 to 4.7 mm depth); most of the head bears on the pad.
- The ledges at the front and back ends weren't measured, so the model has no pads there (body depth 7.1 mm).

## 7. Model outputs
Set `part` in `throat_plate.scad` (or pass `-D 'part="front"'` on the command line) to choose what to render. STLs are in `stl/`, oriented face-down for printing.

| `part` | File | Contents |
|---|---|---|
| `assembled` | `stl/assembled.stl` | Whole plate in saw coordinates, for reference only (too long to print) |
| `front` / `back` | `stl/front.stl`, `stl/back.stl` | The printable halves. The back half carries the dovetail tails |
| `modifier_front` / `modifier_back` | `stl/modifier_*.stl` | Blade-strip volumes for a 100 % infill modifier. They share each half's coordinates; if Bambu Studio doesn't place one correctly, add a box modifier instead: 15 mm wide, centered 36.5 mm from the left edge, full length, 7.1 mm deep |
| `fit_front` / `fit_back` | `stl/fit_*.stl` | 2 mm fit-test frame, also split with the dovetail, so it tests the outline, every hole position, the back tab and the joint clearance at once |

Rebuild everything with:
```
for p in assembled front back modifier_front modifier_back fit_front fit_back; do
  openscad-nightly --backend=manifold --export-format binstl -D "part=\"$p\"" -o stl/$p.stl throat_plate.scad
done
```

## 8. Fitting and safety procedure
1. Print and test the fit with the outline ring. Adjust `fit_clearance` and any hole positions if needed.
2. Print the halves and glue them, keeping the top face flat (clamp them face-down on a flat surface).
3. With the blade **fully lowered and at 90°**, drop the plate in, tab first under the back lip. Fit the riving knife through its slot.
4. Adjust the four leveling screws until the plate is flush. Fit the two hold-down screws.
5. With the plate **screwed down** (not held by hand), switch on and raise the blade slowly through the plate to cut the zero-clearance kerf. The kerf runs into the pre-cut riving knife slot.
6. Never tilt the blade with this plate installed: the rail moves when the blade tilts and supports the plate.

## 9. Parameter summary (defaults)

```
opening_len = 376; opening_wid = 94; corner_r = 9.5; fit_clearance = 0.25;
ledge_depth_left = 8; ledge_depth_right = 9; rail_depth = 5; support_gap = 0.3;
body_depth = 7.1; rib_depth = 17; blade_left = 35; blade_strip = [31, 42];
rail_from_left = [10.5, 27]; rail_from_back = [13, 328]; rail_margin = 0.5;
tab_w = 10; tab_len = 3; tab_t = 2; tab_top_depth = 4; tab_center_from_left = 52;
knife_slot = [31, 41] x [18, 90] (from left x from back);
cbore_d = 10; cbore_depth = 4; screw_clear_d = 5.5; level_hole_d = 5;
seam_from_back = 187.5; joint_clearance = 0.15;
```
