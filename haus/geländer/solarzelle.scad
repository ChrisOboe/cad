include <../../libraries/BOSL2/std.scad>
include <../../libraries/BOSL2/screws.scad>

$fn = 200;
THICKNESS = 2;

module clamp() {
  difference() {
    union() {
      // cylinder(h=20,d=46.7);
      cyl(h = 20, d = 46.7, center = false, rounding = 4);
      // translate([0,0,10]) rotate([90,-90,0]) cube([20,65,8.7], true);
      translate([0, 0, 10])
        rotate([90, -90, 0])
          cuboid([20, 67, 18], rounding = 2);
      // translate([0,14,10]) rotate([90,-90,0]) cube([20,50,20], true);
      translate([0, 11, 10])
        rotate([90, -90, 0])
          cuboid([20, 15.5, 55], rounding = 2);
    }
    translate([-25, 31, 10])
      rotate([0, 90, 0])
        cylinder(h = 50, d = 5.4);

    translate([0, 0, -1])
      cylinder(h = 22, d = 42.7);
    translate([0, 0, 10])
      rotate([90, -90, 0])
        cube([22, 100, 1], true);


    translate([27.5, 0, 10])
      screw_hole("M4", length = 18, head = "socket", counterbore = 6, anchor = CENTER, orient = BACK);
    translate([-27.5, 0, 10])
      screw_hole("M4", length = 18, head = "socket", counterbore = 6, anchor = CENTER, orient = BACK);
    translate([27.5, -7.1, 10])
      nut_trap_inline(4, "M4", orient = FRONT, anchor = CENTER);
    translate([-27.5, -7.1, 10])
      nut_trap_inline(4, "M4", orient = FRONT, anchor = CENTER);
  }
}

module sensor() {
  difference() {
    cube([80, 24, 10], true);
    translate([-40 + 15, 0, -10])
      cylinder(d = 5, h = 25);
    translate([-40 + 48, 0, -10])
      cylinder(d = 5, h = 20);
  }
}

clamp();

// translate([10,50,10])rotate([90,0,0]) sensor();
