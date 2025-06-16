shader_type canvas_item;

uniform int is_negative = 0;

vec4 make_foil(vec4 tex_color, vec2 uv) {
	float shine_width = 0.2;
	float shine_speed = 1.0;
	vec4 shine_color = vec4(1.0, 1.0, 1.0, 1.0);
	float shine_strength = 0.4;
	vec2 shine_direction = vec2(1.1, -0.9);

	vec2 dir = normalize(shine_direction);
    float shine_coord = dot(uv, dir);
    float travel = shine_speed * TIME;
    float shine_pos = mod(shine_coord - travel, 1.0 + shine_width * 2.0);

    shine_pos -= shine_width;
    float shine = smoothstep(shine_width, 0.0, abs(shine_pos));
	float base_shine = 0.1;
	if (is_negative == 1) {
		base_shine = -base_shine;
	}
    vec3 final_color = tex_color.rgb + max(vec3(base_shine), shine * shine_strength * shine_color.rgb);
	return vec4(final_color, tex_color.a);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = make_foil(tex_color, UV);
}