extends Node

const Data : GDScript = preload("res://Scripts/System/data.gd");
const Dictionaries : GDScript = preload("res://Scripts/System/dictionaries.gd");
const Display : int = 2;
const Fighting : GDScript = preload("res://Scripts/System/fighting.gd");
const Floats : GDScript = preload("res://Scripts/System/floats.gd");
const Instance : GDScript = preload("res://Scripts/System/instance.gd");
const Json : GDScript = preload("res://Scripts/System/json.gd");
const Leds : GDScript = preload("res://Scripts/System/leds.gd");
const Levels : GDScript = preload("res://Scripts/System/levels.gd");
const Paths : GDScript = preload("res://Scripts/System/paths.gd");
const PreResults : GDScript = preload("res://Scripts/System/pre-results.gd");
const Random : GDScript = preload("res://Scripts/System/random.gd");
const Rules : GDScript = preload("res://Scripts/System/rules.gd");
const Scale : GDScript = preload("res://Scripts/System/scale.gd");
const Shaders : GDScript = preload("res://Scripts/System/shaders.gd");
const Vectors : GDScript = preload("res://Scripts/System/vectors.gd");
const Window_ : Vector2 = Vector2(1080, 1920);

var random : RandomNumberGenerator = RandomNumberGenerator.new();
var base_rotation : float = 0;
var game_speed : float = 1;
var game_speed_multiplier : float = 1 / game_speed;
var game_speed_additive_multiplier : float = min(1, game_speed_multiplier);
var running_instance_id : int;
var auto_play : bool = Config.AUTO_PLAY;

func update_game_speed(speed : float) -> void:
	game_speed = max(Config.MIN_PITCH, speed);
	game_speed_multiplier = 1 / game_speed;
	game_speed_additive_multiplier = min(1, game_speed_multiplier);

static func create_directories() -> void:
	Json.create_directory();

func wait(wait : float) -> void:
	var timer : Timer = Timer.new();
	timer.wait_time = wait * System.game_speed_multiplier;
	timer.one_shot = true;
	add_child(timer);
	timer.start();
	await timer.timeout;
	timer.queue_free();

func wait_range(min : float, max : float) -> void:
	await wait(System.random.randf_range(min, max));
