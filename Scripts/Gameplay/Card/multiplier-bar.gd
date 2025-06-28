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
	multi = value;
	label.text = str(value) + "x";
	get_panel_material();

func update_opacity() -> void:
	if sprite.material == pattern_shader:
		sprite.material.set_shader_parameter("opacity", opacity);
	panel.modulate.a = opacity;
	label.modulate.a = opacity;

func get_panel_material() -> StyleBoxFlat:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = POSITIVE_BACKGROUND_COLOR if multi >= 0 else NEGATIVE_BACKGROUND_COLOR;
	style.border_color = POSITIVE_BORDER_COLOR if multi >= 0 else NEGATIVE_BORDER_COLOR;
	style.border_width_left = BORDER_WIDTH;
	style.border_width_top = BORDER_WIDTH;
	style.border_width_bottom = BORDER_WIDTH;
	style.corner_radius_top_left = BORDER_RADIUS;
	style.corner_radius_bottom_left = BORDER_RADIUS;
	style.border_width_right = BORDER_WIDTH;
	style.corner_radius_top_right = BORDER_RADIUS;
	style.corner_radius_bottom_right = BORDER_RADIUS;
	panel.add_theme_stylebox_override("panel", style);
	return style;
