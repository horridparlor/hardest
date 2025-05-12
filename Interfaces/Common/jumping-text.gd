extends Control
class_name JumpingText

const MIN_SCALE : float = 1;
const MAX_SCALE : float = 1.4
const INFLATE_SPEED : float = 0.2;
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

func _process(delta: float) -> void:
	if is_stopped:
		return;
	var starting_scale : float = scale_multiplier;
	scale_multiplier += direction * (INFLATE_SPEED if direction == 1 else DEFLATE_SPEED) * delta * error;
	if direction == 1:
		if scale_multiplier >= MAX_SCALE:
			scale_multiplier = MAX_SCALE;
			direction = -1;
	else:
		if scale_multiplier <= MIN_SCALE:
			scale_multiplier = MIN_SCALE;
			direction = 1;
	scale = Vector2(scale_multiplier, scale_multiplier);
	position *= (scale / starting_scale);
	error += System.Random.direction() * ERROR_CHANCE * delta;
	if is_fading_in:
		modulate.a += FADE_IN_SPEED * delta;
		if modulate.a >= 1:
			modulate.a == 0;
			is_fading_in = false;
	if !is_dying:
		return;
	modulate.a -= DYING_SPEED * delta;
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
	visible = false;
