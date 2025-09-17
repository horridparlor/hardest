extends Node2D
class_name Rattle

enum RattleState {
	FADE_IN,
	SUSTAIN,
	FADE_OUT
}

const VIBRATION_BASE_SPEED : float = 560 * Config.GAME_SPEED;
const MIN_VIBRATION_SPEED : float = 1.0;
const MAX_VIBRATION_SPEED : float = 1.6;
const MIN_FADING_OUT_SPEED : float = 2.7 * Config.GAME_SPEED;
const MAX_FADING_OUT_SPEED : float = 3.9 * Config.GAME_SPEED;
const MIN_FADE_IN_SPEED : float = 2.7 * Config.GAME_SPEED;
const MAX_FADE_IN_SPEED : float = 3.6 * Config.GAME_SPEED;
const MIN_SUSTAIN_TIME : float = 0.52 * Config.GAME_SPEED_MULTIPLIER;
const MAX_SUSTAIN_TIME : float = 0.96 * Config.GAME_SPEED_MULTIPLIER;
const MIN_ROTATION_EDGE : float = 25.6;
const MAX_ROTATION_EDGE : float = 45.6;
const VIBRATION_SPEED_UP_BY_OPACITY : float = 1.1;

var vibration_speed : float;
var fading_out_speed : float;
var fade_in_speed : float;
var sustain_time : float;
var state : RattleState;
var rotation_edge : float;
var rotation_direction : int;

func _ready() -> void:
	modulate.a = 0;
	vibration_speed = System.random.randf_range(MIN_VIBRATION_SPEED, MAX_VIBRATION_SPEED);
	fading_out_speed = System.random.randf_range(MIN_FADING_OUT_SPEED, MAX_FADING_OUT_SPEED);
	fade_in_speed = System.random.randf_range(MIN_FADE_IN_SPEED, MAX_FADE_IN_SPEED);
	sustain_time = System.random.randf_range(MIN_SUSTAIN_TIME, MAX_SUSTAIN_TIME);
	rotation_edge = System.random.randf_range(MIN_ROTATION_EDGE, MAX_ROTATION_EDGE);
	rotation_direction = System.Random.direction();
	
	state = RattleState.FADE_IN;

func _process(delta : float) -> void:
	vibrate_frame(delta);
	match state:
		RattleState.FADE_IN:
			fade_in_frame(delta);
		RattleState.SUSTAIN:
			sustain_frame(delta);
		RattleState.FADE_OUT:
			fading_out_frame(delta);

func vibrate_frame(delta : float) -> void:
	rotation_degrees += rotation_direction * vibration_speed * VIBRATION_BASE_SPEED * delta * (1 + modulate.a * VIBRATION_SPEED_UP_BY_OPACITY);
	if (rotation_direction == 1 and rotation_degrees >= rotation_edge) \
	or (rotation_direction == -1 and rotation_degrees <= -rotation_edge):
		rotation_direction *= -1;
		vibration_speed = System.random.randf_range(MIN_VIBRATION_SPEED, MAX_VIBRATION_SPEED);
		rotation_edge = System.random.randf_range(MIN_ROTATION_EDGE, MAX_ROTATION_EDGE);

func fade_in_frame(delta : float) -> void:
	modulate.a += fade_in_speed * delta;
	if modulate.a >= 1:
		state = RattleState.SUSTAIN;
	
func sustain_frame(delta : float) -> void:
	sustain_time -= delta;
	if sustain_time <= 0:
		state = RattleState.FADE_OUT;

func fading_out_frame(delta : float) -> void:
	modulate.a -= fading_out_speed * delta;
	if modulate.a <= 0:
		queue_free();
