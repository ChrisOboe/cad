// Author: https://makerworld.com/en/@TooManyThings
// Link: https://makerworld.com/en/models/704997
// Copyright (c) 2024-2025. All rights reserved.

module baseplate(width, depth) {
  // Enter measured size in mm, or, number of Gridfinity units x 42.
  Width = 358;

  // Enter measured size in mm, or, number of Gridfinity units x 42.
  Depth = 421;

  // Suggest 2mm where measurements don't already allow for clearance.
  Clearance = 0;

  Build_Plate_Size = 236; //[180: Small (A1 Mini), 236: Standard (X1/P1/A1), 350: Large (350mm)]

  // Include a half-width grid in the margin(s) if there is sufficient space.
  Half_Sized_Filler = false;

  // When disabled, a normal butt-together baseplate will be generated.
  Generate_Locking_Tabs = true;

  /* [Advanced] */

  // In mm. Use with caution as this will increase warping.
  Solid_Base_Thickness = 0;

  // Offset grid right or left in mm.
  Offset_Horizontal = 0;

  // Offset grid back or forward in mm.
  Offset_Vertical = 0;

  // Amount of extra rounding to apply to the corners. This value is limited based on the size of the margins.
  Extra_Corner_Rounding = 0;

  // Mirrors the baseplate left-to-right.
  Mirror = false;

  // Standard Gridfinity is 42 mm
  Base_Unit_Dimension = 42;

  // Useful for editing model before printing
  Show_Assembled = false;

  /* [Hidden] */

  // Calculate unit counts, margins and whether we have half strips.
  adjusted_width = Width - Clearance;
  adjusted_depth = Depth - Clearance;

  whole_units_wide = floor(adjusted_width / Base_Unit_Dimension);
  whole_units_deep = floor(adjusted_depth / Base_Unit_Dimension);

  have_vertical_half_strip = Half_Sized_Filler && (adjusted_width - whole_units_wide * Base_Unit_Dimension) >= Base_Unit_Dimension / 2;
  have_horizontal_half_strip = Half_Sized_Filler && (adjusted_depth - whole_units_deep * Base_Unit_Dimension) >= Base_Unit_Dimension / 2;
  units_wide = whole_units_wide + (have_vertical_half_strip ? 0.5 : 0);
  units_deep = whole_units_deep + (have_horizontal_half_strip ? 0.5 : 0);

  half_margin_h = (adjusted_width - units_wide * Base_Unit_Dimension) / 2;
  half_margin_v = (adjusted_depth - units_deep * Base_Unit_Dimension) / 2;
  clamped_offset_h = min(max(Offset_Horizontal, -half_margin_h), half_margin_h);
  clamped_offset_v = min(max(Offset_Vertical, -half_margin_v), half_margin_v);
  margin_left = half_margin_h + clamped_offset_h;
  margin_back = half_margin_v + clamped_offset_v;
  margin_right = half_margin_h - clamped_offset_h;
  margin_front = half_margin_v - clamped_offset_v;

  base_corner_radius = 4;
  max_extra_corner_radius = max(min(margin_left, margin_right), min(margin_front, margin_back));
  outer_corner_radius = base_corner_radius + max(0, min(Extra_Corner_Rounding, max_extra_corner_radius));

  fn_min = 20;
  fn_max = 40;
  function lerp(x, x0, x1, y0, y1) =
    y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  $fn = max(min(lerp(units_wide * units_deep, 200, 400, fn_max, fn_min), fn_max), fn_min);

  max_unit_dimension = max(units_wide, whole_units_wide, whole_units_deep);

  // Need to increase as the cutting tool intentionally extends deeper than necessary.
  extra_base_thickness = Solid_Base_Thickness > 0 ? Solid_Base_Thickness + 0.5 : 0;

  max_recursion_depth = 12;
  part_spacing = Show_Assembled ? 0 : 10;

  cut_overshoot = 0.1;
  min_corner_radius = 1;
  non_grips_edge_clearance = 0.25;
  grips_min_margin_for_full_tab = 2.75;

  entry_point();
}

module entry_point() {
  translate([-Base_Unit_Dimension * units_wide / 2, -Base_Unit_Dimension * units_deep / 2, 0])
    if (Mirror)
      mirror([1, 0, 0])
        cut_baseplate();
    else
      cut_baseplate();
}

module cut_baseplate() {
  recurse_x();
}

module recurse_x(x_depth = 0, start_offset = 0) {
  end_offset = GetCutOffsetForward(start_offset, margin_left, margin_right, units_wide);

  if (end_offset < 0 || x_depth > max_recursion_depth) {
    // We've reached the right end or recursing too much, use remaining right part.
    recurse_y(x_depth, start_offset, units_wide);
  } else {
    // Left part.
    recurse_y(x_depth, start_offset, end_offset);

    // Recursively break up the right part.
    recurse_x(x_depth + 1, end_offset);
  }
}

module recurse_y(x_depth, x_start_offset, x_end_offset, y_depth = 0, y_start_offset = 0) {
  alt_cuts = x_depth % 2 != 0;
  standard_offset = GetCutOffsetForward(y_start_offset, margin_front, margin_back, units_deep);
  y_end_offset = alt_cuts && y_start_offset == 0 && standard_offset >= 0 ? GetAltStartOffset(margin_front, margin_back, units_deep) : standard_offset;

  if (y_end_offset < 0 || y_depth > max_recursion_depth) {
    // We've reached the end or recursing too much, use remaining back part.
    sub_baseplate(x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, units_deep);
  } else {
    // Front part.
    sub_baseplate(x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, y_end_offset);

    // Recursively break up rear part.
    recurse_y(x_depth, x_start_offset, x_end_offset, y_depth + 1, y_end_offset);
  }
}

module sub_baseplate(x_depth, y_depth, x_start_offset, x_end_offset, y_start_offset, y_end_offset) {
  translate([x_start_offset * Base_Unit_Dimension + part_spacing * x_depth, y_start_offset * Base_Unit_Dimension + part_spacing * y_depth, 0]) {
    w = x_end_offset - x_start_offset;
    d = y_end_offset - y_start_offset;

    is_left = x_start_offset == 0;
    is_right = x_end_offset == units_wide;
    is_front = y_start_offset == 0;
    is_back = y_end_offset == units_deep;

    r_fl = is_left && is_front ? outer_corner_radius : min_corner_radius;
    r_bl = is_left && is_back ? outer_corner_radius : min_corner_radius;
    r_br = is_right && is_back ? outer_corner_radius : min_corner_radius;
    r_fr = is_right && is_front ? outer_corner_radius : min_corner_radius;

    inner_margin = Generate_Locking_Tabs ? tab_extent_allowance : -non_grips_edge_clearance;
    m_l = is_left ? margin_left : inner_margin;
    m_b = is_back ? margin_back : inner_margin;
    m_r = is_right ? margin_right : inner_margin;
    m_f = is_front ? margin_front : inner_margin;

    difference() {
      uncut_baseplate(w, d, r_fl, r_bl, r_br, r_fr, m_l, m_b, m_r, m_f);
      if (Generate_Locking_Tabs) {
        front_tab_amount = (is_front && margin_front < grips_min_margin_for_full_tab) ? 0.5 : 1.0;
        back_tab_amount = (is_back && margin_back < grips_min_margin_for_full_tab) ? 0.5 : 1.0;
        left_tab_amount = is_left ? (margin_left < grips_min_margin_for_full_tab ? 0.5 : 1.0) : 0.0;
        right_tab_amount = is_right ? (margin_right < grips_min_margin_for_full_tab ? 0.5 : 1.0) : 0.0;

        if (!is_left)
          interlock_cutting_tool_left(front_tab_amount, back_tab_amount, d);
        if (!is_right)
          translate([w * Base_Unit_Dimension, 0, 0])
            interlock_cutting_tool_right(front_tab_amount, back_tab_amount, d);
        if (!is_front)
          interlock_cutting_tool_front(left_tab_amount, right_tab_amount, w);
        if (!is_back)
          translate([0, d * Base_Unit_Dimension, 0])
            interlock_cutting_tool_back(left_tab_amount, right_tab_amount, w);
      }
    }
  }
}

function GetCutOffsetForward(prev_offset, margin_start, margin_end, axis_unit_length) =
  let (prev_carry_over = prev_offset == 0 ? margin_start : left_tab_extent, remaining = prev_carry_over + (axis_unit_length - prev_offset) * Base_Unit_Dimension + margin_end, next_offset = prev_offset + floor((Build_Plate_Size - left_tab_extent - right_tab_extent - (prev_offset == 0 ? margin_start : 0)) / Base_Unit_Dimension), next_remaining_approx = (axis_unit_length - next_offset) * Base_Unit_Dimension + margin_end)

    remaining <= Build_Plate_Size ? -1 : (next_remaining_approx < Base_Unit_Dimension + grips_min_margin_for_full_tab + 0.001) ? next_offset - 1 : next_offset;

function GetAltEndOffset(margin_end, axis_unit_length) =
  let (space_for_full_units = Build_Plate_Size - margin_end - left_tab_extent - (axis_unit_length % 1) * Base_Unit_Dimension, full_units = floor(space_for_full_units / Base_Unit_Dimension), offset = floor(axis_unit_length) - full_units)
    offset;

function GetUnitsPerInnerSection(axis_unit_length) =
  let (space_for_full_units = Build_Plate_Size - left_tab_extent - right_tab_extent)
    floor(space_for_full_units / Base_Unit_Dimension);

function GetAltStartOffset(margin_start, margin_end, axis_unit_length) =
  let (end_offset = GetAltEndOffset(margin_end, axis_unit_length), units_per_inner_section = GetUnitsPerInnerSection(axis_unit_length), initial_offset = end_offset % units_per_inner_section, adjusted_offset = (initial_offset == 0) ? (Base_Unit_Dimension * units_per_inner_section + right_tab_extent + margin_start <= Build_Plate_Size) ? units_per_inner_section : 1 : initial_offset, final_offset = (adjusted_offset == 1 && margin_start < (grips_min_margin_for_full_tab + 0.001)) ? 2 : adjusted_offset)
    final_offset;

// New baseplate generation code.

// Predefine/precalculate values.
b_top_chamfer_height = 1.9;
b_center_height = 1.8;
b_bottom_chamfer_height = 0.8;
b_total_height = b_top_chamfer_height + b_center_height + b_bottom_chamfer_height + Solid_Base_Thickness;

b_cut_overshoot = 0.1;
b_tool_top_chamfer_height = b_top_chamfer_height + cut_overshoot;
b_tool_bottom_chamfer_height = b_bottom_chamfer_height + (Solid_Base_Thickness > 0 ? 0 : cut_overshoot);

b_corner_center_inset = 4;
b_corner_center_radius = 1.85;
b_tool_top_scale = (b_corner_center_radius + b_tool_top_chamfer_height) / b_corner_center_radius;
b_tool_bottom_scale = (b_corner_center_radius - b_tool_bottom_chamfer_height) / b_corner_center_radius;

module uncut_baseplate(units_x, units_y, r_fl, r_bl, r_br, r_fr, m_l, m_b, m_r, m_f) {

  main_width = Base_Unit_Dimension * units_x;
  main_depth = Base_Unit_Dimension * units_y;

  difference() {
    // Baseplate body.
    hull() {
      translate([r_fl - m_l, r_fl - m_f, 0])
        cylinder(r = r_fl, h = b_total_height, center = false);
      translate([r_bl - m_l, main_depth - r_bl + m_b, 0])
        cylinder(r = r_bl, h = b_total_height, center = false);
      translate([main_width - r_br + m_r, main_depth - r_br + m_b, 0])
        cylinder(r = r_br, h = b_total_height, center = false);
      translate([main_width - r_fr + m_r, r_fr - m_f, 0])
        cylinder(r = r_fr, h = b_total_height, center = false);
    }
    // Grid of cutting tools.
    for(y = [1:ceil(units_y)]) {
      for(x = [1:ceil(units_x)]) {
        translate([Base_Unit_Dimension * (x - 0.5), Base_Unit_Dimension * (y - 0.5), 0])
          gridfinity_cutting_tool(x > units_x, y > units_y);
      }
    }
  }
}

module gridfinity_cutting_tool(half_x, half_y) {
  base_offset = Base_Unit_Dimension / 2 - b_corner_center_inset;

  if (half_x || half_y) {
    adjust_x = half_x ? Base_Unit_Dimension / 4 : 0;
    adjust_y = half_y ? Base_Unit_Dimension / 4 : 0;
    translate([-adjust_x, -adjust_y, 0])
      gridfinity_cutting_tool_from_offsets(base_offset - adjust_x, base_offset - adjust_y);
  } else {
    gridfinity_cutting_tool_from_offsets(base_offset, base_offset);
  }
}

module gridfinity_cutting_tool_from_offsets(offset_x, offset_y) {

  top_z_offset = b_total_height - b_top_chamfer_height;
  middle_z_offset = b_total_height - b_top_chamfer_height - b_center_height;
  hull() {
    for(x = [-offset_x, offset_x])
      for(y = [-offset_y, offset_y])
        translate([x, y, top_z_offset])
          linear_extrude(height = b_tool_top_chamfer_height, scale = [b_tool_top_scale, b_tool_top_scale])
            circle(r = b_corner_center_radius);
  }

  hull() {
    for(x = [-offset_x, offset_x])
      for(y = [-offset_y, offset_y])
        translate([x, y, middle_z_offset]) {
          cylinder(r = b_corner_center_radius, h = b_center_height, center = false);
          mirror([0, 0, 1])
            linear_extrude(height = b_tool_bottom_chamfer_height, scale = [b_tool_bottom_scale, b_tool_bottom_scale])
              circle(r = b_corner_center_radius);
        }
  }
}

// Interlock cutting tools.
module interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units) {
  grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, grips_left_polyline_data(), 1);
}

module interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units) {
  grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, grips_right_polyline_data(), -1);
}

module interlock_cutting_tool_back(start_tab_amount, end_tab_amount, units) {
  rotate([0, 0, -90])
    interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units);
}

module interlock_cutting_tool_front(start_tab_amount, end_tab_amount, units) {
  rotate([0, 0, -90])
    interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units);
}

// GRIPS cutting tools.

// Tessellation functions
function tessellate_arc(start, end, bulge, segments = 8) =
  let (chord = end - start, chord_length = norm(chord), sagitta = abs(bulge) * chord_length / 2, radius = (chord_length / 2) ^ 2 / (2 * sagitta) + sagitta / 2, center_height = radius - sagitta, center_offset = [-chord.y, chord.x] * center_height / chord_length, center = (start + end) / 2 + (bulge >= 0 ? center_offset : -center_offset), start_angle = atan2(start.y - center.y, start.x - center.x), end_angle = atan2(end.y - center.y, end.x - center.x), angle_diff = (bulge >= 0) ? (end_angle < start_angle ? end_angle - start_angle + 360 : end_angle - start_angle) : (start_angle < end_angle ? start_angle - end_angle + 360 : start_angle - end_angle), num_segments = max(1, round(segments * (angle_diff / 360))), angle_step = angle_diff / num_segments)
    [
      for (i = [0:num_segments - 1])
        let (angle = start_angle + (bulge >= 0 ? 1 : -1) * i * angle_step)
          center + radius * [cos(angle), sin(angle)]
    ];

function tessellate_polyline(data) =
  let (polyline_curve_segments = 8, points = [
    for (i = [0:len(data) - 1])
      let (start = [data[i][0], data[i][1]], end = [data[(i + 1) % len(data)][0], data[(i + 1) % len(data)][1]], bulge = data[i][2])
        if (bulge == 0)
          [start]
        else
          tessellate_arc(start, end, bulge, polyline_curve_segments)
  ])
    [
      for (segment = points, point = segment)
        point
    ];

// Profile data (as provided before)
function reverse_polyline_data(data) =
  let (n = len(data), reversed = [
    for (i = [n - 1:-1:0])
      [data[i][0], data[i][1], i > 0 ? -data[i - 1][2] : 0] // Negate bulge from previous point
  ])
    reversed;

polyline_data_1 = [
  [0.2499999999999975, 38.523373536222223, 0.13165249758739542], 
  [0.17229473419497243, 38.813373536222223, 0], 
  [-0.77549874656872519, 40.454999999987507, -0.76732698797895982], 
  [-0.43399239561125647, 40.796506350944981, 0], 
  [0.44430391496627875, 40.289421739604791, 0.57735026918962284], 
  [1.0743039149299163, 40.653152409173259, 0]
];

polyline_data_2 = [
  [0.90430391492990991, 40.653152409173259, -0.57735026918962595], 
  [0.52930391496627871, 40.436646058248151, 0], 
  [-0.3489923956112484, 40.943730669588334, 0.76732698797896193], 
  [-0.92272306521208713, 40.369999999987513, 0], 
  [-0.28349364905389146, 39.262822173508923, -0.13165249758738012], 
  [-0.25000000000000011, 39.137822173508923, 0]
];

function get_min_polyline_x(data) =
  min([
    for (point = tessellate_polyline(data))
      point[0]
  ]);

function get_max_polyline_x(data) =
  max([
    for (point = tessellate_polyline(data))
      point[0]
  ]);

left_tab_extent = -min(0, min(get_min_polyline_x(polyline_data_1), get_min_polyline_x(polyline_data_2)));
right_tab_extent = max(0, max(get_max_polyline_x(polyline_data_1), get_max_polyline_x(polyline_data_2)));
reversed_polyline_data_2 = reverse_polyline_data(polyline_data_2);
tab_min_clearance = polyline_data_1[len(polyline_data_1) - 1].x - polyline_data_2[0].x;

tab_extent_allowance = max(left_tab_extent, right_tab_extent) + cut_overshoot + min_corner_radius;
grips_tool_extent_allowance = tab_extent_allowance + cut_overshoot;

// 2D point array helper functions.
function reverse_points(arr) =
  [
    for (i = [len(arr) - 1:-1:0])
      arr[i]
  ];
function y_mirror_points(points) =
  [
    for (point = reverse_points(points))
      [point.x, -point.y]
  ];
function y_translate_points(points, y_delta) =
  [
    for (point = points)
      [point.x, point.y + y_delta]
  ];

function lower_butt_profile(direction) =
  let (close_clearance = tab_min_clearance / 2, delta = non_grips_edge_clearance - close_clearance, start = [close_clearance * -direction, -grips_min_margin_for_full_tab], end = [start.x + delta * -direction, start.y - delta], )
    [end, start];

function upper_butt_profile(direction) =
  [
    [non_grips_edge_clearance * -direction, 0]
  ];

function tesselate_and_adjust_grips_profile(polyline_data) =
  y_translate_points(tessellate_polyline(polyline_data), -42);

function lower_half_profile(grips_base_profile) =
  grips_base_profile;

function upper_half_profile(grips_base_profile) =
  y_mirror_points(grips_base_profile);

function full_profile(grips_base_profile) =
  [
    each lower_half_profile(grips_base_profile), 
    each upper_half_profile(grips_base_profile)
  ];

function repeat_profile(profile, repetitions, start_offset) =
  repetitions <= 0 ? [] : let (repeated = [
    for (i = [0:repetitions - 1])
      [
        for (point = profile)
          [point.x, point.y + i * Base_Unit_Dimension + start_offset]
      ]
  ])
    [
      for (segment = repeated, point = segment)
        point
    ];

module grips_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
  grips_base_profile = tesselate_and_adjust_grips_profile(base_polyline);
  full_tab_profile = full_profile(grips_base_profile);
  start_profile = start_tab_amount == 0 ? upper_butt_profile(direction) : (start_tab_amount < 1 ? upper_half_profile(grips_base_profile) : full_tab_profile);
  end_profile = end_tab_amount == 0 ? lower_butt_profile(direction) : (end_tab_amount < 1 ? lower_half_profile(grips_base_profile) : full_tab_profile);
  translated_end_profile = y_translate_points(end_profile, Base_Unit_Dimension * units);

  repeated = repeat_profile(full_tab_profile, floor(units - 0.5), Base_Unit_Dimension);

  x_ext = grips_tool_extent_allowance * direction;
  down_ext = start_profile[0] + [0, -Base_Unit_Dimension];
  up_ext = translated_end_profile[len(translated_end_profile) - 1] + [0, Base_Unit_Dimension];

  start_ext = [x_ext, down_ext.y];
  end_ext = [x_ext, up_ext.y];

  polygon([
    start_ext, 
    down_ext, 
    each start_profile, 
    each repeated, 
    each translated_end_profile, 
    up_ext, 
    end_ext, 
    [end_ext.x, start_ext.y]
  ]);
}

cutting_tool_height = (b_total_height + cut_overshoot) * 2;

function grips_left_polyline_data() =
  reversed_polyline_data_2;

function grips_right_polyline_data() =
  polyline_data_1;

module grips_cutting_tool_common(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
  linear_extrude(height = cutting_tool_height, center = true)
    grips_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction);
}

// M3 screw interface cutting tools.
module m3_clearance_hole_cutter() {
  rotate([90, 0, -90]) {
    linear_extrude(height = b_corner_center_inset) {
      circle(r = m3_clearance_radius * 1.1547, $fn = 6);
    }
  }
}
