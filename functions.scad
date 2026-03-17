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
