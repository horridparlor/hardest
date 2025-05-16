shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 1000.0) = 10.0;
uniform float sin_wave : hint_range(0.0, 1.0) = 0.5;
uniform float chaos_factor : hint_range(0.0, 2.0) = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    float phase = sin_wave;
    float sineDistortion = sin((uv.x + phase) * 10.0) * 0.02;
    sineDistortion += cos((uv.y * 5.0 - phase * 0.8)) * 0.02;
    float chaos = fract(sin(dot(uv * 50.0, vec2(12.9898,78.233))) * 43758.5453);
    float noiseWave = sin((uv.y * 30.0 + chaos * 10.0 + phase * 1.5)) * chaos_factor * 0.02;
    float totalOffset = (sineDistortion + noiseWave) * amplitude;
    uv.y += totalOffset;
    COLOR = texture(TEXTURE, uv);
	COLOR.a *= opacity;
}