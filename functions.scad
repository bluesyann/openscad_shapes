// -----------------------------------------------------
// Utility: squircle (circle + rectangle)
// -----------------------------------------------------

module squircle(radius, foot, segments) {
    union() {
        circle(r = radius, $fn = segments);
        translate([-(radius + foot) / 2, 0, 0])
            square([foot + radius, 2 * radius], center = true);
    }
}

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