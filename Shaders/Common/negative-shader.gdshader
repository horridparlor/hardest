shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = vec4(vec3(1.0) - tex_color.rgb, tex_color.a);
}