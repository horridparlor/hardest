extends Node2D
class_name RoguelikePage

signal death
signal enter_level(level_data)
signal save

const MIN_IN_VELOCITY : float = 3.2 * Config.GAME_SPEED;
const MAX_IN_VELOCITY : float = 3.8 * Config.GAME_SPEED;
const MIN_OUT_VELOCITY : float = 1800 * Config.GAME_SPEED;
const MAX_OUT_VELOCITY : float = 2600 * Config.GAME_SPEED;
const SIZE : Vector2 = Vector2(740, 1250);
const PROGRESS_PANEL_SIZE : Vector2 = Vector2(680, 110);
const PROGRESS_PANEL_BORDER_WIDTH : int = 4;
const DEATH_MIN_SPEED : float = 0.7 * Config.GAME_SPEED;
const DEATH_MAX_SPEED : float = 0.9 * Config.GAME_SPEED;
const UNDEATH_MIN_SPEED : float = 2.9 * Config.GAME_SPEED;
const UNDEATH_MAX_SPEED : float = 3.5 * Config.GAME_SPEED;
const DEATH_PANEL_SIZE : Vector2 = Vector2(280, 110);
const LEVEL_BUTTON_STARTING_POSITION : Vector2 = Vector2(0, -40);
const BACKGROUND_OPACITY : float = 0.34;
const PROGRESS_BAR_PATTERN_OPACITY : float = 0.07;
const ROGUELIKE_DEATH_PATTERN_OPACITY : float = 0.21;
const PACK_BUTTON_PATTERN_OPACITY : float = 0.18;

const LEVEL_BUTTONS_MIN_REVEAL_SPEED : float = 1.6 * Config.GAME_SPEED;
const LEVEL_BUTTONS_MAX_REVEAL_SPEED : float = 2.1 * Config.GAME_SPEED;
const COLLECTING_MIN_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const COLLECTING_MAX_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const CHOICE_BUTTON_ROTATION : float = 2.3;
const CARD_X_MARGIN : int = 233;

var velocity : float
var is_rolling_in : bool;
var is_rolling_out : bool;
var origin_point : Vector2;
var data : RoguelikeData;
var is_dying : bool;
var death_progress : float;
var death_speed : float;
var is_undeathing : bool;
var is_active : bool;
var level_buttons : Array;
var cards : Array;
var focused_card : GameplayCard;
var is_revealing_level_buttons : bool;
var level_buttons_reveal_speed : float;
var has_picked : bool = false;

func init(roguelike_data : RoguelikeData):
	pass;

func roll_out() -> void:
	velocity = System.random.randf_range(MIN_OUT_VELOCITY, MAX_OUT_VELOCITY);
	is_rolling_in = false;
	is_rolling_out = true;

func roll_in() -> void:
	velocity = System.random.randf_range(MIN_IN_VELOCITY, MAX_IN_VELOCITY);
	is_rolling_out = false;
	is_rolling_in = true;

func _process(delta : float) -> void:
	death_progress_frame(delta);
	reveal_level_buttons_frame(delta);
	if is_rolling_in:
		position = System.Vectors.slide_towards(position, origin_point, velocity * delta);
		if System.Vectors.equal(position, origin_point):
			position = origin_point;
			is_rolling_in = false;
	if is_rolling_out:
		position.y += velocity * delta * System.game_speed;
		if !System.Vectors.is_inside_window(position, SIZE):
			is_rolling_out = false;
	if Config.AUTO_PLAY and is_active and !data.lost_heart and !has_picked and cards.size() > 2 and position.distance_to(origin_point) < 100:
		has_picked = true;
		await System.random.randf_range(0.1, 0.2);
		_on_focus_card(cards[System.random.randi_range(0, 2)]);
		await System.random.randf_range(0.1, 0.2);
		_on_pack_it_triggered();

func _on_pack_it_triggered() -> void:
	pass;

func _on_focus_card(card : GameplayCard) -> void:
	pass;

func reveal_level_buttons_frame(delta : float) -> void:
	pass;

func death_progress_frame(delta : float) -> void:
	pass;

func toggle_active(value : bool = true) -> void:
	is_active = value;

func set_origin_point() -> void:
	origin_point = position;
