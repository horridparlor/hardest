extends Node2D
class_name RoguelikePage

signal death
signal enter_level(level_data)

const MIN_IN_VELOCITY : float = 3.2 * Config.GAME_SPEED;
const MAX_IN_VELOCITY : float = 3.8 * Config.GAME_SPEED;
const MIN_OUT_VELOCITY : float = 1800 * Config.GAME_SPEED;
const MAX_OUT_VELOCITY : float = 2600 * Config.GAME_SPEED;
const SIZE : Vector2 = Vector2(740, 1130);
const PROGRESS_PANEL_SIZE : Vector2 = Vector2(680, 110);
const PROGRESS_PANEL_BORDER_WIDTH : int = 4;
const DEATH_MIN_SPEED : float = 0.4 * Config.GAME_SPEED
const DEATH_MAX_SPEED : float = 0.5 * Config.GAME_SPEED
const UNDEATH_MIN_SPEED : float = 1.4 * Config.GAME_SPEED
const UNDEATH_MAX_SPEED : float = 1.8 * Config.GAME_SPEED
const DEATH_PANEL_SIZE : Vector2 = Vector2(280, 110);
const LEVEL_BUTTON_STARTING_POSITION : Vector2 = Vector2(-232, -100);

var velocity : float
var is_rolling_in : bool;
var is_rolling_out : bool;
var origin_point : Vector2;
var data : RoguelikeData;
var is_dying : bool;
var death_progress : float;
var death_speed : float;
var is_undeathing : bool;
var is_active : bool;
var level_buttons : Array;

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
	death_progress_frame(delta);
	if is_rolling_in:
		position = System.Vectors.slide_towards(position, origin_point, velocity * delta);
		if System.Vectors.equal(position, origin_point):
			position = origin_point;
			is_rolling_in = false;
	if is_rolling_out:
		position.y += velocity * delta * System.game_speed;
		if !System.Vectors.is_inside_window(position, SIZE):
			is_rolling_out = false;

func death_progress_frame(delta : float) -> void:
	pass;

func toggle_active(value : bool = true) -> void:
	is_active = value;
