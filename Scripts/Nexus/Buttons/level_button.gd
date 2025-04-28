extends LevelButton

@onready var face_sprite : Sprite2D = $CharacterFace;

func _on_level_pressed_triggered() -> void:
	emit_signal("pressed", level_data);

func update_visuals() -> void:
	var face_texture : Resource = load(CHARACTER_FACE_PATH % [GameplayEnums.CharacterToId[level_data.opponent]]);
	face_sprite.texture = face_texture;
