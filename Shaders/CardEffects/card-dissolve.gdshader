shader_type canvas_item;

uniform float threshold : hint_range(0.0, 2.0);
uniform vec2 viewport_size;
uniform float opacity : hint_range(0.0, 1.0);

const float MAX_CHUNK_SIZE = 200.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec3 original_color = COLOR.rgb;

    float chunk_size = mix(1.0, MAX_CHUNK_SIZE, threshold);

    vec2 chunk_pos = floor(UV * viewport_size / chunk_size);

    float r = rand(chunk_pos + vec2(1.0, 0.0));
    float g = rand(chunk_pos + vec2(0.0, 1.0));
    float b = rand(chunk_pos + vec2(1.0, 1.0));
    vec3 random_color = vec3(r, g, b);

    vec3 mixed_color = mix(original_color, random_color, pow(threshold, 1.3) / 2.6);
    COLOR = vec4(mixed_color, (1.0 - pow(threshold, 0.9) / 1.8) * opacity);
}