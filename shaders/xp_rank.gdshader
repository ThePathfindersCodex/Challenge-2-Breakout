shader_type canvas_item;

// UNIFORMS
uniform int current_xp = 0;
uniform int xp_for_rank_1 = 100;
uniform int xp_for_rank_2 = 200;
uniform int xp_for_rank_3 = 400;
uniform int xp_for_rank_4 = 800;

// Colors for filled and unfilled areas
uniform vec4 fill_color : source_color = vec4(0.2, 0.8, 0.2, 1.0);
uniform vec4 empty_color : source_color = vec4(0.1, 0.1, 0.5, 1.0);

void fragment() {
    float fill = 0.0;

    // Determine current level and progress within that level
    int xp0 = 0;
    int xp1 = xp_for_rank_1;
    int xp2 = xp_for_rank_2;
    int xp3 = xp_for_rank_3;
    int xp4 = xp_for_rank_4;
    int range_start = 0;
    int range_end = xp1;
    if (current_xp < xp1) {
        range_start = xp0;
        range_end = xp1;
    } else if (current_xp < xp2) {
        range_start = xp1;
        range_end = xp2;
    } else if (current_xp < xp3) {
        range_start = xp2;
        range_end = xp3;
    } else if (current_xp < xp4) {
        range_start = xp3;
        range_end = xp4;
    } else {
        fill = 1.0;
    }

    // Calculate fill fraction within the current range
    if (fill < 1.0) {
        float range_size = float(range_end - range_start);
        float progress_in_range = float(current_xp - range_start);
        fill = clamp(progress_in_range / range_size, 0.0, 1.0);
    }

    // Fill horizontally from left to right
    if (UV.x <= fill) {
        COLOR = fill_color;
    } else {
        COLOR = empty_color;
    }
}
