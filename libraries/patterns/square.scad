module cube_square(dimensions = [0, 0, 0], density = 40, border = 2) {
  square([dimensions.x, border]);
  translate([0, dimensions.y - border])
    square([dimensions.x, border]);
  square([border, dimensions.y]);
  translate([dimensions.x - border, 0])
    square([border, dimensions.y]);

  length = sqrt((pow(dimensions.x,2)+pow(dimensions.y,2)))
  for(i = [0:density:dimensions.y]) {
    translate([0, i])
      rotate([0, 0, 45])
        square([dimensions.x, 10]);
  }
}

cube_square([100, 200, 300]);
