extends Gameplay

@onready var cards_layer : Node2D = $CardsLayer;
@onready var cards_layer2 : Node2D = $CardsLayer2;
@onready var above_cards_layer : Node2D = $AboveCardsLayer;
@onready var field_lines : Node2D = $FieldLines;
@onready var starting_hints : JumpingText = $Background/StartingHints;
@onready var victory_banner : JumpingText = $VictoryBanner;
@onready var victory_pattern : Sprite2D = $VictoryBanner/VictoryPattern;
@onready var relics_layer : GlowNode = $Points/Relics;
@onready var die_button : Control = $Points/Relics/DieButton;
@onready var dashboard_button : Control = $Points/Relics/DashboardButton;
@onready var reset_progress_panel : Panel = $Points/Relics/DieButton/DeathProgress;

@onready var die_panel : Panel = $Points/Relics/DieButton/Panel;
@onready var die_pattern : Sprite2D = $Points/Relics/DieButton/GameplayDeathPattern;
@onready var dashboard_panel : Panel = $Points/Relics/DashboardButton/Panel;
@onready var dashboard_pattern : Sprite2D = $Points/Relics/DashboardButton/DashboardPattern;
@onready var your_point_panel : Panel = $Points/PointPanels/YourPointsPanel/Panel;
@onready var your_point_panel_top_margin : Panel = $Points/PointPanels/YourPointsPanel/TopMargin;
@onready var your_point_panel_right_margin : Panel = $Points/PointPanels/YourPointsPanel/RightMargin;
@onready var opponents_point_panel : Panel = $Points/PointPanels/OpponentsPointsPanel/Panel;
@onready var opponents_point_panel_top_margin : Panel = $Points/PointPanels/OpponentsPointsPanel/TopMargin;
@onready var opponents_point_panel_left_margin : Panel = $Points/PointPanels/OpponentsPointsPanel/LeftMargin;
@onready var your_point_pattern : Sprite2D = $Points/PointPanels/YourPointsPanel/YourPointPattern;
@onready var opponents_point_pattern : Sprite2D = $Points/PointPanels/OpponentsPointsPanel/OpponentsPointPattern;
@onready var gameplay_title : Sprite2D = $Points/TitleLayer/GameplayTitle;
@onready var title_layer : GlowNode = $Points/TitleLayer;
@onready var ocean_pattern : Sprite2D = $Background/OceanPattern;

@onready var round_results_timer : Timer = $Timers/RoundResultsTimer;
@onready var pre_results_timer : Timer = $Timers/PreResultsTimer;
@onready var round_end_timer : Timer = $Timers/RoundEndTimer;
@onready var game_over_timer : Timer = $Timers/GameOverTimer;
@onready var points_click_timer : Timer = $Timers/PointsClickTimer;
@onready var card_focus_timer : Timer = $Timers/CardFocusTimer;
@onready var opponents_play_wait : Timer = $Timers/OpponentsPlayWait;
@onready var you_play_wait : Timer = $Timers/YouPlayWait;
@onready var spying_timer : Timer = $Timers/SpyingTimer;
@onready var troll_timer : Timer = $Timers/TrollingTimer;
@onready var led_timer : Timer = $Timers/LedTimer;
@onready var auto_play_timer : Timer = $Timers/AutoPlayTimer;
@onready var start_next_round_timer : Timer = $Timers/StartNextRoundTimer;
@onready var wet_wait_timer : Timer = $Timers/WetWaitTimer;
@onready var animation_wait_timer : Timer = $Timers/AnimationWaitTimer;

@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var your_point_meter : PointMeter = $Points/PointPanels/YourPointsPanel/PointMeter;
@onready var opponents_point_meter : PointMeter = $Points/PointPanels/OpponentsPointsPanel/PointMeter;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;
@onready var animation_sfx : AudioStreamPlayer2D = $Background/AnimationSfx;
@onready var sfx_player : AudioStreamPlayer2D = $SfxPlayer;
@onready var cards_shadow : Node2D = $CardsShadow;
@onready var points_layer : Node = $Points;
@onready var keywords_hints : RichTextLabel = $CardsShadow/KeywordsHints;
@onready var opponents_face : Sprite2D = $Points/OpponentsCharacter/OpponentsFace;
@onready var enemy_name : Label = $Points/EnemyName;
@onready var your_face : Sprite2D = $Points/YourCharacter/YourFace;
@onready var your_name : Label = $Points/YourName;
@onready var your_character : JumpingText = $Points/YourCharacter;
@onready var opponents_character : JumpingText = $Points/OpponentsCharacter;
@onready var background_pattern : Sprite2D = $Background/Pattern;
@onready var trolling_sprite : Sprite2D = $TrollingSprite;
@onready var leds_layer : Node2D = $Background/Leds;
@onready var divine_judgment : DivineJudgment = $AboveCardsLayer/DivineJudgment;

func init(level_data_ : LevelData, do_start : bool = true) -> void:
	level_data = level_data_;
	init_player(player_one, GameplayEnums.Controller.PLAYER_ONE, level_data.deck2_id, do_start);
	init_player(player_two, GameplayEnums.Controller.PLAYER_TWO, level_data.deck_id, do_start);
	init_layers();
	set_going_first(0 if level_data.id == System.Levels.INTRODUCTION_LEVEL else System.Random.boolean());
	highlight_face(false);
	update_character_faces();
	initialize_background_pattern();
	cards_shadow.modulate.a = 0;
	trolling_sprite.visible = false;
	ocean_pattern.visible = false;
	spawn_leds();
	init_time_stop_nodes();
	init_audio();
	init_title();
	victory_banner.stop();
	victory_banner.visible = true;
	divine_judgment.visible = false;
	for button in [
		die_button,
		dashboard_button
	]:
		button.rotation_degrees = System.random.randf_range(-DIE_BUTTON_ROTATION, DIE_BUTTON_ROTATION) * (1 if button == die_button else 0.3);
	dashboard_button.visible = false;
	
	if !do_start:
		_on_points_click_timer_timeout();
		return;
	start_first_round();

func init_title() -> void:
	var tutorial_texture : Resource;
	gameplay_title.rotation_degrees = System.random.randf_range(-TITLE_ROTATION, TITLE_ROTATION);
	title_layer.activate_animations();
	if level_data.is_roguelike or level_data.id - 1 > System.Levels.MAX_TUTORIAL_LEVELS:
		return;
	tutorial_texture = load("res://Assets/Art/BackgroundProps/TutorialTitle.png");
	gameplay_title.texture = tutorial_texture;

func init_starting_hints() -> void:
	starting_hints.text = "[center]Rock-Paper-Scissors!\n[b]%s points[/b] [i]to[/i] win!\n[b][i]​[/i][/b]\nDrag a card forward.\n[b][i]​[/i][/b]\n[i](Hold a card in hand\nto read its effects.)[/i][/center]" % [level_data.point_goal];

func init_time_stop_nodes() -> void:
	time_stop_nodes = [
		background_pattern
	];
	time_stop_nodes2 = [
		your_face,
		opponents_face,
		die_panel,
		die_pattern,
		dashboard_panel,
		dashboard_pattern,
		reset_progress_panel,
		your_point_panel,
		your_point_panel_top_margin,
		your_point_panel_right_margin,
		opponents_point_panel,
		your_point_pattern,
		opponents_point_pattern,
		opponents_point_panel_top_margin,
		opponents_point_panel_left_margin,
		gameplay_title
	];
	for led in leds_left + leds_right:
		time_stop_nodes += led.get_shader_layers();

func highlight_face(is_yours : bool = true) -> void:
	your_face.modulate.a = ACTIVE_CHARACTER_VISIBILITY if is_yours else INACTIVE_CHARACTER_VISIBILITY;
	opponents_face.modulate.a = INACTIVE_CHARACTER_VISIBILITY if is_yours else ACTIVE_CHARACTER_VISIBILITY;
	your_character.stop();
	opponents_character.stop();
	your_character.start() if is_yours else opponents_character.start();

func init_audio() -> void:
	point_streamer.volume_db = Config.VOLUME + Config.SFX_VOLUME;

func set_going_first(value : bool):
	going_first = value;
	player_one.going_first = going_first;
	player_two.going_first = !going_first;

func spawn_leds() -> void:
	var led : Led;
	var position : Vector2 = LED_STARTING_POSITION;
	var direction : float = 1;
	if leds_right.size() > 0:
		return;
	for i in range(LEDS_PER_COLUMN):
		led = System.Instance.load_child(System.Paths.LED, leds_layer);
		led.position = Vector2(-position.x, position.y);
		leds_left.append(led);
		
		led = System.Instance.load_child(System.Paths.LED, leds_layer);
		led.position = position;
		position += Vector2(direction * LED_MARGIN.x, abs(direction) * LED_MARGIN.y);
		direction *= -0.965;
		leds_right.append(led);
	led_timer.wait_time = LED_WAIT * System.game_speed_multiplier;
	led_timer.start();

func init_player(player : Player, controller : GameplayEnums.Controller, deck_id : int, do_start : bool = true) -> void:
	var card : CardData;
	var character_id : GameplayEnums.Character = \
		level_data.player if controller == GameplayEnums.Controller.PLAYER_ONE else level_data.opponent;
	var point_meter : PointMeter = your_point_meter if player == player_one else opponents_point_meter;
	var point_goal : int = level_data.point_goal if player == player_one \
		else min(System.Rules.OPPONENT_MAX_POINT_GOAL + round(System.Rules.POINT_GOAL_MULTIPLIER * (log(level_data.point_goal) / log(System.Rules.POINT_GOAL_MULTIPLIER))), \
		level_data.point_goal, \
		System.Rules.OPPONENT_MAX_POINT_GOAL + round(level_data.point_goal / 3 / 1.5) - 3);
	player.controller = controller;
	player.point_goal = point_goal;
	player.is_roguelike = level_data.is_roguelike;
	point_meter.set_max_points(point_goal);
	if do_start:
		player.eat_decklist(deck_id, character_id);
	for c in player.cards_in_deck:
		card = c;
		card.controller = player;
	player.field_position = FIELD_POSITION if controller == GameplayEnums.Controller.PLAYER_ONE else -FIELD_POSITION;
	player.visit_point = VISIT_POSITION if controller == GameplayEnums.Controller.PLAYER_ONE else -VISIT_POSITION;
	
func initialize_background_pattern() -> void:
	var pattern : Resource = load(LEVEL_BACKGROUND_PATH % [level_data.background_id]);
	background_pattern.texture = pattern;
	background_pattern.material.set_shader_parameter("opacity", BACKGROUND_OPACITY);
	
func update_character_faces() -> void:
	var your_face_texture : Resource = load_face_texture(level_data.player_variant);
	var opponent_face_texture : Resource = load_face_texture(level_data.opponent_variant);
	var troll_texture : Resource = load(CHARACTER_FULL_ART_PATH % level_data.opponent_variant);
	var opponents_point_texture : Resource = load(OPPONENT_POINT_PATTERN_PATH % level_data.opponent_variant);
	your_face.texture = your_face_texture;
	opponents_face.texture = opponent_face_texture;
	opponents_point_pattern.texture = opponents_point_texture;
	your_name.text = translate_character_name(level_data.player);
	enemy_name.text = translate_character_name(level_data.opponent);
	trolling_sprite.texture = troll_texture;

func load_face_texture(character_id : int) -> Resource:
	return load(LevelButton.CHARACTER_FACE_PATH % character_id);

func translate_character_name(character_id : GameplayEnums.Character) -> String:
	return GameplayEnums.CharacterShowcaseName[character_id] \
		if GameplayEnums.CharacterShowcaseName.has(character_id) \
		else "?";

func get_troll_wait() -> void:
	troll_timer.wait_time = System.random.randf_range(TROLL_MIN_WAIT, TROLL_MAX_WAIT) * System.game_speed_additive_multiplier;

func have_you_won() -> bool:
	var result : bool = player_one.points >= player_one.point_goal;
	if result:
		_on_you_won();
	return result;

func _on_you_won() -> void:
	highlight_face();

func has_opponent_won() -> bool:
	var result : bool = player_two.points >= player_two.point_goal;
	if result:
		_on_opponent_wins();
	return result;

func _on_opponent_wins() -> void:
	pass;

func start_first_round() -> void:
	init_starting_hints();
	start_round();
	update_point_visuals();
	relics_layer.activate_animations();
	
func start_round() -> void:
	if has_game_ended:
		return;
	if have_you_won() or has_opponent_won():
		start_game_over();
		return;
	victory_banner.modulate.a = 0;
	round_number += 1;
	player_one.draw_hand();
	player_two.draw_hand();
	show_hand();
	player_two.shuffle_hand();
	if going_first:
		your_turn();
	else:
		opponents_turn();

func start_game_over() -> void:
	if has_game_ended:
		return;
	has_game_ended = true;
	victory_banner.fade_in(2);
	init_victory_banner_sprite();
	if did_win:
		spawn_victory_poppets();
	game_over_timer.wait_time = GAME_OVER_WAIT * System.game_speed_additive_multiplier;
	game_over_timer.start();

func init_victory_banner_sprite() -> void:
	var texture : Resource = load("res://Assets/Art/VictoryBanners/%s.png" % ["champion" if did_win else "loser"]);
	victory_pattern.texture = texture;

func spawn_victory_poppets() -> void:
	var colors : Array = get_victory_poppet_colors();
	var count : int = min(MAX_VICTORY_POPPETS, MIN_VICTORY_POPPETS + player_one.points) + System.random.randi_range(-POPPETS_RANDOM_ADDITION, POPPETS_RANDOM_ADDITION);
	for i in range(count):
		spawn_victory_poppet(System.Random.item(colors));

func get_victory_poppet_colors() -> Array:
	var colors : Array = [Poppet.PoppetColor.BLUE];
	var points : int = player_one.points;
	if points >= 10:
		colors.append(Poppet.PoppetColor.RED);
	if points >= 40:
		colors.append(Poppet.PoppetColor.GOLD);
	if points >= 100:
		colors.append(Poppet.PoppetColor.RAINBOW);
	return colors;

func spawn_victory_poppet(color : Poppet.PoppetColor) -> void:
	var y_margin : float = System.Window_.y / 2 + 2 * Poppet.MAX_SIZE.y / 2;
	var spawn_point : Vector2 = Vector2(System.random.randf_range(-System.Window_.x / 2, System.Window_.x / 2), y_margin);
	var goal_point : Vector2 = Vector2(System.random.randf_range(-System.Window_.x / 2, System.Window_.x / 2), -y_margin);
	var poppet : Poppet = spawn_poppet(spawn_point, goal_point, color);
	poppet.speed *= VICTORY_POPPET_SPEED;

func end_game() -> void:
	if is_time_stopped:
		time_stop_effect_out();
	emit_signal("game_over");

func your_turn() -> void:
	if is_spying:
		you_play_wait.wait_time = YOU_TO_PLAY_WAIT * System.game_speed_additive_multiplier;
		return you_play_wait.start();
	active_player = player_one;
	led_direction = YOUR_LED_DIRECTION if started_playing else OFF_LED_DIRECTION;
	led_color = IDLE_LED_COLOR if started_playing else OFF_LED_DIRECTION;
	show_hand();
	highlight_face();
	if player_one.hand_empty():
		_on_your_turn_end() if going_first else _on_opponent_turns_end();
		return;
	can_play_card = true;
	if !System.auto_play:
		return;
	auto_play_timer.wait_time = System.random.randf_range(AUTO_PLAY_MIN_WAIT, AUTO_PLAY_MAX_WAIT) * System.game_speed_additive_multiplier;
	auto_play_timer.start()

func init_layers() -> void:
	field_lines.modulate.a = 0;

func show_hand() -> void:
	var card : CardData;
	var gameplay_card : GameplayCard;
	for c in player_one.cards_in_hand:
		card = c;
		gameplay_card = spawn_card(card);
		show_multiplier_bar(gameplay_card);
	order_hand_positions();
	reorder_hand();

func order_hand_positions() -> void:
	var positions : Array;
	for card in player_one.cards_in_hand:
		if System.Vectors.is_inside_window(get_card(card).position, GameplayCard.SIZE * GameplayCard.MIN_SCALE):
			continue;
		positions.append(get_card(card).position);
	positions.sort_custom(func(vector_a : Vector2, vector_b : Vector2): return vector_a.x < vector_b.x);
	positions.reverse();
	for card in player_one.cards_in_hand:
		if System.Vectors.is_inside_window(get_card(card).position, GameplayCard.SIZE * GameplayCard.MIN_SCALE):
			continue;
		get_card(card).position = positions.pop_back();

func get_card(card : CardData) -> GameplayCard:
	return cards[card.instance_id] if card and cards.has(card.instance_id) else null;

func reorder_hand(do_shuffle : bool = false) -> void:
	var card : GameplayCard;
	var position : Vector2 = HAND_POSITION;
	var cards_count : int = player_one.count_hand();
	var margin : float = HAND_MARGIN * (1 if cards_count <= round(HAND_FITS_CARDS) else HAND_FITS_CARDS / cards_count);
	var layer : Node2D;
	if do_shuffle:
		player_one.cards_in_hand.shuffle()
	else:
		player_one.cards_in_hand.sort_custom(sort_by_card_position);
	position.x -= margin * ((player_one.count_hand() - 1) / 2.0);
	for card_data in player_one.cards_in_hand:
		if System.Instance.exists(active_card) and active_card.card_data.instance_id == card_data.instance_id:
			position.x += margin;
			continue;
		if !get_card(card_data) or get_card(card_data).is_despawning:
			continue;
		card = cards[card_data.instance_id];
		card.goal_position = position;
		card.move();
		layer = cards_layer if cards_layer.is_ancestor_of(card) else cards_layer2;
		layer.remove_child(card);
		layer.add_child(card);
		position.x += margin;

func spawn_card(card_data : CardData) -> GameplayCard:
	update_alterations_for_card(card_data);
	if cards.has(card_data.instance_id):
		return cards[card_data.instance_id];
	elif card_data.controller == player_two and System.Instance.exists(opponents_field_card) and card_data.instance_id == opponents_field_card.card_data.instance_id:
		opponents_field_card.is_despawning = false;
		return opponents_field_card;
	var card : GameplayCard = System.Instance.load_child(System.Paths.CARD, cards_layer if active_card == null else cards_layer2);
	card.card_data = card_data;
	card.instance_id = card_data.instance_id;
	card.init(card_data.controller.gained_keyword);
	cards[card.card_data.instance_id] = card;
	card.position = CARD_STARTING_POSITION if card_data.controller == player_one else -CARD_STARTING_POSITION;
	card.position.x = System.random.randf_range(-System.Window_.x, System.Window_.x) / 2;
	card.pressed.connect(_on_card_pressed);
	card.released.connect(_on_card_released);
	card.despawned.connect(_on_card_despawned);
	card.visited.connect(_on_card_visited);
	if is_time_stopped:
		add_time_stop_shader(card);
	card.show_multiplier_bar(0);
	card.hide_multiplier_bar();
	if card.card_data.has_aura_farming():
		card.menacing_effect();
	show_multiplier_bar(card);
	time_stop_nodes += card.get_shader_layers();
	custom_time_stop_nodes[card.card_data.instance_id] = card.get_custom_shader_layers();
	if is_time_stopped:
		var shader_material : ShaderMaterial;
		var custom_shader_material : ShaderMaterial = get_time_stop_material();
		for node in time_stop_nodes:
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

func add_time_stop_shader(card : GameplayCard) -> void:
	var material : ShaderMaterial = get_time_stop_material();
	for layer in card.get_shader_layers():
		layer.material = material;

func _on_card_visited(card : GameplayCard) -> void:
	var enemy : CardData;
	if cards_to_dissolve.has(card.instance_id):
		enemy = cards_to_dissolve[card.instance_id];
		cards_to_dissolve.erase(card.instance_id);
		loser_dissolve_effect(card.card_data, enemy);
		card.despawn_to_same_direction();
	if is_spying:
		resolve_spying(card);
		
func resolve_spying(spy_target : GameplayCard) -> void:
	var enemy : CardData = spy_target.card_data;
	var opponent : Player = enemy.controller;
	var player : Player = get_opponent(enemy);
	var card : CardData = player.get_field_card();
	var winner : GameplayEnums.Controller = determine_winner(card, enemy);
	var points : int = 1;
	var do_spy_hand : bool = spy_zone == CardEnums.Zone.HAND;
	if current_spy_type == SpyType.DIRT:
		enemy.multiply_advantage = abs(enemy.multiply_advantage) * -(pow(2, opponent.played_same_type_in_a_row + 1) if opponent.get_matching_type(enemy.card_type) != CardEnums.CardType.NULL else 1);
		show_multiplier_bar(spy_target);
		match player.controller:
			GameplayEnums.Controller.PLAYER_ONE:
				spy_target.despawn(-CARD_STARTING_POSITION if opponent.controller == GameplayEnums.Controller.PLAYER_TWO else CARD_STARTING_POSITION);
			GameplayEnums.Controller.PLAYER_TWO:
				reorder_hand();
		spying_timer.wait_time = SPY_WAIT_TIME * System.game_speed_additive_multiplier;
		spying_timer.start();
		return;
	if do_spy_hand and enemy.has_secrets():
		winner = GameplayEnums.Controller.PLAYER_ONE;
		points = 3;
	if card and card.is_gun() and winner != GameplayEnums.Controller.PLAYER_TWO:
		play_shooting_animation(card, enemy, false, false, true);
		winner = determine_winner(card, enemy);
	if enemy and enemy.is_gun() and winner != GameplayEnums.Controller.PLAYER_ONE:
		play_shooting_animation(enemy, card, false, false, true);
		winner = determine_winner(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			trigger_winner_loser_effects(card, enemy, player, opponent, points);
			opponent.discard_from_hand(enemy) if do_spy_hand else opponent.mill_from_deck(enemy);
			loser_dissolve_effect(enemy, card);
			spy_target.dissolve();
			spy_target.despawn_to_same_direction();
			if cards_to_spy > 0:
				if spy_opponent(card, player, opponent, cards_to_spy, spy_zone):
					return;
			if player != active_player and active_player.hand_empty():
				stop_spying();
				continue_play();
				return;
		GameplayEnums.Controller.PLAYER_TWO:
			trigger_winner_loser_effects(enemy, card, opponent, player);
			player.send_from_field_to_grave(card);
			if get_card(card):
				loser_dissolve_effect(card, enemy);
				get_card(card).despawn_to_same_direction();
			match player.controller:
				GameplayEnums.Controller.PLAYER_ONE:
					spy_target.despawn(-CARD_STARTING_POSITION);
				GameplayEnums.Controller.PLAYER_TWO:
					if spy_target.card_data.zone == CardEnums.Zone.HAND:
						reorder_hand();
					else:
						spy_target.despawn(-CARD_STARTING_POSITION);
			match active_player:
				GameplayEnums.Controller.PLAYER_ONE:
					if !player_one.hand_empty():
						opponents_play_wait.stop();
						pre_results_timer.stop();
						stop_spying();
						you_play_wait.wait_time = YOU_TO_PLAY_WAIT * System.game_speed_additive_multiplier;
						you_play_wait.start();
						return;
				GameplayEnums.Controller.PLAYER_TWO:
					if !player_two.hand_empty():
						you_play_wait.stop();
						stop_spying();
						opponents_play_wait.wait_time = OPPONENTS_PLAY_WAIT * System.game_speed_additive_multiplier;
						opponents_play_wait.start();
						return;
		GameplayEnums.Controller.NULL:
			play_tie_sound();
			if opponent.controller == GameplayEnums.Controller.PLAYER_TWO or !do_spy_hand:
				spy_target.despawn(-CARD_STARTING_POSITION if opponent.controller == GameplayEnums.Controller.PLAYER_TWO else CARD_STARTING_POSITION);
			else:
				reorder_hand();
	spying_timer.wait_time = SPY_WAIT_TIME * System.game_speed_additive_multiplier;
	spying_timer.start();

func continue_play() -> void:
	your_turn() if active_player == player_one else opponents_turn();

func stop_spying() -> void:
	is_spying = false;

func update_card_alterations(rerender_shader : bool = false) -> void:
	for card in player_one.get_active_cards() + player_two.get_active_cards():
		update_alterations_for_card(card, rerender_shader);
		if !is_time_stopped and get_card(card):
			if (get_card(card).has_emp_visuals and !card.has_emp()) \
			or (get_card(card).has_negative_visuals and !card.is_negative_variant()) \
			or (get_card(card).has_holographic_visuals and !card.is_holographic) \
			or (get_card(card).has_foil_visuals and !card.is_foil):
				get_card(card).add_art_base_shader(true);

func update_alterations_for_card(card_data : CardData, rerender_shader : bool = false) -> void:
	var card : GameplayCard = get_card(card_data);
	if card_data.has_undead():
		if card_data.has_undead(true):
			card_data.set_card_type(CardEnums.CardType.GUN);
		else:
			if card_data.default_type == CardEnums.CardType.MIMIC and card_data.card_type == CardEnums.CardType.GUN:
				pass;
			else:
				card_data.set_card_type(card_data.default_type);
	if card:
		if rerender_shader and !is_time_stopped:
			card.card_art.material = null;
		card.update_visuals(card.card_data.controller.gained_keyword);

func _on_card_pressed(card : GameplayCard) -> void:
	if System.Instance.exists(active_card) or card.card_data.zone != CardEnums.Zone.HAND or has_game_ended:
		return;
	if !started_playing:
		_on_started_playing();
	active_card = card;
	card.toggle_follow_mouse();
	update_keywords_hints(card);
	card_focus_timer.wait_time = CARD_FOCUS_WAIT * System.game_speed_additive_multiplier;
	card_focus_timer.start();
	put_other_cards_behind(card);

func _on_started_playing() -> void:
	started_playing = true;
	led_direction = YOUR_LED_DIRECTION;
	led_color = IDLE_LED_COLOR;
	starting_hints.die();

func toggle_points_visibility(value : bool = true) -> void:
	points_goal_visibility = 1 if value else 0;
	shadow_goal_visibility = 0 if value else 1;
	is_updating_points_visibility = true;

func update_keywords_hints(card : GameplayCard) -> void:
	keywords_hints.text = card.get_keyword_hints();

func put_other_cards_behind(card : GameplayCard) -> void:
	for instance_id in cards:
		if instance_id == card.card_data.instance_id:
			continue;
		cards_layer.remove_child(cards[instance_id]);
		cards_layer2.add_child(cards[instance_id]);

func _on_card_released(card : GameplayCard, auto_action : bool = false) -> void:
	if !System.Instance.exists(active_card) or card != active_card:
		return;
	card.toggle_follow_mouse(false);
	return_other_cards_front(card);
	active_card = null;
	card_focus_timer.stop();
	toggle_points_visibility();
	field_lines_visible = false;
	fading_field_lines = true;
	reorder_hand();
	if auto_action:
		return;
	check_if_played(card);
	show_multiplier_bar(card);

func show_multiplier_bar(gameplay_card : GameplayCard) -> void:
	if !System.Instance.exists(gameplay_card):
		return;
	var card : CardData = gameplay_card.card_data;
	var multi : int = card.multiply_advantage * card.stopped_time_advantage;
	if card.zone == CardEnums.Zone.HAND and card.has_multiply() and \
	card.controller.get_matching_type(card.card_type) != CardEnums.CardType.NULL:
		multi *= pow(2, card.controller.played_same_type_in_a_row + 1);
	if multi > 1 or multi < 0:
		gameplay_card.show_multiplier_bar(multi);
	else:
		gameplay_card.hide_multiplier_bar();

func return_other_cards_front(card : GameplayCard) -> void:
	for instance_id in cards:
		if instance_id == card.card_data.instance_id:
			continue;
		cards_layer2.remove_child(cards[instance_id]);
		cards_layer.add_child(cards[instance_id]);
	cards_layer.remove_child(card);
	cards_layer.add_child(card);

func sort_by_card_position(card_a : CardData, card_b : CardData) -> int:
	var a_x : int = cards[card_a.instance_id].position.x if cards.has(card_a.instance_id) else 0;
	var b_x : int = cards[card_b.instance_id].position.x if cards.has(card_b.instance_id) else 0;
	return a_x < b_x;

func _on_card_despawned(card : GameplayCard) -> void:
	if System.Instance.exists(card) and (player_one.get_field_card() == card.card_data or player_two.get_field_card() == card.card_data):
		return;
	cards.erase(card.instance_id);
	card.queue_free();

func check_if_played(card : GameplayCard) -> bool:
	var mouse_position : Vector2 = get_local_mouse_position();
	var card_margin : int = GameplayCard.SIZE.y;
	if !(can_play_card and mouse_position.y + card_margin >= FIELD_START_LINE and mouse_position.y - card_margin <= FIELD_END_LINE) or card.scale > GameplayCard.MIN_SCALE_VECTOR:
		return false;
	play_card(card, player_one, player_two);
	return true;

func replace_played_card(card : CardData) -> void:
	var player : Player = card.controller;
	var opponent : Player = get_opponent(card);
	var card_to_replace : GameplayCard = get_card(player.get_field_card());
	if card_to_replace:
		card_to_replace.despawn();
		card_to_replace.move();
	player.clear_field();
	play_card(spawn_card(card), player, opponent, true);

func play_card(card : GameplayCard, player : Player, opponent : Player, is_digital_speed : bool = false) -> bool:
	player.play_card(card.card_data, is_digital_speed);
	if player == player_two:
		opponents_field_card = card;
	if card.card_data.has_hydra() and !card.card_data.has_buried():
		player.build_hydra(card.card_data);
	if card.card_data.has_buried():
		if !is_digital_speed:
			card.bury();
	opponent.trigger_opponent_placed_effects();
	update_card_alterations();
	if check_for_devoured(card, player, opponent):
		reorder_hand();
		if player == player_one and System.auto_play:
			auto_play_timer.wait_time = System.random.randf_range(AUTO_PLAY_MIN_WAIT, AUTO_PLAY_MAX_WAIT) * System.game_speed_additive_multiplier;
			auto_play_timer.start();
		return false;
	elif !card.card_data.is_buried:
		trigger_play_effects(card.card_data, player, opponent);
	if player == player_two:
		show_opponents_field();
		return true;
	if !started_playing:
		_on_started_playing();
	card.goal_position = FIELD_POSITION;
	card.is_moving = true;
	reorder_hand();
	if is_digital_speed:
		return true;
	can_play_card = false;
	highlight_face(false);
	if going_first:
		_on_your_turn_end();
	else:
		_on_opponent_turns_end();
	return true;

func _on_your_turn_end() -> void:
	if has_been_stopping_turn:
		stopped_time_results();
		return;
	wait_opponent_to_play();

func _on_opponent_turns_end() -> void:
	go_to_pre_results();

func check_for_devoured(card : GameplayCard, player : Player, opponent : Player, is_digital_speed : bool = false) -> bool:
	var enemy : CardData = opponent.get_field_card();
	var eater_was_face_down : bool;
	var devoured_keywords : Array;
	if is_digital_speed:
		return false;
	if enemy and enemy.has_devour(true) and player.cards_played_this_turn == 1:
		eater_was_face_down = enemy.is_buried;
		devoured_keywords = opponent.devour_card(enemy, card.card_data);
		player.send_from_field_to_grave(card.card_data);
		if eater_was_face_down:
			trigger_play_effects(enemy, opponent, player);
		else:
			for keyword in devoured_keywords:
				trigger_play_effects(enemy, opponent, player, keyword);
		update_alterations_for_card(enemy);
		spawn_tongue(card, get_card(enemy));
		erase_card(card, opponent.field_position + Vector2(0, -GameplayCard.SIZE.y * 0.1 \
			if player.controller == GameplayEnums.Controller.PLAYER_ONE else 0));
		
		return true;
	return false;

func spawn_tongue(card : GameplayCard, enemy : GameplayCard) -> void:
	var tongue : Tongue;
	if !card or !enemy:
		return;
	tongue = System.Instance.load_child(System.Paths.TONGUE, cards_layer2);
	tongue.form(enemy, card);
	emit_signal("quick_zoom_to", enemy.position);
	play_gulp_sound();

func play_time_stop_sound() -> void:
	var sound : Resource = load("res://Assets/SFX/CardSounds/Bursts/time-stop.wav");
	play_sfx(sound, Config.SFX_VOLUME + Config.GUN_VOLUME, System.game_speed * time_stop_goal_velocity / TIME_STOP_IN_GLITCH_MIN_SPEED);
	emit_signal("stop_music");
	if Config.MUTE_SFX:
		return;
	await sfx_player.finished;
	emit_signal("play_song", 1001, System.random.randf_range(MIN_TIME_STOP_PITCH, MAX_TIME_STOP_PITCH));

func play_time_stop_sound_reverse() -> void:
	var sound : Resource = load("res://Assets/SFX/CardSounds/Bursts/time-accelerate.wav");
	play_sfx(sound, Config.SFX_VOLUME + Config.GUN_VOLUME, 1 * ((time_stop_goal_velocity + time_stop_goal_velocity2) / (TIME_STOP_OUT_BW_MIN_SPEED + TIME_STOP_OUT_GLITCH_MIN_SPEED)));
	if !Config.MUTE_SFX:
		await sfx_player.finished;
	emit_signal("play_prev_song");

func play_gulp_sound() -> void:
	var sound : Resource = load("res://Assets/SFX/CardSounds/Transformations/mimic-gulp.wav");
	await System.wait(GULP_WAIT);
	play_sfx(sound, Config.SFX_VOLUME + Config.GUN_VOLUME);

func play_sfx(sound : Resource, volume : int = Config.SFX_VOLUME, pitch : float = System.game_speed):
	if Config.MUTE_SFX:
		return;
	sfx_player.pitch_scale = pitch;
	sfx_player.volume_db = volume;
	sfx_player.stream = sound;
	sfx_player.play();

func erase_card(card : GameplayCard, despawn_position : Vector2 = Vector2.ZERO) -> void:
	cards.erase(card.instance_id);
	cards_layer.remove_child(card);
	cards_layer2.add_child(card);
	card.despawn(despawn_position);

func trigger_play_effects(card : CardData, player : Player, opponent : Player, only_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	var enemy : CardData = opponent.get_field_card();
	var keywords : Array = [only_keyword] if only_keyword != CardEnums.Keyword.NULL else card.get_keywords();
	if enemy and enemy.has_carrot_eater() and !is_time_stopped:
		eat_carrot(enemy);
	for keyword in keywords:
		match keyword:
			CardEnums.Keyword.ALPHA_WEREWOLF:
				player.played_alpha_werewolf = true;
			CardEnums.Keyword.CELEBRATE:
				celebrate(player);
			CardEnums.Keyword.CLONING:
				trigger_cloning(card, player);
			CardEnums.Keyword.CONTAGIOUS:
				trigger_contagious(card, player);
			CardEnums.Keyword.HORSE_GEAR:
				draw_horse_card(player);
			CardEnums.Keyword.INFLUENCER:
				influence_opponent(opponent, card.card_type);
			CardEnums.Keyword.PERFECT_CLONE:
				trigger_cloning(card, player, true);
			CardEnums.Keyword.RAINBOW:
				opponent.get_rainbowed();
				update_card_alterations(true);
			CardEnums.Keyword.RELOAD:
				player.shuffle_random_card_to_deck(CardEnums.CardType.GUN).controller = player;
			CardEnums.Keyword.SABOTAGE:
				trigger_sabotage(card, opponent);
			CardEnums.Keyword.SCAMMER:
				player.points = -100;
				gain_points_effect(player);
			CardEnums.Keyword.SPRING_ARRIVES:
				trigger_spring_arrives(card, player);
			CardEnums.Keyword.VERY_NUTTY:
				if !enemy or !enemy.has_november():
					player.nut_multiplier *= 2;
			CardEnums.Keyword.WRAPPED:
				player.gained_keyword = CardEnums.Keyword.BURIED;
	if is_time_stopped:
		return;
	if card.has_time_stop():
		activate_time_stop(card);
		return;
	for keyword in keywords:
		match keyword:
			CardEnums.Keyword.BERSERK:
				spy_opponent(card, player, opponent, System.Rules.MAX_BERSERKER_SHOTS, CardEnums.Zone.DECK);
			CardEnums.Keyword.CARROT_EATER:
				eat_carrot(card);
			CardEnums.Keyword.DIRT:
				spy_opponent(card, player, opponent, 1, CardEnums.Zone.HAND, SpyType.DIRT);
			CardEnums.Keyword.MULTI_SPY:
				spy_opponent(card, player, opponent, 3);
			CardEnums.Keyword.NUT_COLLECTOR:
				if !enemy or !enemy.has_november():
					collect_nuts(player);
			CardEnums.Keyword.OCEAN:
				trigger_ocean(card);
			CardEnums.Keyword.POSITIVE:
				trigger_positive(card, enemy, player);
			CardEnums.Keyword.SPY:
				spy_opponent(card, player, opponent);

func trigger_sabotage(card : CardData, opponent : Player) -> void:
	var enemy : CardData = opponent.random_discard(true);
	var gameplay_card : GameplayCard;
	if !System.Instance.exists(enemy):	
		return;
	gameplay_card = spawn_card(enemy);
	if opponent == player_one:
		show_hand();
		gameplay_card.go_visit_point(VISIT_POSITION);
		cards_to_dissolve[enemy.instance_id] = card;
	else:
		gameplay_card = spawn_card(enemy);
		gameplay_card.go_visit_point(-VISIT_POSITION);
		cards_to_dissolve[enemy.instance_id] = card;
		
func trigger_spring_arrives(card : CardData, player : Player) -> void:
	var hand_size : int = player.count_hand();
	player.fill_hand();
	for i in range(System.Rules.MAX_HAND_SIZE - hand_size):
		card.multiply_advantage *= 2;
	if player == player_one:
		show_hand();

func trigger_contagious(source_card : CardData, player : Player) -> void:
	var card_type : CardEnums.CardType = source_card.card_type;
	var card_to_alter : CardData;
	var source : Array;
	var card : CardData;
	for c in player.cards_in_hand:
		card = c;
		if !card.card_types.has(card_type):
			source.append(card);
	if source.is_empty():
		return;
	card_to_alter = System.Random.item(source);
	if card_to_alter.is_dual_type() and CardEnums.BASIC_COLORS.has(card_type):
		card_type = System.Random.item(CardData.expand_type(card_type));
	player.rainbow_a_card(card_to_alter, card_type);
	player.make_card_alterations_permanent(card_to_alter);
	if card_to_alter.has_auto_hydra():
		player.build_hydra(card_to_alter, true);
	update_alterations_for_card(card_to_alter, true);

func trigger_cloning(card : CardData, player : Player, is_perfect_clone : bool = false) -> void:
	var cloned_card : CardData;
	var card_to_clone : CardData;
	var gameplay_card : GameplayCard;
	if player.hand_empty() or (player.count_hand() + 1) > System.Rules.MAX_HAND_SIZE:
		return;
	card_to_clone = System.Random.item(player.cards_in_hand);
	cloned_card = player.spawn_card(card_to_clone, CardEnums.Zone.HAND);
	cloned_card.spawn_id = System.random.randi();
	if is_perfect_clone:
		cloned_card.is_holographic = true;
		cloned_card.stamp = CardEnums.Stamp.RARE;
	if cloned_card.controller == player_two:
		return;
	gameplay_card = spawn_card(cloned_card);
	player.make_new_card_permanent(cloned_card);
	if get_card(card_to_clone):
		var pos : Vector2 = get_card(card_to_clone).position;
		gameplay_card.position = pos + Vector2(-2, 0);
	show_hand();

func trigger_positive(card : CardData, enemy : CardData, player : Player) -> void:
	var multiplier : int = calculate_base_points(card, enemy, true, false);
	var points_gained : int = player.gain_points(player.points * multiplier, false);
	if points_gained == 0:
		return;
	wait_for_animation(card, AnimationType.POSITIVE, {
		"points": points_gained,
		"card": card,
		"player": player
	});

func wait_for_animation(card : CardData, type : AnimationType, animation_data : Dictionary = {}) -> void:
	var instance_id = System.Random.instance_id();
	var animation_sound : Resource;
	if animation_instance_id != 0:
		animation_wait_timer.stop();
		after_animation(true);
	animation_instance_id = instance_id;
	animation_data.type = type;
	current_animation_type = type;
	animations[instance_id] = animation_data;
	animation_wait_timer.wait_time = System.random.randf_range(AnimationMinWaitTime[type], AnimationMaxWaitTime[type]) * System.game_speed_additive_multiplier;
	animation_wait_timer.start();
	is_waiting_for_animation_to_finnish = true;
	match type:
		AnimationType.OCEAN:
			pass;
		AnimationType.POSITIVE:
			if get_card(animation_data.card):
				get_card(animation_data.card).shine_star_effect();
	if get_card(card):
		ocean_card = get_card(card);
	ocean_pattern.material = get_ocean_material_for_animation(animation_data.type);
	ocean_effect_wave_speed = System.random.randf_range(OCEAN_EFFECT_MIN_STARTING_WAVE_SPEED, OCEAN_EFFECT_MAX_STARTING_WAVE_SPEED);
	ocean_effect_speed_exponent = System.random.randf_range(OCEAN_SPEED_EFFECT_MIN_EXPONENT, OCEAN_SPEED_EFFECT_MAX_EXPONENT);
	is_low_tiding = false;
	ocean_pattern.visible = true;
	ocean_pattern.modulate.a = 0;
	high_tide_speed = System.random.randf_range(HIGH_TIDE_MIN_SPEED, HIGH_TIDE_MAX_SPEED);
	match animation_data.type:
		AnimationType.POSITIVE:
			high_tide_speed *= 2;
			ocean_effect_speed_exponent /= 5;
	emit_signal("stop_music");
	if Config.MUTE_SFX:
		return;
	animation_sfx.stream = load(get_animation_sound_path(type));
	animation_sfx.volume_db = Config.SFX_VOLUME + Config.GUN_VOLUME;
	animation_sfx.play();

func get_ocean_material_for_animation(type : AnimationType) -> ShaderMaterial:
	var shader : Resource;
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	match type:
		AnimationType.OCEAN:
			shader = load("res://Shaders/CardEffects/ocean-shader.gdshader");
		AnimationType.POSITIVE:
			shader = load("res://Shaders/Background/star-wave.gdshader");
	shader_material.shader = shader;
	match type:
		AnimationType.OCEAN:
			shader_material.set_shader_parameter("wave_speed", 1.0);
			shader_material.set_shader_parameter("wave_frequency", 20.0);
			shader_material.set_shader_parameter("wave_amplitude", 0.02);
			shader_material.set_shader_parameter("water_color", Color(0.0, 0.4, 0.8, 1.0));
			shader_material.set_shader_parameter("shine_speed", 10.0);
			shader_material.set_shader_parameter("shine_color", Color(1.0, 1.0, 1.0, 1.0));
			shader_material.set_shader_parameter("shine_strength", 0.3);
			shader_material.set_shader_parameter("opacity", 1.0);
			shader_material.set_shader_parameter("mix_rate", 1.0);
		AnimationType.POSITIVE:
			shader_material.set_shader_parameter("wave_speed", 0)
			shader_material.set_shader_parameter("wave_frequency", 20.0)
			shader_material.set_shader_parameter("wave_amplitude", 0.02)
			shader_material.set_shader_parameter("star_points", 5)
			shader_material.set_shader_parameter("star_sharpness", 5.0)
			shader_material.set_shader_parameter("star_color", Color(1.0, 1.0, 0.0, 1.0))
			shader_material.set_shader_parameter("shine_speed", 5.0)
			shader_material.set_shader_parameter("shine_color", Color(0.0, 0.0, 0.7, 1.0))
			shader_material.set_shader_parameter("shine_strength", 5.0)
			shader_material.set_shader_parameter("opacity", 1.0)
			shader_material.set_shader_parameter("mix_rate", 1.0)
			shader_material.set_shader_parameter("wave_center", Vector2(0.5, 0.5))
	return shader_material;

func get_animation_sound_path(type : AnimationType) -> String:
	match type:
		AnimationType.OCEAN:
			return "res://Assets/SFX/CardSounds/Bursts/ocean.wav";
		AnimationType.POSITIVE:
			return "res://Assets/SFX/CardSounds/Bursts/positive-sound.wav";
	return "";

func draw_horse_card(player : Player) -> void:
	if player.draw_horse():
		show_hand();

func trigger_ocean(card : CardData) -> void:
	var enemy : CardData = get_opponent(card).get_field_card();
	var cards_to_wet : Array = player_one.cards_in_hand.duplicate() + player_two.cards_in_hand.duplicate() + ([enemy] if enemy else []) + [card];
	var wait_per_card_trigger : float;
	var triggers : int;
	for c in cards_to_wet:
		if make_card_wet(c, false) and (c.controller == player_one or c.zone == CardEnums.Zone.FIELD):
			triggers += 1;
	has_ocean_wet_self = false;
	wait_for_animation(card, AnimationType.OCEAN);
	wait_per_card_trigger = animation_wait_timer.wait_time / (triggers + 2);
	await System.wait(wait_per_card_trigger * 1.9);
	for c in cards_to_wet:
		if c == card:
			has_ocean_wet_self = true;
		if make_card_wet(c):
			await System.wait(wait_per_card_trigger);

func eat_carrot(card : CardData) -> void:
	var enemy : CardData = get_opponent(card).get_field_card();
	var keywords : Array;
	var sound : Resource;
	if !enemy or enemy.is_buried:
		return;
	keywords = enemy.keywords.duplicate();
	keywords.shuffle();
	for keyword in keywords:
		if card.add_keyword(keyword):
			card.keywords.erase(CardEnums.Keyword.CARROT_EATER);
			enemy.keywords.erase(keyword);
			sound = load("res://Assets/SFX/CardSounds/Transformations/puffer-fish.wav");
			play_sfx(sound);
			trigger_play_effects(card, card.controller, get_opponent(card), keyword);
			break;

func activate_time_stop(card : CardData) -> void:
	if time_stopping_player != null:
		return;
	time_stopping_player = card.controller;
	time_stop_effect_in();

func collect_nuts(player : Player) -> void:
	for i in range(System.Rules.NUTS_TO_COLLECT):
		player.spawn_card_from_id(System.Random.item(CardEnums.NUT_IDS));
	player.shuffle_deck();

func spy_opponent(card : CardData, player : Player, opponent : Player, chain : int = 1, zone : CardEnums.Zone = CardEnums.Zone.HAND, spy_type : SpyType = SpyType.FIGHT) -> bool:
	var spied_card_data : CardData;
	var spied_card : GameplayCard;
	spy_zone = zone;
	var do_spy_hand : bool = spy_zone == CardEnums.Zone.HAND;
	if do_spy_hand and opponent.hand_empty():
		return false;
	current_spy_type = spy_type;
	spied_card_data = determine_spied_card(opponent) if do_spy_hand else opponent.get_top_deck();
	spawn_card(spied_card_data);
	spied_card = get_card(spied_card_data);
	match opponent.controller:
		GameplayEnums.Controller.PLAYER_ONE:
			if System.Instance.exists(active_card) and spied_card == active_card:
				_on_card_released(spied_card, true);
	spied_card.go_visit_point(opponent.visit_point);
	cards_to_spy = chain - 1;
	is_spying = true;
	return true;

func determine_spied_card(opponent : Player) -> CardData:
	var cards_with_secret : Array = opponent.cards_in_hand.filter(func(card : CardData):
		return card.has_secrets();	
	);
	var source : Array = cards_with_secret if current_spy_type == SpyType.FIGHT and cards_with_secret.size() else opponent.cards_in_hand.duplicate();
	return System.Random.item(source);

func celebrate(player : Player) -> void:
	var cards_where_in_hand : Array = player.cards_in_hand.duplicate();
	player.celebrate();
	for card in cards_where_in_hand:
		if get_card(card):
			get_card(card).despawn();
	show_hand();

func opponents_turn() -> void:
	var card : CardData;
	if is_spying:
		return wait_opponent_to_play();
	active_player = player_two;
	if player_two.hand_empty():
		_on_opponent_turns_end() if going_first else your_turn();
		return;
	led_direction = OPPONENTS_LED_DIRECTION;
	led_color = IDLE_LED_COLOR;
	player_two.cards_in_hand.sort_custom(best_to_play_for_opponent);
	#for car in player_two.cards_in_hand:
		#print(car.card_name, " ", get_result_for_playing(car));
	#print("-----");
	card = player_two.cards_in_hand.back();
	if !play_card(spawn_card(card), player_two, player_one):
		wait_opponent_playing();
		return;
	if going_first or has_been_stopping_turn:
		go_to_pre_results();
	else:
		your_turn();

func wait_opponent_to_play(do_extend : bool = false) -> void:
	opponents_play_wait.wait_time = OPPONENT_TO_PLAY_WAIT * (2 if do_extend else 1) * System.game_speed_additive_multiplier;
	opponents_play_wait.start();

func wait_opponent_playing() -> void:
	opponents_play_wait.wait_time = OPPONENTS_PLAY_WAIT * System.game_speed_additive_multiplier;
	opponents_play_wait.start();

func cannot_go_to_results() -> bool:
	return is_spying or is_waiting_for_animation_to_finnish or is_wet_wait_on;

func go_to_results() -> void:
	#This structure waits and comes back everytime some action is done
	#So that player has time to see animation and react mentally.
	#Better structure to use enum for the phase and make it not crawl
	#The whole structure like this. Fix, if this ever gets longer than
	#Let's say 100 lines :D
	if is_time_stopped:
		return start_results();
	if cannot_go_to_results():
		return results_wait();
	if results_phase < 2:
		if mimics_phase():
			return results_wait();
	if results_phase < 4:
		if nut_phase():
			return results_wait(NUT_WAIT_MULTIPLIER - 0.2 * nut_combo);
	if results_phase < 6:
		if digitals_phase():
			return results_wait();
	if results_phase < 8:
		if shadow_replace_phase():
			return results_wait();
	show_multiplier_bar(get_card(player_one.get_field_card()));
	show_multiplier_bar(get_card(player_two.get_field_card()));
	start_results();

func start_results() -> void:
	round_results_timer.wait_time = ROUND_RESULTS_WAIT * System.game_speed_additive_multiplier;
	round_results_timer.start();

func mimics_phase() -> bool:
	if going_first:
		if results_phase < 1:
			results_phase = 1;
			if transform_your_mimics():
				return true;
		if results_phase < 2:
			results_phase = 2;
			if transform_opponents_mimics():
				return true;
	else:
		if results_phase < 1:
			results_phase = 1;
			if transform_opponents_mimics():
				return true;
		if results_phase < 2:
			results_phase = 2;
			if transform_your_mimics():
				return true;
	return false;

func nut_phase() -> bool:
	if going_first:
		if results_phase < 3:
			results_phase = 3;
			if nut_your_nuts():
				results_phase = 2;
				return true;
		if results_phase < 4:
			results_phase = 4;
			if nut_opponents_nuts():
				results_phase = 3;
				return true;
	else:
		if results_phase < 3:
			results_phase = 3;
			if nut_opponents_nuts():
				results_phase = 2;
				return true;
		if results_phase < 4:
			results_phase = 4;
			if nut_your_nuts():
				results_phase = 3;
				return true;
	nut_combo = 0;
	return false;

func nut_your_nuts() -> bool:
	return nut_players_nuts(player_one, player_two);

func nut_opponents_nuts() -> bool:
	return nut_players_nuts(player_two, player_one);

func nut_players_nuts(player : Player, opponent : Player) -> bool:
	var card : CardData = player.get_field_card();
	var enemy : CardData = opponent.get_field_card();
	if !card or (enemy and enemy.stopped_time_advantage > 1):
		return false;
	var can_nut : bool = (card.get_max_nuts() > 0) or (!card.has_november() and enemy and enemy.has_shared_nut());
	var can_steal_nut : bool = card.has_nut_stealer() and enemy and enemy.can_nut(card.has_shared_nut());
	var nut_prevented : bool = enemy and (enemy.has_november() or enemy.has_nut_stealer());
	if card.has_copycat() and enemy:
		card.set_card_type(enemy.card_type);
		update_alterations_for_card(card);
	if can_nut and !nut_prevented and card.can_nut(enemy and enemy.has_shared_nut()):
		if nut_with_card(card, enemy, player):
			return true;
	if can_steal_nut and !nut_prevented and card.nuts_stolen < 2 * max(1, enemy.get_max_nuts(card.has_shared_nut())):
		if nut_with_card(card, enemy, player):
			card.nuts -= 1;
			card.nuts_stolen += 1;
			return true;
	return false;

func nut_with_card(card : CardData, enemy : CardData, player : Player) -> bool:
	var multiplier : int = calculate_base_points(card, enemy, true, false);
	var points : int = player.points;
	card.nuts += 1;
	if player.do_nut(multiplier):
		points = player.points - points;
		spawn_poppets(points, card, player);
		if get_card(card):
			get_card(card).recoil(get_card(card).position);
			var sound : Resource = load("res://Assets/SFX/CardSounds/Bursts/bottle-shake.wav");
			play_sfx(sound, Config.SFX_VOLUME, System.game_speed * pow(1.1, nut_combo));
			emit_signal("quick_zoom_to", get_card(card).position);
			nut_combo += 1;
		gain_points_effect(player);
		return true;
	return false;

func gain_points_effect(player : Player) -> void:
	click_your_points() if player == player_one else click_opponents_points();
	update_point_visuals();

func shadow_replace_phase() -> bool:
	if going_first:
		if results_phase < 7:
			results_phase = 7;
			if play_your_shadows():
				return true;
		if results_phase < 8:
			results_phase = 8;
			if play_opponents_shadows():
				results_phase = 2;
				return true;
	else:
		if results_phase < 7:
			results_phase = 7;
			if play_opponents_shadows():
				return true;
		if results_phase < 8:
			results_phase = 8;
			if play_your_shadows():
				results_phase = 2;
				return true;
	return false;

func play_your_shadows() -> bool:
	return play_shadows(player_one, player_two);

func play_opponents_shadows() -> bool:
	return play_shadows(player_two, player_one);

func no_reason_to_counterspell(player : Player, opponent : Player) -> bool:
	var winner : GameplayEnums.Controller = determine_winning_player(player, opponent);
	return (player.get_field_card() and player.get_field_card().has_cursed()) or winner == GameplayEnums.Controller.PLAYER_ONE;

func play_shadows(player : Player, opponent : Player) -> bool:
	var shadow_card : CardData;
	var card : CardData = player.get_field_card();
	var enemy : CardData = opponent.get_field_card();
	var winner : GameplayEnums.Controller = determine_winning_player(player, opponent);
	if no_reason_to_counterspell(player, opponent) or player.deck_empty():
		return false;
	for i in range(player.count_deck()):
		var c : CardData = player.cards_in_deck[player.count_deck() - (1 + i)];
		if !c.has_aura_farming() or (c.has_shadow_replace() and ![winner, GameplayEnums.Controller.PLAYER_TWO].has(determine_winner(c, enemy))):
			if (card and card.has_shadow_replace()) or c.has_shadow_replace():
				shadow_card = c;
	if shadow_card == null:
		return false;
	if [winner, GameplayEnums.Controller.PLAYER_TWO].has(determine_winner(shadow_card, enemy)):
		return false;
	replace_played_card(shadow_card);
	return true;

func digitals_phase() -> bool:
	var card : CardData = player_one.get_field_card();
	var enemy : CardData = player_two.get_field_card();
	if (card and card.has_emp()) or (enemy and enemy.has_emp()):
		return false;
	if going_first:
		if results_phase < 5:
			results_phase = 5;
			if play_your_digitals():
				return true;
		if results_phase < 6:
			results_phase = 6;
			if play_opponents_digitals():
				results_phase = 2;
				return true;
	else:
		if results_phase < 5:
			results_phase = 5;
			if play_opponents_digitals():
				return true;
		if results_phase < 6:
			results_phase = 6;
			if play_your_digitals():
				results_phase = 2;
				return true;
	return false;

func transform_your_mimics() -> bool:
	var enemy : CardData = player_two.get_field_card();
	if enemy and enemy.prevents_opponents_reveal():
		return false;
	return transform_mimics(player_one.cards_on_field, player_one, player_two);

func transform_opponents_mimics() -> bool:
	var enemy : CardData = player_one.get_field_card();
	if enemy and enemy.prevents_opponents_reveal():
		return false;
	return transform_mimics(player_two.cards_on_field, player_two, player_one);

func play_your_digitals() -> bool:
	return play_digitals(player_one, player_two);

func play_opponents_digitals() -> bool:
	return play_digitals(player_two, player_one);

func play_digitals(player : Player, opponent : Player) -> bool:
	var cards : Array;
	var enemy : CardData;
	var digital_to_play : CardData;
	var winner : GameplayEnums.Controller = determine_winning_player(player, opponent);
	if no_reason_to_counterspell(player, opponent):
		return false;
	cards = player.cards_in_hand.filter(func(card : CardData): return card.has_digital());
	enemy = opponent.get_field_card();
	if cards.size() == 0:
		return false;
	cards.sort_custom(
		func(card_a : CardData, card_b : CardData):
			return determine_points_result(card_a, enemy) < determine_points_result(card_b, enemy);
	);
	digital_to_play = cards.back();
	if [winner, GameplayEnums.Controller.PLAYER_TWO].has(determine_winner(digital_to_play, enemy)):
		return false;
	replace_played_card(digital_to_play);
	return true;

func get_opponent(card : CardData) -> Player:
	if card.controller == player_one:
		return player_two;
	return player_one;

func determine_points_result(card : CardData, enemy : CardData) -> int:
	var winner : GameplayEnums.Controller = determine_winner(card, enemy);
	var win_points : int = get_win_points(card, enemy);
	var lose_points : int = get_lose_points(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			return win_points;
		GameplayEnums.Controller.PLAYER_TWO:
			return lose_points;
	return 0;

func get_win_points(card : CardData, enemy : CardData) -> int:
	var points : int = calculate_base_points(card, enemy, true);
	var points_to_steal : int = calculate_points_to_steal(card, enemy);
	return points + points_to_steal;

func get_lose_points(card : CardData, enemy : CardData) -> int:
	var points : int = calculate_base_points(card, enemy, false, false);
	var points_to_lose : int = calculate_points_to_steal(enemy, card);
	return -(points + points_to_lose);

func calculate_base_points(card : CardData, enemy : CardData, did_win : bool = false, add_advantages : bool = true) -> int:
	var points : int = 1;
	if card and card.has_champion():
		points *= 2;
	if enemy and enemy.has_champion():
		points *= 2;
	if add_advantages:
		if card.stopped_time_advantage > 1:
			points *= card.stopped_time_advantage;
		if abs(card.multiply_advantage) > 1:
			points *= abs(card.multiply_advantage);
		if enemy and enemy.multiply_advantage < 0:
			points *= abs(enemy.multiply_advantage)
	if !did_win:
		return points;
	if card.has_rare_stamp():
		points *= 2;
	if card.is_holographic:
		points *= 2;
	if card.is_god() and points < 10:
		points = 10;
	return points;

func calculate_points_to_steal(card : CardData, enemy : CardData) -> int:
	var points : int;
	if card.has_vampire():
		points += 1;
	if enemy.has_salty():
		points += 1;
	return min(points, enemy.controller.points);

func determine_winning_player(player : Player, opponent : Player) -> GameplayEnums.Controller:
	return determine_winner(player.get_field_card(), opponent.get_field_card());

func go_to_pre_results() -> void:
	results_phase = 0;
	results_wait();

func results_wait(multiplier : float = 1) -> void:
	pre_results_timer.wait_time = PRE_RESULTS_WAIT * System.game_speed_additive_multiplier * multiplier;
	pre_results_timer.start();

func no_mimics() -> bool:
	var card_data : CardData;
	if (player_one.get_field_card() and player_one.get_field_card().prevents_opponents_reveal()) \
	or (player_two.get_field_card() and player_two.get_field_card().prevents_opponents_reveal()):
		return true;
	for card in cards:
		card_data = cards[card].card_data;
		if card_data.card_type == CardEnums.CardType.MIMIC or card_data.is_buried:
			return false;
	return true;

func transform_mimics(your_cards : Array, player : Player, opponent : Player) -> bool:
	var card : CardData;
	var transformed_any : bool;
	for c in your_cards:
		card = c;
		if card.is_buried:
			card.is_buried = false;
			if card.has_hydra():
				player.build_hydra(card);
			trigger_play_effects(card, player, opponent);
			transformed_any = true;
		if card.has_copycat() and opponent.get_field_card():
			card.set_card_type(opponent.get_field_card().card_type);
		if get_card(card):
			update_alterations_for_card(card);
	return transformed_any;

func influence_opponent(opponent : Player, card_type : CardEnums.CardType) -> void:
	opponent.cards_in_deck[opponent.cards_in_deck.size() - 1].eat_json(System.Data.read_card(CardEnums.BasicIds[card_type]));

func best_to_play_for_you(card_a : CardData, card_b : CardData) -> int:
	return best_to_play(card_a, card_b, player_one, player_two);

func best_to_play_for_opponent(card_a : CardData, card_b : CardData) -> int:
	return best_to_play(card_a, card_b, player_two, player_one);

func best_to_play(card_a : CardData, card_b : CardData, player : Player, opponent : Player) -> int:
	var a_value : int = get_result_for_playing(card_a, player, opponent);
	var b_value : int = get_result_for_playing(card_b, player, opponent);
	if a_value == b_value:
		return most_valuable(card_a, card_b, player, opponent) * (-1 if time_stopping_player == player else 1);
	return a_value < b_value if time_stopping_player != player else a_value > b_value;

func most_valuable(card_a : CardData, card_b : CardData, player : Player, opponent : Player) -> int:
	return -get_card_value(card_a, player, opponent, -1) < -get_card_value(card_b, player, opponent, -1);

func get_card_value(card : CardData, player : Player, opponent : Player, direction : int = 1) -> int:
	var value : int = 10 * get_card_base_value(card);
	var card_data : CardData;
	for c in player.cards_in_hand:
		card_data = c;
		if card_data.card_type == card.card_type:
			value += direction * 1;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.ALPHA_WEREWOLF:
				value -= 2;
			CardEnums.Keyword.BERSERK:
				value += 5;
			CardEnums.Keyword.BURIED:
				value += 5;
			CardEnums.Keyword.CELEBRATE:
				value += 0;
			CardEnums.Keyword.CHAMELEON:
				value += 1;
			CardEnums.Keyword.CLONING:
				value += player.cards_in_hand.size();
			CardEnums.Keyword.CONTAGIOUS:
				value += 5 if card.is_gun() else 0;
			CardEnums.Keyword.COOTIES:
				value += 1;
			CardEnums.Keyword.COPYCAT:
				value += 1;
			CardEnums.Keyword.CURSED:
				value += 1;
			CardEnums.Keyword.DEVOUR:
				value += 5 if player.going_first else -1;
			CardEnums.Keyword.DIGITAL:
				value += 3;
			CardEnums.Keyword.DIRT:
				value += 4;
			CardEnums.Keyword.DIVINE:
				value += 0;
			CardEnums.Keyword.ELECTROCUTE:
				value += 1;
			CardEnums.Keyword.EMP:
				value += 2;
			CardEnums.Keyword.EXTRA_SALTY:
				value += 6 if player.points == 0 else 2;
			CardEnums.Keyword.GREED:
				value += 10;
			CardEnums.Keyword.HIGH_GROUND:
				value += 2;
			CardEnums.Keyword.HIGH_NUT:
				value += 2 * player.turns_waited_to_nut * player.nut_multiplier;
			CardEnums.Keyword.HORSE_GEAR:
				value += 4;
			CardEnums.Keyword.HYDRA:
				value += 2;
			CardEnums.Keyword.INCINERATE:
				value += 1;
			CardEnums.Keyword.INFLUENCER:
				value -= 1;
			CardEnums.Keyword.MULTI_SPY:
				value += 3;
			CardEnums.Keyword.MULTIPLY:
				value += 0;
			CardEnums.Keyword.MUSHY:
				value -= 1;
			CardEnums.Keyword.NOVEMBER:
				value += 1;
			CardEnums.Keyword.NUT:
				value += 2 * player.turns_waited_to_nut * player.nut_multiplier;
			CardEnums.Keyword.NUT_COLLECTOR:
				value += 1;
			CardEnums.Keyword.NUT_STEALER:
				value += 1;
			CardEnums.Keyword.OCEAN:
				value += 0;
			CardEnums.Keyword.OCEAN_DWELLER:
				value += 0;
			CardEnums.Keyword.PAIR:
				value += 3;
			CardEnums.Keyword.PAIR_BREAKER:
				value += 1;
			CardEnums.Keyword.PERFECT_CLONE:
				value += 2 * player.cards_in_hand.size();
			CardEnums.Keyword.PICK_UP:
				value += 0;
			CardEnums.Keyword.POSITIVE:
				value += 2 * player.points;
			CardEnums.Keyword.RAINBOW:
				value += 1;
			CardEnums.Keyword.RELOAD:
				value += 1;
			CardEnums.Keyword.RUST:
				value += 1;
			CardEnums.Keyword.SABOTAGE:
				value += 4;
			CardEnums.Keyword.SALTY:
				value += 5 if player.points == 0 else 1;
			CardEnums.Keyword.SCAMMER:
				value -= 100;
			CardEnums.Keyword.SECRETS:
				value += 0;
			CardEnums.Keyword.SHARED_NUT:
				value += 2 * (player.turns_waited_to_nut * player.nut_multiplier - opponent.turns_waited_to_nut * opponent.nut_multiplier);
			CardEnums.Keyword.SILVER:
				value += 1;
			CardEnums.Keyword.SOUL_HUNTER:
				value += 1;
			CardEnums.Keyword.SPRING_ARRIVES:
				value *= pow(2, System.Rules.MAX_HAND_SIZE - player.count_hand());
			CardEnums.Keyword.SPY:
				value += 2;
			CardEnums.Keyword.TIDAL:
				value += 0;
			CardEnums.Keyword.TIME_STOP:
				value += 10;
			CardEnums.Keyword.UNDEAD:
				value -= 1;
			CardEnums.Keyword.VAMPIRE:
				value += 5 if opponent.points > 0 else 0;
			CardEnums.Keyword.VERY_NUTTY:
				value += 10 * player.turns_waited_to_nut * player.nut_multiplier;
			CardEnums.Keyword.WEREWOLF:
				value += 0;
			CardEnums.Keyword.WRAPPED:
				value += 0 if player.going_first else 1;
	value *= calculate_base_points(card, null, true);
	if value < 0:
		return value;
	if card.is_gun and !card.is_buried and (time_stopping_player == player or (time_stopping_player == null and card.has_time_stop())):
		value *= card.stopped_time_advantage;
	return value;

func get_card_base_value(card : CardData) -> int:
	match card.card_type:
		CardEnums.CardType.ROCK:
			return 1;
		CardEnums.CardType.PAPER:
			return 1;
		CardEnums.CardType.SCISSORS:
			return 1;
		CardEnums.CardType.GUN:
			return 3;
		CardEnums.CardType.BEDROCK:
			return 2;
		CardEnums.CardType.ZIPPER:
			return 2;
		CardEnums.CardType.ROCKSTAR:
			return 2;
	return 0;

func get_result_for_playing(card : CardData, player : Player, opponent : Player) -> int:
	var winner : GameplayEnums.Controller;
	var enemy : CardData = get_enemy_card_truth(opponent);
	var value : int = 1;
	var multiplier : int = calculate_base_points(card, enemy, true);
	if player.going_first and opponent.gained_keyword == CardEnums.Keyword.BURIED and card.prevents_opponents_reveal():
		return value * multiplier;
	if card.has_nut_stealer() and enemy and enemy.get_max_nuts() > 0:
		return value * multiplier * player.turns_waited_to_nut * player.nut_multiplier * 2;
	if !enemy:
		return get_value_to_threaten(card, player, opponent);
	winner = determine_winner(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			if enemy.has_greed() and !player.is_close_to_winning():
				return -2;
			return value * multiplier;
		GameplayEnums.Controller.PLAYER_TWO:
			if card.has_greed() and !opponent.is_close_to_winning():
				return 2;
			return -value;
	return 0;

func get_enemy_card_truth(opponent : Player) -> CardData:
	var card : CardData = opponent.get_field_card();
	if !card:
		return null;
	card = card.clone();
	if card.has_chameleon():
		opponent.trigger_chameleon(card);
	return card;

func get_first_face_up_card(source : Array) -> CardData:
	for card in source:
		if !card.is_buried:
			return card;
	return null;

func get_value_to_threaten(card : CardData, player : Player, opponent : Player) -> int:
	var value : int;
	if card.has_digital():
		return -1;
	if card.has_champion():
		return 0;
	value = get_card_value(card, player, opponent);
	return value;

func round_results() -> void:
	var card : CardData = player_one.get_field_card();
	var enemy : CardData = player_two.get_field_card();
	round_winner = determine_winner(
		card,
		enemy
	);
	var is_motion_shooting : bool;
	var someone_close_to_winning : bool = player_one.is_close_to_winning() or player_two.is_close_to_winning();
	if is_time_stopped:
		stopped_time_results();
		return;
	led_direction = YOUR_LED_DIRECTION;
	led_color = YOUR_LED_COLOR if round_winner == GameplayEnums.Controller.PLAYER_ONE else IDLE_LED_COLOR;
	if card and card.does_shoot() and round_winner != GameplayEnums.Controller.PLAYER_TWO:
		is_motion_shooting = true;
		play_shooting_animation(card, enemy, round_winner != GameplayEnums.Controller.NULL or System.Random.chance(2));
		round_winner = determine_winner(card, enemy);
	if enemy and enemy.does_shoot() and round_winner != GameplayEnums.Controller.PLAYER_ONE:
		is_motion_shooting = true;
		play_shooting_animation(enemy, card, true);
		round_winner = determine_winner(card, enemy);
	if round_winner == GameplayEnums.Controller.PLAYER_TWO:
		led_direction = OPPONENTS_LED_DIRECTION;
		led_color = OPPONENTS_LED_COLOR;
		if !is_motion_shooting and (System.Random.chance(TROLL_CHANCE) or player_two.points >= player_two.point_goal - 1):
			opponent_trolling_effect();
			led_direction = WARNING_LED_DIRECTION;
			led_color = WARNING_LED_COLOR;
	match round_winner:
		GameplayEnums.Controller.PLAYER_ONE:
			trigger_winner_loser_effects(card, enemy, player_one, player_two);
			if !player_one.is_close_to_winning() and !System.Random.chance(YOUR_POINTS_ZOOM_CHANCE):
				emit_signal("quick_zoom_to", your_points.position);
			loser_dissolve_effect(enemy, card);
		GameplayEnums.Controller.PLAYER_TWO:
			trigger_winner_loser_effects(enemy, card, player_two, player_one);
			if !player_two.is_close_to_winning() and !System.Random.chance(OPPONENTS_POINTS_ZOOM_CHANCE):
				emit_signal("quick_zoom_to", opponents_points.position);
			loser_dissolve_effect(card, enemy);
		GameplayEnums.Controller.NULL:
			play_tie_sound()
	if round_winner == GameplayEnums.Controller.NULL:
		end_round();
		return;
	round_end_timer.wait_time = ROUND_END_WAIT * System.game_speed_additive_multiplier;
	round_end_timer.start();

func loser_dissolve_effect(card : CardData, enemy : CardData) -> void:
	if !get_card(card):
		return;
	if (card.has_sinful() or enemy.has_incinerate()) and !card.has_cursed():
		get_card(card).burn_effect();
		burn_card(card);
	get_card(card).dissolve();

func electrocute_card(card : CardData) -> void:
	if !get_card(card):
		return;
	get_card(card).electrocuted_effect();
	zoom_to_node(get_card(card));
	play_electrocuted_sound();

func play_electrocuted_sound() -> void:
	var sound : Resource = load("res://Assets/SFX/CardSounds/Bursts/electrocution.wav");
	play_sfx(sound, Config.SFX_VOLUME + Config.GUN_VOLUME);

func burn_card(card : CardData) -> void:
	if !card:
		return;
	card.controller.burn_card(card);

func stopped_time_results() -> void:
	if !time_stopping_player:
		time_stopping_player = player_one;
	var card : CardData = time_stopping_player.get_field_card();
	var enemy : CardData = get_opponent(card).get_field_card() if card else null;
	await System.wait_range(MIN_STOPPED_TIME_WAIT, MAX_STOPPED_TIME_WAIT);
	if time_stopping_player.hand_empty() or time_stopping_player.cards_played_this_turn >= System.Rules.MAX_TIME_STOP_CARDS_PLAYED or (card and !card.is_buried and (card.is_gun() or card.is_god())):
		if card and (card.is_gun() and !card.is_buried) and (!enemy or check_type_results(card, enemy) != GameplayEnums.Controller.PLAYER_TWO):
			await stopped_time_shooting(card, get_opponent(card).get_field_card());
		time_stop_effect_out();
		return;
	time_stopping_player.send_from_field_to_grave(card);
	if get_card(card):
		get_card(card).dissolve();
	has_been_stopping_turn = true;
	if time_stopping_player == player_one:
		if System.auto_play:
			auto_play_timer.start();
		your_turn();
	else:
		opponents_play_wait.start();

func stopped_time_shooting(card : CardData, enemy : CardData) -> void:
	var stopped_time_advantage : int = System.random.randi_range(System.Rules.STOPPED_TIME_MIN_SHOTS, System.Rules.STOPPED_TIME_MAX_SHOTS);
	for i in range(stopped_time_advantage):
		for bullet in play_shooting_animation(card, enemy, true, true):
			time_stopped_bullets.append(bullet);
			await System.wait_range(MIN_STOPPED_TIME_SHOOTING_ROUND_WAIT, MAX_STOPPED_TIME_SHOOTING_ROUND_WAIT);
	card.stopped_time_advantage = stopped_time_advantage;

func play_tie_sound() -> void:
	play_point_sfx(TIE_SOUND_PATH);

func update_point_visuals() -> void:
	your_points.text = str(player_one.points);
	opponents_points.text = str(player_two.points);
	update_point_meter(player_one);
	update_point_meter(player_two);
	opponents_point_meter.mirror();
 
func trigger_winner_loser_effects(card : CardData, enemy : CardData,
	player : Player, opponent : Player, points : int = 1
) -> void:
	if has_game_ended:
		return;
	points *= calculate_base_points(card, enemy, true);
	player.gain_points(points);
	spawn_poppets(points, card, player);
	check_lose_effects(enemy, opponent);
	if card:
		if card.is_god():
			summon_divine_judgment(card, enemy);
		for keyword in card.keywords:
			match keyword:
				CardEnums.Keyword.DIVINE:
					summon_divine_judgment(card, enemy);
				CardEnums.Keyword.ELECTROCUTE:
					electrocute_card(enemy);
				CardEnums.Keyword.SOUL_HUNTER:
					if enemy:
						player.steal_card_soul(enemy);
				CardEnums.Keyword.VAMPIRE:
					opponent.lose_points(points);
	if enemy:
		for keyword in enemy.keywords:
			match keyword:
				CardEnums.Keyword.EXTRA_SALTY:
					opponent.lose_points(System.Rules.EXTRA_SALTY_POINTS_LOST);
				CardEnums.Keyword.SALTY:
					opponent.lose_points(System.Rules.SALTY_POINTS_LOST);
	gain_points_effect(player);
	if have_you_won() or has_opponent_won():
		start_game_over();

func spawn_poppets(points : int, card : CardData, player : Player) -> void:
	var color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE;
	var count : int = points;
	var extra_count : int;
	if points > 12:
		color = Poppet.PoppetColor.RAINBOW;
		count /= 6;
		extra_count = points - 5 * count + System.random.randi_range(0, 5);
	elif points > 4:
		color = Poppet.PoppetColor.GOLD;
		count /= 4;
		extra_count = points - 4 * count + System.random.randi_range(0, 3);
	elif points > 1:
		color = Poppet.PoppetColor.RED;
		count /= 2;
		extra_count = points - 2 * count + System.random.randi_range(0, 1);
	for i in range(min(MAX_CARD_POPPETS, count)):
		spawn_poppet_for_card(card, player, color);
	for i in range(min(MAX_CARD_POPPETS, extra_count)):
		spawn_poppet_for_card(card, player);

func spawn_poppet_for_card(card : CardData, player : Player, color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE) -> void:
	var goal_position : Vector2
	if !get_card(card):
		return;
	goal_position = (your_point_panel.position if player == player_one else opponents_point_panel.position) + Vector2(235, 95) + Vector2(System.random.randf_range(-130, 130), System.random.randf_range(-50, 50));
	spawn_poppet(get_card(card).position + System.Random.vector(0, 50), goal_position, color);

func spawn_poppet(spawn_position : Vector2, goal_position : Vector2, color : Poppet.PoppetColor) -> Poppet:
	var poppet : Poppet;
	poppet = System.Instance.load_child(System.Paths.POPPET, above_cards_layer);
	poppet.position = spawn_position;
	poppet.rotation_degrees = System.random.randf_range(-40, 40);
	poppet.move_to(goal_position, color);
	poppets[poppet.instance_id] = poppet;
	return poppet;
		

func summon_divine_judgment(card : CardData, enemy : CardData) -> void:
	var judgment_position : Vector2;
	if !get_card(enemy):
		return;
	judgment_position = Vector2(
		get_card(enemy).position.x,
		get_card(enemy).position.y + GameplayCard.SIZE.y / 2
	);
	divine_judgment.strike_down(judgment_position);
	if System.game_speed == 1 and !card.is_gun():
		emit_signal("zoom_to", get_card(enemy).position);

func play_shooting_animation(card : CardData, enemy : CardData, do_zoom : bool = false, slow_down : bool = false, do_fade : bool = false) -> Array:
	match card.get_shooting_type():
		CardData.ShootingType.BULLETS:
			return play_bullets_shooting_animation(card, enemy, do_zoom, slow_down);
		CardData.ShootingType.TENTACLES:
			return play_tentacles_shooting_animation(card, enemy, do_zoom, slow_down, do_fade);
	return [];

func play_bullets_shooting_animation(card : CardData, enemy : CardData, do_zoom : bool = false, slow_down : bool = false) -> Array:
	var bullets : Array;
	var bullet : Bullet;
	if !get_card(card):
		return bullets;
	var enemy_position : Vector2 = get_shooting_enemy_position(card, enemy);
	var count : int = get_count_of_bullets_shot(card);
	if count <= 0:
		return bullets;
	for i in range(count):
		if i > 0:
			enemy_position += System.Random.vector(MIN_BULLET_MARGIN, MAX_BULLET_MARGIN);
		bullet = System.Data.load_bullet(card.bullet_id, cards_layer);
		if slow_down:
			bullet.slow_down();
		bullet.init(enemy_position - (get_card(card).get_recoil_position() if get_card(card) else Vector2.ZERO), i < 2);
		bullets.append(bullet);
		if do_zoom and i == 0:
			zoom_to_node(bullet);
	if get_card(card):
		get_card(card).recoil(enemy_position);
	if card.shoots_wet_bullets():
		make_card_wet(enemy, true, false);
	return bullets;

func get_shooting_enemy_position(card : CardData, enemy : CardData) -> Vector2:
	return get_card(enemy).get_recoil_position() if (enemy and get_card(enemy)) else -get_card(card).get_recoil_position();

func get_count_of_bullets_shot(card : CardData) -> int:
	var count : int = 1;
	if card.stopped_time_advantage > 1:
		return -1;
	if card.has_champion():
		count = System.random.randi_range(3, 5);
		if card.has_rare_stamp():
			count *= 2;
	elif card.has_pair():
		count = 2;
	if card.has_multiply() and count == 1 and card.multiply_advantage > 1:
		count = min(8, card.multiply_advantage);
	if count == 1 and CollectionEnums.TRIPLE_SHOOTING_CARDS.has(card.card_id):
		count = 3;
	return count;

func move_card_front(card : GameplayCard) -> void:
	if cards_layer.is_ancestor_of(card):
		cards_layer.remove_child(card);
	else:
		cards_layer2.remove_child(card);
	cards_layer.add_child(card);

func play_tentacles_shooting_animation(card : CardData, enemy : CardData, do_zoom : bool = false, slow_down : bool = false, do_fade : bool = false) -> Array:
	var tentacles : Array;
	var gameplay_card : GameplayCard = get_card(card);
	if !gameplay_card:
		return tentacles;
	var enemy_position : Vector2 = get_shooting_enemy_position(card, enemy);
	var count : int = min(MAX_TENTACLES, (8 if !slow_down else 2) + (2 if !slow_down else 1) * get_count_of_bullets_shot(card));
	var tentacle : Tentacle;
	if count <= 0:
		return tentacles;
	for i in range(count):
		tentacle = System.Instance.load_child(System.Paths.TENTACLE, cards_layer);
		if slow_down:
			tentacle.slow_down();
		if do_fade:
			tentacle.do_fade = true;
		tentacle.init(gameplay_card, get_card(enemy), enemy_position, i < 2);
		tentacles.append(tentacle);
		if do_zoom and i == 0 and !do_fade:
			zoom_to_node(tentacle);
	gameplay_card.recoil(-enemy_position);
	move_card_front(gameplay_card);
	return tentacles;

func make_card_wet(card : CardData, do_trigger : bool = true, fully_moist : bool = true) -> bool:
	var player : Player;
	var would_trigger : bool;
	var did_gain_keywords : bool;
	if !card or card.is_buried:
		return would_trigger;
	player = card.controller;
	if card.has_ocean_dweller() and (card.controller == player_one or card.zone == CardEnums.Zone.FIELD):
		if do_trigger:
			trigger_ocean_dweller(card, player);
		would_trigger = true;
	if card.has_tidal() and !card.is_gun():
		if do_trigger:
			card.set_card_type(CardEnums.CardType.GUN);
			update_alterations_for_card(card);
			if get_card(card):
				get_card(card).wet_effect();
			start_wet_wait()
		would_trigger = true;
	if !fully_moist:
		return would_trigger;
	if (card.is_scissor() and !card.is_aquatic() and card.add_keyword(CardEnums.Keyword.RUST, false, do_trigger)):
		did_gain_keywords = true;
	if (card.is_paper() and !card.is_aquatic() and card.add_keyword(CardEnums.Keyword.MUSHY, false, do_trigger)):
		did_gain_keywords = true;
	if did_gain_keywords:
		if do_trigger:
			update_alterations_for_card(card);
			if get_card(card):
				get_card(card).wet_effect();
			start_wet_wait();
		would_trigger = true;
	return would_trigger;

func start_wet_wait() -> void:
	is_wet_wait_on = true;
	wet_wait_timer.wait_time = System.random.randf_range(WET_MIN_WAIT, WET_MAX_WAIT) * System.game_speed_additive_multiplier;
	wet_wait_timer.start();

func zoom_to_node(node : Node2D) -> void:
	emit_signal("zoom_to", node, true);

func check_lose_effects(card : CardData, player : Player) -> void:
	if card and card.has_greed():
		player.draw_cards(2);

func click_your_points() -> void:
	your_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(YOUR_POINT_SOUND_PATH);
	if have_you_won():
		did_win = true;
		return;
	points_click_timer.wait_time = POINTS_CLICK_WAIT * System.game_speed_additive_multiplier;
	points_click_timer.start();

func update_point_meter(player : Player) -> void:
	var point_meter : PointMeter = your_point_meter if player == player_one else opponents_point_meter;
	point_meter.set_points(player.points);

func play_point_sfx(file_path : String) -> void:
	var sound_file : Resource = load(file_path);
	point_streamer.stream = sound_file;
	if Config.MUTE_SFX:
		return;
	point_streamer.pitch_scale = max(Config.MIN_BULLET_PITCH, System.game_speed);
	point_streamer.play();

func click_opponents_points() -> void:
	opponents_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(OPPONENTS_POINT_SOUND_PATH);
	if has_opponent_won():
		return;
	points_click_timer.wait_time = POINTS_CLICK_WAIT * System.game_speed_additive_multiplier;
	points_click_timer.start();

func opponent_trolling_effect() -> void:
	trolling_sprite.position = Vector2.ZERO;
	trolling_sprite.visible = true;
	trolling_sprite.rotation_degrees *= System.Random.direction();
	is_trolling = true;
	get_troll_wait();
	troll_timer.start();

func determine_winner(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var you_have_negative_multiplier : bool = card and card.multiply_advantage < 0;
	var opponent_has_negative_multiplier : bool = enemy and enemy.multiply_advantage < 0;
	if you_have_negative_multiplier and !opponent_has_negative_multiplier:
		return opponent_wins;
	if opponent_has_negative_multiplier and !you_have_negative_multiplier:
		return you_win;
	if card == null and enemy == null:
		return tie;
	if card == null:
		return opponent_wins;
	if enemy == null:
		return you_win;
	var winner_a : GameplayEnums.Controller = check_winner_from_side(card, enemy);
	var winner_b : GameplayEnums.Controller = GameplayEnums.flip_player(check_winner_from_side(enemy, card));
	if winner_a == winner_b:
		return winner_a;
	elif winner_a == tie:
		return winner_b;
	elif winner_b == tie:
		return winner_a;
	return tie;

func check_winner_from_side(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	var pre_type_result : GameplayEnums.Controller = check_pre_types_keywords(card, enemy);
	if pre_type_result != not_determined:
		return pre_type_result;
	var type_result : GameplayEnums.Controller = check_type_results(card, enemy);
	if type_result != not_determined:
		return type_result;
	var post_type_result : GameplayEnums.Controller = check_post_types_keywords(card, enemy);
	if post_type_result != not_determined:
		return post_type_result;
	return tie;

func check_pre_types_keywords(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	if card.has_pair() and enemy.has_pair_breaker():
		return opponent_wins;
	elif enemy.has_pair() and card.has_pair_breaker():
		return you_win;
	if card.is_nut_tied() and enemy.has_november():
		return opponent_wins;
	if enemy.is_nut_tied() and card.has_november():
		return you_win;
	if card.is_aquatic() and enemy.has_electrocute():
		return opponent_wins;
	elif enemy.is_aquatic() and card.has_electrocute():
		return you_win;
	if card.is_buried and !enemy.is_buried and enemy_type != CardEnums.CardType.MIMIC:
		return opponent_wins;
	elif enemy.is_buried and !card.is_buried and card_type != CardEnums.CardType.MIMIC:
		return you_win;
	if card.is_vanilla() and enemy.has_cooties():
		return opponent_wins;
	elif enemy.is_vanilla() and card.has_cooties():
		return you_win;
	if card.has_undead() and enemy.has_divine():
		return opponent_wins;
	elif enemy.has_undead() and card.has_divine():
		return you_win;
	return not_determined;

func check_type_results(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	match enemy_type:
		CardEnums.CardType.GUN:
			if card.has_rust():
				return you_win;
			if ![CardEnums.CardType.GUN, CardEnums.CardType.GOD].has(card_type):
				return opponent_wins;
		CardEnums.CardType.MIMIC:
			if card_type != CardEnums.CardType.MIMIC:
				return you_win;
		CardEnums.CardType.GOD:
			if card_type != CardEnums.CardType.GOD:
				return opponent_wins;
		CardEnums.CardType.ROCK:
			if card.has_mushy():
				return opponent_wins;
	match card_type:
		CardEnums.CardType.ROCK:
			if enemy.has_mushy():
				return you_win;
			match enemy_type:
				CardEnums.CardType.SCISSORS:
					return you_win;
				CardEnums.CardType.PAPER:
					return opponent_wins;
				CardEnums.CardType.BEDROCK:
					return opponent_wins;
				CardEnums.CardType.ZIPPER:
					return opponent_wins;
		CardEnums.CardType.PAPER:
			match enemy_type:
				CardEnums.CardType.ROCK:
					return you_win;
				CardEnums.CardType.SCISSORS:
					return opponent_wins;
				CardEnums.CardType.ZIPPER:
					return opponent_wins;
				CardEnums.CardType.ROCKSTAR:
					return opponent_wins;
		CardEnums.CardType.SCISSORS:
			match enemy_type:
				CardEnums.CardType.PAPER:
					return you_win;
				CardEnums.CardType.ROCK:
					return opponent_wins;
				CardEnums.CardType.BEDROCK:
					return opponent_wins;
				CardEnums.CardType.ROCKSTAR:
					return opponent_wins;
		CardEnums.CardType.GUN:
			if enemy.has_rust():
				return opponent_wins;
			if ![CardEnums.CardType.GUN, CardEnums.CardType.GOD].has(enemy_type):
				return you_win;
		CardEnums.CardType.MIMIC:
			if enemy_type != CardEnums.CardType.MIMIC:
				return opponent_wins;
		CardEnums.CardType.GOD:
			if enemy_type != CardEnums.CardType.GOD:
				return you_win;
		CardEnums.CardType.BEDROCK:
			match enemy_type:
				CardEnums.CardType.ROCK:
					return you_win;
				CardEnums.CardType.SCISSORS:
					return you_win;
				CardEnums.CardType.ROCKSTAR:
					return you_win;
				CardEnums.CardType.ZIPPER:
					return opponent_wins;
		CardEnums.CardType.ZIPPER:
			match enemy_type:
				CardEnums.CardType.ROCK:
					return you_win;
				CardEnums.CardType.PAPER:
					return you_win;
				CardEnums.CardType.BEDROCK:
					return you_win;
				CardEnums.CardType.ROCKSTAR:
					return opponent_wins;
		CardEnums.CardType.ROCKSTAR:
			match enemy_type:
				CardEnums.CardType.PAPER:
					return you_win;
				CardEnums.CardType.SCISSORS:
					return you_win;
				CardEnums.CardType.ZIPPER:
					return you_win;
				CardEnums.CardType.BEDROCK:
					return opponent_wins;
	return not_determined;

func check_post_types_keywords(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	if card.stopped_time_advantage > 1:
		return you_win;
	elif enemy.stopped_time_advantage > 1:
		return opponent_wins;
	if card.multiply_advantage > 100000 and enemy.multiply_advantage > 100000:
		System.Random.item([card, enemy]).multiply_advantage -= 1;
	if card.multiply_advantage > enemy.multiply_advantage:
		return you_win;
	elif enemy.multiply_advantage > card.multiply_advantage:
		return opponent_wins;
	if card.has_pair():
		if !enemy.has_pair():
			return you_win;
	elif enemy.has_pair():
		if !card.has_pair():
			return opponent_wins;
	return not_determined;

func end_round() -> void:
	if clear_field():
		start_next_round_timer.wait_time = System.random.randf_range(OCEAN_POINTS_MIN_WAIT, OCEAN_POINTS_MAX_WAIT) * System.game_speed_additive_multiplier;
		start_next_round_timer.start();
	else:
		if is_time_stopped:
			time_stop_effect_out();
			return;
		start_next_round();

func start_next_round() -> void:
	set_going_first(!going_first);
	start_round();

func clear_field() -> bool:
	var did_trigger_clear_field_effects : bool;
	if clear_players_field(player_one, round_winner == GameplayEnums.Controller.PLAYER_ONE, round_winner == GameplayEnums.Controller.PLAYER_TWO):
		did_trigger_clear_field_effects = true;
	if clear_players_field(player_two, round_winner == GameplayEnums.Controller.PLAYER_TWO, round_winner == GameplayEnums.Controller.PLAYER_ONE):
		did_trigger_clear_field_effects = true;
	return did_trigger_clear_field_effects;

func clear_players_field(player : Player, did_win : bool, did_lose : bool) -> bool:
	var card : CardData;
	var gameplay_card : GameplayCard;
	var starting_points : int = player.points;
	var did_trigger_ocean : bool;
	for c in player.cards_on_field:
		card = c;
		gameplay_card = get_card(card);
		if gameplay_card:
			gameplay_card.despawn();
	for c in player.cards_in_hand:
		card = c;
		if card.has_werewolf():
			trigger_werewolf(card);
	for c in player.cards_in_hand:
		card = c;
		if card.has_alpha_werewolf():
			trigger_alpha_werewolf(player);
	if player.played_alpha_werewolf:
		trigger_alpha_werewolf(player);
		player.played_alpha_werewolf = false;
	for c in player.cards_in_hand.duplicate():
		card = c;
		gameplay_card = get_card(card);
		if card.has_ocean_dweller() and card.controller == player_one:
			trigger_ocean_dweller(card, player)
			if gameplay_card and !gameplay_card.is_visiting:
				gameplay_card.recoil();
			did_trigger_ocean = true;
		if !card.has_pick_up():
			continue;
		if gameplay_card:
			gameplay_card.despawn();
	player.end_of_turn_clear(did_win);
	return true;

func trigger_alpha_werewolf(player : Player) -> void:
	var played_color : CardEnums.CardType = player.true_last_type_played;
	var card : CardData;
	for c in player.cards_in_hand:
		card = c;
		if !card.has_werewolf():
			continue;
		card.set_card_type(played_color);
	for c in player.cards_in_hand:
		card = c;
		if !card.has_werewolf():
			continue;
		card.add_keyword(CardEnums.Keyword.MULTIPLY);
		update_alterations_for_card(card);

func trigger_werewolf(card : CardData) -> void:
	card.controller.trigger_chameleon(card);
	update_alterations_for_card(card);

func trigger_ocean_dweller(card : CardData, player : Player) -> void:
	var points : int = calculate_base_points(card, null, true, false);
	player.gain_points(points);
	gain_points_effect(player);
	if get_card(card):
		get_card(card).wet_effect();
	spawn_poppets(points, card, player);

func show_opponents_field() -> void:
	var card : GameplayCard;
	for card_data in player_two.cards_on_field:
		card = get_card(card_data);
		if !card:
			return;
		card.goal_position = ENEMY_FIELD_POSITION;
		card.move();

func _process(delta : float) -> void:
	if fading_field_lines:
		fade_field_lines(delta);
	if System.Instance.exists(active_card):
		reorder_hand();
	if is_updating_points_visibility:
		update_points_visibility(delta);
	if is_trolling:
		move_troll_layer(delta);
	time_stop_frame(delta);
	if is_dying:
		death_frame(delta);
	if is_undying:
		undying_frame(delta);
	if has_game_ended:
		victory_pattern.material.set_shader_parameter("opacity", victory_banner.modulate.a);
	if current_animation_type != AnimationType.NULL:
		high_tide_frame(delta);
	if is_low_tiding:
		low_tide_frame(delta);

func high_tide_frame(delta : float) -> void:
	var wave_speed : float = pow(ocean_effect_wave_speed, ocean_effect_speed_exponent * ocean_pattern.modulate.a);
	ocean_pattern.modulate.a += high_tide_speed * delta;
	ocean_pattern.material.set_shader_parameter("wave_speed", wave_speed);
	ocean_pattern.material.set_shader_parameter("wave_frequency", wave_speed * 20);
	ocean_pattern.material.set_shader_parameter("wave_amplitude", wave_speed * 0.02);
	update_ocean_pattern();

func low_tide_frame(delta : float) -> void:
	ocean_pattern.modulate.a -= low_tide_speed * delta;
	update_ocean_pattern();
	if ocean_pattern.modulate.a <= 0:
		ocean_pattern.modulate.a = 0;
		is_low_tiding = false;

func update_ocean_pattern() -> void:
	var max_opacity : float = OCEAN_PATTERN_MAX_OPACITY;
	match current_animation_type:
		AnimationType.POSITIVE:
			max_opacity = POSITIVE_BACKGROUND_MAX_OPACITY;
	max_opacity = max(ocean_pattern.material.get_shader_parameter("opacity"), max_opacity);
	ocean_pattern.material.set_shader_parameter("opacity", min(max_opacity, ocean_pattern.modulate.a));
	if !System.Instance.exists(ocean_card):
		return;
	ocean_pattern.material.set_shader_parameter("wave_center", System.Vectors.get_scale_position(ocean_card.position));

func init_time_stop() -> void:
	var shader_material : ShaderMaterial = get_time_stop_material();
	var shader_material2 : ShaderMaterial = get_time_stop_material();
	var custom_material : ShaderMaterial;
	var card : CardData;
	for node in get_time_stop_nodes():
		node.material = shader_material;
	for instance_id in get_custom_time_stop_nodes():
		card = cards[instance_id].card_data;
		custom_material = get_time_stop_material();
		System.Shaders.set_card_art_shader_parameters(custom_material, card.is_negative_variant(), card.is_holographic, card.is_foil);
		for node in custom_time_stop_nodes[instance_id]:
			node.material = custom_material;
	for node in get_time_stop_nodes2():
		if !System.Instance.exists(node):
			continue;
		node.material = shader_material2;
	led_wait *= TIME_STOP_LED_ACCELERATION;
	is_time_stopped = true;
	if animation_instance_id != 0:
		animation_wait_timer.stop();
		after_animation(true);
	play_time_stop_sound();

func get_time_stop_nodes2() -> Array:
	return time_stop_nodes2 + your_point_meter.get_nodes() + opponents_point_meter.get_nodes() + get_poppet_nodes();

func get_poppet_nodes() -> Array:
	var nodes : Array;
	for instance_id in poppets:
		if !System.Instance.exists(poppets[instance_id]):
			poppets.erase(instance_id);
		else:
			nodes += poppets[instance_id].get_shader_nodes();
	return nodes;

func get_time_stop_material() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/CardEffects/za-warudo-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	shader_material.set_shader_parameter("time", 0.9999);
	shader_material.set_shader_parameter("glitch_mix", 0.3);
	shader_material.set_shader_parameter("bw_mix", 0.96);
	shader_material.set_shader_parameter("pulse_width", 0.8);
	return shader_material;

func after_time_stop() -> void:
	var shader : Resource = load("res://Shaders/Background/background-wave.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	var node_card : GameplayCard;
	shader_material.shader = shader;
	for node in get_time_stop_nodes():
		node.material = null;
	for instance_id in get_custom_time_stop_nodes():
		node_card = cards[instance_id];
		node_card.add_art_base_shader(true);
	for node in get_time_stop_nodes2():
		if !System.Instance.exists(node):
			continue;
		node.material = null;
	for card in cards.values():
		if !System.Instance.exists(card):
			continue;
		card.after_time_stop();
		
	for node in [
		background_pattern,
		die_pattern,
		your_point_pattern,
		opponents_point_pattern,
		gameplay_title
	]:
		node.material = shader_material;
	led_wait /= TIME_STOP_LED_ACCELERATION;
	System.update_game_speed(1);
	is_time_stopped = false;
	is_stopping_time = false;
	has_been_stopping_turn = false;
	time_stopping_player = null;
	for bullet in time_stopped_bullets:
		bullet.speed_up();
	time_stopped_bullets = [];
	pre_results_timer.start();

func time_stop_frame(delta : float) -> void:
	if !is_stopping_time and !is_accelerating_time:
		return;
	time_stop_velocity = System.Scale.baseline(time_stop_velocity, time_stop_goal_velocity, delta * TIME_STOP_ACCELERATION_SPEED * System.game_speed);
	if is_stopping_time:
		time_stop_shader_time -= time_stop_velocity * delta * System.game_speed;
		if time_stop_shader_time <= 0:
			time_stop_shader_time = 1.9999;
			time_stop_goal_velocity = System.random.randf_range(TIME_STOP_IN_BW_MIN_SPEED, TIME_STOP_IN_BW_MAX_SPEED);
		if time_stop_goal_velocity < TIME_STOP_IN_GLITCH_MIN_SPEED and time_stop_shader_time <= 1.0001:
			time_stop_shader_time = 1.001;
			time_stop_velocity = 0;
	if is_accelerating_time:
		time_stop_shader_time += time_stop_velocity * delta * System.game_speed;
		if time_stop_shader_time >= 1.9999:
			time_stop_shader_time = 0;
			time_stop_goal_velocity = time_stop_goal_velocity2;
		if time_stop_goal_velocity > TIME_STOP_OUT_BW_MAX_SPEED and time_stop_shader_time >= 0.9999:
			time_stop_shader_time = 0.9999;
			is_accelerating_time = false;
			time_stop_velocity = 0;
			after_time_stop();
	System.update_game_speed(System.Scale.baseline(\
		System.game_speed, TIME_STOP_GAME_SPEED if is_stopping_time else 1, delta));
	update_time_stop_time();

func get_time_stop_nodes() -> Array:
	for node in time_stop_nodes.duplicate():
		if !System.Instance.exists(node):
			time_stop_nodes.erase(node);
	return time_stop_nodes;

func get_custom_time_stop_nodes() -> Dictionary:
	for instance_id in custom_time_stop_nodes.duplicate():
		if !cards.has(instance_id) or !System.Instance.exists(cards[instance_id]):
			custom_time_stop_nodes.erase(instance_id);
	return custom_time_stop_nodes;

func update_time_stop_time() -> void:
	for node in get_time_stop_nodes():
		if !node.material:
			continue;
		node.material.set_shader_parameter("time", time_stop_shader_time);
		break;
	for instance_id in get_custom_time_stop_nodes():
		for node in custom_time_stop_nodes[instance_id]:
			if !node.material:
				continue;
			node.material.set_shader_parameter("time", time_stop_shader_time);
	for node in time_stop_nodes2:
		if node.material == null:
			break;
		node.material.set_shader_parameter("time", time_stop_shader_time);
		break;

func time_stop_effect_in() -> void:
	init_time_stop();
	time_stop_shader_time = 0.9999;
	is_accelerating_time = false;
	is_stopping_time = true;
	time_stop_goal_velocity = System.random.randf_range(TIME_STOP_IN_GLITCH_MIN_SPEED, TIME_STOP_IN_GLITCH_MAX_SPEED);

func time_stop_effect_out() -> void:
	time_stop_shader_time = 1.01;
	is_stopping_time = false;
	is_accelerating_time = true;
	time_stop_goal_velocity = System.random.randf_range(TIME_STOP_OUT_BW_MIN_SPEED, TIME_STOP_OUT_BW_MAX_SPEED);
	time_stop_goal_velocity2 = System.random.randf_range(TIME_STOP_OUT_GLITCH_MIN_SPEED, TIME_STOP_OUT_GLITCH_MAX_SPEED);
	emit_signal("stop_music_if_special");
	play_time_stop_sound_reverse();

func move_troll_layer(delta : float) -> void:
	trolling_sprite.position += delta * System.game_speed * Vector2(
		System.Random.direction() * System.random.randf_range(TROLL_MIN_MOVE, TROLL_MAX_MOVE),
		System.Random.direction() * System.random.randf_range(TROLL_MIN_MOVE, TROLL_MAX_MOVE)
	);

func update_points_visibility(delta : float) -> void:
	points_layer.modulate.a = System.Scale.baseline(
		points_layer.modulate.a,
		points_goal_visibility,
		(POINTS_FADE_IN_SPEED if points_goal_visibility == 1 else POINTS_FADE_OUT_SPEED) * delta * System.game_speed
	);
	if your_face.material:
		your_face.material.set_shader_parameter("opacity", points_layer.modulate.a);
	cards_shadow.modulate.a = System.Scale.baseline(
		cards_shadow.modulate.a,
		shadow_goal_visibility,
		(SHADOW_FADE_IN_SPEED if shadow_goal_visibility == 1 else SHADOW_FADE_OUT_SPEED) * delta * System.game_speed
	);
	if System.Scale.equal(points_layer.modulate.a, points_goal_visibility):
		points_layer.modulate.a = points_goal_visibility;
		cards_shadow.modulate.a = shadow_goal_visibility;
		is_updating_points_visibility = false;

func fade_field_lines(delta : float) -> void:
	var direction : int = 1 if field_lines_visible else -1;
	field_lines.modulate.a += direction * delta * System.game_speed * (FIELD_LINES_FADE_IN_SPEED if field_lines_visible else FIELD_LINES_FADE_OUT_SPEED);
	if abs(field_lines.modulate.a) >= 1:
		field_lines.modulate.a = 1 if field_lines_visible else 0;
		fading_field_lines = false;

func _on_round_results_timer_timeout() -> void:
	round_results_timer.stop();
	round_results();

func _on_round_end_timer_timeout() -> void:
	round_end_timer.stop();
	end_round();

func _on_game_over_timer_timeout() -> void:
	game_over_timer.stop();
	end_game();

func _on_points_click_timer_timeout() -> void:
	points_click_timer.stop();
	your_points.add_theme_color_override("font_color", Color.WHITE);
	opponents_points.add_theme_color_override("font_color", Color.WHITE);

func _on_pre_results_timer_timeout() -> void:
	pre_results_timer.stop();
	go_to_results();

func _on_card_focus_timer_timeout() -> void:
	card_focus_timer.stop();
	toggle_points_visibility(false);
	if !can_play_card:
		return;
	field_lines_visible = true;
	fading_field_lines = true;
	field_lines.modulate.a = min(1, max(0, field_lines.modulate.a));

func _on_opponents_play_wait_timeout() -> void:
	opponents_play_wait.stop();
	opponents_turn();

func _on_spying_timer_timeout() -> void:
	spying_timer.stop();
	stop_spying();

func _on_you_play_wait_timeout() -> void:
	you_play_wait.stop();
	your_turn();


func _on_trolling_timer_timeout() -> void:
	troll_timer.stop();
	is_trolling = false;
	trolling_sprite.visible = false;

func _on_led_wait_timeout() -> void:
	led_timer.stop();
	led_frame();
	led_wait += System.Random.direction() * System.Leds.LED_CLOCK_ERROR;
	led_wait = max(System.Leds.MIN_LED_WAIT, led_wait);
	led_timer.wait_time = led_wait * System.game_speed_multiplier;
	led_timer.start();

func led_frame() -> void:
	var fast_led_color : Led.LedColor = YOUR_LED_COLOR if led_direction == YOUR_LED_DIRECTION else OPPONENTS_LED_COLOR;
	System.Leds.shut_leds(fast_led_index, LEDS_PER_COLUMN, get_led_columns());
	System.Leds.shut_leds(fast_led_index + LEDS_PER_COLUMN / 2 - 1, LEDS_PER_COLUMN, get_led_columns());
	for i in range(LED_BURSTS):
		System.Leds.shut_leds(led_index + 3 * i, LEDS_PER_COLUMN, get_led_columns());
	led_index = System.Leds.index_tick(fast_led_index, LEDS_PER_COLUMN, led_direction);
	fast_led_index = System.Leds.index_tick(fast_led_index, LEDS_PER_COLUMN, led_direction * FAST_LED_SPEED);
	for i in range(LED_BURSTS):
		System.Leds.light_leds(led_index + 3 * i, LEDS_PER_COLUMN, get_led_columns(), led_color);
	if !started_playing:
		System.Leds.light_leds(fast_led_index, LEDS_PER_COLUMN, get_led_columns(), YOUR_LED_COLOR);
	if led_direction == OFF_LED_DIRECTION:
		return;
	System.Leds.light_leds(fast_led_index, LEDS_PER_COLUMN, get_led_columns(), fast_led_color);
	System.Leds.light_leds(fast_led_index + LEDS_PER_COLUMN / 2 - 1, LEDS_PER_COLUMN, get_led_columns(), fast_led_color);

func get_led_columns() -> Array:
	return [
		leds_left,
		leds_right
	];

func _on_auto_play_timer_timeout() -> void:
	var card : CardData;
	auto_play_timer.stop();
	if System.Random.chance(CHANCE_TO_FLICKER_HAND):
		reorder_hand(true);
		auto_play_timer.wait_time *= FLICKER_SPEED_UP;
		auto_play_timer.start();
		return;
	active_player = player_one;
	player_one.shuffle_hand();
	player_one.cards_in_hand.sort_custom(best_to_play_for_you);
	card = player_one.cards_in_hand.back();
	spawn_card(card);
	play_card(get_card(card), player_one, player_two);

func _on_start_next_round_timer_timeout() -> void:
	start_next_round_timer.stop();
	start_next_round();

func update_death_progress_panel(was_full : bool = true) -> void:
	reset_progress_panel.size.x = death_progress * DEATH_PANEL_SIZE.x;
	if death_progress == 1:
		reset_progress_panel.add_theme_stylebox_override("panel", get_full_death_progress_style());
	elif was_full:
		reset_progress_panel.add_theme_stylebox_override("panel", get_nonfull_death_progress_style());

func get_full_progress_style(bg_color : String, border_color : String, is_nonfull : bool = false) -> StyleBoxFlat:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = bg_color;
	style.border_width_bottom = 4;
	style.border_width_left = 2;
	style.border_width_right = 0 if is_nonfull else 2;
	style.border_width_top = 2;
	style.border_color = border_color;
	style.border_blend = true;
	style.corner_radius_bottom_left = 21;
	style.corner_radius_bottom_right = 10 if is_nonfull else 21;
	style.corner_radius_top_left = 16;
	style.corner_radius_top_right = 8 if is_nonfull else 16;
	return style;

func get_full_death_progress_style() -> StyleBoxFlat:
	return get_full_progress_style("#860015", "fcdcd5");

func get_nonfull_death_progress_style() -> StyleBoxFlat:
	return get_full_progress_style("#860015", "fcdcd5", true);

func _on_die_pressed() -> void:
	if has_game_ended or is_preloaded:
		return;
	is_dying = true;
	is_undying = false;

func _on_die_released() -> void:
	if has_game_ended or is_preloaded:
		return;
	is_undying = true;
	is_dying = false;

func _on_wet_wait_timer_timeout() -> void:
	wet_wait_timer.stop();
	is_wet_wait_on = false;

func after_ocean(is_forced : bool) -> void:
	var card : CardData = ocean_card.card_data if System.Instance.exists(ocean_card) else null;
	var enemy : CardData = get_opponent(card).get_field_card() if System.Instance.exists(ocean_card) else null;
	if is_forced:
		return;
	make_card_wet(enemy);
	if !has_ocean_wet_self:
		make_card_wet(card);

func after_positive(is_forced : bool, points : int, card : CardData, player : Player) -> void:
	if get_card(card):
		get_card(card).shine_star.shutter();
	if is_forced:
		return;
	player.gain_points(points);
	gain_points_effect(player);
	spawn_poppets(points, card, player);
	
func after_animation(is_forced : bool = false) -> void:
	var animation_data : Dictionary;
	if animation_instance_id == 0:
		return;
	animation_data = animations[animation_instance_id]
	
	is_waiting_for_animation_to_finnish = false;
	animations.erase(animation_instance_id);
	animation_instance_id = 0;
	current_animation_type = AnimationType.NULL;
	animation_sfx.stop();
	match animation_data.type:
		AnimationType.OCEAN:
			after_ocean(is_forced);
		AnimationType.POSITIVE:
			after_positive(is_forced, animation_data.points, animation_data.card, animation_data.player);
	low_tide_speed = System.random.randf_range(LOW_TIDE_MIN_SPEED, LOW_TIDE_MAX_SPEED) * System.game_speed_multiplier;
	is_low_tiding = true;
	if is_time_stopped:
		return;
	emit_signal("play_prev_song");
	
func _on_animation_wait_timer_timeout() -> void:
	animation_wait_timer.stop();
	after_animation();
	
