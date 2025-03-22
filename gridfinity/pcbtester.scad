include <../libraries/gridfinity-rebuilt-openscad/gridfinity-rebuilt-bins.scad>

enable_zsnap = true;
refined_holes = false;

gridx = 4;
gridy = 4;
gridz = 2;

{
  gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl = style_lip) {
    if (divx > 0 && divy > 0) {
      cutEqual(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop, place_tab = place_tab);
    } else if (cdivx > 0 && cdivy > 0) {
    //cutCylinders(n_divx = cdivx, n_divy = cdivy, cylinder_diameter = cd, cylinder_height = ch, coutout_depth = c_depth, orientation = c_orientation, chamfer = c_chamfer);
    }
  }
  gridfinityBase([gridx, gridy], hole_options = hole_options, only_corners = only_corners, thumbscrew = enable_thumbscrew);
}
