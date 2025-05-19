extends NexusPageToggleArrow

@onready var sprite2 : Sprite2D = $Sprite2D2;

const GOAL_POSITION : Vector2 = Vector2(0, 100);
const MIN_VELOCITY : float = 0.4;
const MAX_VELOCITY : float = 1.78;
const ANIMATION_OPACITY : float = 0.9;
const MIN_SPEED : float = 2;
const SPAWN_MIN_SCALE : float = 0.87;
const SPAWN_MAX_SCALE : float = 1.12;

var velocity : float;
var random : RandomNumberGenerator = RandomNumberGenerator.new();

func _ready() -> void:
	sprite2.modulate.a = ANIMATION_OPACITY;
	random.seed = System.random.seed;
	randomize_arrow2_scale();

func randomize_arrow2_scale() -> void:
	var scale : float = random.randf_range(SPAWN_MIN_SCALE, SPAWN_MAX_SCALE);
	sprite2.scale = Vector2(scale, scale);
	velocity = random.randf_range(MIN_VELOCITY, MAX_VELOCITY);

func _process(delta : float) -> void:
	var goal_position : Vector2 = System.Vectors.default() + GOAL_POSITION;
	sprite2.position = System.Vectors.slide_towards(sprite2.position, goal_position, velocity * delta, MIN_SPEED);
	sprite2.modulate.a = sprite2.position.distance_to(goal_position) / System.Vectors.default().distance_to(goal_position) * ANIMATION_OPACITY;
	if System.Vectors.equal(sprite2.position, goal_position):
		sprite2.position = System.Vectors.default();
		sprite2.modulate.a = ANIMATION_OPACITY;
		randomize_arrow2_scale();

func _on_touch_screen_button_triggered() -> void:
	emit_signal("triggered");
