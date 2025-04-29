extends GlowNode
class_name LevelButton

signal pressed(level_data);

const CHARACTER_FACE_PATH : String = "res://Assets/Art/CharacterFace/%s.png";

var level_data : LevelData;

func init(level_data_ : LevelData) -> void:
	level_data = level_data_;
	update_visuals();
	activate_animations();

func update_visuals() -> void:
	pass;

func hide_button() -> void:
	pass;
