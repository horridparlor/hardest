extends GlowNode
class_name LevelButton

signal pressed(level_data);

const CHARACTER_FACE_PATH : String = "res://Assets/Art/CharacterFace/%s.png";
const BORDER_WIDTH : int = 4;
const BORDER_RADIUS : int = 9;
const LATEST_LEVEL_BG_COLOR : String = "#ff006b";
const LATEST_LEVEL_BORDER_COLOR : String = "#ebb2ca";

var level_data : LevelData;
var is_latest_level : bool;

func init(level_data_ : LevelData, is_latest_level_ : bool) -> void:
	level_data = level_data_;
	is_latest_level = is_latest_level_;
	update_visuals();
	activate_animations();

func update_visuals() -> void:
	pass;

func hide_button() -> void:
	pass;
