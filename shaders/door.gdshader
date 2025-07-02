shader_type canvas_item;

uniform int state : hint_range(0, 3) = 1;
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform float speed : hint_range(0.0, 10.0) = 0.5;
uniform float angle : hint_range(0.0, 360.0) = 0.0;
uniform int band_count : hint_range(1, 100) = 6;

uniform vec4 color1 : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Yellow
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Black

void fragment() {
	if (state==0)
	{
		COLOR=vec4(0.0);
	}
	if (state==1) {
	    // Rotate UV space for angled bands
	    float radians_angle = radians(angle);
	    float coord = UV.x * cos(radians_angle) - UV.y * sin(radians_angle);

	    // Animate shift along the bands
	    coord += TIME * speed;

	    // Calculate stepped band index
	    float band_index = floor(fract(coord) * float(band_count));

	    // Alternate between color1 and color2 based on band index
	    vec4 band_color = mod(band_index, 2.0) < 1.0 ? color1 : color2;

	    // Sample original texture
	    vec4 tex_color = texture(TEXTURE, UV);

	    // Blend stripe color with original texture
	    COLOR = mix(tex_color, band_color, strength * COLOR.a);
	}
	if (state==2) {
		//COLOR=vec4(0.0,0.0,0.0,1.0);
		COLOR = vec4(mix(vec3(1.0,0.0,0.0), COLOR.rgb, .75),COLOR.a);
	}
	if (state==3) {
		//COLOR=vec4(1.0);
		COLOR = vec4(mix(vec3(0.0,1.0,0.0), COLOR.rgb, .75),COLOR.a);
	}
}
