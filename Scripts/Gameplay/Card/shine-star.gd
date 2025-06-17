extends ShineStar

@onready var sprite : Sprite2D = $Sprite2D;

func init_sprite() -> void:
	var shader : Resource = load("res://Shaders/CardEffects/shine-star-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	shader_material.set_shader_parameter("time_speed", time_speed);
	shader_material.set_shader_parameter("shine_intensity", shine_intensity);
	shader_material.set_shader_parameter("glow_speed", glow_speed);
	shader_material.set_shader_parameter("wiggle_strength", wiggle_strength);
	shader_material.set_shader_parameter("scale_strength", 0.2);
	shader_material.set_shader_parameter("opacity", modulate.a);
	sprite.material = shader_material;

func update_opacity() -> void:
	sprite.material.set_shader_parameter("opacity", modulate.a);

func _on_shutter() -> void:
	sprite.material.set_shader_parameter("time_speed", 0.0);
	sprite.material.set_shader_parameter("glow_speed", 0.0);
