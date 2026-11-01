// Evolution R255 TBL zero-clearance throat plate
// See SPEC.md for the source of every dimension.
//
// Coordinates (model space):
//   X = distance from the LEFT wall of the table opening (operator's left)
//   Y = distance from the FRONT wall of the table opening (operator end)
//   Z = 0 at the table surface, negative downward (depth = -Z)
// This is a right-handed system: viewed from above with the operator at the
// bottom, +X points right and +Y points away toward the riving knife.
// SPEC.md gives many positions "from back"; they appear here as
// from-front values (opening_len - d).
//
// Render a part from the command line:
//   openscad-nightly --backend=manifold -D 'part="front"' -o front_half.stl throat_plate.scad

/* [Output] */
// assembled | front | back | modifier_front | modifier_back | fit_front | fit_back
part = "assembled";

/* [Table opening] */
opening_len = 376;
opening_wid = 94;
corner_r = 9.5;
fit_clearance = 0.25;          // per side, plate to opening wall

/* [Support] */
ledge_depth_left = 8;
ledge_depth_right = 9;
rail_depth = 5;                // aluminum rail top, below table surface
ledge_gap = 0.3;               // pad-to-ledge gap; 0 = rest on ledges
rail_gap = 0.3;                // plate-to-rail gap; 0 = rest on rail
body_depth = 7.1;              // factory plate thickness

// Left ledge: [from_front_start, from_front_end, width]
ledges_left = [[0, 143, 9], [205, 376, 8]];
// Right ledge: [from_front_start, from_front_end, width]
ledges_right = [[0, 159, 8], [159, 203, 4], [317, 376, 9]];

rail_x = [10.5, 27];           // from left wall
rail_y = [48, 363];            // from front wall (13-328 from back)
rail_margin = 0.5;

/* [Ribs] */
rib_depth = 17;                // below table surface (blade is at 20)
rib_w = 3;
rib_x = [44.5, 52, 59.5, 67];  // rib centers, inside the reference's proven envelope
rib_y = [62, 336];             // rib extent from front
rib_taper = 8;
cross_rib_depth = 11;
cross_rib_w = 2.5;
cross_rib_pitch = 40;

/* [Blade and riving knife] */
blade_strip = [31, 42];        // keep-out for ribs (blade left face at 35)
knife_slot_x = [31, 41];
knife_slot_y = [286, 358];     // 18-90 from back
knife_slot_r = 1;

/* [Screws and holes] */
cbore_d = 10;
cbore_depth = 4;
screw_clear_d = 5.5;
level_hole_d = 5;
// [x from left, y from front]
holddowns = [[8, opening_len - 85], [opening_wid - 8, 17]];
level_holes = [[8, opening_len - 70], [opening_wid - 8, opening_len - 27],
               [opening_wid - 8, 55], [8, 55]];

/* [Lock (reference two-piece lock)] */
lock_pos = [41.6, 22.5];
lock_cbore_d = 18.6;           // knob flange is 18.0
lock_cbore_depth = 3;
lock_hole_d = 16.4;            // knob shaft is 15.8
lock_tube_od = 19.0;
lock_tube_depth = 10;
lock_sweep_r = 13.5;           // cam arm sweep (arm reaches r 12.6)

/* [Finger hole] */
finger_pos = [opening_wid - 30.3, 49.8];
finger_d = 17.5;

/* [Back tab] */
tab_w = 10;
tab_len = 3;
tab_t = 2;
tab_top_depth = 4;
tab_x = 52;

/* [Split joint] */
seam_y = opening_len - 187.5;  // from front (187.5 from back)
joint_clearance = 0.15;        // total gap between the halves
tail_x = [17, 56, 80];
tail_neck = 8;
tail_head = 13;
tail_len = 9;

/* [Fit test] */
fit_t = 2;
fit_band = 8;
fit_ring = 2;

/* [Hidden] */
$fn = 64;
eps = 0.01;
big = 100;

px0 = fit_clearance;
px1 = opening_wid - fit_clearance;
py0 = fit_clearance;
py1 = opening_len - fit_clearance;

// ---------- 2D helpers ----------

module outline2d() {
    r = corner_r - fit_clearance;
    translate([px0 + r, py0 + r])
        offset(r = r) square([px1 - px0 - 2 * r, py1 - py0 - 2 * r]);
}

// Ledge span [y0, y1, width]; spans touching the opening ends run past the
// outline so the intersection never leaves slivers at the corners.
module ledge_span2d(l, x0, x1) {
    y0 = l[0] <= 0 ? -big : l[0];
    y1 = l[1] >= opening_len ? opening_len + big : l[1];
    translate([x0, y0]) square([x1 - x0, y1 - y0]);
}

module ledge_left2d() {
    for (l = ledges_left) ledge_span2d(l, -big, l[2]);
}

module ledge_right2d() {
    for (l = ledges_right) ledge_span2d(l, opening_wid - l[2], opening_wid + big);
}

module rail_zone2d() {
    translate([-big, rail_y[0] - rail_margin])
        square([big + rail_x[1] + rail_margin, rail_y[1] - rail_y[0] + 2 * rail_margin]);
}

module knife_slot2d() {
    translate([knife_slot_x[0] + knife_slot_r, knife_slot_y[0] + knife_slot_r])
        offset(r = knife_slot_r)
            square([knife_slot_x[1] - knife_slot_x[0] - 2 * knife_slot_r,
                    knife_slot_y[1] - knife_slot_y[0] - 2 * knife_slot_r]);
}

// Region belonging to the back half; tails project forward across the seam.
module back_region2d() {
    translate([-big, seam_y]) square([opening_wid + 2 * big, opening_len - seam_y + big]);
    for (x = tail_x)
        polygon([[x - tail_neck / 2, seam_y + eps], [x + tail_neck / 2, seam_y + eps],
                 [x + tail_head / 2, seam_y - tail_len], [x - tail_head / 2, seam_y - tail_len]]);
}

module slab(depth) { translate([0, 0, -depth]) linear_extrude(depth) children(); }

// Everything deeper than `depth` inside the 2D region.
module below(depth) { translate([0, 0, -big]) linear_extrude(big - depth) children(); }

// ---------- 3D plate ----------

module rib(x) {
    translate([x - rib_w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(rib_w)
        polygon([[rib_y[0], eps], [rib_y[1], eps],
                 [rib_y[1] - rib_taper, -rib_depth], [rib_y[0] + rib_taper, -rib_depth]]);
}

module ribs() {
    for (x = rib_x) rib(x);
    // Pitched from the back end of the ribs.
    for (y = [rib_y[1] - rib_taper - cross_rib_pitch / 2 : -cross_rib_pitch : rib_y[0] + rib_taper])
        translate([rib_x[0], y - cross_rib_w / 2, -cross_rib_depth])
            cube([rib_x[len(rib_x) - 1] - rib_x[0], cross_rib_w, cross_rib_depth]);
}

module rib_keepouts() {
    translate([blade_strip[0], -big, -big]) cube([blade_strip[1] - blade_strip[0], 3 * big + opening_len, 2 * big]);
    slab(big) offset(delta = 2) knife_slot2d();
    translate([lock_pos[0], lock_pos[1], -big]) cylinder(r = lock_sweep_r, h = big);
    translate([finger_pos[0], finger_pos[1], -big]) cylinder(d = finger_d + 4, h = big);
}

module plate_solid() {
    // One outline extrusion to the deepest pad, with the shallower zones cut
    // away from below. Only the outline forms outer walls, so zone boundaries
    // never coincide with them.
    pad_left = ledge_depth_left - ledge_gap;
    pad_right = ledge_depth_right - ledge_gap;
    difference() {
        slab(max(body_depth, pad_left, pad_right)) outline2d();
        below(body_depth) difference() {
            translate([-big, -big]) square([opening_wid + 2 * big, opening_len + 2 * big]);
            ledge_left2d();
            ledge_right2d();
        }
        below(rail_depth - rail_gap) difference() { rail_zone2d(); ledge_left2d(); ledge_right2d(); }
        below(pad_left) ledge_left2d();
        below(pad_right) ledge_right2d();
    }
    // Stiffening ribs, outside every keep-out.
    difference() {
        intersection() { ribs(); slab(big) offset(delta = -1) outline2d(); }
        rib_keepouts();
    }
    // Lock tube.
    translate([lock_pos[0], lock_pos[1], -lock_tube_depth]) cylinder(d = lock_tube_od, h = lock_tube_depth);
    // Back tab.
    translate([tab_x - tab_w / 2, py1 - 1, -tab_top_depth - tab_t]) cube([tab_w, tab_len + 1, tab_t]);
}

module holes() {
    slab(big) knife_slot2d();
    for (p = holddowns) translate([p[0], p[1], 0]) {
        translate([0, 0, -cbore_depth]) cylinder(d = cbore_d, h = cbore_depth + eps);
        translate([0, 0, -big]) cylinder(d = screw_clear_d, h = big + eps);
    }
    for (p = level_holes) translate([p[0], p[1], -big]) cylinder(d = level_hole_d, h = big + eps);
    translate([lock_pos[0], lock_pos[1], 0]) {
        translate([0, 0, -lock_cbore_depth]) cylinder(d = lock_cbore_d, h = lock_cbore_depth + eps);
        translate([0, 0, -big]) cylinder(d = lock_hole_d, h = big + eps);
    }
    translate([finger_pos[0], finger_pos[1], -big]) cylinder(d = finger_d, h = big + eps);
}

module plate() { difference() { plate_solid(); holes(); } }

// ---------- Fit test (2 mm frame with every hole) ----------

module fit_solid() {
    feature_pts = concat(holddowns, level_holes, [lock_pos, finger_pos]);
    slab(fit_t) intersection() {
        outline2d();
        union() {
            difference() { outline2d(); offset(delta = -fit_band) outline2d(); }
            offset(delta = fit_ring) knife_slot2d();
            translate([knife_slot_x[0], knife_slot_y[0]]) square([knife_slot_x[1] - knife_slot_x[0], opening_len - knife_slot_y[0]]);
            translate([0, seam_y - tail_len - 15]) square([opening_wid, tail_len + 30]);
            for (p = feature_pts) {
                translate(p) circle(d = 20);
                hull() { translate(p) circle(d = 4); translate([p[0] < opening_wid / 2 ? 0 : opening_wid, p[1]]) circle(d = 4); }
            }
        }
    }
    // Post down to the back tab.
    translate([tab_x - tab_w / 2, py1 - 3, -tab_top_depth - tab_t]) cube([tab_w, 3, tab_top_depth + tab_t]);
    translate([tab_x - tab_w / 2, py1 - 1, -tab_top_depth - tab_t]) cube([tab_w, tab_len + 1, tab_t]);
}

module fit_test() { difference() { fit_solid(); holes(); } }

// ---------- Split and orientation ----------

module back_of(clr) { intersection() { children(); slab(big) offset(delta = -clr / 2) back_region2d(); } }
module front_of(clr) { difference() { children(); slab(big) offset(delta = clr / 2) back_region2d(); } }

// Top face down on the bed: flip about X, so +Z becomes the underside.
module print_pose() { rotate([180, 0, 0]) children(); }

module blade_modifier() {
    translate([blade_strip[0] - 2, -big, -body_depth]) cube([blade_strip[1] - blade_strip[0] + 4, 3 * big + opening_len, body_depth]);
}

if (part == "assembled") plate();
else if (part == "front") print_pose() front_of(joint_clearance) plate();
else if (part == "back") print_pose() back_of(joint_clearance) plate();
else if (part == "modifier_front") print_pose() front_of(joint_clearance) intersection() { plate(); blade_modifier(); }
else if (part == "modifier_back") print_pose() back_of(joint_clearance) intersection() { plate(); blade_modifier(); }
else if (part == "fit_front") print_pose() front_of(joint_clearance) fit_test();
else if (part == "fit_back") print_pose() back_of(joint_clearance) fit_test();
