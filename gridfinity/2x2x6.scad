include <../libraries/gridfinity-rebuilt-openscad/gridfinity-rebuilt-bins.scad>

enable_zsnap = true;
refined_holes = false;

gridx = 2;
gridy = 2;
gridz = 6;

{
  gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl = style_lip) {
    cube([1000, 1000, 1000], true);
  }
  gridfinityBase([gridx, gridy], hole_options = hole_options, only_corners = only_corners, thumbscrew = enable_thumbscrew);
}
