shader_type canvas_item;

uniform float time_speed : hint_range(0.0, 5.0) = 1.2;
uniform float shine_intensity : hint_range(0.0, 2.0) = 0.9;
uniform float glow_speed : hint_range(0.0, 5.0) = 1.1;
uniform float wiggle_strength : hint_range(0.0, 0.1) = 0.002;
uniform float scale_strength : hint_range(0.0, 0.5) = 0.2;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	if (COLOR.a == 0.0) {
		discard;
	}
    vec2 uv = UV;
    float time = TIME * time_speed;
    float wiggle_x = sin(uv.y * 30.0 + time * 5.0) * wiggle_strength;
    float wiggle_y = cos(uv.x * 30.0 + time * 5.0) * wiggle_strength;
    uv += vec2(wiggle_x, wiggle_y);
    vec2 center = vec2(0.5);
    vec2 to_center = uv - center;
    float scale = 1.0 + sin(time * 2.0) * scale_strength;
    uv = center + to_center / scale;
    vec4 tex = texture(TEXTURE, uv);
    float pulse = sin(time * 2.0) * 0.5 + 0.5;
    vec2 diff = uv - center;
    float dist = length(diff);
    float angle = atan(diff.y, diff.x);
    float shine = sin(angle * 4.0 + time * 2.0) * 0.5 + 0.5;
    shine *= smoothstep(0.0, 0.5, 0.5 - dist);
    float final_shine = pulse * shine * shine_intensity;
    float glow = smoothstep(0.5, 0.0, dist) * pulse * glow_speed * 0.2;
    vec3 final_color = tex.rgb + vec3(final_shine + glow);
    COLOR = vec4(final_color, opacity);
}