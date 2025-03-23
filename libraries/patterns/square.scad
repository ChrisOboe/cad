module square(dimensions = [0, 0, 0], density = 10, border = 2) {
  cube([dimensions.x, border, dimensions.z]);

}

square(100, 200, 300);
