extends Node2D
class_name EmpGlitch

func update_shader() -> void:
	material.set_shader_parameter("sin_wave", 0.5);
	material.set_shader_parameter("amplitude", 0.01);
	material.set_shader_parameter("chaos_factor", 0.05);
	material.set_shader_parameter("radius", 56);
	material.set_shader_parameter("size", Vector2(700, 500));
