extends Node2D
class_name Nexus

signal enter_level(level_data);

const LEVEL_BUTTON_PATH : String = "res://Prefabs/Nexus/Buttons/level-button.tscn";
const LEVEL_BUTTON_X_MARGIN : int = 342;
const LEVEL_BUTTON_Y_MARGIN : int = 400;
const LEVEL_BUTTONS_STARTING_POSITION : Vector2 = Vector2(-LEVEL_BUTTON_X_MARGIN * 0.5, -180);
const LEVEL_BUTTONS_PER_ROW : int = 2;
const BACKGROUND_CARDS_SCALE : float = 0.96;

const LEDS_PER_COLUMN : int = 19;
const LED_MARGIN : Vector2 = Vector2(20, 100);
const LED_STARTING_POSITION : Vector2 = Vector2(-480, -900);
const LED_FRAME_WAIT : float = 0.12;
const LEDS_IN_BURST : int = 3;
const LEDS_BETWEEN_BURSTS : int = 6;
const RED_LED_SPEED : int = 2;
const RED_LED_COLOR_CHANGE_CHANCE : int = 4;

const MIN_CARD_SPAWN_WAIT : float = 0.1;
const MAX_CARD_SPAWN_WAIT : float = 3.0;
const AUTO_START_WAIT : float = 0.5;

var is_active : bool;
var leds_left : Array;
var leds_right : Array;
var current_led_row : int = LEDS_PER_COLUMN - 1;
var red_led_index : int;
var red_led_color : Led.LedColor = Led.LedColor.RED;
var level_buttons : Array;
var levels_unlocked : int;

func init(levels_unlocked_ : int) -> void:
	pass

func instance_background_card(parent : Node) -> GameplayCard:
	var card : GameplayCard = System.Instance.load_child(System.Paths.CARD, parent);
	card.card_data = System.Data.load_card(System.random.randi_range(1, System.Rules.MAX_CARD_ID));
	card.position = Vector2(System.Random.x(), -System.Window_.y / 2 - GameplayCard.SIZE.y / 2);
	card.init();
	card.flow_down();
	return card;
