module square(dimensions = [0, 0, 0], density = 10, border = 2) {
  cube([dimensions.x, border, dimensions.z]);
  translate([0, dimensions.y - border, 0])
    cube([dimensions.x, border, dimensions.z]);
  cube([border, dimensions.y, dimensions.z]);
  translate([dimensions.x - border, 0, 0])
    cube([border, dimensions.y, dimensions.z]);
}

square([100, 200, 0]);
