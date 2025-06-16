shader_type canvas_item;

uniform float sin_wave : hint_range(0.0, 100.0) = 20.0;
uniform float amplitude : hint_range(0.0, 1.0) = 0.05;
uniform float chaos_factor : hint_range(0.0, 1.0) = 0.2;
uniform float radius : hint_range(0.0, 100.0) = 56.0;
uniform vec2 size = vec2(700.0, 500.0);

const float base_block_size = 4.0;
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

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

float pick_block_scale(vec2 block_id) {
    float r = random(block_id + TIME);
    if (r < 0.33) return 1.0;
    else if (r < 0.66) return 2.0;
    else return 4.0;
}

void fragment() {
    vec2 base_uv = UV;
    vec2 pos = base_uv * size;
    vec2 corner = min(pos, size - pos);
    float dx = max(radius - corner.x, 0.0);
    float dy = max(radius - corner.y, 0.0);
    if (dx * dx + dy * dy > radius * radius) {
        discard;
    }
    vec2 block_id = floor(pos / base_block_size);
    float scale = pick_block_scale(block_id);
    float block_size = base_block_size * scale;
    vec2 scaled_block_pos = floor(pos / block_size) * block_size;
    vec2 block_uv = scaled_block_pos / size;
    float wave_offset = sin(block_uv.y * sin_wave + TIME * 10.0) * amplitude;
    float chaos = random(block_uv + TIME) * chaos_factor;
    vec2 uv = base_uv;
    uv.x += wave_offset;
    uv.y += chaos;
    uv.x += chaos * 0.5;
	vec4 tex_color = texture(TEXTURE, uv);
    if (is_negative == 1) {
        tex_color.rgb = vec3(1.0) - tex_color.rgb;
    }
    COLOR = tex_color;
	if (is_holographic == 1) {
		COLOR = make_holographic(COLOR, uv);
	}
	if (is_foil == 1) {
		COLOR = make_foil(COLOR, uv);
	}
}