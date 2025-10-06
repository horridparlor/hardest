extends Node2D
class_name LichKingShadow

const MIN_FADE_IN_SPEED : float = 1.26 * Config.GAME_SPEED;
const MAX_FADE_IN_SPEED : float = 1.47 * Config.GAME_SPEED;
const MIN_FADE_OUT_SPEED : float = 1.32 * Config.GAME_SPEED;
const MAX_FADE_OUT_SPEED : float = 1.54 * Config.GAME_SPEED;
const MIN_GOAL_OPACITY : float = 0.74;
const MAX_GOAL_OPACITY : float = 0.79;
const MIN_MOVE_UP_SPEED : float = 56.7 * Config.GAME_SPEED;
const MAX_MOVE_UP_SPEED : float = 64.4 * Config.GAME_SPEED;
const SPEED_UP_EXPONENT : float = 1.2;
const SCALE_INCREASE_SPEED : float = 0.72 * Config.GAME_SPEED;

var is_fading_in : bool;
var is_fading_out : bool;
var exponent : float = 1;
var fade_in_speed : float;
var fade_out_speed : float;
var goal_opacity : float;
var move_up_speed : float;

func _ready() -> void:
	modulate.a = 0;
	is_fading_in = true;
	fade_in_speed = System.random.randf_range(MIN_FADE_IN_SPEED, MAX_FADE_IN_SPEED);
	fade_out_speed = System.random.randf_range(MIN_FADE_OUT_SPEED, MAX_FADE_OUT_SPEED);
	goal_opacity = System.random.randf_range(MIN_GOAL_OPACITY, MAX_GOAL_OPACITY);
	move_up_speed = System.random.randf_range(MIN_MOVE_UP_SPEED, MAX_MOVE_UP_SPEED);

func _process(delta : float) -> void:
	if is_fading_in:
		exponent += SPEED_UP_EXPONENT * delta;
		scale *= pow(1 + delta * SCALE_INCREASE_SPEED, exponent);
		modulate.a += delta * pow(fade_in_speed, exponent);
		if modulate.a >= goal_opacity:
			modulate.a = goal_opacity;
			fade_out();
	if is_fading_out:
		modulate.a -= delta * fade_out_speed;
		if modulate.a <= 0:
			queue_free();
	position.y -= pow(move_up_speed, exponent) * delta;

func fade_out() -> void:
	is_fading_in = false;
	is_fading_out = true;

func get_shader_layers() -> Array:
	return [];
