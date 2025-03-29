include <../../libraries/multiboard-parametric/multiboard_parametric_extended.scad>

// Büro: 900x600
// 900 -> 4*9
// 600 -> 3*8

// 6 core
// 2 side 8x9
// 3 side 9x8
// 1 corner
// quad offset snap ds a 6
// quad offset snap ds b 6
// dual offset snap ds a 10
// duall snap ds b       10
// signle offset snap a  4
// signle offset snap b  4

stack_size = 6;
x_cells = 9;
y_cells = 8;
type = "core"; // side or corner


multiboard();
