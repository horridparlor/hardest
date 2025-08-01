extends GlowNode
class_name MultiplierBar

const MIN_FADE_IN_SPEED : float = 1.1;
const MAX_FADE_IN_SPEED : float = 1.6;
const MIN_FADE_OUT_SPEED : float = 2.1;
const MAX_FADE_OUT_SPEED : float = 2.9;
const BORDER_WIDTH : int = 8;
const BORDER_RADIUS : int = 13;
const POSITIVE_BACKGROUND_COLOR : String = "#0e4287";
const POSITIVE_BORDER_COLOR : String = "#6b9bdb";
const NEGATIVE_BACKGROUND_COLOR : String = "#de321c";
const NEGATIVE_BORDER_COLOR : String = "#febfb3";

var is_fading_in : bool;
var is_fading_out : bool;
var opacity : float;
var fade_in_speed : float;
var fade_out_speed : float;
var pattern_shader : ShaderMaterial;
var multi : int;

func get_shader_layers() -> Array:
	return [];

func set_number(value : int) -> void:
	pass;

func fade_in() -> void:
	is_fading_out = false;
	is_fading_in = true;
	visible = true;
	
func fade_out() -> void:
	is_fading_in = false;
	is_fading_out = true;

func _process(delta : float) -> void:
	if is_fading_in:
		opacity += delta * fade_in_speed;
		update_opacity();
		if opacity >= 1:
			opacity = 1;
			is_fading_in = false;
	if is_fading_out:
		opacity -= delta * fade_out_speed;
		update_opacity();
		if opacity <= 0:
			opacity = 0;
			visible = false;
			is_fading_out = false;

func update_opacity() -> void:
	pass;

func after_time_stop() -> void:
	pass;
