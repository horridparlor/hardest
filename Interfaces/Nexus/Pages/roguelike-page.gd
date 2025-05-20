extends Node2D
class_name RoguelikePage

signal death

const MIN_IN_VELOCITY : float = 3.2 * Config.GAME_SPEED;
const MAX_IN_VELOCITY : float = 3.8 * Config.GAME_SPEED;
const MIN_OUT_VELOCITY : float = 1800 * Config.GAME_SPEED;
const MAX_OUT_VELOCITY : float = 2600 * Config.GAME_SPEED;
const SIZE : Vector2 = Vector2(740, 1130);
const PROGRESS_PANEL_SIZE : Vector2 = Vector2(680, 110);
const PROGRESS_PANEL_BORDER_WIDTH : int = 4;

var velocity : float
var is_rolling_in : bool;
var is_rolling_out : bool;
var origin_point : Vector2;
var data : RoguelikeData;

func init(roguelike_data : RoguelikeData):
	pass;

func roll_out() -> void:
	velocity = System.random.randf_range(MIN_OUT_VELOCITY, MAX_OUT_VELOCITY);
	is_rolling_in = false;
	is_rolling_out = true;

func roll_in() -> void:
	velocity = System.random.randf_range(MIN_IN_VELOCITY, MAX_IN_VELOCITY);
	is_rolling_out = false;
	is_rolling_in = true;

func _process(delta : float) -> void:
	if is_rolling_in:
		position = System.Vectors.slide_towards(position, origin_point, velocity * delta);
		if System.Vectors.equal(position, origin_point):
			position = origin_point;
			is_rolling_in = false;
	if is_rolling_out:
		position.y += velocity * delta * System.game_speed;
		if !System.Vectors.is_inside_window(position, SIZE):
			is_rolling_out = false;
