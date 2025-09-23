static func init_time_stop(gameplay : Gameplay) -> void:
	var shader_material : ShaderMaterial = System.Shaders.time_stop_material();
	var shader_material2 : ShaderMaterial = System.Shaders.time_stop_material();
	var custom_material : ShaderMaterial;
	var card : CardData;
	for node in get_time_stop_nodes(gameplay):
		node.material = shader_material;
	for instance_id in get_custom_time_stop_nodes(gameplay):
		if !System.Instance.exists(gameplay.cards[instance_id]) or !System.Instance.exists(gameplay.cards[instance_id].card_data):
			continue;
		card = gameplay.cards[instance_id].card_data;
		custom_material = System.Shaders.time_stop_material();
		custom_material.set_shader_parameter("time", gameplay.time_stop_shader_time);
		System.Shaders.set_card_art_shader_parameters(custom_material, card.is_negative_variant(), card.is_holographic, card.is_foil);
		for node in gameplay.custom_time_stop_nodes[instance_id]:
			node.material = custom_material;
	for node in get_time_stop_nodes2(gameplay):
		if !System.Instance.exists(node):
			continue;
		node.material = shader_material2;
	gameplay.led_wait *= Gameplay.TIME_STOP_LED_ACCELERATION;
	gameplay.is_time_stopped = true;
	gameplay.results_phase = 0;
	if gameplay.animation_instance_id != 0:
		gameplay.animation_wait_timer.stop();
		gameplay.after_animation(true);
	gameplay.play_time_stop_sound();

static func get_time_stop_nodes2(gameplay : Gameplay) -> Array:
	return gameplay.time_stop_nodes2 + gameplay.your_point_meter.get_nodes() + gameplay.opponents_point_meter.get_nodes() + get_poppet_nodes(gameplay);

static func get_poppet_nodes(gameplay : Gameplay) -> Array:
	var nodes : Array;
	for instance_id in gameplay.poppets:
		if !System.Instance.exists(gameplay.poppets[instance_id]):
			gameplay.poppets.erase(instance_id);
		else:
			nodes += gameplay.poppets[instance_id].get_shader_nodes();
	return nodes;

static func after_time_stop(gameplay : Gameplay) -> void:
	var shader : Resource = load("res://Shaders/Background/background-wave.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	var node_card : GameplayCard;
	shader_material.shader = shader;
	for node in get_time_stop_nodes(gameplay):
		node.material = null;
	for instance_id in get_custom_time_stop_nodes(gameplay):
		node_card = gameplay.cards[instance_id];
		node_card.add_art_base_shader(true);
	for node in get_time_stop_nodes2(gameplay):
		if !System.Instance.exists(node):
			continue;
		node.material = null;
	for card in gameplay.cards.values():
		if !System.Instance.exists(card):
			continue;
		card.after_time_stop();

	for node in [
		gameplay.background_pattern,
		gameplay.die_pattern,
		gameplay.your_point_pattern,
		gameplay.opponents_point_pattern,
		gameplay.gameplay_title
	]:
		node.material = shader_material;
	gameplay.led_wait /= Gameplay.TIME_STOP_LED_ACCELERATION;
	System.update_game_speed(1);
	gameplay.is_time_stopped = false;
	gameplay.is_stopping_time = false;
	gameplay.has_been_stopping_turn = false;
	gameplay.time_stopping_player = null;
	for bullet in gameplay.time_stopped_bullets:
		bullet.speed_up();
	gameplay.time_stopped_bullets = [];
	gameplay.pre_results_timer.start();

static func time_stop_frame(delta : float, gameplay : Gameplay) -> void:
	if !gameplay.is_stopping_time and !gameplay.is_accelerating_time:
		return;
	gameplay.time_stop_velocity = System.Scale.baseline(gameplay.time_stop_velocity, gameplay.time_stop_goal_velocity, delta * Gameplay.TIME_STOP_ACCELERATION_SPEED * System.game_speed);
	if gameplay.is_stopping_time:
		gameplay.time_stop_shader_time -= gameplay.time_stop_velocity * delta * System.game_speed;
		if gameplay.time_stop_shader_time <= 0:
			gameplay.time_stop_shader_time = 1.9999;
			gameplay.time_stop_goal_velocity = System.random.randf_range(Gameplay.TIME_STOP_IN_BW_MIN_SPEED, Gameplay.TIME_STOP_IN_BW_MAX_SPEED);
		if gameplay.time_stop_goal_velocity < Gameplay.TIME_STOP_IN_GLITCH_MIN_SPEED and gameplay.time_stop_shader_time <= 1.0001:
			gameplay.time_stop_shader_time = 1.001;
			gameplay.time_stop_velocity = 0;
	if gameplay.is_accelerating_time:
		gameplay.time_stop_shader_time += gameplay.time_stop_velocity * delta * System.game_speed;
		if gameplay.time_stop_shader_time >= 1.9999:
			gameplay.time_stop_shader_time = 0;
			gameplay.time_stop_goal_velocity = gameplay.time_stop_goal_velocity2;
		if gameplay.time_stop_goal_velocity > Gameplay.TIME_STOP_OUT_BW_MAX_SPEED and gameplay.time_stop_shader_time >= 0.9999:
			gameplay.time_stop_shader_time = 0.9999;
			gameplay.is_accelerating_time = false;
			gameplay.time_stop_velocity = 0;
			after_time_stop(gameplay);
	System.update_game_speed(System.Scale.baseline(\
		System.game_speed, Gameplay.TIME_STOP_GAME_SPEED if gameplay.is_stopping_time else 1, delta));
	update_time_stop_time(gameplay);

static func get_time_stop_nodes(gameplay : Gameplay) -> Array:
	for node in gameplay.time_stop_nodes.duplicate():
		if !System.Instance.exists(node):
			gameplay.time_stop_nodes.erase(node);
	return gameplay.time_stop_nodes;

static func get_custom_time_stop_nodes(gameplay : Gameplay) -> Dictionary:
	for instance_id in gameplay.custom_time_stop_nodes.duplicate():
		if !gameplay.cards.has(instance_id) or !System.Instance.exists(gameplay.cards[instance_id]):
			gameplay.custom_time_stop_nodes.erase(instance_id);
	return gameplay.custom_time_stop_nodes;

static func update_time_stop_time(gameplay : Gameplay) -> void:
	for node in get_time_stop_nodes(gameplay):
		if !node.material:
			continue;
		node.material.set_shader_parameter("time", gameplay.time_stop_shader_time);
		break;
	for instance_id in get_custom_time_stop_nodes(gameplay):
		for node in gameplay.custom_time_stop_nodes[instance_id]:
			if !node.material:
				continue;
			node.material.set_shader_parameter("time", gameplay.time_stop_shader_time);
	for node in gameplay.time_stop_nodes2:
		if node.material == null:
			break;
		node.material.set_shader_parameter("time", gameplay.time_stop_shader_time);
		break;

static func time_stop_effect_in(gameplay : Gameplay) -> void:
	init_time_stop(gameplay);
	gameplay.time_stop_shader_time = 0.9999;
	gameplay.is_accelerating_time = false;
	gameplay.is_stopping_time = true;
	gameplay.time_stop_goal_velocity = System.random.randf_range(Gameplay.TIME_STOP_IN_GLITCH_MIN_SPEED, Gameplay.TIME_STOP_IN_GLITCH_MAX_SPEED);

static func time_stop_effect_out(gameplay : Gameplay) -> void:
	gameplay.time_stop_shader_time = 1.01;
	gameplay.is_stopping_time = false;
	gameplay.is_accelerating_time = true;
	gameplay.time_stop_goal_velocity = System.random.randf_range(Gameplay.TIME_STOP_OUT_BW_MIN_SPEED, Gameplay.TIME_STOP_OUT_BW_MAX_SPEED);
	gameplay.time_stop_goal_velocity2 = System.random.randf_range(Gameplay.TIME_STOP_OUT_GLITCH_MIN_SPEED, Gameplay.TIME_STOP_OUT_GLITCH_MAX_SPEED);
	gameplay.emit_signal("stop_music_if_special");
	gameplay.play_time_stop_sound_reverse();

static func init_time_stop_nodes(gameplay : Gameplay) -> void:
	gameplay.time_stop_nodes = [
		gameplay.background_pattern
	];
	gameplay.time_stop_nodes2 = [
		gameplay.your_face,
		gameplay.opponents_face,
		gameplay.die_panel,
		gameplay.die_pattern,
		gameplay.dashboard_panel,
		gameplay.dashboard_pattern,
		gameplay.dashboard_icon,
		gameplay.reset_progress_panel,
		gameplay.your_point_panel,
		gameplay.your_point_panel_top_margin,
		gameplay.your_point_panel_right_margin,
		gameplay.opponents_point_panel,
		gameplay.your_point_pattern,
		gameplay.opponents_point_pattern,
		gameplay.opponents_point_panel_top_margin,
		gameplay.opponents_point_panel_left_margin,
		gameplay.gameplay_title
	];
	for led in gameplay.leds_left + gameplay.leds_right:
		gameplay.time_stop_nodes += led.get_shader_layers()
