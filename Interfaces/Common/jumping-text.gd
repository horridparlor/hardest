extends Control
class_name JumpingText

const MIN_SCALE : float = 1;
const MAX_SCALE : float = 1.4
const INFLATE_SPEED : float = 0.2 * Config.GAME_SPEED;
const DEFLATE_SPEED : float = 0.4;
const ERROR_CHANCE : float = 0.1;
const DYING_SPEED : float = 1.5 * Config.GAME_SPEED;
const FADE_IN_SPEED : float = 0.4 * Config.GAME_SPEED;

var scale_multiplier : float = 1;
var direction : int = 1;
var error : float = 1;
var is_dying : bool;
var is_fading_in : bool;
var is_stopped : bool;
var dont_move : bool;
var override_max_scale : float = 0;
var override_min_scale : float = 0;

func _process(delta: float) -> void:
	if is_stopped:
		return;
	var starting_scale : float = scale_multiplier;
	var max : float = MAX_SCALE if override_max_scale <= 0 else override_max_scale;
	var min : float = MIN_SCALE if override_min_scale <= 0 else override_min_scale;
	var true_delta : float = delta * System.game_speed;
	scale_multiplier += direction * (INFLATE_SPEED if direction == 1 else DEFLATE_SPEED) * true_delta * error;
	if direction == 1:
		if scale_multiplier >= max:
			scale_multiplier = max;
			direction = -1;
	else:
		if scale_multiplier <= min:
			scale_multiplier = min;
			direction = 1;
	scale = Vector2(scale_multiplier, scale_multiplier);
	if !dont_move:
		position *= (scale / starting_scale);
	error += System.Random.direction() * ERROR_CHANCE * true_delta;
	if is_fading_in:
		modulate.a += FADE_IN_SPEED * true_delta;
		if modulate.a >= 1:
			modulate.a == 0;
			is_fading_in = false;
	if !is_dying:
		return;
	modulate.a -= DYING_SPEED * true_delta;
	if modulate.a <= 0:
		queue_free();

func die() -> void:
	is_dying = true;

func fade_in() -> void:
	visible = true;
	modulate.a = 0;
	is_fading_in = true;
	is_stopped = false;

func stop():
	is_stopped = true;

func start():
	is_stopped = false;
	dont_move = true;
	override_max_scale = 1.02;
	override_min_scale = MIN_SCALE + (override_max_scale - MAX_SCALE) / 2;
	error = 0.4
