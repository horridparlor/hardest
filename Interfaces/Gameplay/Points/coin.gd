extends GlowNode
class_name Coin

const MIN_VERTICAL_FLIP_SPEED : float = 6.3 * Config.GAME_SPEED;
const MAX_VERTICAL_FLIP_SPEED : float = 10.2 * Config.GAME_SPEED;
const MIN_HORIZONTAL_FLIP_SPEED : float = 1.1 * Config.GAME_SPEED;
const MAX_HORIZONTAL_FLIP_SPEED : float = 3.2 * Config.GAME_SPEED;
const MIN_RISE_SPEED : float = 2.1 * Config.GAME_SPEED;
const MAX_RISE_SPEED : float = 6.8 * Config.GAME_SPEED;
const MIN_FALL_SPEED : float = 1090 * Config.GAME_SPEED;
const MAX_FALL_SPEED : float = 2880 * Config.GAME_SPEED;
const GOAL_MIN_DISTANCE : Vector2 = Vector2(0, 1560);
const GOAL_MAX_DISTANCE : Vector2 = Vector2(150, 2720);
const MIN_HORIZONTAL_FLIP_EDGE : float = 0.69;
const MAX_HORIZONTAL_FLIP_EDGE : float = 0.99;
const MIN_ROTATION_SPEED : float = 10.9 * Config.GAME_SPEED;
const MAX_ROTATION_SPEED : float = 48.5 * Config.GAME_SPEED;
const MIN_ROTATION_EDGE : float = 0;
const MAX_ROTATION_EDGE : float = 45.2;
const SIZE : Vector2 = Vector2(256, 256);
const MIN_SPAWN_X : int = 225;
const MAX_SPAWN_X : int = 450;
const MIN_SPAWN_Y : int = 0;
const MAX_SPAWN_Y : int = 200;
const MIN_BASE_SPRITE_SCALE : float = 0.6;
const MAX_BASE_SPRITE_SCALE_LOSING : float = 0.8;
const MAX_BASE_SPRITE_SCALE : float = 1.2;
const GOAL_EDGE : float = 20;
const LOSING_COIN_FALL_MULTIPLIER : float = 1.46;

var is_flipping : bool;
var vertical_flip_direction : int = 1;
var is_falling : bool;
var goal_position : Vector2;
var vertical_flip_speed : float;
var horizontal_flip_speed : float;
var horizontal_flip_edge : float;
var horizontal_flip_direction : int = 1;
var rise_speed : float;
var fall_speed : float;
var rotation_speed : float;
var rotation_edge : float;
var rotation_direction : int = 1;
var base_sprite_scale : float;
var sprite_scale : Vector2 = Vector2.ONE;

func _ready() -> void:
	position = Vector2(
		System.Random.direction() * System.random.randf_range(MIN_SPAWN_X, MAX_SPAWN_X),
		System.Window_.y / 2 + SIZE.y / 2 + System.random.randf_range(MIN_SPAWN_Y, MAX_SPAWN_Y)	
	);
	base_sprite_scale = get_base_scale();
	activate_animations();

static func get_base_scale(max_scale : float = MAX_BASE_SPRITE_SCALE) -> float:
	return System.random.randf_range(MIN_BASE_SPRITE_SCALE, max_scale);

func lose_init() -> void:
	full_shutter();
	position.y = -position.y;
	base_sprite_scale = System.random.randf_range(MIN_BASE_SPRITE_SCALE, MAX_BASE_SPRITE_SCALE_LOSING);
	init();
	fall();
	fall_speed *= LOSING_COIN_FALL_MULTIPLIER;
	vertical_flip_speed /= LOSING_COIN_FALL_MULTIPLIER;
	horizontal_flip_speed /= LOSING_COIN_FALL_MULTIPLIER;
	rotation_speed /= LOSING_COIN_FALL_MULTIPLIER;

func init() -> void:
	randomize_flip_stats();
	is_flipping = true;
	rise_speed = System.random.randf_range(MIN_RISE_SPEED, MAX_RISE_SPEED);
	fall_speed = System.random.randf_range(MIN_FALL_SPEED, MAX_FALL_SPEED);
	goal_position = position - Vector2(
		System.Random.direction() * System.random.randf_range(GOAL_MIN_DISTANCE.x, GOAL_MAX_DISTANCE.x),
		System.random.randf_range(GOAL_MIN_DISTANCE.y, GOAL_MAX_DISTANCE.y)
	);

func randomize_flip_stats() -> void:
	vertical_flip_speed = System.random.randf_range(MIN_VERTICAL_FLIP_SPEED, MAX_VERTICAL_FLIP_SPEED);
	horizontal_flip_speed = System.random.randf_range(MIN_HORIZONTAL_FLIP_SPEED, MAX_HORIZONTAL_FLIP_SPEED);
	horizontal_flip_edge = System.random.randf_range(MIN_HORIZONTAL_FLIP_EDGE, MAX_HORIZONTAL_FLIP_EDGE);
	rotation_speed = System.random.randf_range(MIN_ROTATION_SPEED, MAX_RISE_SPEED);
	rotation_edge = System.random.randf_range(MIN_ROTATION_EDGE, MAX_ROTATION_EDGE);

func flip_frame(sprite : Sprite2D, delta : float) -> void:
	sprite_scale.y -= vertical_flip_direction * vertical_flip_speed * delta;
	if (vertical_flip_direction == 1 and sprite_scale.y <= -1) \
	or (vertical_flip_direction == -1 and sprite_scale.y >= 1):
		vertical_flip_direction *= -1;
	sprite_scale.x -= horizontal_flip_direction * horizontal_flip_speed * delta;
	if (horizontal_flip_direction == 1 and sprite_scale.x <= horizontal_flip_edge) \
	or (horizontal_flip_direction == -1 and sprite_scale.x >= 1):
		horizontal_flip_direction *= -1;
	sprite.scale = sprite_scale * base_sprite_scale;
	sprite.rotation_degrees += rotation_direction * rotation_speed * delta;
	if (rotation_direction == 1 and sprite.rotation_degrees >= rotation_edge) \
	or (rotation_direction == -1 and sprite.rotation_degrees <= -rotation_edge):
		rotation_direction *= -1;
	if is_falling:
		position.y += delta * fall_speed;
		position.x += delta * horizontal_flip_speed * System.Random.direction();
		if !System.Vectors.is_inside_window(position, base_sprite_scale * SIZE):
			queue_free();
	else:
		position = System.Vectors.slide_towards(position, goal_position, rise_speed * delta);
		if System.Vectors.equal(position, goal_position, GOAL_EDGE):
			fall();

func fall() -> void:
	randomize_flip_stats();
	is_falling = true;
