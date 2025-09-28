shader_type canvas_item;

uniform vec2 wave_center = vec2(0.5, 0.5);
uniform float event_horizon_radius : hint_range(0.0, 1.0) = 0.1;
uniform float pull_strength : hint_range(0.0, 5.0) = 2;
uniform float swirl_strength : hint_range(0.0, 8.0) = 3.0;
uniform float swirl_speed = 2;
uniform float chaos_amount : hint_range(0.0, 2.0) = 0.8;
uniform float chaos_freq = 16.0;

uniform float wave_speed = 1.9;
uniform float wave_frequency = 64.0;
uniform float wave_amplitude = 0.02;
uniform float angular_bias : hint_range(0.0, 1.0) = 0.6;

uniform vec4 space_color : source_color = vec4(0.04, 0.02, 0.07, 1.0);
uniform vec4 hole_tint  : source_color = vec4(0.12, 0.00, 0.22, 1.0);
uniform vec4 ring_color : source_color = vec4(0.85, 0.60, 1.00, 1.0);

uniform float ring_radius = 0.2;
uniform float ring_thickness = 0.04;
uniform float ring_glow = 1.4;
uniform float ring_scroll = 1.2;

uniform float mix_rate : hint_range(0.0, 1.0) = 1.0;
uniform float opacity  : hint_range(0.0, 1.0) = 1.0;

uniform bool use_screen_texture = true;
uniform sampler2D screen_tex : hint_screen_texture;

float safe_len(vec2 v) { return max(length(v), 1e-4); }

vec2 rotate(vec2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(vec2(c, s), vec2(-s, c)) * p;
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    vec2 suv = SCREEN_UV;
    vec4 src = use_screen_texture ? texture(screen_tex, suv)
                                  : texture(TEXTURE, UV) * COLOR;

    vec2 to_c = suv - wave_center;
    float r = safe_len(to_c);
    vec2 dir = to_c / r;

    float pull = pull_strength * smoothstep(1.0, 0.0, r) / (r + 0.12);
    vec2 pulled = suv - dir * pull * 0.03;

    float base_spin = swirl_strength * smoothstep(1.0, 0.0, r);
    float wobble = chaos_amount * (hash21(to_c * chaos_freq + TIME) - 0.5);
    float spin = (base_spin + wobble) * (0.6 + 0.4 * sin(TIME * swirl_speed));
    vec2 swirl_vec = rotate(pulled - wave_center, spin * (0.25 + 0.75 * smoothstep(1.0, 0.0, r))) + wave_center;

    vec2 tang = vec2(-dir.y, dir.x);
    float wave = sin(r * wave_frequency - TIME * wave_speed)
               + 0.5 * sin((r * wave_frequency * 0.5 + atan(to_c.y, to_c.x) * 3.0) - TIME * wave_speed * 1.7);
    vec2 angled = mix(dir, tang, angular_bias);
    vec2 wave_offset = angled * wave * wave_amplitude * (1.0 + 1.25 * smoothstep(1.0, 0.0, r));

    vec2 final_uv = swirl_vec + wave_offset;
    final_uv = clamp(final_uv, vec2(0.001), vec2(0.999));

    vec4 lensed = use_screen_texture ? texture(screen_tex, final_uv)
                                     : texture(TEXTURE, final_uv) * COLOR;

    float horizon = smoothstep(event_horizon_radius * 1.05, event_horizon_radius * 0.8, r);
    vec3 tinted = mix(lensed.rgb, mix(space_color.rgb, hole_tint.rgb, 0.65), horizon);

    float ring_pos = r - ring_radius;
    float ring_shape = exp(-pow(ring_pos / ring_thickness, 2.0));
    float theta = atan(to_c.y, to_c.x);
    float ring_flux = 0.6 + 0.4 * sin(theta * 6.0 + TIME * ring_scroll)
                            * (1.0 + 0.6 * sin(TIME * 2.3 + r * 30.0));
    vec3 ring = ring_color.rgb * ring_shape * ring_glow * ring_flux;

    float vignette = smoothstep(0.95, 0.25, r);
    vec3 with_vignette = mix(tinted, space_color.rgb, vignette * 0.35);

    vec3 black_hole_rgb = with_vignette + ring;
    vec3 mixed_rgb = mix(src.rgb, black_hole_rgb, mix_rate);

    COLOR = vec4(mixed_rgb, opacity);
}