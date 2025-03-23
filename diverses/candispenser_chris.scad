use <../libraries/patterns/square.scad>



module dispenser(can_height = 109, can_width = 75, depth = 410, angle = 5) {
  total_height = sin(angle) * depth;
  cube_square([total_height, depth, 10], density = 6, border = 2);
  //translate([0, 0, can_height + 2 * 10])
  //  cube_square([100, depth, 10], density = 6, border = 2);

  #rotate([0, 0, -angle])
    cube([2, depth, 20]);

  height = sin(angle) * (depth - can_width);


  #translate([height * 2 + can_width, 0, 0])
    rotate([0, 0, angle])
      cube([2, depth - can_width, 20]);

}

dispenser();
