use <../libraries/patterns/square.scad>

module dispenser(can_height = 109, can_width = 75, depth = 410) {
  cube_square([100, depth, 10], density = 6, border = 2);
}

dispenser();
