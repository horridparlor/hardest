extends GlowNode
class_name GameplayCard

signal pressed(_self)
signal released(_self)
signal despawned(_self)
signal visited(_self)

const MIN_SCALE : float = 0.2;
const MAX_SCALE :float = 1.0;
const DESPAWNING_SUCKING_DISTANCE : int = 500;
const DESPAWNING_SUCKING_EVENT_HORIZON : int = 50;
const MIN_SCALE_VECTOR : Vector2 = Vector2(MIN_SCALE, MIN_SCALE);
const MAX_SCALE_VECTOR : Vector2 = Vector2(MAX_SCALE, MAX_SCALE);
const SPEED : int = 6 * Config.GAME_SPEED;
const SIZE : Vector2 = Vector2(MIN_SCALE * 900, MIN_SCALE * 1400);
const BORDER_WIDTH : int = 24;
const BORDER_RADIUS : int = 60;
const TYPE_ICON_PATH : String = "res://Assets/Art/CardIcons/%s_120.png";
const TYPE_FONT_SIZE_BIG : int = 128;
const TYPE_FONT_SIZE_SMALL : int = 112;
const CARD_ART_PATH : String = "res://Assets/Art/CardArtSmall/%s.png";
const CARD_FULLART_PATH : String = "res://Assets/Art/CardArt/%s.png";
const ROTATION_SPEED : float = 0.12;
const CHAMELEON_ROTATION_SPEED : float = 0.37;
const FOCUS_WAIT : float = 1.8;
const BACKGROUND_PATTERN_PATH : String = "res://Assets/Art/SpecialPatterns/%s.png";
const MIN_MOVEMENT_SPEED : float = 1.0 * Config.GAME_SPEED;
const MIN_VISIT_SPEED : float = 4.5 * Config.GAME_SPEED;
const KEYWORD_HINT_LINE : String = "[b][i]%s[/i][/b] [i]–[/i] %s\n";
const STAMP_HINT_LINE : String = "[b]%s Stamp[/b] [i]–[/i] %s\n";
const VARIANT_HINT_LINE : String = "[b]%s Variant[/b] [i]–[/i] %s\n";
const HOLO_HINT_LINE : String = "[b]Holographic[/b] [i]–[/i] Scores double.\n";
const MULTI_TYPE_HINT_LINE : String = "[b]%s[/b] [i]–[/i] Defeats %s and %s. [i](Ties with %s.)[/i]\n";
const MULTI_TYPE_HINT_REPLACEMENTS : Dictionary = {
	CardEnums.CardType.BEDROCK: ["Bedrock", "rock", "scissors", "paper"],
	CardEnums.CardType.ZIPPER: ["Zipper", "rock", "paper", "scissors"],
	CardEnums.CardType.ROCKSTAR: ["Rockstar", "paper", "scissors", "rock"]
};

const FLOW_SPEED : float = 0.6;
const MIN_GRAVITY : float = 100;
const MAX_GRAVITY : float = 1000;
const X_FLOW_MULTIPLIER : float = 0.4;
const MIN_X_FLOW : int = 100;
const CHANCE_TO_DISSOLVE_DURING_FLOWING : int = 84;
const MIN_DISSOLVE_SPEED : float = 1.1;
const MAX_DISSOLVE_SPEED : float = 1.6;
const MAX_DISSOLVE_VALUE : float = 2;
const FLOW_DISSOLVE_MULTIPLIER : float = 0.21;
const BACKGROUND_PATTERN_OPACITY : float = 0.32;
const OCEAN_IN_SPEED : float = 3.7 * Config.GAME_SPEED;
const OCEAN_OUT_SPEED : float = 0.3 * Config.GAME_SPEED;
const OCEAN_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const ANIMATION_DYING_SPEED : float = 1.4 * Config.GAME_SPEED;
const RATTLE_POSITION : Vector2 = Vector2(420, -700);

const MIN_RECOIL_DISTANCE : int = 400;
const MAX_RECOIL_DISTANCE : int = 600;
const RECOIL_MIN_SHAKE : int = 400;
const RECOIL_MAX_SHAKE : int = 1000;
const RECOIL_WAIT : float = 0.4 * Config.GAME_SPEED_MULTIPLIER;
const SHAKE_POS_WAIT : float = 0.05 * Config.GAME_SPEED_MULTIPLIER;
const MIN_RECOIL : int = 0;
const MAX_RECOIL : int = 20;

const SHINE_STAR_POSITION : Vector2 = Vector2(-350, -430);
const MULTIPLIER_BAR_POSITION : Vector2 = Vector2(0, -840);

const ROCK_BG_COLOR = "#008242";
const ROCK_BORDER_COLOR = "#7bffc3";
const PAPER_BG_COLOR = "#3683cf";
const PAPER_BORDER_COLOR = "#92cffd";
const SCISSORS_BG_COLOR = "#f9662d";
const SCISSORS_BORDER_COLOR = "#ffbf8d";
const GUN_BG_COLOR = "#a2a037";
const GUN_BORDER_COLOR = "#fbe100";
const MIMIC_BG_COLOR = "#b420b6";
const MIMIC_BORDER_COLOR = "#fbcafb";
const GOD_BG_COLOR = "847033";
const GOD_BORDER_COLOR = "e9d392";

const SHADER_COLOR_GREEN : Color = Color(0.0, 0.6, 0.0, 1.0);
const SHADER_COLOR_BLUE : Color = Color(0, 0.4, 0.8, 1.0);
const SHADER_COLOR_ORANGE : Color = Color(1.0, 0.5, 0.0, 1.0);
const SHADER_COLOR_GOLD : Color = Color(1.0, 0.84, 0.0, 1.0);
const SHADER_COLOR_PURPLE : Color = Color(0.5, 0.0, 0.5, 1.0);
const SHADER_COLOR_WHITE : Color = Color(0.8, 0.8, 0.85, 1.0);
const SHADER_COLOR_NEON : Color = Color(0.0, 1.0, 0.7, 1.0);
const SHADER_COLOR_SILVER : Color = Color(0.8, 0.6, 0.55, 1.0);
const SHADER_COLOR_RED : Color = Color(1.0, 0.25, 0.0, 1.0);

const CARD_SCALE : Dictionary = {
	CardEnums.Zone.DECK: MIN_SCALE_VECTOR,
	CardEnums.Zone.HAND: MIN_SCALE_VECTOR,
	CardEnums.Zone.FIELD: MIN_SCALE_VECTOR,
	CardEnums.Zone.GRAVE: MIN_SCALE_VECTOR
}

var instance_id : int;
var card_data : CardData = CardData.new();
var is_moving : bool;
var is_focused : bool;
var following_mouse : bool;
var goal_position : Vector2;
var visit_point : Vector2;
var starting_position : Vector2;
var is_despawning : bool;
var is_scaling : bool;
var focus_timer : Timer = Timer.new();
var recoil_timer : Timer = Timer.new();
var ocean_timer : Timer = Timer.new();
var shake_pos_alter_timer : Timer = Timer.new();
var is_visiting : bool;
var flow_x : float;
var flow_gravity : float;
var is_flowing : bool;
var is_shaking : bool;
var shake_to_position : Vector2;
var has_emp_visuals : bool;
var has_negative_visuals : bool;
var has_holographic_visuals : bool;
var has_foil_visuals : bool;
var is_in_ocean : bool;
var is_out_ocean : bool;
var shine_star : ShineStar;
var rattle : Rattle;

var dissolve_value : float;
var is_dissolving : bool;
var dissolve_speed : float;
var throwable_effect : Node2D;
var particle_effect : Node2D;
var multiplier_bar : MultiplierBar;
var is_dying : bool;
var still_wait_time : float = -0.01;
var visit_instance_id : int;
var do_get_small : bool;

func init(gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	rescale(true);
	update_visuals(gained_keyword);
	activate_animations();
	initialize_timers();

func init_shader() -> void:
	var shader : Resource = load("res://Shaders/CardEffects/card-dissolve.gdshader");
	var shader_material := ShaderMaterial.new();
	shader_material.shader = shader;
	material = shader_material;

func initialize_timers() -> void:
	add_child(focus_timer);
	focus_timer.wait_time = FOCUS_WAIT;
	focus_timer.timeout.connect(_on_focus_timer_timeout);
	add_child(recoil_timer);
	recoil_timer.wait_time = RECOIL_WAIT;
	recoil_timer.timeout.connect(_on_recoil_timer_timeout)
	add_child(shake_pos_alter_timer);
	shake_pos_alter_timer.wait_time = SHAKE_POS_WAIT;
	shake_pos_alter_timer.timeout.connect(_on_shake_pos_alter_timer_timeout);
	add_child(ocean_timer);
	ocean_timer.wait_time = OCEAN_WAIT;
	ocean_timer.timeout.connect(_on_out_ocean);

func update_visuals(gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	pass;

func rescale(is_instant : bool = false) -> void:
	if is_instant:
		scale = CARD_SCALE[card_data.zone];
		return;

func _process(delta: float) -> void:
	if is_dying:
		dying_frame(delta);
		return;
	if is_dissolving:
		dissolve_frame(delta);
	if is_in_ocean:
		in_ocean_frame(delta);
	if is_out_ocean:
		out_ocean_frame(delta);
	if !(is_moving or following_mouse or is_flowing):
		baseline_rotation(delta);
		return;
	move_card(delta);
	update_scale(delta);

func in_ocean_frame(delta : float) -> void:
	pass;

func out_ocean_frame(delta : float) -> void:
	pass;

func dying_frame(delta : float) -> void:
	particle_effect.modulate.a -= delta * ANIMATION_DYING_SPEED;
	if particle_effect.modulate.a <= 0:
		queue_free();

func move_card(delta : float) -> void:
	var card_margin : Vector2 = GameplayCard.SIZE / 2;
	var original_position : Vector2 = position;
	if still_wait_time > 0:
		still_wait_time -= System.game_speed_multiplier * delta;
		if still_wait_time < 0:
			still_wait_time == -0.01;
		return;
	if is_moving or following_mouse:
		if System.Instance.exists(card_data) and card_data.controller and card_data.controller.controller == GameplayEnums.Controller.PLAYER_TWO and System.Vectors.is_default(goal_position):
			if is_visiting:
				goal_position = get_despawn_position();
			else:
				goal_position = Gameplay.ENEMY_FIELD_POSITION;
		position = System.Vectors.slide_towards(position, (get_local_mouse_position() - starting_position) \
			if following_mouse else (visit_point if is_visiting \
			else goal_position),
			SPEED * delta * System.game_speed,
			MIN_VISIT_SPEED if is_visiting or is_despawning else MIN_MOVEMENT_SPEED
		);
		if is_shaking:
			position = System.Vectors.slide_towards(position, position + shake_to_position, delta);
	if is_visiting and System.Vectors.equal(position, visit_point):
		is_visiting = false;
		is_shaking = false;
		emit_signal("visited", self);
	if is_moving and System.Vectors.equal(position, goal_position):
		if is_despawning:
			emit_signal("despawned", self);
		is_moving = false;
	if following_mouse:
		position = Vector2(
			min(System.Window_.x / 2 - card_margin.x, max(position.x, -System.Window_.x / 2 + card_margin.x)),
			min(System.Window_.y / 2 - card_margin.y, max(position.y, -System.Window_.y / 2 + card_margin.y))
		);
	if is_flowing:
		flow_frame(delta);
	rotate_card(position - original_position, delta);

func despawn_to_same_direction() -> void:
	var despawn_point : Vector2 = get_despawn_position();
	despawn(Vector2(
		System.Floats.direction(global_position.x) * abs(despawn_point.x),
		position.y * System.random.randf_range(0.8, 1.2)
	));

func flow_frame(delta : float) -> void:
	position = System.Vectors.slide_towards(position, Vector2(position.x + flow_x, position.y + flow_gravity), FLOW_SPEED * delta);
	if !is_dissolving and System.Random.chance(CHANCE_TO_DISSOLVE_DURING_FLOWING * (1 / (System.Window_.y / position.y)) * (1 / delta)):
		dissolve();
	if !System.Vectors.is_inside_window(position, SIZE) or dissolve_value == MAX_DISSOLVE_VALUE:
		queue_free();

func rotate_card(position_change : Vector2, delta : float) -> void:
	if !System.Vectors.equal(position_change):
		rotation_degrees += position_change.x * (CHAMELEON_ROTATION_SPEED if (System.Instance.exists(card_data) and card_data.has_chameleon()) else ROTATION_SPEED);
	if is_flowing:
		return;
	baseline_rotation(delta);

func baseline_rotation(delta : float) -> void:
	rotation_degrees = System.Scale.baseline(rotation_degrees, 0 if following_mouse else System.base_rotation, delta);

func toggle_follow_mouse(value : bool = true) -> void:
	following_mouse = value;
	starting_position = get_local_mouse_position();
	starting_position.y = (starting_position.y + GameplayCard.SIZE.y) / 2;
	toggle_focus(value);
	
func despawn(despawn_position : Vector2 = Vector2.ZERO, wait_time : float = 0) -> void:
	is_shaking = false;
	is_visiting = false;
	is_despawning = true;
	still_wait_time += wait_time;
	goal_position = despawn_position \
		if !System.Vectors.is_default(despawn_position) \
		else get_despawn_position();
	toggle_focus(false);
	if still_wait_time > 0:
		return;
	hide_multiplier_bar();

func get_despawn_position() -> Vector2:
	return Vector2( System.Random.direction() \
		* (System.Window_.x / 2 + SIZE.x), goal_position.y);

func dissolve(multiplier : float = 1) -> void:
	pass;

func dissolve_frame(delta : float) -> void:
	pass;

func toggle_focus(value : bool = true) -> void:
	if value:
		focus_timer.start();
	else:
		focus_timer.stop();
		is_focused = false;
		update_card_art();
	move();

func move() -> void:
	is_moving = true;
	is_scaling = true;

func go_visit_point(position : Vector2) -> void:
	visit_point = position;
	is_shaking = false;
	is_visiting = true;
	move();

func update_scale(delta : float) -> void:
	var new_scale : float;
	if !is_scaling:
		return;
	new_scale = System.Scale.baseline(scale.x, (MAX_SCALE if is_focused else MIN_SCALE), delta);
	if is_despawning and do_get_small:
		new_scale = clamp(max(0, position.distance_to(goal_position) - DESPAWNING_SUCKING_EVENT_HORIZON) / DESPAWNING_SUCKING_DISTANCE, 0, MIN_SCALE);
	scale = Vector2(new_scale, new_scale);

func _on_focus_timer_timeout() -> void:
	focus_timer.stop();
	is_focused = true;
	hide_multiplier_bar();
	update_card_art(true);

func bury() -> void:
	pass;

func update_card_art(do_full_art : bool = false) -> void:
	pass;

func flow_down() -> void:
	var direction : int;
	flow_x = System.Floats.direction_safe_min(System.Random.x() * X_FLOW_MULTIPLIER, MIN_X_FLOW);
	flow_gravity = System.random.randf_range(MIN_GRAVITY, MAX_GRAVITY);
	is_flowing = true;

func recoil(target_position : Vector2 = position) -> void:
	visit_point = System.Vectors.move_away(position, target_position, \
		System.random.randf_range(MIN_RECOIL_DISTANCE, MAX_RECOIL_DISTANCE));
	is_moving = true;
	is_visiting = true;
	is_shaking = true;
	_on_shake_pos_alter_timer_timeout();
	recoil_timer.start();

func _on_recoil_timer_timeout() -> void:
	recoil_timer.stop();
	is_visiting = false;
	is_shaking = false;

func _on_shake_pos_alter_timer_timeout() -> void:
	shake_pos_alter_timer.stop();
	shake_to_position = System.Random.vector(RECOIL_MIN_SHAKE, RECOIL_MAX_SHAKE);
	if is_shaking:
		shake_pos_alter_timer.start();

func get_recoil_position() -> Vector2:
	return position + System.Random.vector(MIN_RECOIL, MAX_RECOIL);

func get_keyword_hints() -> String:
	var hints_text : String;
	var keywords : Array = card_data.get_keywords();
	var gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL if !card_data.controller else card_data.controller.gained_keyword;
	if  gained_keyword != CardEnums.Keyword.NULL and keywords.size() < System.Rules.MAX_KEYWORDS:
		keywords.append(gained_keyword);
	if card_data.is_multi_type() and (keywords.size() + (1 if card_data.is_negative_variant() else 0) + (1 if card_data.is_holographic else 0) + (0 if card_data.stamp == CardEnums.Stamp.NULL else 1)) <= 2 and (keywords.filter(func(keyword : int): return (CardEnums.KeywordHints[keyword] if CardEnums.KeywordHints.has(keyword) else "").length() >= 80).size() == 0 or keywords.size() == 1):
		hints_text += MULTI_TYPE_HINT_LINE % MULTI_TYPE_HINT_REPLACEMENTS[card_data.card_type];
	for keyword in keywords:
		var hint_text : String = CardEnums.KeywordHints[keyword] if CardEnums.KeywordHints.has(keyword) else "";
		hint_text = enrich_hint(hint_text);
		hints_text += KEYWORD_HINT_LINE % [CardEnums.KeywordNames[keyword] if CardEnums.KeywordNames.has(keyword) else "?", hint_text];
	if card_data.stamp != CardEnums.Stamp.NULL:
		var hint_text : String = CardEnums.StampHints[card_data.stamp] if CardEnums.StampHints.has(card_data.stamp) else "";
		var stamp_name : String = CardEnums.TranslateStampBack[card_data.stamp] if CardEnums.TranslateStampBack.has(card_data.stamp) else "?";
		hints_text += STAMP_HINT_LINE % [stamp_name[0].to_upper() + stamp_name.substr(1), hint_text];
	if card_data.is_holographic:
		hints_text += HOLO_HINT_LINE;
	if card_data.variant != CardEnums.CardVariant.REGULAR:
		var hint_text : String = CardEnums.VariantHints[card_data.variant] if CardEnums.VariantHints.has(card_data.variant) else "";
		var variant_name : String = CardEnums.TranslateVariantBack[card_data.variant] if CardEnums.TranslateVariantBack.has(card_data.variant) else "?";
		hints_text += VARIANT_HINT_LINE % [variant_name[0].to_upper() + variant_name.substr(1), hint_text];
	return hints_text;

func enrich_hint(message : String) -> String:
	message = message \
		.replace("SAME_TYPES", CardEnums.CardTypeName[card_data.default_type].to_lower() + "s") \
		.replace("SAME_TYPE", CardEnums.CardTypeName[card_data.card_type].to_lower()) \
		.replace("SAME_BASIC", ("a " if [
			CardEnums.CardType.ROCK,
			CardEnums.CardType.PAPER,
			CardEnums.CardType.MIMIC
		].has(card_data.card_type) else "") + "[b]%s[/b]" % CardEnums.BasicNames[card_data.card_type]);
	return message;

func wet_effect(color : Color = SHADER_COLOR_BLUE) -> void:
	pass;

func menacing_effect() -> void:
	System.Instance.load_child(System.Paths.MENACING_EFFECT, self);

func burn_effect() -> void:
	if System.Instance.exists(particle_effect):
		particle_effect.queue_free();
	particle_effect = System.Instance.load_child(System.Paths.BURNING_EFFECT, self);
	particle_effect.position.y = 200;

func sabotage_effect() -> void:
	if System.Instance.exists(throwable_effect):
		throwable_effect.queue_free();
	throwable_effect = System.Instance.load_child(System.Paths.SABOTAGE_EFFECT, self);
	throwable_effect.position.y = 200;

func electrocuted_effect() -> void:
	if System.Instance.exists(particle_effect):
		particle_effect.queue_free();
	particle_effect = System.Instance.load_child(System.Paths.ELECTROCUTED_EFFECT, self);
	particle_effect.position.y = -400;

func _on_out_ocean() -> void:
	ocean_timer.stop();
	is_in_ocean = false;
	is_out_ocean = true;

func get_shader_layers(include_multiplier_bar : bool = true) -> Array:
	return [];

func get_custom_shader_layers() -> Array:
	return [];

func add_art_base_shader(do_force : bool = false) -> void:
	pass;

func shine_star_effect() -> void:
	pass;

func show_multiplier_bar(value : int) -> void:
	if !System.Instance.exists(multiplier_bar):
		multiplier_bar = System.Instance.load_child(System.Paths.MULTIPLIER_BAR, self);
		multiplier_bar.scale *= 1.8;
		multiplier_bar.position = MULTIPLIER_BAR_POSITION;
	multiplier_bar.set_number(value);
	multiplier_bar.fade_in();

func hide_multiplier_bar() -> void:
	if !System.Instance.exists(multiplier_bar):
		return;
	multiplier_bar.fade_out();

func after_time_stop() -> void:
	if card_data.has_emp():
		update_emp_visuals();
	if !System.Instance.exists(multiplier_bar):
		return;
	multiplier_bar.after_time_stop();

func update_emp_visuals() -> void:
	pass;

func die() -> void:
	pass;

func rattlesnake_effect() -> void:
	if System.Instance.exists(rattle):
		return;
	rattle = System.Instance.load_child(System.Paths.RATTLE, self);
	rattle.position = RATTLE_POSITION;
	rattle.sprite.material = material;
	if card_data and card_data.controller.controller == GameplayEnums.Controller.PLAYER_TWO:
		rattle.position.x *= -1;
