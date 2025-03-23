use <../libraries/patterns/square.scad>



module dispenser(can_height = 109, can_width = 75, depth = 410) {
  cube_square([100, depth, 10], density = 6, border = 2);
  //translate([0, 0, can_height + 2 * 10])
  //  cube_square([100, depth, 10], density = 6, border = 2);

  #rotate([0, 0, -5])
    cube([2, depth, 20]);

  height = sin(5) * (depth - can_width);

  #translate([height + can_width, 0, 0])
    rotate([0, 0, 0])
      cube([2, depth, 20]);

}

dispenser();
