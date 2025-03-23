use <../libraries/patterns/square.scad>

module can_inversion(diameter = 75, angle = 90, width = 2, height = 4) {
  //difference() {
  //  cylinder(h = height, d = diameter + 2 * width);
  //  translate([0, 0, -1])
  //    cylinder(h = height + 2, d = diameter);
  //}

  rotate_extrude(angle = angle, convexity = 2)
    translate([10, 0, 0])
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

  can_inversion(can_width);

}


can_inversion(can_width);
//dispenser();
