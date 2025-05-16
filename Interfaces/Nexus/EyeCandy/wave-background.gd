extends Sprite2D
class_name WaveBackground

const MIN_STARTING_AMPLITUDE : float = 0.12 * Config.GAME_SPEED;
const MAX_STARTING_AMPLITUDE : float = 1.12 * Config.GAME_SPEED;
const MIN_STARTING_VELOCITY : float = 0.3 * Config.GAME_SPEED;
const MAX_STARTING_VELOCITY : float = 2.3 * Config.GAME_SPEED;
const AMPLITUDE_ERROR : float = 0.01 * Config.GAME_SPEED;
const VELOCITY_ERROR : float = 0.05 * Config.GAME_SPEED;
const DEFAULT_DISTORTION : float = 0.001 * Config.GAME_SPEED;
const DISTORTION_ERROR : float = 0.01 * Config.GAME_SPEED;

var amplitude : float = System.random.randf_range(MIN_STARTING_AMPLITUDE, MAX_STARTING_AMPLITUDE);
var velocity : float = System.random.randf_range(MIN_STARTING_VELOCITY, MAX_STARTING_VELOCITY);
var sin : float;
var distortion : float = DEFAULT_DISTORTION;

func _process(delta : float) -> void:
	panel_shader_frame(delta);

func panel_shader_frame(delta : float) -> void:
	sin += velocity * delta * System.game_speed;
	velocity += System.Random.direction() * VELOCITY_ERROR * delta * System.game_speed;
	material.set_shader_parameter("sin_wave", sin);
	amplitude += System.Random.direction() * AMPLITUDE_ERROR * delta * System.game_speed;
	material.set_shader_parameter("amplitude", amplitude);
	distortion += System.Random.direction() * DISTORTION_ERROR * delta * System.game_speed;
	material.set_shader_parameter("chaos_factor", distortion);
