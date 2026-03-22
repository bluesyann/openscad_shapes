/*
 * 3D-Printable Bracket System
 *
 * Features:
 *   - Modular bracket with rounded corners
 *   - Supports for inserts and screws
 *   - Adjustable dimensions via parameters
 *
 * Usage:
 *   - Adjust parameters at the top to fit your needs
 *   - Use `edge()` for straight sections, `corner()` for corners
 */

include <BOSL2/std.scad>
include <functions.scad>

// ===== USER PARAMETERS =====
$fn = 32;
clearance = 0.2;
bracket_height = 30;
bracket_thickness = 8;
ratio = 2; // Ratio between bracket length and thickness
panel_thickness = 2.9 + clearance;
hole_diameter = 2;

// Corner geometry
corner_tip_length = 5;
screw_diameter = 3;
screw_head_diameter = 5.6;
screw_head_thickness = 2;

// Insert geometry
insert_outer_radius = 4.4 / 2;
insert_hole_height = 12;

// Derived values
bracket_length = ratio * bracket_thickness;
radius = (bracket_thickness - panel_thickness) / 2;
half_thck = bracket_thickness / 2;

// ===== MODULES =====

module half_bracket() {
    difference() {
        // Main arm
        translate(v = [-half_thck, -half_thck, 0])
            rounded_rect(
                l = bracket_length,
                w = bracket_thickness,
                r = radius
            );
        // Panel rail
        translate(v = [half_thck, -panel_thickness/2, 0])
            square(size = [bracket_length, panel_thickness]);
    }
    // Rounded inner corner
    translate(v = [half_thck, half_thck, 0])
        difference() {
            square(size = radius);
            translate(v = [radius, radius, 0])
                circle(r = radius, $fn = 30);
        }
}

module bracket_section() {
    union() {
        half_bracket();
        mirror(v = [-1, 1, 0]) half_bracket();
    }
}

module half_edge() {
    difference() {
        union() {
            linear_extrude(height = bracket_height/2) bracket_section();
            linear_extrude(height = insert_hole_height)
                polygon(points = [
                    [half_thck, half_thck],
                    [bracket_length - half_thck - radius, half_thck],
                    [half_thck, bracket_length - half_thck - radius]
                ]);
        };
        // Hole for the insert
        translate(v = [half_thck, half_thck, 0])
            cylinder(h = insert_hole_height, r = insert_outer_radius, $fn = 30);
    }
}

module edge() {
    difference() {
        union() {
            half_edge();
            mirror(v = [0, 0, 1])
                translate(v = [0, 0, -bracket_height])
                    half_edge();
        }
        // Lightening hole
        cylinder(h = bracket_height, r = hole_diameter);
    }
}

module corner() {
    corner_thck = (bracket_thickness + panel_thickness) / 2;
    difference() {
        convex_offset_extrude(top = os_circle(r = radius), height = corner_thck, steps = 10)
            hull() bracket_section();
        // Space for top/bottom panels
        translate(v = [-panel_thickness/2, -panel_thickness/2, 0])
            cube(size = [bracket_length, bracket_length, panel_thickness]);
        // Hole for the screw
        translate(v = [half_thck, half_thck, 0])
            cylinder(h = corner_thck, r = screw_diameter/2 + clearance);
        // Hole for the screw head
        translate(v = [half_thck, half_thck, corner_thck - screw_head_thickness])
            cylinder(
                h = screw_head_thickness,
                r1 = screw_diameter/2 + clearance,
                r2 = screw_head_diameter/2 + clearance,
                $fn = 30
            );
    }
    // Tip for corner alignment
    down(corner_tip_length)
        cylinder(h = corner_thck + corner_tip_length, r = hole_diameter - clearance);
}

// ===== MAIN =====
up(1.1 * bracket_height) corner();
edge();
