extends MultiplierBar

@onready var panel : Panel = $Panel;
@onready var sprite : Sprite2D = $Sprite2D;
@onready var label : Label = $Label;

func _ready() -> void:
	activate_animations();
	pattern_shader = System.Shaders.background_wave();
	sprite.material = pattern_shader;
	opacity = 0;
	fade_in_speed = System.random.randf_range(MIN_FADE_IN_SPEED, MAX_FADE_IN_SPEED);
	fade_out_speed = System.random.randf_range(MIN_FADE_OUT_SPEED, MAX_FADE_OUT_SPEED);
	update_opacity();

func after_time_stop() -> void:
	sprite.material = pattern_shader;

func get_shader_layers() -> Array:
	return [
		panel,
		sprite,
		label
	];

func set_number(value : int) -> void:
	label.text = str(value) + "x";

func update_opacity() -> void:
	if sprite.material == pattern_shader:
		sprite.material.set_shader_parameter("opacity", opacity);
	panel.modulate.a = opacity;
	label.modulate.a = opacity;
