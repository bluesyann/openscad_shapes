// Rack-and-pinion pen holder / slide mechanism
// Requires: use <gears/gears.scad>;  (provides rack_and_pinion())
// git submodule add https://github.com/chrisspen/gears
use<gears/gears.scad>;
include <functions.scad>
// ---------------------------
// Global parameters
// ---------------------------

// Slide bar thicknesses
inner_bar_thickness  = 4;    // thickness of inner sliding bar
outer_bar_thickness  = 8;    // total outer wall thickness

// Clearances and dimensions
slide_clearance      = 0.3;  // gap between the two slides
rack_width           = 3;    // rack width (slot width)
pinion_radius        = 15;   // pinion radius including teeth
rack_length          = 50;   // rack length
rack_overlap         = 3;    // how much the rack overhangs the pinion region
circle_resolution    = 40;   // circle polygon resolution

// Gear parameters
gear_module          = 0.5;
gear_teeth           = 2 * pinion_radius / gear_module - 1; // remove 2 teeth so it fits through the opening
gear_bore            = 1;
gear_face_width      = inner_bar_thickness / 2;
pressure_angle       = 20;
helix_angle          = 20;
gear_clearance       = 0.2;  // difference between pinion thickness and groove width


// Cross-section of the slide profile
// thk   : total thickness
// w     : groove width
// rp    : pinion radius
// over  : extra overhang over the pinion
// fill  : if true, fill the central region
module slide_profile(thk, w, rp, over, fill) {
    translate([-w - rp, 0, 0])
    union() {
        // Main rounded outer profile
        difference() {
            circle(r = thk / 2, $fn = circle_resolution);
            translate([thk / 2, 0, 0])
                square(thk, center = true);
        }

        // Upper and lower rails
        translate([0, thk / 2 - thk / 4, 0])
            square([w + over, thk / 4]);
        translate([0, -thk / 2, 0])
            square([w + over, thk / 4]);

        // Optional fill between rails
        if (fill)
            translate([0, -thk / 2, 0])
                square([w + over, thk]);
    }
}


// ---------------------------
// Main J-shaped part with slide and rack
// ---------------------------

module Jshape() {
    // End shape (curved outer shell)
    difference() {
        rotate([-90, 0, 0])
            rotate_extrude(angle = -180, $fn = circle_resolution)
                translate([outer_bar_thickness / 2 + pinion_radius + gear_module, 0, 0])
                    squircle(outer_bar_thickness / 2, 0);

        // Slot for the complementary slide
        rotate([0, 0, 180])
            linear_extrude(rack_length)
                slide_profile(
                    inner_bar_thickness + slide_clearance,
                    rack_width,
                    pinion_radius,
                    rack_overlap + slide_clearance,
                    true
                );
    }

    // Alignment cylinder
    translate([0, 0, pinion_radius + rack_width])
        rotate([90, 0, 0])
            cylinder(
                h = 1.5 * outer_bar_thickness,
                r = outer_bar_thickness / 4,
                $fn = circle_resolution
            );

    // Inner slide
    difference() {
        translate([0, 0, -rack_length])
            linear_extrude(rack_length)
                slide_profile(
                    inner_bar_thickness,
                    rack_width,
                    pinion_radius,
                    rack_overlap,
                    false
                );

        // Opening to insert the pinion
        rotate([90, 0, 0])
            translate([0, 0, -outer_bar_thickness / 2])
                linear_extrude(outer_bar_thickness)
                    circle(r = pinion_radius + gear_module, $fn = 2 * circle_resolution);
    }

    // Rack and pinion + pen passage shaping
    difference() {
        union() {
            // Rack-and-pinion assembly
            translate([-pinion_radius, inner_bar_thickness / 4, -rack_length / 2])
                rotate([0, 90, -90])
                    rack_and_pinion(
                        modul          = gear_module,
                        rack_length    = rack_length,
                        gear_teeth     = gear_teeth,
                        rack_height    = rack_width,
                        gear_bore      = gear_bore,
                        width          = gear_face_width,
                        pressure_angle = pressure_angle,
                        helix_angle    = helix_angle,
                        together_built = false,
                        optimized      = false
                    );
            // Support underneath the pinion
            translate([pinion_radius - 0.5, 0, -rack_length / 2])
                rotate([90, 0, 0])
                    cylinder(
                        h  = inner_bar_thickness,
                        r = pinion_radius-rack_overlap-slide_clearance,
                        $fn= circle_resolution
                    );
        }
        // Conical pen lead-in through the gear axis
        translate([pinion_radius - 0.5, inner_bar_thickness / 4, -rack_length / 2])
            rotate([90, 0, 0])
                cylinder(
                    h  = 1.4*inner_bar_thickness,
                    r1 = outer_bar_thickness,
                    r2 = 0
                );

        // Trim the gear thickness so it fits in the slide
        translate([-inner_bar_thickness,
                   inner_bar_thickness / 4 - gear_clearance,
                   -1.1 * rack_length])
            cube(50);
    }
}



// ---------------------------
// Final parts
// Intersection / difference with the cube is a trick to generate
// the pinion and the arm separately
// ---------------------------

// Gear part - comment to generate the J-shaped parts only
intersection() {
    Jshape();
    translate([-rack_length / 8, -rack_length / 2, -0.9 * rack_length])
        cube(0.8 * rack_length);
}

// sides parts - comment to generate the central gear only
difference() {
    Jshape();
    translate([-rack_length / 8, -rack_length / 2, -0.9 * rack_length])
        cube(0.8 * rack_length);
}

// Optional second J part for visualization
/*
z = -30;
translate([0, 0, z]) rotate([0, 180, 0]) Jshape();
*/
