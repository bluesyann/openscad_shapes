$fn=60;

top_outer_radius=3;
top_height=1.5;
bottom_outer_radius=1.85;
bottom_height=1.3;
inner_radius=1.5;


difference() {
    union() {
    cylinder(h = top_height, r = top_outer_radius, center=True);
    translate(v = [0,0,top_height])
        cylinder(h = bottom_height, r = bottom_outer_radius, center=True);
    };
    cylinder(h = top_height+bottom_height, r = inner_radius);
}