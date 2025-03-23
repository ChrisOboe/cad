use <../libraries/patterns/square.scad>

module can_inversion(diameter = 75, angle = 90, width = 2, height = 4) {
  rotate_extrude(angle = angle, convexity = 2)
    translate([diameter, 0, 0])
      square([width, height]);

}

module dispenser(can_height = 109, can_width = 75, depth = 410, angle = 5, can_hold = 30) {
  line_width = 4;
  total_height = sin(angle) * depth * 2 + can_width;
  cube_square([total_height, depth, 10], density = 12, border = line_width);

  rotate([0, 0, -angle])
    cube([line_width, depth - can_width, can_hold]);

  height = sin(angle) * (depth - can_width);

  translate([height * 2 + can_width, 0, 0])
    rotate([0, 0, angle])
      cube([line_width, depth - can_width, can_hold]);

  translate([can_width + line_width, 0, 0])
    rotate([0, 0, 180])
      can_inversion(can_width, angle = 60, height = can_hold, width = line_width);

  translate([height + can_width + line_width, depth - can_width - line_width, 0])
    rotate([0, 0, 90])
      can_inversion(can_width, height = can_hold, width = line_width);

  translate([total_height - (total_height - can_height - 2), depth - line_width, 0])
    cube([total_height - can_height + 2, line_width, can_hold]);

}


//can_inversion(diameter = can_width);
dispenser();
