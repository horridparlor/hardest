extends GlowNode
class_name LevelButton

signal pressed(level_data);

const CHARACTER_FACE_PATH : String = "res://Assets/Art/CharacterFace/%s.png";
const BORDER_WIDTH : int = 4;
const BORDER_RADIUS : int = 9;
const LATEST_LEVEL_BG_COLOR : String = "#ff006b";
const LATEST_LEVEL_BORDER_COLOR : String = "#ebb2ca";
const MIN_ROLL_ERROR : float = 0;
const MAX_ROLL_ERROR : float = 50;
const SIZE : Vector2 = Vector2(280, 320);
const MIN_ROLL_IN_VELOCITY : float = 2.9 * Config.GAME_SPEED;
const MAX_ROLL_IN_VELOCITY : float = 3.7 * Config.GAME_SPEED;
const MIN_ROLL_OUT_VELOCITY : float = 6.7 * Config.GAME_SPEED;
const MAX_ROLL_OUT_VELOCITY : float = 8.1 * Config.GAME_SPEED;
const ROTATION_SPEED : float = 3.4;

var level_data : LevelData;
var is_latest_level : bool;
var origin_point : Vector2;
var is_rolling_in : bool;
var is_rolling_out : bool;
var rolling_direction : Vector2;
var velocity : float;
var random : RandomNumberGenerator = RandomNumberGenerator.new();
var base_rotation : float;

func init(level_data_ : LevelData, is_latest_level_ : bool) -> void:
	base_rotation = System.random.randf_range(-ROTATION_SPEED, ROTATION_SPEED);
	rotation_degrees = base_rotation;
	level_data = level_data_;
	level_data.position = position;
	is_latest_level = is_latest_level_;
	origin_point = position;
	random.seed = System.random.seed;
	update_visuals();
	activate_animations();
	if level_data.is_locked:
		hide_button();

func update_visuals() -> void:
	pass;

func hide_button() -> void:
	pass;

func trigger() -> void:
	emit_signal("pressed", level_data);

func roll_out() -> void:
	velocity = random.randf_range(MIN_ROLL_OUT_VELOCITY, MAX_ROLL_OUT_VELOCITY);
	rolling_direction = get_rolling_direction();
	is_rolling_in = false;
	is_rolling_out = true;

func get_rolling_direction() -> Vector2:
	return origin_point + System.Random.vector(MIN_ROLL_ERROR, MAX_ROLL_ERROR, random);

func roll_in() -> void:
	velocity = random.randf_range(MIN_ROLL_IN_VELOCITY, MAX_ROLL_IN_VELOCITY);
	is_rolling_out = false;
	is_rolling_in = true;

func _process(delta : float) -> void:
	var start_position : Vector2 = position;
	if is_rolling_out:
		position += rolling_direction * velocity * delta * System.game_speed;
		if !System.Vectors.is_inside_window(position, SIZE):
			is_rolling_out = false;
	if is_rolling_in:
		position = System.Vectors.slide_towards(position, origin_point, delta * velocity);
		if System.Vectors.equal(position, origin_point):
			position = origin_point;
			is_rolling_in = false;
	rotation_frame(position.x - start_position.x, delta);

func rotation_frame(angle : float, delta : float) -> void:
	rotation_degrees += angle * ROTATION_SPEED * delta;
	if is_rolling_in:
		rotation_degrees = System.Scale.baseline(rotation_degrees, base_rotation, ROTATION_SPEED / 2 * delta);
