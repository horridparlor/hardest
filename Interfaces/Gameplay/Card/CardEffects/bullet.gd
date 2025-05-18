extends Node2D
class_name Bullet

const MIN_SPEED : int = 7 * Config.GAME_SPEED;
const MAX_SPEED : int = 15 * Config.GAME_SPEED;
const SIZE : Vector2 = Vector2(80, 160);
const BULLET_SOUND_PATH : String = "res://Assets/SFX/CardSounds/Bullets/%s.wav";
const BULLET_ART_PATH : String = "res://Assets/Art/CardEffects/Bullets/%s.png";
const SOUND_MIN_DELAY : float = 0 * Config.GAME_SPEED_MULTIPLIER;
const SOUND_MAX_DELAY : float = 1.8 * Config.GAME_SPEED_MULTIPLIER;
const MIN_SLOW_DOWN_SPEED : float = 1 / 0.54 * Config.GAME_SPEED;
const MAX_SLOW_DOWN_SPEED : float = 1 / 0.96 * Config.GAME_SPEED;
const MIN_SPEED_UP_SPEED : float = 1 / 0.25 * Config.GAME_SPEED;
const MAX_SPEED_UP_SPEED : float = 1 / 0.38 * Config.GAME_SPEED;
const MIN_BULLET_SOUND_DELAY_POST_TIME_STOP : float = 0 * Config.GAME_SPEED_MULTIPLIER;
const MAX_BULLET_SOUND_DELAY_POST_TIME_STOP : float = 0.01 * Config.GAME_SPEED_MULTIPLIER;

var direction : Vector2;
var speed : float;
var speed_multiplier : float = 1;
var bullet_data : BulletData;
var sfx_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var sprite : Sprite2D = Sprite2D.new();
var is_moving : bool;
var is_slowing_down : bool;
var is_speeding_up : bool;
var slowing_acceleration : float;

func init(direction_ : Vector2, play_sound : bool = false):
	add_child(sfx_player);
	sfx_player.finished.connect(queue_free);
	sfx_player.volume_db = Config.VOLUME + Config.SFX_VOLUME + Config.GUN_VOLUME if play_sound and !Config.MUTE_SFX else Config.INAUDBLE_DB;
	add_child(sprite);
	speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	direction = direction_;
	rotation_degrees = direction.angle() * 180 / PI;
	set_sprite();
	set_sound();
	is_moving = true;

func _process(delta: float) -> void:
	if is_slowing_down:
		slowing_frame(delta);
		return;
	if is_speeding_up:
		speeding_frame(delta);
	position += direction * delta * speed * speed_multiplier * System.game_speed;
	if !System.Vectors.is_inside_window(position, SIZE):
		if bullet_data.id != 8:
			queue_free();
			return;
		is_moving = false;
		position = System.Vectors.default();
		visible = false;

func slowing_frame(delta : float):
	speed_multiplier -= slowing_acceleration * delta;
	if speed_multiplier < 0.1:
		sfx_player.stop();
	else:
		sfx_player.pitch_scale *= min(1, speed_multiplier * System.game_speed);
	if speed_multiplier <= 0:
		speed_multiplier = 0;
		is_slowing_down = false;

func speeding_frame(delta : float):
	speed_multiplier += slowing_acceleration * delta;
	if !sfx_player.playing:
		sfx_player.play(System.random.randf_range(MIN_BULLET_SOUND_DELAY_POST_TIME_STOP, MAX_BULLET_SOUND_DELAY_POST_TIME_STOP));
		sfx_player.pitch_scale = 1;
	if speed_multiplier >= 1:
		speed_multiplier = 1;
		is_speeding_up = false;

func set_data(data : BulletData) -> void:
	bullet_data = data;

func set_sprite() -> void:
	var texture : Resource = load(BULLET_ART_PATH % bullet_data.art_name);
	sprite.rotation_degrees = 180;
	sprite.texture = texture;

func set_sound(pitch : float = System.game_speed) -> void:
	var sound : Resource = load(BULLET_SOUND_PATH % bullet_data.sound_name);
	sfx_player.stream = sound;
	await randf_range(SOUND_MIN_DELAY, SOUND_MAX_DELAY);
	sfx_player.pitch_scale = max(Config.MIN_PITCH, pitch);
	sfx_player.play();

func speed_up() -> void:
	is_slowing_down = false;
	slowing_acceleration = System.random.randf_range(MIN_SPEED_UP_SPEED, MAX_SPEED_UP_SPEED);
	is_speeding_up = true;

func slow_down() -> void:
	is_speeding_up = false;
	slowing_acceleration = System.random.randf_range(MIN_SLOW_DOWN_SPEED, MAX_SLOW_DOWN_SPEED);
	is_slowing_down = true;
