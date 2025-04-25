extends Node2D
class_name Gameplay

signal game_over

const CARD_PATH : String = "res://Prefabs/Gameplay/Card/card.tscn";
const HAND_POSITION : Vector2 = Vector2(0, 760);
const HAND_MARGIN : int = 200;
const CARD_STARTING_POSITION : Vector2 = Vector2(0, System.Window_.y + GameplayCard.SIZE.y)
const FIELD_LINES_FADE_IN_SPEED : float = 0.6;
const FIELD_LINES_FADE_OUT_SPEED : float = 1.2;
const FIELD_START_LINE : int = -115;
const FIELD_END_LINE : int = 405;
const FIELD_POSITION : Vector2 = Vector2(0, FIELD_START_LINE + (FIELD_END_LINE - FIELD_START_LINE) / 2);
const ENEMY_FIELD_POSITION : Vector2 = Vector2(0, 3 * FIELD_START_LINE);
const ROUND_RESULTS_WAIT : float = 0.4;
const ROUND_END_WAIT : float = 0.8;
const GAME_OVER_WAIT : float = 1.2;
const POINTS_CLICK_WAIT : float = 0.2;

var player_one : Player = Player.new();
var player_two : Player = Player.new();
var cards : Dictionary;
var active_card : GameplayCard;
var fading_field_lines : bool;
var field_lines_visible : bool;
var can_play_card : bool;
var going_first : bool;
