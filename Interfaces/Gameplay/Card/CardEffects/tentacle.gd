extends Node2D
class_name Tentacle

const BASE_ROTATION : int = 90;
const MAX_POSITION : int = GameplayCard.SIZE.x / 2 * GameplayCard.MIN_SCALE;
const MIN_SPEED : float = 15 * Config.GAME_SPEED;
const MAX_SPEED : float = 30 * Config.GAME_SPEED;
const MIN_MAX_WIGGLE_DEGREES : int = 45;
const MAX_MAX_WIGGLE_DEGREES : int = 180;
const MIN_WIGGLE_ROTATION_SPEED : float = 60 * Config.GAME_SPEED;
const MAX_WIGGLE_ROTATION_SPEED : float = 120 * Config.GAME_SPEED;
const LEVIATHAN_SOUND_LENGTH : float = 5.72;
const WIGGLE_SPEED_ACCELERATION : int = 50 * Config.GAME_SPEED;
const WIGGLE_ROTATION_SPEED_ACCELERATION : int = 150 * Config.GAME_SPEED;
const FADE_SPEED : float = 0.1 * Config.GAME_SPEED;
const FADE_EXPONENT : float = 24.2;

var sfx_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var is_playing_sound : bool;
var parent : Node2D;
var enemy : Node2D;
var target_position : Vector2;
var is_init : bool;
var starting_position : Vector2;
var starting_time : int;
var rotation_speed : float;
var base_rotation : float;
var wiggle_speed : float;
var wiggle_position : Vector2;
var center_position : Vector2;
var wiggle_degrees : float;
var wiggle_direction : int;
var wiggle_rotation_speed : float;
var base_wiggle_speed : float;
var base_wiggle_rotation_speed : float;
var max_wiggle_degrees : float;
var is_slowing_down : bool;
var is_speeding_up : bool;
var do_fade : bool;

func _ready() -> void:
	add_child(sfx_player);
	starting_position = position;
	position += System.Random.vector(0, MAX_POSITION);
	base_rotation = BASE_ROTATION + rad_to_deg((position - starting_position).angle()) / 5;
	position.x = 0;
	wiggle_speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	base_wiggle_speed = wiggle_speed;
	wiggle_rotation_speed = System.random.randf_range(MIN_WIGGLE_ROTATION_SPEED, MAX_WIGGLE_ROTATION_SPEED);
	base_wiggle_rotation_speed = wiggle_rotation_speed;
	wiggle_position = System.Random.vector(0, MAX_POSITION);
	max_wiggle_degrees = System.random.randf_range(MIN_MAX_WIGGLE_DEGREES, MAX_MAX_WIGGLE_DEGREES);
	wiggle_degrees = System.random.randf_range(-max_wiggle_degrees, max_wiggle_degrees);
	wiggle_direction = System.Random.direction();

func init(parent_ : Node2D, target_node : Node2D, target_position_ : Vector2, play_sound : bool = false) -> void:
	parent = parent_
	enemy = target_node;
	target_position = target_position_;
	init_sprite();
	if play_sound:
		play_kraken_sound();
	starting_position = position;
	starting_time = Time.get_ticks_msec();
	is_init = true;
	center_position = parent.position;
	position += center_position;

func init_sprite() -> void:
	pass;

func play_kraken_sound() -> void:
	var sound : Resource;
	if Config.MUTE_SFX:
		return;
	is_playing_sound = true;
	sound = load("res://Assets/SFX/CardSounds/Bullets/leviathan-roar.wav");
	sfx_player.stream = sound;
	sfx_player.pitch_scale = System.game_speed;
	sfx_player.play();
	await System.wait(LEVIATHAN_SOUND_LENGTH / 2);
	is_playing_sound = false;
	
func _process(delta : float) -> void:
	if !is_init:
		return;
	if !System.Instance.exists(parent):
		if !is_playing_sound and !System.Vectors.is_inside_window(position, Vector2(437, 437)):
			queue_free();
		else:
			continue_moving(delta);
	follow_parent();
	rotate_to_enemy(delta);
	wiggle(delta);
	if is_slowing_down:
		slow_frame(delta);
	elif is_speeding_up:
		speed_frame(delta);
	elif do_fade and wiggle_speed > 0:
		modulate.a -= delta * FADE_SPEED * pow(1 + FADE_SPEED, max(1, modulate.a * FADE_EXPONENT));
		if modulate.a <= 0:
			modulate.a = 0;
			queue_free();

func speed_frame(delta : float) -> void:
	wiggle_speed += delta * WIGGLE_SPEED_ACCELERATION;
	if wiggle_speed >= base_wiggle_speed:
		wiggle_speed = base_wiggle_speed;
	wiggle_rotation_speed += delta * WIGGLE_ROTATION_SPEED_ACCELERATION;
	if wiggle_rotation_speed >= base_wiggle_rotation_speed:
		wiggle_rotation_speed = base_wiggle_rotation_speed;
	if wiggle_speed == base_wiggle_speed and wiggle_rotation_speed == base_wiggle_rotation_speed:
		is_speeding_up = false;

func slow_frame(delta : float) -> void:
	wiggle_speed -= delta * WIGGLE_SPEED_ACCELERATION;
	if wiggle_speed <= 0:
		wiggle_speed = 0;
	wiggle_rotation_speed -= delta * WIGGLE_ROTATION_SPEED_ACCELERATION;
	if wiggle_rotation_speed <= 0:
		wiggle_rotation_speed = 0;
	if wiggle_speed == 0 and wiggle_rotation_speed == 0:
		is_slowing_down = false;

func wiggle(delta : float) -> void:
	position = System.Vectors.slide_towards(position, center_position + wiggle_position, wiggle_speed * delta);
	if System.Vectors.equal(position, center_position + wiggle_position, MAX_POSITION / 20):
		wiggle_position = System.Random.vector(0, MAX_POSITION);
	wiggle_degrees += wiggle_direction * wiggle_rotation_speed * delta;
	if abs(wiggle_degrees) > max_wiggle_degrees and System.Floats.direction(wiggle_degrees) == wiggle_direction:
		wiggle_degrees = System.Floats.direction(wiggle_degrees) * max_wiggle_degrees;
		wiggle_direction = -wiggle_direction;
	position.x = center_position.x;
	position.y = clamp(position.y, center_position.y - MAX_POSITION, center_position.y + MAX_POSITION);

func continue_moving(delta : float) -> void:
	var direction : Vector2 = starting_position.direction_to(center_position);
	var time_moved : int = float(Time.get_ticks_msec() - starting_time) / 1000;
	var speed : float = starting_position.distance_to(center_position) / time_moved;
	center_position += direction * speed * delta;

func follow_parent() -> void:
	if !System.Instance.exists(parent):
		return;
	center_position = parent.position;

func rotate_to_enemy(delta : float) -> void:
	var enemy_position : Vector2 = target_position;
	var goal_rotation : float;
	if System.Instance.exists(enemy):
		enemy_position = enemy.position;
		target_position = enemy_position;
	goal_rotation = rad_to_deg((enemy_position - position).angle());
	rotation_degrees = goal_rotation + base_rotation + wiggle_degrees;

func speed_up() -> void:
	is_slowing_down = false;
	is_speeding_up = true;
	starting_time = Time.get_ticks_msec();

func slow_down() -> void:
	is_speeding_up = false;
	is_slowing_down = true;
