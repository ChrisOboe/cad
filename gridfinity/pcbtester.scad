include <../libraries/gridfinity-rebuilt-openscad/gridfinity-rebuilt-bins.scad>

enable_zsnap = true;
refined_holes = false;

gridx = 4;
gridy = 4;
gridz = 2;

{
  gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl = style_lip) {
    cut(x = 10, y = 10, w = 10, h = 10);
    cut(0, 2, 2, 1, 5, 0);
    cut(1, 0, 1, 3, 5);
    cut(1, 0, 2, 1, 5);
    cut(0, 0, 1, 2);
    cut(2, 1, 1, 2);
    cylinder(r = 5, h = 1000, center = true);
  }
  gridfinityBase([gridx, gridy], hole_options = hole_options, only_corners = only_corners, thumbscrew = enable_thumbscrew);
}
