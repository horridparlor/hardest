shader_type canvas_item;

uniform float time : hint_range(0.0, 2.0) = 1.9999;
uniform float glitch_mix : hint_range(0.0, 1.0) = 1.0;
uniform float bw_mix : hint_range(0.0, 1.0) = 1.0;
uniform vec2 screen_center = vec2(0.5, 0.5);
uniform float pulse_width = 0.15;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

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

vec3 rgb2gray(vec3 color) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    return vec3(gray);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0, 4, 2), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

vec3 glitch_color(vec2 uv, float t) {
    float hue = mod(t + uv.y * 4.0 + sin(uv.x * 30.0 + t * 25.0) * 0.15, 1.0);
    return hsv2rgb(vec3(hue, 1.0, 1.0));
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);
	if (is_negative == 1) {
        original.rgb = vec3(1.0) - original.rgb;
    }
	if (is_holographic == 1) {
		original.rgb = make_holographic(vec4(original), UV).rgb;
	}
	if (is_foil == 1) {
		original.rgb = make_foil(vec4(original), UV).rgb;
	}
    vec2 screen_uv = SCREEN_UV;
    float dist = distance(screen_uv, screen_center);
    float pulse_radius;
    float effect_strength = 0.0;
    vec3 color = original.rgb;

    if (time < 1.0) {
        // Wave: Original → Glitch
        pulse_radius = time;
        effect_strength = smoothstep(pulse_radius - pulse_width, pulse_radius, dist);
        vec3 glitch = mix(original.rgb, glitch_color(screen_uv, time), glitch_mix);
        color = mix(original.rgb, glitch, effect_strength);
    }
    else if (time < 2.0) {
        // Wave: Glitch → Grayscale of original
        pulse_radius = time - 1.0;
        effect_strength = smoothstep(pulse_radius - pulse_width, pulse_radius, dist);
        vec3 glitch = mix(original.rgb, glitch_color(screen_uv, time), glitch_mix);
        vec3 grayscale = mix(glitch, rgb2gray(original.rgb), bw_mix);
        color = mix(glitch, grayscale, effect_strength);
    }

    COLOR = vec4(color, original.a * opacity);
}