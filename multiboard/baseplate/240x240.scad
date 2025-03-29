include <../../libraries/multiboard-parametric/multiboard_parametric_extended.scad>

// Büro: 900x600
// 900 -> 4*9
// 600 -> 4*8

stack_size = 1;
x_cells = 9;
y_cells = 8;
type = "core"; // side or corner


multiboard();
