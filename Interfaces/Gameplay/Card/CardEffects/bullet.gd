extends Node2D
class_name Bullet

const MIN_SPEED : int = 7;
const MAX_SPEED : int = 15;
const SIZE : Vector2 = Vector2(80, 160);
const BULLET_SOUND_PATH : String = "res://Assets/SFX/CardSounds/%s.wav";
const BULLET_ART_PATH : String = "res://Assets/Art/CardEffects/Bullets/%s.png";
const SOUND_MIN_DELAY : float = 0;
const SOUND_MAX_DELAY : float = 1.8;

var direction : Vector2;
var speed : float;
var bullet_data : BulletData;
var sfx_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var sprite : Sprite2D = Sprite2D.new();

func init(direction_ : Vector2):
	add_child(sfx_player);
	sfx_player.finished.connect(queue_free);
	add_child(sprite);
	speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	direction = direction_;
	rotation_degrees = direction.angle() * 180 / PI;
	set_sprite();
	set_sound();

func _process(delta: float) -> void:
	position += direction * delta * speed * System.game_speed;

func set_data(data : BulletData) -> void:
	bullet_data = data;

func set_sprite() -> void:
	var texture : Resource = load(BULLET_ART_PATH % bullet_data.art_name);
	sprite.rotation_degrees = 180;
	sprite.texture = texture;

func set_sound() -> void:
	var sound : Resource = load(BULLET_SOUND_PATH % bullet_data.sound_name);
	sfx_player.stream = sound;
	await randf_range(SOUND_MIN_DELAY, SOUND_MAX_DELAY);
	sfx_player.pitch_scale = System.game_speed;
	sfx_player.play();
