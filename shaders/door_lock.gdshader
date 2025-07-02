shader_type canvas_item;
uniform bool active = false;
uniform vec3 lock_color : source_color = vec3(1.0,0.0,0.0);
void fragment() {
	if (active)
		COLOR = vec4(0.0,1.0,0.0,COLOR.a*0.8);
	else
		COLOR = vec4(lock_color,COLOR.a*0.8);
}
