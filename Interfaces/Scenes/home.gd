extends Node2D
class_name Home

const GAMEPLAY_PATH : String = "res://Prefabs/Scenes/gameplay.tscn";
const NEXUS_PATH : String = "res://Prefabs/Scenes/nexus.tscn";
const SAVE_FILE_NAME : String = "save";
const MAX_BASE_ROTATION : float = 5;
const BASE_RATION_SPEED : float = 2.4;
const BASE_ROTATION_ERROR : float = 0.01;
const ZOOM_WAIT : float = 1.1;
const ZOOM_MIN_IN_SPEED : float = 2.9;
const ZOOM_MAX_IN_SPEED : float = 3.5;
const ZOOM_MIN_OUT_SPEED : float = 4.8;
const ZOOM_MAX_OUT_SPEED : float = 5.6;
const MIN_ZOOM_SPEED : float = 0.1;
const ZOOM_MULTIPLIER : float = 1.6;
const ZOOMED_IN_SCALE : Vector2 = Vector2(ZOOM_MULTIPLIER, ZOOM_MULTIPLIER);
const CAMERA_MOVE_SPEED : float = 0.9;

var gameplay : Gameplay;
var nexus : Nexus;
var save_data : SaveData;
var level_data : LevelData;
var base_rotation_direction : int = System.Random.direction();
var base_rotation_right_speed_error : float = 1;
var base_rotation_left_speed_error : float = 1;
var min_base_rotation_error : float = 1;
var max_base_rotation_error : float = 1;
var camera : Camera2D = Camera2D.new();
var zoom_timer : Timer = Timer.new();
var goal_zoom : Vector2 = System.Vectors.default_scale();
var is_zooming : bool;
var zoom_speed : float;
var zoom_position : Vector2;
var is_moving_camera : bool;

func _ready() -> void:
	for node in [
		camera,
		zoom_timer
	]:
		add_child(node);
	System.random.randomize();
	System.create_directories();
	DisplayServer.window_set_current_screen(System.Display);
	set_process_input(true);
	save_data = System.Data.load_save_data();
	init_timers();
	init();

func init_timers() -> void:
	zoom_timer.timeout.connect(_on_zoom_out);

func init() -> void:
	pass;

func zoom_in(point : Vector2 = System.Vectors.default()) -> void:
	goal_zoom = ZOOMED_IN_SCALE;
	zoom_speed = System.random.randf_range(ZOOM_MIN_IN_SPEED, ZOOM_MAX_IN_SPEED);
	zoom_position = point * (System.Vectors.default_scale() / ZOOMED_IN_SCALE);
	is_zooming = true;
	is_moving_camera = true;
	zoom_timer.wait_time = ZOOM_WAIT * System.game_speed_multiplier;
	zoom_timer.start();

func reset_camera() -> void:
	camera.zoom = System.Vectors.default_scale();
	camera.position = System.Vectors.default();

func _on_zoom_out() -> void:
	zoom_timer.stop();
	goal_zoom = System.Vectors.default_scale();
	zoom_speed = System.random.randf_range(ZOOM_MIN_OUT_SPEED, ZOOM_MAX_OUT_SPEED);
	zoom_position = System.Vectors.default();
	if nexus:
		if !level_data.is_locked:
			open_gameplay();
			return;
		else:
			nexus.toggle_active();
	is_zooming = true;
	is_moving_camera = true;

func zoom_frame(delta : float) -> void:
	if is_zooming:
		zoom_camera(delta);
	if is_moving_camera:
		move_camera(delta);

func open_gameplay(level_data_ : LevelData = level_data) -> void:
	pass;

func move_camera(delta : float) -> void:
	camera.position = System.Vectors.slide_towards(camera.position, zoom_position, zoom_speed * delta * CAMERA_MOVE_SPEED);
	if System.Vectors.equal(camera.position, zoom_position):
		camera.position = zoom_position;
		is_moving_camera = false;

func zoom_camera(delta : float) -> void:
	camera.zoom = System.Vectors.slide_towards(camera.zoom, goal_zoom, zoom_speed * delta, MIN_ZOOM_SPEED);
	if System.Vectors.equal(camera.zoom, goal_zoom):
		camera.zoom = goal_zoom;
		is_zooming = false;
