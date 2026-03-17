// =====================================================
// Soldering Station Organizers
// - Desoldering pump holder
// - Solder spool holder (U-bracket + axle)
// =====================================================
include <functions.scad>
$fn = 30;

// -----------------------------------------------------
// Parameters – Solder spool axle + U-shaped holder
// -----------------------------------------------------

inner_shaft_radius   = 2.5;   // Small axle radius (fits 6 mm bore)
outer_shaft_radius   = 9;     // Large axle radius (fits 20 mm bore)
holder_thickness     = 4;     // Thickness of spool holder arms
arm_span             = 40 + holder_thickness; // Distance between outer faces of U arms
strut_thickness      = 3;     // Thickness of internal support struts
shaft_gap            = 1;     // Gap between shaft and holder
circle_segments      = 30;

// Panel shape parameters
panel_width          = 60;
panel_foot           = 10;


// -----------------------------------------------------
// Parameters – Desoldering pump holder
// -----------------------------------------------------

pump_holder_width    = 40;
pump_holder_length   = 60;
pump_holder_thick    = 4;
pump_tip_radius      = 4;
pump_body_radius     = 10;

// -----------------------------------------------------
// Solder spool axle (double-ended shaft + struts)
// -----------------------------------------------------

module half_spool_shaft() {
    translate([0, 0, -(arm_span+holder_thickness) / 2]) {
        // Central shaft
        cylinder(h = (arm_span+holder_thickness) / 2, r = inner_shaft_radius, $fn = 30);

        // Outer ring + radial struts
        translate([0, 0, holder_thickness + shaft_gap]) {
            cylinder(h = strut_thickness, r = outer_shaft_radius, $fn = 30);

            // Radial spokes
            for (angle = [0 : 36 : 360]) {
                translate([
                    (outer_shaft_radius - strut_thickness / 2) * cos(angle),
                    (outer_shaft_radius - strut_thickness / 2) * sin(angle),
                    0
                ])
                    cylinder(h = arm_span / 2 - shaft_gap,
                             r = strut_thickness / 2, $fn = 20);
            }
        }
    }
}

module spool_shaft() {
    union() {
        half_spool_shaft();
        mirror([0, 0, 1])
            half_spool_shaft();
    }
}


// -----------------------------------------------------
// Solder spool U‑shaped holder
// -----------------------------------------------------

module spool_holder() {
    union() {
        // Front panel
        translate([0, 0, arm_span]) {
            linear_extrude(height = holder_thickness) {
                difference() {
                    squircle(panel_width / 2, panel_foot, circle_segments);
                    rotate(160)
                        squircle(panel_width / 20, panel_width, circle_segments);
                }
            }
        }

        // Rear panel
        linear_extrude(height = holder_thickness) {
            difference() {
                squircle(panel_width / 2, panel_foot, circle_segments);
                rotate(160)
                    squircle(panel_width / 20, panel_width, circle_segments);
            }
        }

        // Side bridge between panels (U shape)
        translate([-(panel_width / 2 + panel_foot), 0, arm_span / 2])
            rotate([0, 90, 0])
                linear_extrude(height = holder_thickness)
                    square([arm_span, panel_width], center = true);
    }
}


// -----------------------------------------------------
// Desoldering pump holder
// -----------------------------------------------------

module desoldering_pump_holder() {
    union() {
        // Front ring + support
        translate([0, 0, pump_holder_length])
            linear_extrude(height = pump_holder_thick) {
                difference() {
                    union() {
                        circle(r = pump_holder_width / 2, $fn = 50);
                        translate([-pump_holder_width / 4, 0, 0])
                            square([pump_holder_width / 2, pump_holder_width], center = true);
                    }
                    circle(r = pump_tip_radius, $fn = 50);  // inner hole
                }
            }

        // Rear ring + support
        linear_extrude(height = pump_holder_thick) {
            difference() {
                union() {
                    circle(r = pump_holder_width / 2, $fn = 50);
                    translate([-pump_holder_width / 4, 0, 0])
                        square([pump_holder_width / 2, pump_holder_width], center = true);
                }
                circle(r = pump_body_radius, $fn = 50); // larger inner cutout
            }
        }

        // Base arm connecting rings
        translate([-pump_holder_width / 2, -pump_holder_width / 2, 0])
            rotate([0, -90, 0])
                linear_extrude(height = pump_holder_thick)
                    square([pump_holder_length + pump_holder_thick, pump_holder_width]);
    }
}


// -----------------------------------------------------
// Assembly – show all parts
// -----------------------------------------------------

//color("orange") translate(v = [0,100,0]) desoldering_pump_holder();
//color("green") spool_holder();
color("yellow") translate(v = [0,0,(arm_span+holder_thickness)/2]) spool_shaft();
