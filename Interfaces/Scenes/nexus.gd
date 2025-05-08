extends Node2D
class_name Nexus

signal enter_level(level_data);

const LEVEL_BUTTON_PATH : String = "res://Prefabs/Nexus/Buttons/level-button.tscn";
const LEVEL_BUTTON_X_MARGIN : int = 342;
const LEVEL_BUTTON_Y_MARGIN : int = 400;
const LEVEL_BUTTONS_STARTING_POSITION : Vector2 = Vector2(-LEVEL_BUTTON_X_MARGIN * 0.5, -180);
const LEVEL_BUTTONS_PER_ROW : int = 2;

const LED_PATH : String = "res://Prefabs/Nexus/EyeCandy/Led.tscn";
const LEDS_PER_COLUMN : int = 19;
const LED_MARGIN : Vector2 = Vector2(20, 100);
const LED_STARTING_POSITION : Vector2 = Vector2(-480, -900);
const LED_FRAME_WAIT : float = 0.12;
const LEDS_IN_BURST : int = 3;
const LEDS_BETWEEN_BURSTS : int = 6;
const RED_LED_SPEED : int = 2;

var is_active : bool;
var leds_left : Array;
var leds_right : Array;
var current_led_row : int = LEDS_PER_COLUMN - 1;
var red_lex_index : int;

func init(music_position : float) -> void:
	pass
