extends GlowNode
class_name Poppet

enum PoppetColor {
	BLUE,
	RED,
	GOLD,
	RAINBOW
}

const MIN_MOVEMENT_SPEED : float = 1.7 * Config.GAME_SPEED;
const MAX_MOVEMENT_SPEED : float = 3.4 * Config.GAME_SPEED;
const SPEED_MULTIPLIER_BY_COLOR : Dictionary = {
	PoppetColor.BLUE: 1,
	PoppetColor.RED: 0.7,
	PoppetColor.GOLD: 0.5,
	PoppetColor.RAINBOW: 0.3 
}
const DESPAWN_DISTANCE : float = 21.8;
const DESPAWN_MIN_SPEED : float = 3.6 * Config.GAME_SPEED;
const DESPAWN_MAX_SPEED : float = 5.3 * Config.GAME_SPEED;
const MIN_ROTATION_SPEED : float = 0.01;
const MAX_ROTATION_SPEED : float = 0.03;
const MIN_REVEAL_SPEED : float = 2.5;
const MAX_REVEAL_SPEED : float = 3.9;

var instance_id : int;
var goal_position : Vector2;
var is_moving : bool;
var speed : float;
var is_despawning : bool;
var despawn_speed : float;
var rotation_speed : float;
var is_revealing : float;
var reveal_speed : float;
var color : PoppetColor;

func _ready() -> void:
	instance_id = System.Random.instance_id();

func move_to(goal_position_ : Vector2, color_ : PoppetColor = PoppetColor.BLUE) -> void:
	color = color_;
	goal_position = goal_position_;
	on(color);
	speed = SPEED_MULTIPLIER_BY_COLOR[color] * System.random.randf_range(MIN_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED);
	rotation_speed = System.random.randf_range(MIN_ROTATION_SPEED, MAX_ROTATION_SPEED);
	is_moving = true;
	reveal_speed = System.random.randfn(MIN_REVEAL_SPEED, MAX_REVEAL_SPEED);
	is_revealing = true;

func on(color_ : PoppetColor = color) -> void:
	pass;

func _process(delta : float) -> void:
	var original_position : Vector2;
	position = System.Vectors.slide_towards(position, goal_position, speed * delta);
	if !is_despawning and position.distance_to(goal_position) < DESPAWN_DISTANCE:
		is_despawning = true;
		is_revealing = false;
		despawn_speed = System.random.randf_range(DESPAWN_MIN_SPEED, DESPAWN_MAX_SPEED);
	if is_despawning:
		modulate.a -= despawn_speed * delta * System.game_speed;
		if modulate.a <= 0:
			queue_free();
	if is_revealing:
		modulate.a += reveal_speed * delta * System.game_speed;
		if modulate.a >= 1:
			modulate.a = 1;
			is_revealing = false;
	rotate_frame(original_position);

func rotate_frame(original_position : Vector2) -> void:
	rotation_degrees += (position.x - original_position.x) * rotation_speed * SPEED_MULTIPLIER_BY_COLOR[color];

func get_shader_nodes() -> Array:
	return [];
