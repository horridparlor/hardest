extends Node2D
class_name Gameplay

signal game_over

const CARD_PATH : String = "res://Prefabs/Gameplay/Card/card.tscn";
const HAND_POSITION : Vector2 = Vector2(0, 760);
const HAND_MARGIN : int = 200;
const CARD_STARTING_POSITION : Vector2 = Vector2(0, System.Window_.y + GameplayCard.SIZE.y)
const FIELD_LINES_FADE_IN_SPEED : float = 0.4;
const FIELD_LINES_FADE_OUT_SPEED : float = 1.2;
const FIELD_START_LINE : int = -115;
const FIELD_END_LINE : int = 405;
const FIELD_POSITION : Vector2 = Vector2(0, FIELD_START_LINE + (FIELD_END_LINE - FIELD_START_LINE) / 2);
const ENEMY_FIELD_POSITION : Vector2 = Vector2(0, 3 * FIELD_START_LINE);

const ROUND_RESULTS_WAIT : float = 0.3;
const PRE_RESULTS_WAIT : float = 0.4;
const ROUND_END_WAIT : float = 0.8;
const GAME_OVER_WAIT : float = 1.2;
const POINTS_CLICK_WAIT : float = 0.2;
const CARD_FOCUS_WAIT : float = 0.2;
const OPPONENTS_PLAY_WAIT : float = 1.2
const OPPONENT_TO_PLAY_WAIT : float = 0.2;

const YOUR_POINT_SOUND_PATH : String = "res://Assets/SFX/Points/your-point.wav";
const OPPONENTS_POINT_SOUND_PATH : String = "res://Assets/SFX/Points/opponents-point.wav";
const TIE_SOUND_PATH : String = "res://Assets/SFX/Points/tie.wav";
const KEYWORD_HINT_LINE : String = "[b][i]%s[/i][/b] [i]–[/i] %s\n";
const ACTIVE_CHARACTER_VISIBILITY : float = 1.0;
const INACTIVE_CHARACTER_VISIBILITY : float = 0.4;
const LEVEL_THEME_PATH : String = "res://Assets/Music/%s.mp3";
const LEVEL_BACKGROUND_PATH : String = "res://Assets/Art/Patterns/%s.png";
const POINTS_FADE_IN_SPEED : float = 0.4;
const POINTS_FADE_OUT_SPEED : float = 1.2;
const SHADOW_FADE_IN_SPEED : float = 0.6;
const SHADOW_FADE_OUT_SPEED : float = 0.8;

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

func init(level_data_ : LevelData) -> void:
	pass;
