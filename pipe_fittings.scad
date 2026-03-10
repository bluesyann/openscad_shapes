// Parametric tube fittings library
// For plant watering system pipe connectors
$fn = 60; // Circle resolution

// ---------------------------
// TIP / END FITTING module
// Basic building block for all fittings
// ---------------------------
/*
Description: Creates a single tube end fitting with internal shoulder stop and external gripping ridges.
The tip points upward along Z-axis.

Arguments:
| e | wall thickness |
| r | outer radius |
| d | shoulder width |
| b | ridge width |
| l | total length |

Returns: Rotated extrusion forming complete tube end
*/
module tip(e, r, d, b, l) {
    r = r - e; // conversion to inner radius
    
    rotate_extrude(angle = 360)
    union() {
        translate([r, 0, 0]) 
            square(size = [e, 2 * l / 3], center = false); // tube
        
        translate([r + e, 0, 0]) 
            square(size = [d, e], center = false); // shoulder
        
        translate([r, 2 * l / 3, 0]) 
            polygon(points = [[0, 0], [b + e, 0], [0, l / 3]]); // ridge triangles
    }
}

// ---------------------------
// MULTI-WAY CONNECTOR
// ---------------------------
/*
Description: Creates a spherical multi-way pipe connector with N evenly spaced ports.
First port always faces up (+Z), others rotate around at given angle.

Arguments:
| n     | number of ports (≥1) |
| angle | angle between ports (degrees) |
| e     | wall thickness |
| r     | outer radius |
| d     | shoulder width |
| b     | ridge width |
| l     | port length |

Example: connector(3, 90, e1, r1, d1, b1, l1);  // 3-way 90° connector
*/
module connector(n, angle, e, r, d, b, l) {
    RsOut = sqrt(pow(r + e, 2) + pow(r + e + d, 2)); // outer sphere radius
    RsIn = sqrt(pow(r, 2) + pow(r + d, 2)); // inner sphere radius
    
    union() {
        // First port straight up
        translate([0, 0, r + d]) tip(e, r, d, b, l);
        
        // Additional angled ports
        for (i = [0 : n - 1])
            rotate([i * angle, 0, 0]) 
                translate([0, 0, r + d]) tip(e, r, d, b, l);

        // Spherical body with tube channels
        difference() {
            sphere(r = RsOut);
            sphere(r = RsIn);
            
            for (i = [0 : n - 1])
                rotate([i * angle, 0, 0]) 
                    cylinder(h = l, r = r);
        }
    }
}

// ---------------------------
// CONICAL REDUCER
// ---------------------------
/*
Description: Creates a conical reducer transitioning between two different tube sizes.
Larger end (side 1) faces up (+Z), smaller end (side 2) faces down (-Z).

Arguments:
| e1,e2 | wall thickness (side 1, side 2) |
| r1,r2 | outer radius (side 1, side 2) |
| d1,d2 | shoulder width (side 1, side 2) |
| b1,b2 | ridge width (side 1, side 2) |
| l1,l2 | length (side 1, side 2) |
| lt    | transition length |

Example: reducer(e1, r1, d1, b1, l1, e2, r2, d2, b2, l2, lt);
*/
module reducer(e1, r1, d1, b1, l1, e2, r2, d2, b2, l2, lt) {
    union() {
        // Large end (up)
        translate([0, 0, lt / 2]) tip(e1, r1, d1, b1, l1);
        
        // Small end (down, rotated)
        translate([0, 0, -lt / 2]) 
            rotate([0, 180, 0]) tip(e2, r2, d2, b2, l2);
        
        // Conical transition
        translate([0, 0, -lt / 2]) 
            rotate_extrude(angle = 360)
                polygon(points = [[r2 + d2 - e2, 0], [r2 + d2, 0], [r1 + d1, lt], [r1 - e1 + d1, lt]]);
    }
}

// ---------------------------
// EXAMPLES 
// set for the pipes I'm using on my plant watering system :-)
// ---------------------------

// Primary Tip geometry
r1 = 4.25;  // outer radius (mm)
e1 = 1.25;  // wall thickness (mm) 
l1 = 20;    // fitting length (mm)
b1 = 0.7;   // ridge width (mm)
d1 = 2 * b1; // shoulder width (mm)

// Secondary tip geometry (for reducer)
r2 = 2.2;   // outer radius (mm)
e2 = 0.8;   // wall thickness (mm)
l2 = 14;    // fitting length (mm)
b2 = 0.7;   // ridge width (mm)
d2 = 2 * b2; // shoulder width (mm)

lt = 5;     // transition length for reducer (mm)

connector(3, 90, e1, r1, d1, b1, l1);                    // 3-way 90° tee
translate([20, 0, 0])  reducer(e1, r1, d1, b1, l1, e2, r2, d2, b2, l2, lt);  // Size reducer
translate([40, 0, 0])  connector(3, 120, e2, r2, d2, b2, l2);               // 3-way Y-split
translate([40, 40, 0]) connector(2, 120, e2, r2, d2, b2, l2);               // 2-way 120° elbow
translate([20, 40, 0]) connector(2, 90, e2, r2, d2, b2, l2);                // 2-way 90° elbow
translate([0, 40, 0])  connector(2, 90, e2, r2, d2, 2*b2, 2*l2);            // Longer elbow
translate([0, 80, 0])  connector(1, 90, e1, r1, d1, b1, l1);                // Single straight tip
translate([20, 80, 0]) reducer(2*e1, r1, d1, b1, l1, e2, r2, d2, b2, l2, 2*lt); // Thicker wall reducer
