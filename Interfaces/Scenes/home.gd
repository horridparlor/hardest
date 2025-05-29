extends Node2D
class_name Home

const GAMEPLAY_PATH : String = "res://Prefabs/Scenes/gameplay.tscn";

const SAVE_FILE_NAME : String = "save";
const MAX_BASE_ROTATION : float = 7.2;
const BASE_ROTATION_EDGE : float = 4.3;
const BASE_RATION_SPEED : float = 2.4;
const BASE_ROTATION_ERROR : float = 0.01;
const ZOOM_WAIT : float = 0.8;
const ZOOM_MIN_IN_SPEED : float = 2.9;
const ZOOM_MAX_IN_SPEED : float = 3.5;
const ZOOM_MIN_OUT_SPEED : float = 4.8;
const ZOOM_MAX_OUT_SPEED : float = 5.6;
const MIN_ZOOM_SPEED : float = 0.1;
const MIN_ZOOM_MULTIPLIER : float = 1.5;
const MAX_ZOOM_MULTIPLIER : float = 2.4;
const CAMERA_MOVE_SPEED : float = 0.9;
const MIN_CARD_SPAWN_WAIT : float = 0.1;
const MAX_CARD_SPAWN_WAIT : float = 3.0;
const BACKGROUND_CARDS_SCALE : float = 0.96;

const SLOWING_IN_MIN_SPEED : float = 4.1 * Config.GAME_SPEED;
const SLOWING_IN_MAX_SPEED : float = 5.2 * Config.GAME_SPEED;
const SLOWING_OUT_MIN_SPEED : float = 2.2 * Config.GAME_SPEED;
const SLOWING_OUT_MAX_SPEED : float = 3.2 * Config.GAME_SPEED;
const SLOW_GAME_SPEED : float = 0.1;
const SLOW_DOWN_MIN_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const SLOW_DOWN_MAX_WAIT : float = 0.8 * Config.GAME_SPEED_MULTIPLIER;
const MIN_ZOOM_TO_NODE_MULTIPLIER : float = 3.9;
const MAX_ZOOM_TO_NODE_MULTIPLIER : float = 6.7;
const QUICK_ZOOM_MULTIPLIER : float = 0.4;
const AUDIO_SPEED_BACK_GLITCH_CHANCE : int = 3;

var gameplay : Gameplay;
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
var is_slowing : bool;
var zoomed_node : Node2D;
var slowing_speed : float;
var slow_down_timer : Timer = Timer.new();
var is_speeding : bool;
var background_music : AudioStreamPlayer2D = AudioStreamPlayer2D.new();
var zoom_to_node_multiplier : float;
var is_quick_zooming : bool;
var pitch_locked : bool;
var zoomed_in_scale : Vector2;
var cached_game_speed : float = Config.MUSIC_NIGHTCORE_PITCH;
var prev_song_position : float;
var prev_song : int;
var is_song_locked : bool;
var old_gameplay : Gameplay;
var in_roguelike_mode : bool;
var has_game_ended : bool;
var card_spawn_timer : Timer = Timer.new();
var background_cards : Array;
var nexus : Nexus;

func _ready() -> void:
	for node in [
		camera,
		zoom_timer,
		slow_down_timer,
		background_music,
		card_spawn_timer
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
	slow_down_timer.timeout.connect(_on_speed_back_up);
	card_spawn_timer.timeout.connect(spawn_a_background_card);

func spawn_a_background_card() -> void:
	pass;

func init() -> void:
	pass;

func zoom_in(point : Vector2 = System.Vectors.default(), is_quick : bool = false) -> void:
	var zoom_multiplier : float = System.random.randf_range(MIN_ZOOM_MULTIPLIER, MAX_ZOOM_MULTIPLIER);
	zoom_timer.stop();
	slow_down_timer.stop();
	is_quick_zooming = is_quick;
	zoomed_in_scale = Vector2(zoom_multiplier, zoom_multiplier);
	goal_zoom = zoomed_in_scale;
	zoom_speed = System.random.randf_range(ZOOM_MIN_IN_SPEED, ZOOM_MAX_IN_SPEED) * (QUICK_ZOOM_MULTIPLIER if is_quick_zooming else 1);
	zoom_position = point * (System.Vectors.default_scale() / zoomed_in_scale);
	is_zooming = true;
	is_moving_camera = true;
	zoom_timer.wait_time = ZOOM_WAIT * System.game_speed_multiplier * (QUICK_ZOOM_MULTIPLIER if is_quick_zooming else 1);
	zoom_timer.start();

func reset_camera() -> void:
	camera.zoom = System.Vectors.default_scale();
	camera.position = System.Vectors.default();

func _on_zoom_out() -> void:
	zoom_timer.stop();
	goal_zoom = System.Vectors.default_scale();
	zoom_speed = System.random.randf_range(ZOOM_MIN_OUT_SPEED, ZOOM_MAX_OUT_SPEED) * (QUICK_ZOOM_MULTIPLIER if is_quick_zooming else 1);
	zoom_position = System.Vectors.default();
	if !gameplay or (gameplay and (has_game_ended or gameplay.is_preloaded)):
		open_gameplay();
		return;
	is_zooming = true;
	is_moving_camera = true;

func load_music(pitch : float = cached_game_speed) -> void:
	var song : Resource = System.Data.load_song(save_data.current_song);
	background_music.stream = song;
	if Config.MUTE_MUSIC:
		return;
	background_music.pitch_scale = pitch * System.game_speed;
	background_music.play();
	background_music.volume_db = Config.VOLUME + Config.MUSIC_VOLUME;

func _on_quick_zoom_to(position : Vector2) -> void:
	if is_zooming or !zoom_timer.is_stopped() or is_slowing:
		return;
	zoom_in(1 / QUICK_ZOOM_MULTIPLIER * position, true);

func zoom_frame(delta : float) -> void:
	if is_zooming:
		zoom_camera(delta);
	if is_moving_camera:
		move_camera(delta);
	if is_slowing:
		slowing_frame(delta);
	
func slowing_frame(delta : float):
	var goal_speed : float = 1 if is_speeding else SLOW_GAME_SPEED;
	set_game_speed(max(Config.MIN_GAME_SPEED, System.Scale.baseline(System.game_speed, goal_speed, delta * slowing_speed)), !pitch_locked);
	if System.Scale.equal(System.game_speed, goal_speed):
		set_game_speed(goal_speed);
		is_slowing = false;

func set_game_speed(new_speed : float, update_music_pitch : bool = true):
	System.game_speed = new_speed;
	System.game_speed_multiplier = 1 / new_speed;
	if update_music_pitch:
		background_music.pitch_scale = max(Config.MIN_PITCH, System.game_speed * cached_game_speed);

func open_gameplay(level_data_ : LevelData = level_data) -> void:
	pass;

func move_camera(delta : float) -> void:
	var zoomed_node_exists : bool = System.Instance.exists(zoomed_node);
	if zoomed_node_exists:
		zoom_position = zoom_to_node_multiplier * zoomed_node.position;
	camera.position = System.Vectors.slide_towards(camera.position, zoom_position, zoom_speed * delta * CAMERA_MOVE_SPEED);
	if System.Vectors.equal(camera.position, zoom_position) and !zoomed_node_exists:
		camera.position = zoom_position;
		is_moving_camera = false;

func zoom_camera(delta : float) -> void:
	camera.zoom = System.Vectors.slide_towards(camera.zoom, goal_zoom, zoom_speed * delta, MIN_ZOOM_SPEED);
	if System.Vectors.equal(camera.zoom, goal_zoom):
		camera.zoom = goal_zoom;
		is_zooming = false;
		is_quick_zooming = false;

func _on_zoom_to(node : Node2D, do_slow_down : bool = false) -> void:
	if is_slowing or System.Instance.exists(zoomed_node) or is_zooming:
		return;
	zoomed_node = node;
	zoom_in(node.position);
	if do_slow_down:
		slow_game();

func slow_game() -> void:
	slowing_speed = System.random.randf_range(SLOWING_IN_MIN_SPEED, SLOWING_IN_MAX_SPEED);
	slow_down_timer.wait_time = System.random.randf_range(SLOW_DOWN_MIN_WAIT, SLOW_DOWN_MAX_WAIT);
	slow_down_timer.start();
	is_speeding = false;
	is_slowing = true;
	zoom_to_node_multiplier = System.random.randf_range(MIN_ZOOM_TO_NODE_MULTIPLIER, MAX_ZOOM_TO_NODE_MULTIPLIER);
	pitch_locked = false;

func _on_speed_back_up() -> void:
	slow_down_timer.stop();
	is_slowing = true;
	is_speeding = true;
	slowing_speed = System.random.randf_range(SLOWING_OUT_MIN_SPEED, SLOWING_OUT_MAX_SPEED);
	zoomed_node = null;
	_on_zoom_out();
	if System.Random.chance(AUDIO_SPEED_BACK_GLITCH_CHANCE):
		if cached_game_speed == 1:
			cached_game_speed = Config.MUSIC_NIGHTCORE_PITCH;
		else:
			cached_game_speed = 1;
	else:
		pitch_locked = true;
		background_music.pitch_scale = cached_game_speed;

func base_rotation_frame(delta : float) -> void:
	var direction : float = base_rotation_direction * \
		(base_rotation_left_speed_error \
		if base_rotation_direction == -1 \
		else base_rotation_right_speed_error);
	var threshold : float = MAX_BASE_ROTATION * \
		(base_rotation_left_speed_error \
		if min_base_rotation_error == -1 \
		else max_base_rotation_error);
	System.base_rotation += direction * BASE_RATION_SPEED * delta * System.game_speed;
	if abs(System.base_rotation) >= threshold:
		base_rotation_direction *= -1;
		System.base_rotation += base_rotation_direction * BASE_RATION_SPEED * delta * System.game_speed;
	base_rotation_left_speed_error += System.Random.direction() * BASE_ROTATION_ERROR * delta;
	base_rotation_right_speed_error += System.Random.direction() * BASE_ROTATION_ERROR * delta;
	min_base_rotation_error += System.Random.direction() * BASE_ROTATION_ERROR * delta;
	min_base_rotation_error = max(-BASE_ROTATION_EDGE, min_base_rotation_error);
	max_base_rotation_error += System.Random.direction() * BASE_ROTATION_ERROR * delta;
	max_base_rotation_error = min(BASE_ROTATION_EDGE, max_base_rotation_error);

func instance_background_card(parent : Node) -> GameplayCard:
	var card : GameplayCard = System.Instance.load_child(System.Paths.CARD, parent);
	card.card_data = System.Data.load_card(System.random.randi_range(1, Config.MAX_CARD_ID));
	card.position = Vector2(System.Random.x(), -System.Window_.y / 2 - GameplayCard.SIZE.y / 2);
	card.init();
	card.flow_down();
	return card;
