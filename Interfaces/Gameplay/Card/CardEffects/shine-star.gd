extends Node2D
class_name ShineStar

const MIN_TIME_SPEED : float = 1.2;
const MAX_TIME_SPEED : float = 1.6;
const MIN_SHINE_INTENSITY : float = 0.9;
const MAX_SHINE_INTENSITY : float = 1.0;
const MIN_GLOW_SPEED : float = 1.1;
const MAX_GLOW_SPEED : float = 1.6;
const MIN_WIGGLE_STRENGTH : float = 0.001;
const MAX_WIGGLE_STRENGTH : float = 0.002;

const MIN_FLICKER_SPEED : float = 1.6;
const MAX_FLICKER_SPEED : float = 1.8;
const MIN_SHUTTER_SPEED : float = 2.3;
const MAX_SHUTTER_SPEED : float = 2.6;

var is_flickering : bool;
var is_shuttering : bool;
var fade_speed : float;
var time_speed : float;
var shine_intensity : float;
var glow_speed : float;
var wiggle_strength : float;

func _ready() -> void:
	modulate.a = 0;
	time_speed = System.random.randf_range(MIN_TIME_SPEED, MAX_TIME_SPEED);
	shine_intensity = System.random.randf_range(MIN_SHINE_INTENSITY, MAX_SHINE_INTENSITY);
	glow_speed = System.random.randf_range(MIN_GLOW_SPEED, MAX_GLOW_SPEED);
	wiggle_strength = System.random.randf_range(MIN_WIGGLE_STRENGTH, MAX_WIGGLE_STRENGTH);
	init_sprite();

func init_sprite() -> void:
	pass;

func flicker() -> void:
	visible = true;
	is_shuttering = false;
	is_flickering = true;
	fade_speed = System.random.randf_range(MIN_FLICKER_SPEED, MAX_FLICKER_SPEED);
	
func shutter() -> void:
	is_flickering = false;
	is_shuttering = true;
	fade_speed = System.random.randf_range(MIN_SHUTTER_SPEED, MAX_SHUTTER_SPEED);
	_on_shutter();

func _on_shutter() -> void:
	pass;

func update_opacity() -> void:
	pass;

func _process(delta: float) -> void:
	if is_flickering:
		modulate.a += delta * fade_speed;
		update_opacity();
		if modulate.a >= 1:
			modulate.a = 1;
			is_flickering = false;
	if is_shuttering:
		modulate.a -= delta * fade_speed;
		update_opacity();
		if modulate.a <= 0:
			modulate.a = 0;
			queue_free();
