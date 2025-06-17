shader_type canvas_item;

uniform float wave_speed = 1.0;
uniform float wave_frequency = 20.0;
uniform float wave_amplitude = 0.02;
uniform vec4 water_color : source_color = vec4(0.0, 0.4, 0.8, 1.0);
uniform float shine_speed = 10.0;
uniform vec4 shine_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shine_strength = 0.3;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float mix_rate : hint_range(0.0, 1.0) = 1.0;

uniform vec2 wave_center = vec2(0.5, 0.5);

void fragment() {
	vec4 original = COLOR;
    vec2 screen_uv = SCREEN_UV;
    vec2 to_center = screen_uv - wave_center;
    float dist = length(to_center);
    float wave = sin(dist * wave_frequency - TIME * wave_speed);
    float distortion = wave * wave_amplitude;
    vec2 distorted_uv = UV + normalize(to_center) * distortion;
    vec4 base = water_color;
    float shine = sin(dist * wave_frequency * 1.2 - TIME * shine_speed);
    shine = pow(abs(shine), 8.0);
    base.rgb += shine * shine_color.rgb * shine_strength;
	vec4 mixed = mix(original, base, mix_rate);
    COLOR = vec4(mixed.rgb, opacity);
}
