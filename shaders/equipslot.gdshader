shader_type canvas_item;

// sampler2d input to load correct texture - name:  custom_texture
uniform sampler2D custom_texture;
uniform int cooldown_progress : hint_range(0, 100) = 100;
uniform vec4 active_color = vec4(0.2, 0.7, 0.2, 1.0);  // Border color
uniform vec4 cooldown_color = vec4(0.7, 0.2, 0.2, 1.0);  // Border color ON cooldown

void fragment() {
	    vec2 uv = UV;
		float border = 0.05;
		if (uv.x < border || uv.x > 1.0 - border || uv.y < border || uv.y > 1.0 - border) {
			vec4 border_color = (cooldown_progress >= 100) ? active_color : cooldown_color;

			// Spiral sweep when on cooldown
			if (cooldown_progress < 100) {
				vec2 center = vec2(0.5);
				vec2 delta = uv - center;
				float angle = atan(delta.y, delta.x);  // Range: -PI to PI
				if (angle < 0.0) angle += 6.2831;       // Normalize to [0, 2PI]

				// Map progress to sweep angle (0 to 2PI)
				float sweep_angle = float(cooldown_progress) / 100.0 * 6.2831;

				// Highlight when angle < sweep (sweep moves from bottom to top)
				if (angle < sweep_angle) {
					// Add a tinted overlay (darker)
					border_color.rgb *= 0.4;
				}
			}

			COLOR = border_color;
		}
		else
		{
			COLOR = texture(custom_texture, uv);  // Use input texture
		}
}