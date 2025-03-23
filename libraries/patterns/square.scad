module cube_square(dimensions = [0, 0, 0], density = 40, border = 2) {
  difference() {
    union() {
      square([dimensions.x, border]);
      translate([0, dimensions.y - border])
        square([dimensions.x, border]);
      square([border, dimensions.y]);
      translate([dimensions.x - border, 0])
        square([border, dimensions.y]);

      length = sqrt(dimensions.x * dimensions.x + (dimensions.x + border) * (dimensions.x + border));
      for(i = [0:density:dimensions.y * 1.5]) {
        translate([0, i - dimensions.x])
          rotate([0, 0, 45])
            square([length, border]);
      }
      for(i = [0:density:dimensions.y * 1.5]) {
        translate([0, i])
          rotate([0, 0, -45])
            square([length, border]);
      }
    }
    #translate([-500, -1000])
      square([1000, 1000]);
    #translate([-1000, -500])
      square([1000, 1000]);
    #translate([dimensions.x, -500])
      square([1000, 1000]);
    #translate([-500, dimensions.y])
      square([1000, 1000]);

  }

}

cube_square([100, 200, 300]);
