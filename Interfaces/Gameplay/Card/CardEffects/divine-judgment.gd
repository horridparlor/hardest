extends Node2D
class_name DivineJudgment

const SIZE : Vector2 = Vector2(1080, 1536);
const MIN_SPEED : float = 19.8;
const MAX_SPEED : float = 27.6;
const DISAPPEAR_MIN_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const DISAPPEAR_MAX_WAIT : float = 0.9 * Config.GAME_SPEED_MULTIPLIER;
const MIN_DISAPPEAR_SPEED : float = 2.3;
const MAX_DISAPPEAR_SPEED : float = 4.5;
const MIN_SOUND_DELAY : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const MAX_SOUND_DELAY : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;

var goal_position : Vector2;
var speed : float;
var is_moving : bool;
var appear_timer : Timer = Timer.new();
var is_disappearing : bool;
var disappear_speed : float;
var sfx_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var sound_delay_timer : Timer = Timer.new();

func strike_down(point : Vector2) -> void:
	for node in [
		appear_timer,
		sfx_player,
		sound_delay_timer
	]:
		add_child(node);
	position.x = point.x;
	position.y = - (System.Window_.y / 2 + SIZE.y / 2);
	goal_position = Vector2(point.x, point.y - SIZE.y / 2);
	speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	is_moving = true;
	appear_timer.wait_time = System.random.randf_range(DISAPPEAR_MIN_WAIT, DISAPPEAR_MAX_WAIT) * System.game_speed_multiplier;
	appear_timer.timeout.connect(_on_disappear);
	appear_timer.start();
	sound_delay_timer.wait_time = System.random.randf_range(MIN_SOUND_DELAY, MAX_SOUND_DELAY);
	sound_delay_timer.timeout.connect(make_sound);
	sound_delay_timer.start();

func make_sound() -> void:
	var sound : Resource;
	sound_delay_timer.stop();
	sound = load("res://Assets/SFX/CardSounds/Bursts/thunder.wav");
	sfx_player.stream = sound;
	sfx_player.pitch_scale = System.game_speed;
	sfx_player.volume_db = Config.SFX_VOLUME + Config.GUN_VOLUME;
	sfx_player.play();

func _process(delta : float) -> void:
	if is_moving:
		move_frame(delta);
	if is_disappearing:
		disappear_frame(delta);
	
func disappear_frame(delta : float) -> void:
	modulate.a -= delta * disappear_speed;
	if modulate.a <= -4:
		queue_free();

func move_frame(delta : float) -> void:
	position = System.Vectors.slide_towards(position, goal_position, delta * speed);
	if System.Vectors.equal(position, goal_position):
		position = goal_position;
		is_moving = false;

func _on_disappear() -> void:
	appear_timer.stop();
	disappear_speed = System.random.randf_range(MIN_DISAPPEAR_SPEED, MAX_DISAPPEAR_SPEED);
	is_disappearing = true;
