shader_type canvas_item;

// UNIFORMS
uniform int current_xp = 0;
uniform int xp_for_rank_1 = 2;
uniform int xp_for_rank_2 = 4;
uniform int xp_for_rank_3 = 10;
uniform int xp_for_rank_4 = 20;

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
    int range_end = 1;
    if (current_xp < xp_for_rank_1) {
        range_start = 0;
        range_end = xp_for_rank_1;
    } else if (current_xp < xp_for_rank_2) {
        range_start = xp_for_rank_1;
        range_end = xp_for_rank_2;
    } else if (current_xp < xp_for_rank_3) {
        range_start = xp_for_rank_2;
        range_end = xp_for_rank_3;
    } else if (current_xp < xp_for_rank_4) {
        range_start = xp_for_rank_3;
        range_end = xp_for_rank_4;
    } else {
        // Max rank reached
        fill = 1.0;
    }

    // Calculate fill fraction within the current range
    if (fill < 1.0) {
        float progress  = float(current_xp - range_start);
        float range = float(range_end - range_start);
        fill = clamp(progress  / range, 0.0, 1.0);
    }

    // Fill horizontally from left to right
    COLOR = (UV.x <= fill) ? fill_color : empty_color;
}
