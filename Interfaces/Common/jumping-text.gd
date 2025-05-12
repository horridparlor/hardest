extends Control
class_name JumpingText

const MIN_SCALE : float = 1;
const MAX_SCALE : float = 1.4
const INFLATE_SPEED : float = 0.2;
const DEFLATE_SPEED : float = 0.4;
const ERROR_CHANCE : float = 0.1;
const DYING_SPEED : float = 1.5;

var scale_multiplier : float = 1;
var direction : int = 1;
var error : float = 1;
var is_dying : bool;

func _process(delta: float) -> void:
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
	if !is_dying:
		return;
	modulate.a -= DYING_SPEED * delta;
	if modulate.a <= 0:
		queue_free();

func die() -> void:
	is_dying = true;
