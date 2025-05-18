extends Node2D
class_name Tongue

const SIZE : Vector2 = Vector2(100, 10);
const STRETCH_SPEED : float = 3.7 * Config.GAME_SPEED;

var base_node : Node2D;
var extend_node : Node2D;
var rect : ColorRect = ColorRect.new();
var is_active : bool;

func _ready() -> void:
	var shader : Resource = load("res://Shaders/CardEffects/tongue-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	add_child(rect);
	rect.size = SIZE;
	rect.material = shader_material;

func form(base_node_ : Node2D, extend_node_ : Node2D) -> void:
	base_node = base_node_;
	extend_node = extend_node_;
	is_active = true;

func _process(delta: float) -> void:
	if !is_active:
		return;
	if !System.Instance.exists(base_node) or !System.Instance.exists(extend_node) or base_node.position.distance_to(extend_node.position) < GameplayCard.SIZE.y / 2:
		queue_free();
		return;
	rect.position = base_node.position - SIZE / 2 - Vector2(0, GameplayCard.SIZE.y / 2);
	rect.rotation_degrees = base_node.get_angle_to(extend_node.position);
	if extend_node.position.y > base_node.position.y:
		rect.position.y += GameplayCard.SIZE.y;
	else:
		rect.rotation_degrees -= 180;
		rect.position += SIZE;
	grow_tongue(delta);

func grow_tongue(delta : float) -> void:
	rect.size.y += base_node.position.distance_to(extend_node.position) * STRETCH_SPEED * delta * System.game_speed;
	rect.size.y = min(rect.size.y, base_node.position.distance_to(extend_node.position) - GameplayCard.SIZE.y / 2);
