extends Node2D
class_name SplashParticle

const MIN_DIRECTION : int = 40;
const MAX_DIRECTION : int = 160;
const MIN_SPEED : int = 10;
const MAX_SPEED : int = 20;
const SIZE : Vector2 = Vector2(256, 256);
const MIN_WIND : int = 60;
const MAX_WIND : int = 210;
const MIN_SCALE : float = 0.8;
const MAX_SCALE : float = 1.8;
const SIZE_INCREASE_MIN_SPEED : float = 0.1;
const SIZE_INCREASE_MAX_SPEED : float = 0.25;
const BASE_BOUNCE_CHANCE : int = 2;
const MAX_BOUNCES : int = 3;

var direction : Vector2;
var speed : float;
var wind : Vector2;
var size_increase_speed : float;
var times_bounced : int;

func _ready() -> void:
	move();

func move() -> void:
	direction = System.Random.vector(MIN_DIRECTION, MAX_DIRECTION);
	speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	wind = System.Random.vector(MIN_WIND, MAX_WIND);
	scale *= System.random.randf_range(MIN_SCALE, 1);
	rotation = direction.angle();
	size_increase_speed = System.random.randf_range(SIZE_INCREASE_MIN_SPEED, SIZE_INCREASE_MAX_SPEED);

func _process(delta : float) -> void:
	position += speed * direction * delta;
	direction += delta * wind;
	rotation = direction.angle();
	if scale.x < MAX_SCALE:
		scale *= 1 + size_increase_speed * delta;
		if scale.x > MAX_SCALE:
			scale = Vector2(MAX_SCALE, MAX_SCALE);
	if !System.Vectors.is_inside_window(position, scale.x * SIZE):
		if times_bounced < MAX_BOUNCES and System.Random.chance(BASE_BOUNCE_CHANCE + times_bounced):
			times_bounced += 1;
			direction *= -1;
			wind *= -1;
		else:
			queue_free();

func make_negative() -> void:
	pass;
