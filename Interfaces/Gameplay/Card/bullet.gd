extends Node2D
class_name Bullet

const MIN_SPEED : int = 10;
const MAX_SPEED : int = 25;
const SIZE : Vector2 = Vector2(80, 160);

var direction : Vector2;
var speed : float;

func init(direction_ : Vector2):
	speed = System.random.randf_range(MIN_SPEED, MAX_SPEED);
	direction = direction_;
	rotation_degrees = direction.angle() * 180 / PI;

func _process(delta: float) -> void:
	position += direction * delta * speed;
	if !System.Vectors.is_inside_window(position, SIZE):
		queue_free();
