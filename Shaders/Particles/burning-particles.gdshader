shader_type canvas_item;

uniform float speed = 2.0;
uniform float intensity = 2.0;
uniform float scale = 3.0;
uniform float distortion_amount = 0.6;
uniform vec4 fire_color1 = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 fire_color2 = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 fire_color3 = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	if (COLOR.a == 0.0) {
		discard;
	}
    vec2 uv = UV;
    uv.y += TIME * speed;

    float wave = sin(uv.y * 5.0 + TIME * speed) * 0.5
               + sin(uv.y * 10.0 + TIME * speed * 1.5) * 0.5;

    uv.x += wave * distortion_amount;

    float n = sin(uv.x * scale + uv.y) 
            + sin(uv.x * scale * 1.5 + uv.y * 1.5)
            + sin(uv.x * scale * 0.5 + uv.y * 2.0);

    n /= 3.0;
    n = smoothstep(0.0, 1.0, n * intensity);

    vec4 color = mix(fire_color1, fire_color2, n);
    color = mix(color, fire_color3, n * n);

    COLOR = color;
}