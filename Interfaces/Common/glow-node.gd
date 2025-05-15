extends Node2D
class_name GlowNode

enum IsActive {
	BASELINING,
	GLOWING,
	NOT,
	SHUTTERING,
}

enum GlowType {
	LIGHT,
	OPACITY,
}

const MAX_TOP_GLOW : float = 1.5;
const MIN_TOP_GLOW : float = 1.125;
const MAX_SPEED : float = 0.25;
const MIN_SPEED : float = 0.0625;
const OPACITY_MAX_SPEED : float = 0.1;

const BASE_INTENSITY : float = 1.0;
const RADIATE_SPEED_MULTIPLIER : int = 10
const SHUTTERED_INTENSITY : float = 0.72;
const SHUTTER_SPEED_MULTIPLIER : int = 9

const OPACITY_SPEED_MULTIPLIER : float = 0.36;
const OPACITY_MIN_GLOW : float = 1.4;
const OPACITY_RESISTANCE : float = 6.7;
const OPACITY_MULTIPLIER : float = 4.7;

var animations_active : IsActive = IsActive.NOT;
var glow_intensity : float = 1.0;
var glowing_direction : int = 1;
var glow_speed : float;
var top_glow : float;
var radiates : bool = false;
var glow_type : GlowType;

func _physics_process(delta : float) -> void:
	match animations_active:
		IsActive.GLOWING:
			glow_frame(delta);
		IsActive.SHUTTERING:
			shutter_frame(delta);
		IsActive.BASELINING:
			baseline_frame(delta);

func glow_frame(delta : float) -> void:
	glow_intensity += glowing_direction * glow_speed * \
		(RADIATE_SPEED_MULTIPLIER if radiates else 1) * delta * System.game_speed;
	if glowing_direction == 1 and glow_intensity >= top_glow or \
	glowing_direction == -1 and glow_intensity <= BASE_INTENSITY:
		if radiates:
			radiates = false;
		glowing_direction *= -1;
	do_effect();

func shutter_frame(delta : float) -> void:
	glow_intensity -= glow_speed * SHUTTER_SPEED_MULTIPLIER \
		* (OPACITY_SPEED_MULTIPLIER if is_opacity() else 1) * delta * System.game_speed;
	if glow_intensity <= SHUTTERED_INTENSITY:
		glow_intensity = SHUTTERED_INTENSITY;
	do_effect();

func baseline_frame(delta : float) -> void:
	glow_intensity += glow_speed * SHUTTER_SPEED_MULTIPLIER \
		* (OPACITY_SPEED_MULTIPLIER if is_opacity() else 1) * delta * System.game_speed;
	if glow_intensity >= 1:
		glow_intensity = 1;
	do_effect();

func do_effect() -> void:
	match glow_type:
		GlowType.LIGHT:
			light_effect();
		GlowType.OPACITY:
			opacity_effect();

func is_opacity() -> bool:
	return glow_type == GlowType.OPACITY;

func light_effect() -> void:
	modulate = Color(glow_intensity, glow_intensity, glow_intensity);

func opacity_effect() -> void:
	modulate.a = OPACITY_RESISTANCE - OPACITY_MULTIPLIER * glow_intensity;

func activate_animations(
	glow_type_ : GlowType = GlowType.LIGHT
) -> bool:
	if animations_active != IsActive.NOT:
		return false;
	glow_type = glow_type_;
	top_glow = System.random.randf_range(
		(OPACITY_MIN_GLOW if is_opacity() else MIN_TOP_GLOW),
		MAX_TOP_GLOW
	);
	glow_intensity = System.random.randf_range(1.0, top_glow);
	set_glow_speed();
	animations_active = IsActive.GLOWING
	return true;

func set_glow_speed() -> void:
	glow_speed = System.random.randf_range(
		MIN_SPEED,
		(OPACITY_MAX_SPEED if is_opacity() else MAX_SPEED)
	);

func control_glow(glow_state : GameplayEnums.GlowState) -> void:
	match glow_state:
		GameplayEnums.GlowState.GLOW:
			glow();
		GameplayEnums.GlowState.SHUTTER:
			shutter();

func shutter() -> void:
	if !activate_animations():
		set_glow_speed();
	animations_active = IsActive.SHUTTERING;

func full_shutter() -> void:
	shutter();
	glow_intensity = SHUTTERED_INTENSITY;

func baseline() -> void:
	animations_active = IsActive.BASELINING;

func glow() -> void:
	activate_animations();
	if animations_active == IsActive.SHUTTERING:
		glowing_direction = 1;		
		radiates = true;
	animations_active = IsActive.GLOWING;
