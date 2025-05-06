extends LevelButton

@onready var face_sprite : Sprite2D = $CharacterFace;
@onready var panel : Panel = $Panel;

func _on_level_pressed_triggered() -> void:
	emit_signal("pressed", level_data);

func update_visuals() -> void:
	var face_texture : Resource = load(CHARACTER_FACE_PATH % [GameplayEnums.CharacterToId[level_data.opponent]]);
	face_sprite.texture = face_texture;
	if is_latest_level:
		make_latest_level();
	
func make_latest_level() -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = LATEST_LEVEL_BG_COLOR;
	style.border_color = LATEST_LEVEL_BORDER_COLOR;
	style.border_width_left = BORDER_WIDTH;
	style.border_width_right = BORDER_WIDTH;
	style.border_width_top = BORDER_WIDTH;
	style.border_width_bottom = BORDER_WIDTH;
	style.corner_radius_top_left = BORDER_RADIUS;
	style.corner_radius_top_right = BORDER_RADIUS;
	style.corner_radius_bottom_left = BORDER_RADIUS;
	style.corner_radius_bottom_right = BORDER_RADIUS;
	panel.add_theme_stylebox_override("panel", style);

func hide_button() -> void:
	full_shutter();
	face_sprite.modulate = Color(0, 0, 0);
