shaft_radius_base=  3.0;
shaft_radius=  2.75;
shaft_length= 11;
flat_depht= 1.0;
flat_length= 9.5;

pulley_radius= 14;
pulley_length= 18;
pulley_bump_height= 2.0;
pulley_bump_length= 2.0;

$fn=60;

module shaft(){
    union(){
        //base of the shaft
        translate(v = [0,0, flat_length]) 
            cylinder(h = shaft_length-flat_length, r = shaft_radius_base);
        //tip of the shaft
        difference() {
            cylinder(h = shaft_length, r = shaft_radius);
            translate(v = [shaft_radius-flat_depht,-shaft_radius,0]) 
                cube([2*shaft_radius, 2*shaft_radius, flat_length]);
        }
    }
}

module pulley(){
    cylinder(h = pulley_length, r = pulley_radius);
    cylinder(h = pulley_bump_length, r = pulley_radius+pulley_bump_height);
    translate(v = [0,0,pulley_length-pulley_bump_length])
        cylinder(h = pulley_bump_length, r = pulley_radius+pulley_bump_height);
}

difference() {
pulley();
translate(v = [0,0,shaft_length]) 
    rotate(a = 180, v = [1,0,0]) 
        shaft();
}