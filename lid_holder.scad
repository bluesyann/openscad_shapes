// Customizable lid holder for 3D printing.
// Set `part` to "support" or "cap" to select the part to render.

// Which part to render: "support" or "cap".
part = "support";

// Holder length and tip height, in millimeters.
holder_length = 50;
tip_height = 35;

// Holder radius, in millimeters.
holder_radius = 7;

// Support and screw hole radii, in millimeters.
support_hole_radius = 4;
screw_hole_radius = 2.5;

assert(part == "support" || part == "cap", "part must be \"support\" or \"cap\"");
assert(holder_length > tip_height, "holder_length must be greater than tip_height");
assert(support_hole_radius > screw_hole_radius, "support_hole_radius must be greater than screw_hole_radius");

tilt_angle = acos(tip_height / holder_length);
base_length = sqrt(holder_length^2 - tip_height^2);

$fn = 80;

module holder_body(){
    // Tilt the cylinder to reach the desired tip height
    rotate(a = tilt_angle, v = [1, 0, 0])
        union() {
            // Main cylinder with rounded edges
            cylinder(h = holder_length, r = holder_radius);
            sphere(r = holder_radius);
            translate(v = [0, 0, holder_length]) sphere(r = holder_radius);
        }
}

module support(){
    difference() {
        union() {
            difference() {
                holder_body();
                // Hole for the support
                translate(v = [0, -base_length/2, 0])
                    cylinder(h = tip_height + holder_radius, r = support_hole_radius);
            }
            // Merge with the support
            translate(v = [0, -base_length/2, 0])
                difference() {
                    // Support base
                    cylinder(h = tip_height/2, r = holder_radius);
                    // Screw hole
                    cylinder(h = tip_height/2, r = screw_hole_radius);
                }
        }

        // Remove the z<0 region
        translate(v = [-base_length, -base_length, -2*base_length])
            cube(size = 2 * base_length);
    }
}

module cap(){
    intersection() {
        translate(v = [0, -base_length/2, tip_height*.75])
            cylinder(h = tip_height + holder_radius, r = support_hole_radius);
        holder_body();
    }
}

if (part == "support") {
    support();
} else {
    cap();
}