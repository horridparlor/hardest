shader_type canvas_item;

uniform float time : hint_range(0.0, 2.0) = 1.9999;
uniform float glitch_mix : hint_range(0.0, 1.0) = 1.0;
uniform float bw_mix : hint_range(0.0, 1.0) = 1.0;
uniform vec2 screen_center = vec2(0.5, 0.5);
uniform float pulse_width = 0.15;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

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
        vec3 grayscale = mix(glitch, rgb2gray(original.rgb), bw_mix); // Control grayscale intensity
        color = mix(glitch, grayscale, effect_strength);
    }

    COLOR = vec4(color, original.a * opacity);
}