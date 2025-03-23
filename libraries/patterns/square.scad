module cube_square(dimensions = [0, 0, 0], density = 10, border = 2) {
  square([dimensions.x, border]);
  translate([0, dimensions.y - border])
    square([dimensions.x, border]);
  square([border, dimensions.y]);
  translate([dimensions.x - border, 0])
    square([border, dimensions.y]);

  for(i = [0:density:dimensions.y]) {
    square([10,10])
  }
}

cube_square([100, 200, 300]);
