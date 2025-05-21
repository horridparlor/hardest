extends Node2D
class_name Gameplay

signal game_over(did_win)
signal zoom_to(node, do_slow_down)
signal quick_zoom_to(position)
signal play_song(song_id)
signal stop_music
signal stop_music_if_special
signal play_prev_song

const HAND_POSITION : Vector2 = Vector2(0, 760);
const HAND_MARGIN : int = 200;
const CARD_STARTING_POSITION : Vector2 = Vector2(0, System.Window_.y + GameplayCard.SIZE.y)
const FIELD_LINES_FADE_IN_SPEED : float = 0.4;
const FIELD_LINES_FADE_OUT_SPEED : float = 1.2;
const FIELD_START_LINE : int = -115;
const FIELD_END_LINE : int = 445;
const FIELD_POSITION : Vector2 = Vector2(0, FIELD_START_LINE + (FIELD_END_LINE - FIELD_START_LINE) / 2);
const ENEMY_FIELD_POSITION : Vector2 = Vector2(0, 2 * FIELD_START_LINE);
const VISIT_POSITION : Vector2 = Vector2(-350, 350);

const ROUND_RESULTS_WAIT : float = 0.3 * Config.GAME_SPEED_MULTIPLIER;
const PRE_RESULTS_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const ROUND_END_WAIT : float = 0.8 * Config.GAME_SPEED_MULTIPLIER;
const GAME_OVER_WAIT : float = 2 * Config.GAME_SPEED_MULTIPLIER;
const POINTS_CLICK_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const CARD_FOCUS_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const OPPONENTS_PLAY_WAIT : float = 1.2 * Config.GAME_SPEED_MULTIPLIER;
const OPPONENT_TO_PLAY_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const YOU_TO_PLAY_WAIT : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const SPY_WAIT_TIME : float = 0.2 * Config.GAME_SPEED_MULTIPLIER;
const AUTO_PLAY_MIN_WAIT : float = 0.3 * Config.GAME_SPEED_MULTIPLIER;
const AUTO_PLAY_MAX_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const GULP_WAIT : float = 0.35 * Config.GAME_SPEED_MULTIPLIER;

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

const LED_STARTING_POSITION : Vector2 = Vector2(-480, -720);
const LEDS_PER_COLUMN : int = 19;
const LED_MARGIN : Vector2 = Vector2(60, 120);
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

const TIME_STOP_ACCELERATION_SPEED : float = 0.5;
const TIME_STOP_LED_ACCELERATION : int = 12;
const TIME_STOP_GAME_SPEED : float = 0.6;
const MIN_STOPPED_TIME_SHOOTING_ROUND_WAIT : float = 0.2;
const MAX_STOPPED_TIME_SHOOTING_ROUND_WAIT : float = 0.3;
const MIN_STOPPED_TIME_WAIT : float = 0.09;
const MAX_STOPPED_TIME_WAIT : float = 0.18;

const TIME_STOP_IN_GLITCH_MIN_SPEED : float = 5;
const TIME_STOP_IN_GLITCH_MAX_SPEED : float = 7.8;
const TIME_STOP_IN_BW_MIN_SPEED : float = 1.9;
const TIME_STOP_IN_BW_MAX_SPEED : float = 3.8;
const TIME_STOP_OUT_BW_MIN_SPEED : float = 0.3;
const TIME_STOP_OUT_BW_MAX_SPEED : float = 0.9;
const TIME_STOP_OUT_GLITCH_MIN_SPEED : float = 5;
const TIME_STOP_OUT_GLITCH_MAX_SPEED : float = 8.9;


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
var time_stop_nodes2 : Array;
var time_stopping_player : Player;
var time_stopped_bullets : Array;
var has_been_stopping_turn : bool;

func init(level_data_ : LevelData) -> void:
	pass;
