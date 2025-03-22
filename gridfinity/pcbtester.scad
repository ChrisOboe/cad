include <../libraries/gridfinity-rebuilt-openscad/gridfinity-rebuilt-bins.scad>

enable_zsnap = true;
refined_holes = false;

gridx = 4;
gridy = 4;
gridz = 2;

{
  gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl = style_lip) {
    translate([-60, -70, 0])
      cylinder(d = 8, h = 1000, center = true);
    translate([60, -70, 0])
      cylinder(d = 8, h = 1000, center = true);
    translate([-60, 70, 0])
      cylinder(d = 8, h = 1000, center = true);
    translate([60, 70, 0])
      cylinder(d = 8, h = 1000, center = true);

    cut(1);

  }
  gridfinityBase([gridx, gridy], hole_options = hole_options, only_corners = only_corners, thumbscrew = enable_thumbscrew);
}
