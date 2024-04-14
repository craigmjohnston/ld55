shader_type canvas_item;

uniform vec4 origin:source_color;
uniform vec4 new:source_color;
uniform vec4 origin2:source_color;
uniform vec4 new2:source_color;

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	vec3 rgb = vec3(current_pixel.rgb);
	
	if (rgb == vec3(origin.rgb))
		COLOR = new;
	else if (rgb == vec3(origin2.rgb))
		COLOR = new2;
	else
		COLOR = current_pixel;
}