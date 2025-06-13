shader_type canvas_item;

uniform float sin_wave : hint_range(0.0, 100.0) = 20.0;
uniform float amplitude : hint_range(0.0, 1.0) = 0.05;
uniform float chaos_factor : hint_range(0.0, 1.0) = 0.2;
uniform float radius : hint_range(0.0, 100.0) = 56.0;
uniform vec2 size = vec2(700.0, 500.0);

const float base_block_size = 4.0;
uniform int is_negative = 0;

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
}