use <../libraries/patterns/square.scad>

module can_inversion(diameter = 75, angle = 90, width = 2, height = 4) {
  rotate_extrude(angle = angle, convexity = 2)
    translate([diameter, 0, 0])
      square([width, height]);

}

module dispenser(can_height = 109, can_width = 75, depth = 410, angle = 5) {
  total_height = sin(angle) * depth * 2 + can_width;
  cube_square([total_height, depth, 10], density = 6, border = 2);
  //translate([0, 0, can_height + 2 * 10])
  //  cube_square([100, depth, 10], density = 6, border = 2);

  rotate([0, 0, -angle])
    cube([2, depth, 20]);

  height = sin(angle) * (depth - can_width);

  translate([height * 2 + can_width, 0, 0])
    rotate([0, 0, angle])
      cube([2, depth - can_width, 20]);

  translate([can_width + 2, 0, 0])
    rotate([0, 0, 180])
      can_inversion(can_width, angle = 60, height = 20);

  translate([0, depth - can_width, 0])
    rotate([0, 0, 90])
      can_inversion(can_width, height = 20);

}


//can_inversion(diameter = can_width);
dispenser();
