// Adjustable Tip for Joint Box Machine
// Purpose: Sets the teeth stepping on a joint box machine.
// Author: [Your Name]
// License: [Specify, e.g., MIT, GPL, etc.]

include <functions.scad>

// --- User-configurable parameters ---
length = 30;           // Total length of the bump
width = 11;            // Width of the main body
thickness = 8;        // Thickness of the main body
tip_width = 6.2;      // Width of the tip (tooth stepping feature)
tip_length = 4;       // Length of the tip
rscrew = 1.5;          // Radius of the screw holes
lateral_clearance = 6; // Clearance for lateral movement
$fn = 60;              // Resolution for rounded shapes

// --- Modules ---

// Creates a screw hole with lateral clearance
module screw_hole() {
    linear_extrude(height = thickness)
        union() {
            translate(v = [-lateral_clearance, 0, 0])
                rotate(180)
                    squircle(radius = rscrew, foot = lateral_clearance/2, segments = $fn);
            squircle(radius = rscrew, foot = lateral_clearance/2, segments = $fn);
        }
}

// Main body, including the tip for teeth stepping
module body() {
    union() {
        // Main rectangular body
        translate(v = [-width, -tip_width/2, 0])
            cube(size = [width, length, thickness]);

        // tip for teeth stepping
        translate(v = [tip_length - tip_width/2, 0, 0])
            linear_extrude(height = thickness)
                squircle(tip_width/2, tip_length, $fn);
    }
}

// --- Main assembly ---
difference() {
    body();

    // Screw holes (rotated 90 degrees to match the body orientation)
    translate(v = [-width/2, 6*length/8, 0])
        rotate(90)
            screw_hole();

    translate(v = [-width/2, 2*length/8, 0])
        rotate(90)
            screw_hole();
}