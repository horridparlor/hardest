static func play_card(card : GameplayCard, player : Player, opponent : Player, gameplay : Gameplay, is_digital_speed : bool = false) -> bool:
	player.play_card(card.card_data, is_digital_speed);
	if player == gameplay.player_two:
		gameplay.opponents_field_card = card;
	if card.card_data.has_hydra() and !card.card_data.has_buried():
		player.build_hydra(card.card_data);
	if card.card_data.has_buried():
		if !is_digital_speed:
			System.AutoEffects.bury_card(card, gameplay);
	opponent.trigger_opponent_placed_effects();
	gameplay.update_card_alterations();
	if System.AutoEffects.check_for_devoured(card, player, opponent, gameplay, is_digital_speed):
		gameplay.reorder_hand();
		if player == gameplay.player_one and System.auto_play:
			gameplay.auto_play_timer.wait_time = System.random.randf_range(Gameplay.AUTO_PLAY_MIN_WAIT, Gameplay.AUTO_PLAY_MAX_WAIT) * System.game_speed_additive_multiplier;
			gameplay.auto_play_timer.start();
		return false;
	elif !card.card_data.is_buried:
		System.PlayEffects.trigger_play_effects(card.card_data, player, opponent, gameplay);
	if player == gameplay.player_two:
		gameplay.show_opponents_field();
		return true;
	if !gameplay.started_playing:
		gameplay._on_started_playing();
	card.goal_position = Gameplay.FIELD_POSITION;
	card.is_moving = true;
	gameplay.reorder_hand();
	if is_digital_speed:
		return true;
	gameplay.can_play_card = false;
	gameplay.highlight_face(false);
	if gameplay.going_first:
		gameplay._on_your_turn_end();
	else:
		gameplay._on_opponent_turns_end();
	return true;

static func spawn_card(card_data : CardData, gameplay : Gameplay) -> GameplayCard:
	gameplay.update_alterations_for_card(card_data);
	if gameplay.cards.has(card_data.instance_id):
		return gameplay.cards[card_data.instance_id];
	elif card_data.controller == gameplay.player_two and System.Instance.exists(gameplay.opponents_field_card) and System.Instance.exists(card_data) and System.Instance.exists(gameplay.opponents_field_card) and System.Instance.exists(gameplay.opponents_field_card.card_data) and card_data.instance_id == gameplay.opponents_field_card.card_data.instance_id:
		gameplay.opponents_field_card.is_despawning = false;
		return gameplay.opponents_field_card;
	var card : GameplayCard = System.Instance.load_child(System.Paths.CARD, gameplay.cards_layer if gameplay.active_card == null else gameplay.cards_layer2);
	card.card_data = card_data;
	card.instance_id = card_data.instance_id;
	card.init(card_data.controller.gained_keyword);
	gameplay.cards[card.card_data.instance_id] = card;
	card.position = Gameplay.CARD_STARTING_POSITION if card_data.controller == gameplay.player_one else -Gameplay.CARD_STARTING_POSITION;
	card.position.x = System.random.randf_range(-System.Window_.x, System.Window_.x) / 2;
	card.pressed.connect(gameplay._on_card_pressed);
	card.released.connect(gameplay._on_card_released);
	card.despawned.connect(gameplay._on_card_despawned);
	card.visited.connect(gameplay._on_card_visited);
	card.spawn_lich_king_shadow.connect(gameplay._on_spawn_lich_king_shadow);
	if gameplay.is_time_stopped:
		gameplay.add_time_stop_shader(card);
	card.show_multiplier_bar(0);
	card.hide_multiplier_bar();
	if card.card_data.has_aura_farming():
		card.menacing_effect();
	gameplay.show_multiplier_bar(card);
	gameplay.time_stop_nodes += card.get_shader_layers();
	gameplay.custom_time_stop_nodes[card.card_data.instance_id] = card.get_custom_shader_layers();
	for node in card.get_custom_shader_layers():
		node.material.set_shader_parameter("time", gameplay.time_stop_shader_time);
	if gameplay.is_time_stopped:
		var shader_material : ShaderMaterial;
		var custom_shader_material : ShaderMaterial = System.Shaders.time_stop_material();
		custom_shader_material.set_shader_parameter("time", gameplay.time_stop_shader_time);
		for node in gameplay.time_stop_nodes:
			if !node.material:
				continue;
			shader_material = node.material;
			break;
		System.Shaders.set_card_art_shader_parameters(custom_shader_material, card.card_data.is_negative_variant(), card.card_data.is_holographic, card.card_data.is_foil);
		for node in card.get_shader_layers():
			node.material = shader_material;
		for node in card.get_custom_shader_layers():
			node.material = custom_shader_material;
	return card;
