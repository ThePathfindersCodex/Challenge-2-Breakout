shader_type canvas_item;

uniform int map[216];          // Linearized 2D map (cols * rows), contains room numbers
uniform int visited[216];      // Linearized 2D visited flags (1 = visited, 0 = unvisited)
uniform int rows = 18;
uniform int cols = 12;
uniform int currentLevel = 1;  // Room number we are currently in (to search for in map[])
uniform int padding = 2;       // Grid padding around current room (so visible grid is (padding*2+1)x(padding*2+1))

void fragment() {
    vec2 uv = UV;

	// --- draw map border
	if (UV.x < 0.01 || UV.x > 0.99 || UV.y < 0.01 || UV.y > 0.99) {
	    COLOR = vec4(0.5, 0.5, 0.8, 1.0); // White border (or choose any color)
	}
	else {
	    // --- First: Find index of currentLevel inside the map[] array ---
	    int center_index = -1;
	    for (int i = 0; i < cols * rows; i++) {
	        if (map[i] == currentLevel) {
	            center_index = i;
	            break;
	        }
	    }

	    // If not found, don't draw anything
	    if (center_index == -1) {
	        discard;
	    }

	    // Convert center index to map (x, y) coordinates
	    int center_y = center_index / cols;
	    int center_x = center_index % cols;

	    // --- Map UVs to grid cell coordinates ---
	    int grid_size = padding * 2 + 1;
	    float cell_size = 1.0 / float(grid_size);

	    int grid_x = int(floor(uv.x / cell_size));
	    int grid_y = int(floor(uv.y / cell_size));

	    // If UV outside grid bounds, discard
	    if (grid_x < 0 || grid_x >= grid_size || grid_y < 0 || grid_y >= grid_size) {
	        discard;
	    }

	    // Calculate target map coordinates in full map space
	    int target_x = center_x + (grid_x - padding);
	    int target_y = center_y + (grid_y - padding);

	    // Check bounds
	    bool in_bounds = target_x >= 0 && target_x < cols && target_y >= 0 && target_y < rows;
	    if (!in_bounds) {
	        discard;
	    }

	    // Calculate target index
	    int target_index = target_y * cols + target_x;

	    // Check if room was visited
	    bool is_visited = visited[target_index] != 0;
	    if (!is_visited) {
	        discard;
	    }

	    // --- Draw the cell: Light gray fill with dark gray border ---

	    float border = 0.1 * cell_size;
	    vec2 local_uv = fract(uv / cell_size);

		// Check if this cell is the current room
		bool is_current_room = (map[target_index] == currentLevel);

		// Set color
		if (is_current_room) {
		    COLOR = vec4(1.0, 1.0, 0.0, 1.0); // Yellow for current room
		} else if (local_uv.x < border || local_uv.x > 1.0 - border || local_uv.y < border || local_uv.y > 1.0 - border) {
		    COLOR = vec4(0.2, 0.2, 0.2, 1.0);  // Border color
		} else {
		    COLOR = vec4(0.6, 0.6, 0.6, 1.0);  // Fill color for visited rooms
		}
	}
}
