shader_type canvas_item;

uniform float threshold : hint_range(0.0, 2.0);
uniform vec2 viewport_size;
uniform float opacity : hint_range(0.0, 1.0);
uniform int is_negative = 0;
uniform int is_holographic = 0;
uniform int is_foil = 0;

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

const float MAX_CHUNK_SIZE = 200.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	if (COLOR.a == 0.0) {
		discard;
	}
    vec3 original_color = COLOR.rgb;

    float chunk_size = mix(1.0, MAX_CHUNK_SIZE, threshold);

    vec2 chunk_pos = floor(UV * viewport_size / chunk_size);

    float r = rand(chunk_pos + vec2(1.0, 0.0));
    float g = rand(chunk_pos + vec2(0.0, 1.0));
    float b = rand(chunk_pos + vec2(1.0, 1.0));
    vec3 random_color = vec3(r, g, b);

    vec3 mixed_color = mix(original_color, random_color, pow(threshold, 1.3) / 2.6);
	if (is_negative == 1) {
    	mixed_color = vec3(1.0) - mixed_color;
	}
	if (is_holographic == 1) {
		mixed_color = make_holographic(vec4(mixed_color.rgb, COLOR.a), UV).rgb;
	}
	if (is_foil == 1) {
		mixed_color = make_foil(vec4(mixed_color.rgb, COLOR.a), UV).rgb;
	}
    COLOR = vec4(mixed_color, (1.0 - pow(threshold, 0.9) / 1.8) * opacity);
}