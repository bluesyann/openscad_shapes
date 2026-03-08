//
// Buildplate holder designed for Anycubic Photon Mono 4K printer
// It is shorter than the original manufacturer buildplate, allowing to print
// on a part stuck to the buildplate (e.g. bare PCB, wood...)
// Author: <bluesyann>
// License: <MIT>
//

// =======================
// Global parameters
// =======================

// Parameter to adjust to the media thickness
// setting it to 0 will match the orignial manufacturer's part
media_thck   = 10;

// Geometry
r_round      = 5;   // Radius of rounded corners

length       = 51;  // Overall length of the object (Z)
w_top        = 32;  // Width of the top part tied to the actuator (Y)
w_bot        = 18;  // Width of the bottom part fixed to the build plate (Y)
h_top        = 15;  // Height of the top part (X)
h_bot_origin = 17;
h_bot        = h_bot_origin-media_thck;   // Height of the bottom part (X) 15 ok

// Horizontal holes (along Z)
h_hole_r     = 2;
h_hole_span  = 21;
h_hole_shift = 5.5;

// Vertical holes (along X)
v_hole_r     = 2;
v_hole_span  = 35;
counterbore_r= 4;
screw_depth  = 7;

// Cutaway
cut_ratio    = 0.7; // Fraction of total length removed by the cutaway



// =======================
// Utility: rounded rectangle
// =======================
//
// 2D rounded rectangle centered optionally on X/Y.
//
module rounded_rect(l, w, r, center=false, xcenter=false, ycenter=false) {
    translate([
        (center || xcenter) ? -l/2 : 0,
        (center || ycenter) ? -w/2 : 0
    ])
    translate([r, r])
        offset(r = r, $fn = 60)
            // Core rectangle; note that rounding eats 2*r in both directions
            square([l - 2*r, w - 2*r]);
}



// =======================
// 2D profile (X–Y) to be extruded along Z
// =======================
//
// Top rounded rectangle + bottom rectangular “tab”.
//
module profile() {
    shift_bot_x = h_top/2 + h_bot/2;

    difference() {
        union() {
            // Top rounded actuator section, centered at origin
            rounded_rect(
                l = h_top,
                w = w_top,
                r = r_round,
                center = true
            );

            // Bottom rectangular section, attached on +X side
            translate([shift_bot_x, 0])
                square([h_bot, w_bot], center = true);
        }
    }
}



// =======================
// Horizontal mounting holes (along Z)
// =======================
//
// Two cylinders, symmetric in Y, going through full length.
//
module horizontal_holes() {
    holes_length = 3 * length;

    translate([h_hole_shift-h_top/2, -h_hole_span/2, -length])
        union() {
            cylinder(h = holes_length, r = h_hole_r, $fn = 30);

            translate([0, h_hole_span, 0])
                cylinder(h = holes_length, r = h_hole_r, $fn = 30);
        }
}



// =======================
// Cutaway (angled slot through the body)
// =======================
//
// A rounded rectangle extruded and rotated to remove a chunk of the part.
//
module cutaway() {
    w = cut_ratio * length;       // Cut depth (Z)
    l = 2 * h_top;                // Cut length (X)

    translate([
        -l + h_top/2,             // Shift back so cut starts near origin in X
        w_top,                    // Shift above center in Y
        (1 - cut_ratio) * length/2
    ])
    rotate(90, [1, 0, 0])
        linear_extrude(height = 2 * w_top)
            rounded_rect(l = l, w = w, r = r_round);
}



// =======================
// Vertical through‑holes (along X)
// =======================
//
// Two cylinders, symmetric in Z, going across the X dimension.
//
module vertical_holes() {
    holes_length = 2 * (h_bot + h_top);

    translate([
        -holes_length/2,          // Center along X
        0,                        // Center along Y
        (length - v_hole_span)/2  // Position in Z
    ])
    union() {
        // First vertical hole
        rotate(a = 90, v = [0, 1, 0])
            cylinder(h = holes_length, r = v_hole_r, $fn = 30);

        // Second vertical hole
        translate([0, 0, v_hole_span])
            rotate(a = 90, v = [0, 1, 0])
                cylinder(h = holes_length, r = v_hole_r, $fn = 30);
    }
}

// =======================
// Vertical counterbores (along X)
// =======================
//
// Two cylinders, symmetric in Z, going across the X dimension.
// We need a thickness of (screw_depth) mm between the head and the buidplate face
//
module vertical_counterbores() {
    holes_length = h_top+14;

    translate([
        -holes_length+h_bot+h_top/2-screw_depth,          // Center along X
        0,                        // Center along Y
        (length - v_hole_span)/2  // Position in Z
    ])
    union() {
        // First vertical hole
        rotate(a = 90, v = [0, 1, 0])
            cylinder(h = holes_length, r = counterbore_r, $fn = 30);

        // Second vertical hole
        translate([0, 0, v_hole_span])
            rotate(a = 90, v = [0, 1, 0])
                cylinder(h = holes_length, r = counterbore_r, $fn = 30);
    }
}


// =======================
// Main body
// =======================
//
// Hull of the extruded profile, minus all cut features.
//
module actuator_mount() {
    difference() {
        // Solid body
        hull() {
            linear_extrude(height = length)
                profile();
        }

        // Subtracted features
        horizontal_holes();
        cutaway();
        vertical_holes();
        vertical_counterbores();
    }
}



// =======================
// Top‑level call
// =======================

actuator_mount();
