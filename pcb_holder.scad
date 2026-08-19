pcb_thickness=2;
pcb_z_shift=3;

post_height= 7;
post_radius= 5;
$fn=40;

// Insert geometry
insert_outer_radius = 4.4 / 2;

module corner_post() {
    difference() {
        cylinder(h = post_height, r = post_radius);
        translate(v = [0,0,pcb_z_shift])
            cube(size = [post_radius,post_radius,pcb_thickness]);
        cylinder(h = post_height, r = insert_outer_radius);
    }
}

module side_post(){
    difference() {
        cylinder(h = post_height, r = post_radius);
        translate(v = [0,-post_radius,pcb_z_shift])
            cube(size = [post_radius,2*post_radius,pcb_thickness]);
        cylinder(h = post_height, r = insert_outer_radius);
    }    
}

corner_post();
//side_post();
