// lid_holder.scad
// Customizable lid holder for 3D printing
// Parameters:
//   length:      Total length of the holder (default: 60)
//   tip_height:  Height of the tip (adjust to lid thickness, default: 40)
//   R:           Radius of the holder (default: 10)
//   outer_radius: Radius of the support hole (default: 5)
//   inner_radius: Radius of the screw hole (default: 2.5)

// Lid holder length
length = 50;

// Height of the tip of the holder, to adjust to lid thickness
tip_height = 35;

// Radius of the holder
R = 7;

// Fixature geometry
outer_radius = 4;
inner_radius = 2.5; // The screw must fit in

angle = acos(tip_height / length);
base_length = sqrt(length^2 - tip_height^2);

$fn = 80;

module body(){            
    // Tilt the cylinder to reach the desired tip height
    rotate(a = angle, v = [1, 0, 0])
        union() {
            // Main cylinder with rounded edges
            cylinder(h = length, r = R);
            sphere(r = R);
            translate(v = [0, 0, length]) sphere(r = R);
        }
}

module support(){
    difference() {
        union() {
            difference() {
                body();
                // Hole for the support
                translate(v = [0, -base_length/2, 0])
                    cylinder(h = tip_height + R, r = outer_radius);
            }
            // Merge with the support
            translate(v = [0, -base_length/2, 0])
                difference() {
                    // Support base
                    cylinder(h = tip_height/2, r = R);
                    // Screw hole
                    cylinder(h = tip_height/2, r = inner_radius);
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
            cylinder(h = tip_height + R, r = outer_radius);
        body();
    }
}

//support();
cap();