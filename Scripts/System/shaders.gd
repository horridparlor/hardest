static func negative() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/Common/negative-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	return shader_material;

static func background_wave() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/Background/background-wave.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	return shader_material;

static func bump_wave() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/Background/bump-wave.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	return shader_material;

static func card_art(is_negative : bool, is_holographic : bool, is_foil : bool) -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/CardEffects/card-art-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	set_card_art_shader_parameters(shader_material, is_negative, is_holographic, is_foil);
	return shader_material;

static func set_card_art_shader_parameters(shader_material : ShaderMaterial, is_negative : bool, is_holographic : bool, is_foil : bool) -> void:
	shader_material.set_shader_parameter("is_negative", is_negative);
	shader_material.set_shader_parameter("is_holographic", is_holographic);
	shader_material.set_shader_parameter("is_foil", is_foil);

static func emp_shader(is_negative : bool, is_holographic : bool, is_foil : bool) -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/CardEffects/emp-radiation-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	set_card_art_shader_parameters(shader_material, is_negative, is_holographic, is_foil);
	return shader_material;

static func dissolve_shader(is_negative : bool = false, is_holographic : bool = false, is_foil : bool = false) -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/CardEffects/card-dissolve.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	shader_material.set_shader_parameter("viewport_size", System.Window_);
	shader_material.set_shader_parameter("opacity", 1);
	set_card_art_shader_parameters(shader_material, is_negative, is_holographic, is_foil);
	return shader_material;

static func new_shader_material() -> ShaderMaterial:
	return ShaderMaterial.new();
