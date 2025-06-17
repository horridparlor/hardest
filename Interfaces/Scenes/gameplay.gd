extends Node2D
class_name Gameplay

signal game_over
signal zoom_to(node, do_slow_down)
signal quick_zoom_to(position)
signal play_song(song_id)
signal stop_music
signal stop_music_if_special
signal play_prev_song

enum AnimationType {
	NULL,
	OCEAN,
	POSITIVE
}

const AnimationWaitTime : Dictionary = {
	AnimationType.OCEAN: 4.0 * Config.GAME_SPEED_MULTIPLIER,
	AnimationType.POSITIVE: 4.0 * Config.GAME_SPEED_MULTIPLIER
}

const HAND_POSITION : Vector2 = Vector2(0, 760);
const HAND_MARGIN : int = 200;
const CARD_STARTING_POSITION : Vector2 = Vector2(0, System.Window_.y + GameplayCard.SIZE.y)
const FIELD_LINES_FADE_IN_SPEED : float = 0.4;
const FIELD_LINES_FADE_OUT_SPEED : float = 1.2;
const FIELD_START_LINE : int = -100;
const FIELD_END_LINE : int = 445;
const FIELD_POSITION : Vector2 = Vector2(0, FIELD_START_LINE + (FIELD_END_LINE - FIELD_START_LINE) / 2);
const ENEMY_FIELD_POSITION : Vector2 = Vector2(0, 2 * FIELD_START_LINE);
const VISIT_POSITION : Vector2 = Vector2(-350, 350);
const DEATH_PANEL_SIZE : Vector2 = Vector2(200, 100);
const DYING_SPEED : float = 1.2;
const UNDYING_SPEED : float = 4.8;
const HAND_FITS_CARDS : float = 4.72;

const ROUND_RESULTS_WAIT : float = 0.3 * Config.GAME_SPEED_MULTIPLIER;
const PRE_RESULTS_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const ROUND_END_WAIT : float = 0.6 * Config.GAME_SPEED_MULTIPLIER;
const GAME_OVER_WAIT : float = 1.3 * Config.GAME_SPEED_MULTIPLIER;
const POINTS_CLICK_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const CARD_FOCUS_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const OPPONENTS_PLAY_WAIT : float = 1.2 * Config.GAME_SPEED_MULTIPLIER;
const OPPONENT_TO_PLAY_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const YOU_TO_PLAY_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const SPY_WAIT_TIME : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const AUTO_PLAY_MIN_WAIT : float = 0.3 * Config.GAME_SPEED_MULTIPLIER;
const AUTO_PLAY_MAX_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const GULP_WAIT : float = 0.35 * Config.GAME_SPEED_MULTIPLIER;
const NUT_WAIT_MULTIPLIER : float = 1.6;
const VICTORY_POPPET_SPEED : float = 0.26;
const MIN_VICTORY_POPPETS : int = 50;
const MAX_VICTORY_POPPETS : int = 100;
const MAX_CARD_POPPETS : int = 40;
const POPPETS_RANDOM_ADDITION : int = 10;

const TROLL_MIN_WAIT : float = 0.8 * Config.GAME_SPEED_MULTIPLIER;
const TROLL_MAX_WAIT : float = 1.2 * Config.GAME_SPEED_MULTIPLIER;
const TROLL_MIN_MOVE : float = 100;
const TROLL_MAX_MOVE : float = 500;
const TROLL_CHANCE : int = 5;
const CHANCE_TO_FLICKER_HAND : int = 3;
const FLICKER_SPEED_UP : float = 2/3;
const YOUR_POINTS_ZOOM_CHANCE : int = 3;
const OPPONENTS_POINTS_ZOOM_CHANCE : int = 4;
const MIN_TIME_STOP_PITCH : float = 1.2;
const MAX_TIME_STOP_PITCH : float = 1.5;

const YOUR_POINT_SOUND_PATH : String = "res://Assets/SFX/Points/your-point.wav";
const OPPONENTS_POINT_SOUND_PATH : String = "res://Assets/SFX/Points/opponents-point.wav";
const TIE_SOUND_PATH : String = "res://Assets/SFX/Points/tie.wav";
const ACTIVE_CHARACTER_VISIBILITY : float = 1.0;
const INACTIVE_CHARACTER_VISIBILITY : float = 0.4;
const LEVEL_THEME_PATH : String = "res://Assets/Music/%s.mp3";
const LEVEL_BACKGROUND_PATH : String = "res://Assets/Art/Patterns/%s.png";
const POINTS_FADE_IN_SPEED : float = 0.4 * Config.GAME_SPEED;
const POINTS_FADE_OUT_SPEED : float = 1.2 * Config.GAME_SPEED;
const SHADOW_FADE_IN_SPEED : float = 0.6 * Config.GAME_SPEED;
const SHADOW_FADE_OUT_SPEED : float = 0.8 * Config.GAME_SPEED;
const CHARACTER_FULL_ART_PATH : String = "res://Assets/Art/CharacterFull/%s.png";
const OPPONENT_POINT_PATTERN_PATH : String = "res://Assets/Art/OpponentPointPatterns/%s.png";

const LED_STARTING_POSITION : Vector2 = Vector2(-480, -560);
const LEDS_PER_COLUMN : int = 19;
const LED_MARGIN : Vector2 = Vector2(60, 112);
const LED_WAIT : float = 0.2;
const LED_BURSTS : int = LEDS_PER_COLUMN / 3;
const YOUR_LED_COLOR : Led.LedColor = Led.LedColor.BLUE;
const OPPONENTS_LED_COLOR : Led.LedColor = Led.LedColor.RED;
const IDLE_LED_COLOR : Led.LedColor = Led.LedColor.WHITE;
const WARNING_LED_COLOR : Led.LedColor = Led.LedColor.YELLOW;
const OFF_LED_COLOR : Led.LedColor = Led.LedColor.OFF;
const YOUR_LED_DIRECTION : int = 1;
const OPPONENTS_LED_DIRECTION : int = -1;
const WARNING_LED_DIRECTION : int = 0;
const OFF_LED_DIRECTION : int = 0;
const FAST_LED_SPEED : int = 2;
const BACKGROUND_OPACITY : float = 0.6;
const DIE_BUTTON_ROTATION : float = 5.6;
const TITLE_ROTATION : float = 2.1;

const TIME_STOP_ACCELERATION_SPEED : float = 0.5 * Config.GAME_SPEED;
const TIME_STOP_LED_ACCELERATION : int = 12 * Config.GAME_SPEED;
const TIME_STOP_GAME_SPEED : float = 0.6 * Config.GAME_SPEED;
const MIN_STOPPED_TIME_SHOOTING_ROUND_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const MAX_STOPPED_TIME_SHOOTING_ROUND_WAIT : float = 0.3 * Config.GAME_SPEED_MULTIPLIER;
const MIN_STOPPED_TIME_WAIT : float = 0.09;
const MAX_STOPPED_TIME_WAIT : float = 0.18;
const OCEAN_POINTS_MIN_WAIT : float = 0.42 * Config.GAME_SPEED_MULTIPLIER;
const OCEAN_POINTS_MAX_WAIT : float = 0.76 * Config.GAME_SPEED_MULTIPLIER;
const WET_MIN_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const WET_MAX_WAIT : float = 0.67 * Config.GAME_SPEED_MULTIPLIER;
const HIGH_TIDE_MIN_SPEED : float = 0.08 * Config.GAME_SPEED;
const HIGH_TIDE_MAX_SPEED : float = 0.12 * Config.GAME_SPEED;
const LOW_TIDE_MIN_SPEED : float = 0.35 * Config.GAME_SPEED;
const LOW_TIDE_MAX_SPEED : float = 0.42 * Config.GAME_SPEED;
const OCEAN_PATTERN_MAX_OPACITY : float = 0.35;
const OCEAN_EFFECT_MIN_STARTING_WAVE_SPEED : float = 1.31;
const OCEAN_EFFECT_MAX_STARTING_WAVE_SPEED : float = 1.47;
const OCEAN_SPEED_EFFECT_MIN_EXPONENT : float = 12.3;
const OCEAN_SPEED_EFFECT_MAX_EXPONENT : float = 16.5;

const TIME_STOP_IN_GLITCH_MIN_SPEED : float = 5 * Config.GAME_SPEED;
const TIME_STOP_IN_GLITCH_MAX_SPEED : float = 7.8 * Config.GAME_SPEED;
const TIME_STOP_IN_BW_MIN_SPEED : float = 1.9 * Config.GAME_SPEED;
const TIME_STOP_IN_BW_MAX_SPEED : float = 3.8 * Config.GAME_SPEED;
const TIME_STOP_OUT_BW_MIN_SPEED : float = 0.3 * Config.GAME_SPEED;
const TIME_STOP_OUT_BW_MAX_SPEED : float = 0.9 * Config.GAME_SPEED;
const TIME_STOP_OUT_GLITCH_MIN_SPEED : float = 5 * Config.GAME_SPEED;
const TIME_STOP_OUT_GLITCH_MAX_SPEED : float = 8.9 * Config.GAME_SPEED;


var player_one : Player = Player.new();
var player_two : Player = Player.new();
var cards : Dictionary;
var active_card : GameplayCard;
var fading_field_lines : bool;
var field_lines_visible : bool;
var can_play_card : bool;
var going_first : bool;
var level_data : LevelData;
var round_winner : GameplayEnums.Controller;
var results_phase : int;
var points_goal_visibility : float;
var shadow_goal_visibility : float;
var is_updating_points_visibility : float;
var is_spying : bool;
var cards_to_spy : int;
var leds_left : Array;
var leds_right : Array;
var is_trolling : bool;
var led_index : int = LEDS_PER_COLUMN - 1;
var fast_led_index : int = led_index;
var led_direction : int;
var led_color : Led.LedColor = Led.LedColor.WHITE;
var started_playing : bool;
var did_win : bool;
var led_wait : float = LED_WAIT;
var round_number : int;
var time_stop_shader_time : float = 1;
var is_stopping_time : bool;
var is_accelerating_time : bool;
var time_stop_velocity : float;
var time_stop_goal_velocity : float;
var time_stop_goal_velocity2 : float;
var is_time_stopped : bool;
var active_player : Player;
var time_stop_nodes : Array;
var custom_time_stop_nodes : Dictionary;
var time_stop_nodes2 : Array;
var time_stopping_player : Player;
var time_stopped_bullets : Array;
var has_been_stopping_turn : bool;
var has_game_ended : bool;
var is_preloaded : bool;
var nut_combo : int;
var death_progress : float;
var is_dying : bool;
var is_undying : bool;
var poppets : Dictionary;
var is_wet_wait_on : bool;
var high_tide_speed : float;
var is_low_tiding : bool;
var low_tide_speed : float;
var ocean_card : GameplayCard;
var opponents_field_card : GameplayCard;
var sfx_play_id : int;
var ocean_effect_wave_speed : float;
var ocean_effect_speed_exponent : float;
var is_waiting_for_animation_to_finnish : bool;
var animation_instance_id : int;
var animations : Dictionary;
var current_animation_type : AnimationType = AnimationType.NULL;
var has_ocean_wet_self : bool;

func init(level_data_ : LevelData, do_start : bool = true) -> void:
	pass;

func death_frame(delta : float):
	death_progress += delta * DYING_SPEED;
	update_death_progress_panel(false);
	if death_progress >= 1:
		death_progress = 0;
		is_dying = false;
		_on_die();
		
func _on_die() -> void:
	if is_preloaded:
		return;
	start_game_over();
	is_undying = true;

func undying_frame(delta : float):
	death_progress -= delta * UNDYING_SPEED;
	update_death_progress_panel();
	if death_progress <= 0:
		death_progress = 0;
		is_undying = false;

func start_game_over() -> void:
	pass;
	
func update_death_progress_panel(was_full : bool = true) -> void:
	pass;
