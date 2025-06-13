static func negative() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/Common/negative-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	return shader_material;
