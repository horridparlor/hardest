extends Node2D
class_name PointMeter

const MAX_EXTRA_LEDS : int = 20;
const MAX_NEGATIVE_LEDS : int = 105;
const EXTRA_LEDS_MARGIN : Vector2 = Vector2(0, -15);
const EXTRA_LEDS_STARTING_POSITION : Vector2 = Vector2(0, -42) + EXTRA_LEDS_MARGIN;
const NEGATIVE_LEDS_STARTING_POSITION : Vector2 = Vector2(0, 36) - EXTRA_LEDS_MARGIN;
const EXTRA_LEDS_MIN_BETWEEN_WAIT : float = 0.03 * Config.GAME_SPEED_MULTIPLIER;
const EXTRA_LEDS_MAX_BETWEEN_WAIT : float = 0.05 * Config.GAME_SPEED_MULTIPLIER;
const NEGATIVE_LEDS_MIN_BETWEEN_WAIT : float = 0.01 * Config.GAME_SPEED_MULTIPLIER;
const NEGATIVE_LEDS_MAX_BETWEEN_WAIT : float = 0.012 * Config.GAME_SPEED_MULTIPLIER;

var max_points : int;
var extras_lit : bool;
var led_position : Vector2 = EXTRA_LEDS_STARTING_POSITION;
var extra_leds_to_light : int;
var leds : Array;
var negative_leds : Array;
var negative_leds_to_light : int;
var negatives_lit : bool;
var negative_led_position : Vector2 = NEGATIVE_LEDS_STARTING_POSITION;
var min_points : int;

func set_max_points(max_points_ : int) -> void:
	pass;

func set_points(points : int) -> void:
	pass;

func light_extra_leds(points : int) -> void:
	if extras_lit:
		return;
	extra_leds_to_light = min(MAX_EXTRA_LEDS, points / max_points * 5.0);
	if extra_leds_to_light == 0:
		return;
	light_extra_led();
	extras_lit = true;

func light_negative_leds(points : int) -> void:
	if negatives_lit:
		return;
	negative_leds_to_light = min(MAX_NEGATIVE_LEDS, 0 if points >= 0 else abs(points / max_points * 5.0));
	if negative_leds_to_light == 0:
		return;
	light_negative_led();
	min_points = points;
	negatives_lit = true;
		
func light_extra_led() -> void:
	pass;

func light_negative_led() -> void:
	pass;

func get_nodes() -> Array:
	return [];

func mirror() -> void:
	pass;

func reset() -> void:
	reset_leds();

func reset_leds() -> void:
	pass;
