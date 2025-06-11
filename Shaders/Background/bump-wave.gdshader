shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 1000.0) = 10.0;
uniform float sin_wave : hint_range(0.0, 1.0) = 0.5;
uniform float chaos_factor : hint_range(0.0, 2.0) = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float bump_factor : hint_range(0.0, 1000.0) = 5.0;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float wave = sin((dist * sin_wave * bump_factor - TIME * 10.0) + chaos_factor * sin(dist * 100.0 + TIME * 5.0));
    wave = wave * amplitude / 100.0;
    vec2 dir = normalize(uv - center);
    uv += dir * wave;
    COLOR = texture(TEXTURE, uv);
    COLOR.a *= opacity;
}