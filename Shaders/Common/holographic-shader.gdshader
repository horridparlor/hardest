shader_type canvas_item;

uniform int is_negative = 0;

vec4 make_holographic(vec4 tex_color, vec2 uv) {
    float diamond_density = 8.0;
    float diamond_fill = 1.0;
    float shine_speed = 0.2;
    float shine_strength = 0.4;
    vec4 shine_color = vec4(1.0);
	vec2 shine_direction = vec2(0.7, 1.3);
	float base_shine = 0.1;
	if (is_negative == 1) {
		base_shine = -base_shine;
	}

    vec2 moving_uv = uv;
    moving_uv.x += TIME * shine_speed * shine_direction.x;
    moving_uv.y += TIME * shine_speed * 0.4 * shine_direction.y;
    vec2 grid_uv = moving_uv * diamond_density;
    float row = floor(grid_uv.y);
    grid_uv.x += mod(row, 2.0) * 0.5;
    vec2 cell = fract(grid_uv) - 0.5;
    float diamond = abs(cell.x) + abs(cell.y);
    float mask = smoothstep(0.5, 0.5 - diamond_fill * 0.5, diamond);
    vec3 foil = mask * shine_strength * shine_color.rgb;
    vec3 final_color = tex_color.rgb + base_shine + foil;

    return vec4(final_color, tex_color.a);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = make_holographic(tex_color, UV);
}