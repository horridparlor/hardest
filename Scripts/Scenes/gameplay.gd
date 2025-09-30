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
@onready var dashboard_icon : Sprite2D = $Points/Relics/DashboardButton/SettingsCog;
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
@onready var game_monitor_timer : Timer = $Timers/GameMonitorTimer;
@onready var your_point_update_timer : Timer = $Timers/YourPointUpdateTimer;
@onready var opponents_point_update_timer : Timer = $Timers/OpponentsPointUpdateTimer;

@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var your_point_meter : PointMeter = $Points/PointPanels/YourPointsPanel/PointMeter;
@onready var opponents_point_meter : PointMeter = $Points/PointPanels/OpponentsPointsPanel/PointMeter;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;
@onready var animation_sfx : AudioStreamPlayer2D = $Background/AnimationSfx;
@onready var sfx_player : AudioStreamPlayer2D = $SfxPlayer;
@onready var throwable_player : AudioStreamPlayer2D = $ThrowablePlayer;
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

func _ready() -> void:
	set_default_shader_materials();

func set_default_shader_materials():
	background_pattern.material = System.Shaders.background_wave();
	ocean_pattern.material = System.Shaders.new_shader_material();
	gameplay_title.material = System.Shaders.background_wave();
	dashboard_pattern.material = System.Shaders.background_wave();
	die_pattern.material = System.Shaders.background_wave();
	your_point_pattern.material = System.Shaders.background_wave();
	opponents_point_pattern.material = System.Shaders.background_wave();
	victory_pattern.material = System.Shaders.bump_wave();

func init(level_data_ : LevelData, do_start : bool = true) -> void:
	if !level_data_:
		level_data_ = LevelData.from_json({});
	level_data = level_data_;
	init_player(player_one, GameplayEnums.Controller.PLAYER_ONE, level_data.deck2_id, do_start);
	init_player(player_two, GameplayEnums.Controller.PLAYER_TWO, level_data.deck_id, do_start);
	init_layers();
	set_going_first(0 if level_data.id == System.Levels.INTRODUCTION_LEVEL else System.Random.boolean());
	if Config.STARTING_PLAYER != GameplayEnums.Controller.NULL:
		set_going_first(1 if Config.STARTING_PLAYER == GameplayEnums.Controller.PLAYER_ONE else 0);
	highlight_face(false);
	update_character_faces();
	initialize_background_pattern();
	cards_shadow.modulate.a = 0;
	trolling_sprite.visible = false;
	ocean_pattern.visible = false;
	spawn_leds();
	System.TimeStop.init_time_stop_nodes(self);
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
	var point_goal : int = level_data.point_goal if (player == player_one or Config.AUTO_LEVEL != 0) \
		else min(System.Rules.OPPONENT_MAX_POINT_GOAL + round(System.Rules.POINT_GOAL_MULTIPLIER * (log(level_data.point_goal) / log(System.Rules.POINT_GOAL_MULTIPLIER))), \
		level_data.point_goal, \
		System.Rules.OPPONENT_MAX_POINT_GOAL + round(level_data.point_goal / 3 / 1.5) - 3);
	player.controller = controller;
	player.opponent = player_one if player == player_two else player_two;
	player.point_goal = point_goal;
	player.is_roguelike = level_data.is_roguelike;
	point_meter.set_max_points(point_goal);
	point_meter.set_points(0);
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
	is_active = true;
	game_monitor_timer.start();
	
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
		System.EyeCandy.spawn_victory_poppets(self);
	game_over_timer.wait_time = GAME_OVER_WAIT * System.game_speed_additive_multiplier;
	game_over_timer.start();

func init_victory_banner_sprite() -> void:
	var texture : Resource = load("res://Assets/Art/VictoryBanners/%s.png" % ["champion" if did_win else "loser"]);
	victory_pattern.texture = texture;

func end_game() -> void:
	if is_time_stopped:
		System.TimeStop.time_stop_effect_out(self);
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
		_on_player_one_cannot_play_more();
		return;
	can_play_card = true;
	if !System.auto_play:
		return;
	auto_play_timer.wait_time = System.random.randf_range(AUTO_PLAY_MIN_WAIT, AUTO_PLAY_MAX_WAIT) * System.game_speed_additive_multiplier;
	auto_play_timer.start()

func _on_player_one_cannot_play_more() -> void:
	can_play_card = false;
	_on_your_turn_end() if going_first else _on_opponent_turns_end();

func init_layers() -> void:
	field_lines.modulate.a = 0;

func show_hand() -> void:
	var card : CardData;
	var gameplay_card : GameplayCard;
	for c in player_one.cards_in_hand:
		card = c;
		gameplay_card = System.CardManager.spawn_card(card, self);
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

func add_time_stop_shader(card : GameplayCard) -> void:
	var material : ShaderMaterial = System.Shaders.time_stop_material();
	for layer in card.get_shader_layers():
		layer.material = material;

func _on_card_visited(card : GameplayCard) -> void:
	var enemy : CardData;
	if cards_to_dissolve.has(card.instance_id):
		enemy = cards_to_dissolve[card.instance_id];
		cards_to_dissolve.erase(card.instance_id);
		loser_dissolve_effect(card.card_data, enemy);
		card.despawn_to_same_direction();
	if spying_instance_id != card.visit_instance_id:
		return;
	if is_spying_whole_hand:
		if is_already_whole_spying:
			return;
		resolve_spying_whole_hand(card.card_data.controller);
	elif is_spying:
		resolve_spying(card);

func resolve_spying_whole_hand(opponent : Player) -> void:
	is_already_whole_spying = true;
	spying_instance_id = System.Random.instance_id();
	var enemies : Array = opponent.cards_in_hand.duplicate();
	var player : Player = opponent.opponent;
	var card : CardData = player.get_field_card();
	var has_priority : bool = card and card.has_hivemind();
	var results = BattleRoyale.new([card], enemies, has_priority).results;
	var defender : CardData;
	var is_not_first : bool;
	if current_spy_type == GameplayEnums.SpyType.DIRT:
		for c in enemies:
			card = c;
			inflict_dirt_on_card(card, opponent);
		start_spying_wait();
		return;
	for enemy in enemies + [card]:
		if get_card(enemy):
			get_card(enemy).still_wait_time = results.size() * WHOLE_HAND_SPY_MAX_WAIT;
	for result in results:
		if is_not_first:
			await System.wait(System.random.randf_range(WHOLE_HAND_SPY_MIN_WAIT, WHOLE_HAND_SPY_MAX_WAIT) * System.game_speed);
		else:
			is_not_first = true;
		defender = result.defender if result.attacker == card else result.attacker;
		enemies.erase(defender);
		animate_spying_fight(card, player, defender, opponent, true);
	for enemy in enemies:
		if get_card(enemy):
			send_spied_card_back(get_card(enemy), opponent);
	start_spying_wait();

func inflict_dirt_on_card(card : CardData, player : Player) -> void:
	var gameplay_card : GameplayCard = get_card(card);
	card.multiply_advantage = abs(card.multiply_advantage) * -(pow(2, player.played_same_type_in_a_row + 1) if player.get_matching_type(card.card_type) != CardEnums.CardType.NULL else 1);
	card.fix_multiply_advantage();
	show_multiplier_bar(gameplay_card);
	send_spied_card_back(gameplay_card, player);

func send_spied_card_back(card : GameplayCard, player : Player) -> void:
	match player.controller:
		GameplayEnums.Controller.PLAYER_ONE:
			reorder_hand();
		GameplayEnums.Controller.PLAYER_TWO:
			card.despawn(-CARD_STARTING_POSITION if player.controller == GameplayEnums.Controller.PLAYER_TWO else CARD_STARTING_POSITION, DIRT_AFTER_WAIT);

func resolve_spying(spy_target : GameplayCard) -> void:
	spying_instance_id = System.Random.instance_id();
	var enemy : CardData = spy_target.card_data;
	var opponent : Player = enemy.controller;
	var player : Player = get_opponent(enemy);
	var card : CardData = player.get_field_card();
	if current_spy_type == GameplayEnums.SpyType.DIRT:
		inflict_dirt_on_card(enemy, opponent);
		start_spying_wait();
		return;
	if animate_spying_fight(card, player, enemy, opponent):
		return;
	start_spying_wait();

func animate_spying_fight(card : CardData, player : Player, enemy : CardData, opponent : Player, is_spying_all : bool = false) -> bool:
	var do_spy_hand : bool = spy_zone == CardEnums.Zone.HAND;
	var spy_target : GameplayCard = get_card(enemy);
	var winner : GameplayEnums.Controller = determine_winner(card, enemy);
	var points : int = 1;
	if !System.Instance.exists(spy_target):
		return false;
	if card and (card.is_gun() or CollectionEnums.NON_GUN_SHOOTING_CARDS.has(card.card_id)) and winner != GameplayEnums.Controller.PLAYER_TWO:
		play_shooting_animation(card, enemy, false, false, true);
		winner = determine_winner(card, enemy);
	if enemy and (enemy.is_gun() or CollectionEnums.NON_GUN_SHOOTING_CARDS.has(enemy.card_id)) and winner != GameplayEnums.Controller.PLAYER_ONE:
		play_shooting_animation(enemy, card, false, false, true);
		winner = determine_winner(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			trigger_winner_loser_effects(card, enemy, player, opponent, points);
			opponent.discard_from_hand(enemy) if do_spy_hand else opponent.mill_from_deck(enemy);
			loser_dissolve_effect(enemy, card);
			spy_target.dissolve();
			spy_target.despawn_to_same_direction();
			if is_spying_all:
				return false;
			if cards_to_spy > 0:
				if System.PlayEffects.spy_opponent(card, player, opponent, self, cards_to_spy, spy_zone):
					return true;
			if player != active_player and active_player.hand_empty():
				stop_spying();
				continue_play();
				return true;
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
					if spy_target.card_data.is_in_hand():
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
						return true;
				GameplayEnums.Controller.PLAYER_TWO:
					if !player_two.hand_empty():
						you_play_wait.stop();
						stop_spying();
						opponents_play_wait.wait_time = OPPONENTS_PLAY_WAIT * System.game_speed_additive_multiplier;
						opponents_play_wait.start();
						return true;
		GameplayEnums.Controller.NULL:
			play_tie_sound();
			if opponent.controller == GameplayEnums.Controller.PLAYER_TWO or !do_spy_hand:
				spy_target.despawn(-CARD_STARTING_POSITION if opponent.controller == GameplayEnums.Controller.PLAYER_TWO else CARD_STARTING_POSITION);
			else:
				reorder_hand();
	return false;

func start_spying_wait() -> void:
	is_already_whole_spying = false;
	spying_timer.wait_time = SPY_WAIT_TIME * System.game_speed_additive_multiplier;
	spying_timer.start();

func continue_play() -> void:
	your_turn() if active_player == player_one else opponents_turn();

func stop_spying() -> void:
	is_spying = false;
	while !spy_stack.is_empty():
		var spy_data : SpyData = spy_stack.pop_front();
		if System.Instance.exists(spy_data.card) and spy_data.card.is_on_the_field():
			System.PlayEffects.spy_opponent(spy_data.card, spy_data.player, spy_data.opponent, self, spy_data.chain, spy_data.zone, spy_data.spy_type);
			return;

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
	card_data.check_undead();
	if card:
		if rerender_shader and !is_time_stopped:
			card.card_art.material = null;
		card.update_visuals(card.card_data.controller.gained_keyword);

func _on_card_pressed(card : GameplayCard) -> void:
	if System.Instance.exists(active_card) or card.card_data.zone != CardEnums.Zone.HAND or is_clicking_disabled():
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
	if !System.Instance.exists(active_card) or card != active_card or is_clicking_disabled():
		return;
	unfocus_card(card, auto_action);

func unfocus_card(card : GameplayCard, auto_action : bool = false) -> void:
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
	var multi : int = card.multiply_advantage * card.stopped_time_advantage * \
		System.Fighting.get_card_continuous_advantage(card);
	if card.is_in_hand() and card.has_multiply() and \
	card.controller.get_matching_type(card.card_type) != CardEnums.CardType.NULL:
		multi *= 2;
	if !card.is_buried and (multi > 1 or multi < 0):
		gameplay_card.show_multiplier_bar(multi);
	else:
		gameplay_card.hide_multiplier_bar();

func determine_winner(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	return System.Fighting.determine_winner(card, enemy);

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
	card.die();

func check_if_played(card : GameplayCard) -> bool:
	var mouse_position : Vector2 = get_local_mouse_position();
	var card_margin : int = GameplayCard.SIZE.y;
	if !(can_play_card and mouse_position.y + card_margin >= FIELD_START_LINE and mouse_position.y - card_margin <= FIELD_END_LINE) or card.scale > GameplayCard.MIN_SCALE_VECTOR:
		return false;
	System.CardManager.play_card(card, player_one, player_two, self);
	return true;

func replace_played_card(card : CardData) -> void:
	var player : Player = card.controller;
	var opponent : Player = get_opponent(card);
	var card_to_replace : GameplayCard = get_card(player.get_field_card());
	if card_to_replace:
		card_to_replace.despawn();
		card_to_replace.move();
	player.clear_field();
	System.CardManager.play_card(System.CardManager.spawn_card(card, self), player, opponent, self, true);

func _on_your_turn_end() -> void:
	if has_been_stopping_turn:
		stopped_time_results();
		return;
	wait_opponent_to_play();

func _on_opponent_turns_end() -> void:
	go_to_pre_results();

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
	play_sfx_player(sfx_player, sound, volume, pitch);

func play_throwable_sfx(sound_path : String, volume : int = Config.THROWABLE_SFX_VOLUME, pitch : float = System.game_speed):
	var sound : Resource = load(sound_path);
	play_sfx_player(throwable_player, sound, volume, pitch);

func play_sfx_player(player : AudioStreamPlayer2D, sound : Resource, volume : int = Config.SFX_VOLUME, pitch : float = System.game_speed):
	if Config.MUTE_SFX:
		return;
	player.pitch_scale = pitch;
	player.volume_db = volume;
	player.stream = sound;
	player.play();

func erase_card(card : GameplayCard, despawn_position : Vector2 = Vector2.ZERO) -> void:
	cards.erase(card.instance_id);
	cards_layer.remove_child(card);
	cards_layer2.add_child(card);
	card.despawn(despawn_position);
	card.do_get_small = true;

func turn_card_into_another(card : CardData) -> void:
	var player : Player = card.controller;
	player.make_card_alterations_permanent(card);
	if card.has_auto_hydra():
		player.build_hydra(card, true);
	card.just_spawned_dont_discard = true;
	update_alterations_for_card(card, true);
	if get_card(card):
		System.EyeCandy.card_shine_effect(get_card(card), self);

func wait_for_animation(card : CardData, type : GameplayEnums.AnimationType, animation_data : Dictionary = {}) -> int:
	var instance_id = System.Random.instance_id();
	var animation_sound : Resource;
	var is_counter_animation : bool;
	if animation_instance_id != 0:
		animation_wait_timer.stop();
		after_animation(true, true);
		is_counter_animation = true;
	animation_instance_id = instance_id;
	animation_card = card;
	animation_data.type = type;
	current_animation_type = type;
	animations[instance_id] = animation_data;
	animation_wait_timer.wait_time = System.random.randf_range(AnimationMinWaitTime[type], AnimationMaxWaitTime[type]) * System.game_speed_additive_multiplier;
	animation_wait_timer.start();
	is_waiting_for_animation_to_finnish = true;
	results_phase = 0;
	match type:
		GameplayEnums.AnimationType.INFINITE_VOID:
			pass;
		GameplayEnums.AnimationType.OCEAN:
			pass;
		GameplayEnums.AnimationType.POSITIVE:
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
		GameplayEnums.AnimationType.INFINITE_VOID:
			pass;
		GameplayEnums.AnimationType.POSITIVE:
			high_tide_speed *= 2;
			ocean_effect_speed_exponent /= 5;
		GameplayEnums.AnimationType.OCEAN:
			pass;
	if !is_counter_animation:
		emit_signal("stop_music");
	if Config.MUTE_SFX:
		return instance_id;
	animation_sfx.stream = load(get_animation_sound_path(type));
	animation_sfx.volume_db = Config.SFX_VOLUME + Config.GUN_VOLUME;
	animation_sfx.play();
	return instance_id;

func get_ocean_material_for_animation(type : GameplayEnums.AnimationType) -> ShaderMaterial:
	var shader : Resource;
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	match type:
		GameplayEnums.AnimationType.INFINITE_VOID:
			shader = load("res://Shaders/CardEffects/infinite-void-shader.gdshader");
		GameplayEnums.AnimationType.OCEAN:
			shader = load("res://Shaders/CardEffects/ocean-shader.gdshader");
		GameplayEnums.AnimationType.POSITIVE:
			shader = load("res://Shaders/Background/star-wave.gdshader");
	shader_material.shader = shader;
	match type:
		GameplayEnums.AnimationType.INFINITE_VOID:
			shader_material.set_shader_parameter("event_horizon_radius", 0.1);
			shader_material.set_shader_parameter("pull_strength", 2);
			shader_material.set_shader_parameter("swirl_strength", 3.0);
			shader_material.set_shader_parameter("swirl_speed", 2);
			shader_material.set_shader_parameter("chaos_amount", 0.8);
			shader_material.set_shader_parameter("chaos_freq", 16.0);
			
			shader_material.set_shader_parameter("wave_speed", 1.9);
			shader_material.set_shader_parameter("wave_frequency", 64.0);
			shader_material.set_shader_parameter("wave_amplitude", 0.02);
			shader_material.set_shader_parameter("angular_bias", 0.6);
			
			shader_material.set_shader_parameter("space_color", Color(0.04, 0.02, 0.07, 1.0));
			shader_material.set_shader_parameter("hole_tint",  Color(0.12, 0.00, 0.22, 1.0));
			shader_material.set_shader_parameter("ring_color", Color(0.85, 0.60, 1.00, 1.0));
			
			shader_material.set_shader_parameter("ring_radius", 0.2);
			shader_material.set_shader_parameter("ring_thickness", 0.04);
			shader_material.set_shader_parameter("ring_glow", 1.4);
			shader_material.set_shader_parameter("ring_scroll", 1.2);
			
			shader_material.set_shader_parameter("mix_rate", 1.0);
			shader_material.set_shader_parameter("opacity", 1.0);
		GameplayEnums.AnimationType.OCEAN:
			shader_material.set_shader_parameter("wave_speed", 1.0);
			shader_material.set_shader_parameter("wave_frequency", 20.0);
			shader_material.set_shader_parameter("wave_amplitude", 0.02);
			shader_material.set_shader_parameter("water_color", Color(0.0, 0.4, 0.8, 1.0));
			shader_material.set_shader_parameter("shine_speed", 10.0);
			shader_material.set_shader_parameter("shine_color", Color(1.0, 1.0, 1.0, 1.0));
			shader_material.set_shader_parameter("shine_strength", 0.3);
			shader_material.set_shader_parameter("opacity", 1.0);
			shader_material.set_shader_parameter("mix_rate", 1.0);
		GameplayEnums.AnimationType.POSITIVE:
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

func get_animation_sound_path(type : GameplayEnums.AnimationType) -> String:
	match type:
		GameplayEnums.AnimationType.INFINITE_VOID:
			return "res://Assets/SFX/CardSounds/Bursts/infinite-void.wav";
		GameplayEnums.AnimationType.OCEAN:
			return "res://Assets/SFX/CardSounds/Bursts/ocean.wav";
		GameplayEnums.AnimationType.POSITIVE:
			return "res://Assets/SFX/CardSounds/Bursts/positive-sound.wav";
	return "";

func play_sabotage_sound() -> void:
	play_throwable_sfx(SABOTAGE_SOUND_PATH);

func play_coin_flip_sound() -> void:
	play_throwable_sfx(COIN_FLIP_SOUND_PATH);

func play_coin_lose_sound() -> void:
	play_throwable_sfx(COIN_LOSE_SOUND_PATH);

func play_berserk_sound() -> void:
	play_throwable_sfx(BERSERK_SOUND_PATH);

func play_dirt_sound() -> void:
	play_throwable_sfx(DIRT_SOUND_PATH);

func play_spy_sound() -> void:
	play_throwable_sfx(SPY_SOUND_PATH);

func play_digital_sound() -> void:
	play_throwable_sfx(DIGITAL_SOUND_PATH);

func play_shadow_replace_sound() -> void:
	play_throwable_sfx(SHADOW_REPLACE_SOUND_PATH);

func play_recycle_sound() -> void:
	play_throwable_sfx(RECYCLE_SOUND_PATH);

func play_rattlesnake_sound() -> void:
	play_throwable_sfx(RATTLESNAKE_SOUND_PATH);

func play_clone_sound() -> void:
	play_throwable_sfx(CLONE_SOUND_PATH);

func play_perfect_clone_sound() -> void:
	play_throwable_sfx(PERFECT_CLONE_SOUND_PATH);

func play_contagious_sound() -> void:
	play_throwable_sfx(CONTAGIOUS_SOUND_PATH);

func play_perfect_contagious_sound() -> void:
	play_throwable_sfx(PERFECT_CONTAGIOUS_SOUND_PATH);

func send_card_to_be_spied(card : CardData, player : Player, margin : Vector2 = Vector2.ZERO) -> void:
	var spied_card : GameplayCard;
	System.CardManager.spawn_card(card, self);
	spied_card = get_card(card);
	match player.controller:
		GameplayEnums.Controller.PLAYER_ONE:
			if System.Instance.exists(active_card) and spied_card == active_card:
				_on_card_released(spied_card, true);
	spied_card.go_visit_point(player.visit_point + margin);
	spied_card.visit_instance_id = spying_instance_id;
	if card.has_victim():
		play_rattlesnake_sound();
		spied_card.rattlesnake_effect();

func opponents_turn() -> void:
	var card : CardData;
	if is_spying:
		return wait_opponent_to_play();
	active_player = player_two;
	if player_two.hand_empty():
		_on_player_two_cannot_play_more();
		return;
	led_direction = OPPONENTS_LED_DIRECTION;
	led_color = IDLE_LED_COLOR;
	player_two.cards_in_hand.sort_custom(func(a : CardData, b : CardData): return System.EnemyAI.best_to_play_for_opponent(a, b, self));
	#for car in player_two.cards_in_hand:
		#print(car.card_name, " ", get_result_for_playing(car));
	#print("-----");
	card = player_two.cards_in_hand.back();
	if !System.CardManager.play_card(System.CardManager.spawn_card(card, self), player_two, player_one, self):
		wait_opponent_playing();
		return;
	if going_first or has_been_stopping_turn:
		go_to_pre_results();
	else:
		your_turn();

func _on_player_two_cannot_play_more() -> void:
	_on_opponent_turns_end() if going_first else your_turn();

func wait_opponent_to_play(do_extend : bool = false) -> void:
	opponents_play_wait.wait_time = OPPONENT_TO_PLAY_WAIT * (2 if do_extend else 1) * System.game_speed_additive_multiplier;
	opponents_play_wait.start();

func wait_opponent_playing() -> void:
	opponents_play_wait.wait_time = OPPONENTS_PLAY_WAIT * System.game_speed_additive_multiplier;
	opponents_play_wait.start();

func cannot_go_to_results() -> bool:
	return is_spying or is_wet_wait_on or is_waiting_for_animation();

func is_waiting_for_animation() -> bool:
	var card : CardData = animation_card;
	var enemy : CardData;
	if !is_waiting_for_animation_to_finnish:
		return false;
	if System.Instance.exists(card):
		enemy = animation_card.controller.opponent.get_field_card();
		if System.Instance.exists(enemy) and enemy.has_soul_robber() and System.Fighting.determine_winner(card, enemy) == GameplayEnums.Controller.PLAYER_TWO:
			return false;
	return true;

func start_results() -> void:
	round_results_timer.wait_time = ROUND_RESULTS_WAIT * System.game_speed_additive_multiplier;
	round_results_timer.start();

func gain_points_effect(player : Player, is_negative : bool = false) -> void:
	click_your_points(is_negative) if player == player_one else click_opponents_points(is_negative);
	update_point_visuals();

func get_opponent(card : CardData) -> Player:
	if card.controller == player_one:
		return player_two;
	return player_one;

func calculate_base_points(card : CardData, enemy : CardData, did_win : bool = false, add_advantages : bool = true) -> int:
	return System.Fighting.calculate_base_points(card, enemy, did_win, add_advantages);

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
	if ((card.has_sinful() or (enemy and enemy.has_incinerate())) and !card.has_cursed()) or (enemy and enemy.has_soul_robber()):
		get_card(card).burn_effect();
		burn_card(card);
	get_card(card).dissolve();
	get_card(card).loser_small_effect();
	if get_card(enemy):
		get_card(enemy).winner_big_effect();

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
		if card and (card.is_gun() and !card.is_buried) and (!enemy or System.Fighting.check_type_results(card, enemy) != GameplayEnums.Controller.PLAYER_TWO):
			await stopped_time_shooting(card, get_opponent(card).get_field_card());
		System.TimeStop.time_stop_effect_out(self);
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
	if your_point_update_timer.is_stopped():
		your_point_update_wait = POINT_UPDATE_STARTING_WAIT;
		your_point_update_timer.start();
	if opponents_point_update_timer.is_stopped():
		opponents_point_update_wait = POINT_UPDATE_STARTING_WAIT;
		opponents_point_update_timer.start();
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
	System.EyeCandy.spawn_poppets(points, card, player, self);
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
				CardEnums.Keyword.SOUL_ROBBER:
					if enemy:
						player.steal_card(enemy);
				CardEnums.Keyword.VAMPIRE:
					System.EyeCandy.spawn_poppets(opponent.lose_points(points), card, opponent, self);
	if enemy:
		for keyword in enemy.keywords:
			match keyword:
				CardEnums.Keyword.EXTRA_SALTY:
					System.EyeCandy.spawn_poppets(opponent.lose_points(System.Rules.EXTRA_SALTY_POINTS_LOST), enemy, opponent, self);
				CardEnums.Keyword.SALTY:
					System.EyeCandy.spawn_poppets(opponent.lose_points(System.Rules.SALTY_POINTS_LOST), enemy, opponent, self);
	gain_points_effect(player);
	if have_you_won() or has_opponent_won():
		start_game_over();

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
			return System.EyeCandy.play_bullets_shooting_animation(card, enemy, self, do_zoom, slow_down);
		CardData.ShootingType.TENTACLES:
			return System.EyeCandy.play_tentacles_shooting_animation(card, enemy, self, do_zoom, slow_down, do_fade);
	return [];

func move_card_front(card : GameplayCard) -> void:
	if cards_layer.is_ancestor_of(card):
		cards_layer.remove_child(card);
	else:
		cards_layer2.remove_child(card);
	cards_layer.add_child(card);

func start_wet_wait() -> void:
	is_wet_wait_on = true;
	wet_wait_timer.wait_time = System.random.randf_range(WET_MIN_WAIT, WET_MAX_WAIT) * System.game_speed_additive_multiplier;
	wet_wait_timer.start();

func zoom_to_node(node : Node2D) -> void:
	emit_signal("zoom_to", node, true);

func check_lose_effects(card : CardData, player : Player) -> void:
	if card and card.has_greed():
		player.draw_cards(2);

func click_your_points(is_negative : bool = false) -> void:
	your_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(YOUR_POINT_SOUND_PATH if !is_negative else YOUR_NEGATIVE_POINT_SOUND_PATH);
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

func click_opponents_points(is_negative : bool = false) -> void:
	opponents_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(OPPONENTS_POINT_SOUND_PATH if !is_negative else OPPONENTS_NEGATIVE_POINT_SOUND_PATH);
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

func end_round() -> void:
	if System.EndOfTurn.clear_field(self):
		start_next_round_timer.wait_time = System.random.randf_range(OCEAN_POINTS_MIN_WAIT, OCEAN_POINTS_MAX_WAIT) * System.game_speed_additive_multiplier;
		start_next_round_timer.start();
	else:
		if is_time_stopped:
			System.TimeStop.time_stop_effect_out(self);
			return;
		start_next_round();

func start_next_round() -> void:
	times_time_stopped_this_round = 0;
	set_going_first(!going_first);
	start_round();

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
	System.TimeStop.time_stop_frame(delta, self);
	if is_dying:
		death_frame(delta);
	if is_undying:
		undying_frame(delta);
	if has_game_ended:
		victory_pattern.material.set_shader_parameter("opacity", victory_banner.modulate.a);
	if current_animation_type != GameplayEnums.AnimationType.NULL:
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
		GameplayEnums.AnimationType.INFINITE_VOID:
			max_opacity = INFINITE_VOID_BACKGROUND_MAX_OPACITY;
		GameplayEnums.AnimationType.POSITIVE:
			max_opacity = POSITIVE_BACKGROUND_MAX_OPACITY;
		GameplayEnums.AnimationType.OCEAN:
			pass;
	max_opacity = max(ocean_pattern.material.get_shader_parameter("opacity"), max_opacity);
	ocean_pattern.material.set_shader_parameter("opacity", min(max_opacity, ocean_pattern.modulate.a));
	if !System.Instance.exists(ocean_card):
		return;
	ocean_pattern.material.set_shader_parameter("wave_center", System.Vectors.get_scale_position(ocean_card.position));

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
	System.PreResults.go_to_results(self);

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
	player_one.cards_in_hand.sort_custom(func(a : CardData, b : CardData): return System.EnemyAI.best_to_play_for_you(a, b, self));
	card = player_one.cards_in_hand.back();
	System.CardManager.spawn_card(card, self);
	System.CardManager.play_card(get_card(card), player_one, player_two, self);

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
	if is_clicking_disabled():
		return;
	is_dying = true;
	is_undying = false;

func _on_die_released() -> void:
	if is_clicking_disabled():
		return;
	is_undying = true;
	is_dying = false;

func is_clicking_disabled() -> bool:
	return !is_active or has_game_ended or is_preloaded;

func _on_wet_wait_timer_timeout() -> void:
	wet_wait_timer.stop();
	is_wet_wait_on = false;

func after_ocean(is_forced : bool) -> void:
	var card : CardData = ocean_card.card_data if System.Instance.exists(ocean_card) else null;
	var enemy : CardData = get_opponent(card).get_field_card() if System.Instance.exists(ocean_card) else null;
	if is_forced:
		return;
	System.AutoEffects.make_card_wet(enemy, self);
	if !has_ocean_wet_self:
		System.AutoEffects.make_card_wet(card, self);

func after_positive(is_forced : bool, points : int, card : CardData, player : Player) -> void:
	if get_card(card):
		get_card(card).shine_star.shutter();
	if is_forced:
		return;
	player.gain_points(points);
	gain_points_effect(player);
	System.EyeCandy.spawn_poppets(points, card, player, self);

func after_infinite_void() -> void:
	pass;

func after_animation(is_forced : bool = false, is_being_countered : bool = false) -> void:
	var animation_data : Dictionary;
	if animation_instance_id == 0:
		return;
	animation_data = animations[animation_instance_id]
	
	is_waiting_for_animation_to_finnish = false;
	animations.erase(animation_instance_id);
	animation_instance_id = 0;
	animation_card = null;
	current_animation_type = GameplayEnums.AnimationType.NULL;
	animation_sfx.stop();
	match animation_data.type:
		GameplayEnums.AnimationType.INFINITE_VOID:
			after_infinite_void();
		GameplayEnums.AnimationType.OCEAN:
			after_ocean(is_forced);
		GameplayEnums.AnimationType.POSITIVE:
			after_positive(is_forced, animation_data.points, animation_data.card, animation_data.player);
	low_tide_speed = System.random.randf_range(LOW_TIDE_MIN_SPEED, LOW_TIDE_MAX_SPEED) * System.game_speed_multiplier;
	is_low_tiding = true;
	if is_time_stopped or is_being_countered:
		return;
	emit_signal("play_prev_song");
	
func _on_animation_wait_timer_timeout() -> void:
	animation_wait_timer.stop();
	after_animation();
	
func open_settings_menu() -> void:
	pass;

func _on_settings_button_triggered() -> void:
	settings_clicked_counter += 1;
	if settings_clicked_counter == 25:
		emit_signal("reset_game");
	if is_clicking_disabled() or true: #TODO
		return;
	_on_card_released(active_card, true);
	_on_die_released();
	is_active = false;
	open_settings_menu();

func _on_game_monitor_timer_timeout() -> void:
	var card : CardData;
	if !active_player == player_one or !can_play_card:
		return;
	if active_player.hand_empty():
		_on_player_one_cannot_play_more();
	else:
		for c in player_one.cards_in_hand:
			card = c;
			card.zone = CardEnums.Zone.HAND;

func _on_your_point_update_timer_timeout() -> void:
	update_shown_points(player_one);

func _on_opponents_point_update_timer_timeout() -> void:
	update_shown_points(player_two);

func update_shown_points(player : Player) -> void:
	var is_player_one : bool = player.controller == GameplayEnums.Controller.PLAYER_ONE;
	var timer : Timer = your_point_update_timer if is_player_one else opponents_point_update_timer;
	var shown_points : float = your_shown_points if is_player_one else opponents_shown_points;
	var wait_time : float = your_point_update_wait if is_player_one else opponents_point_update_wait;
	var point_label : Label = your_points if is_player_one else opponents_points;
	if shown_points == player.points:
		timer.stop();
		return;
	if shown_points < player.points:
		shown_points += 1;
	else:
		shown_points -= 1;
	point_label.text = str(shown_points);
	if shown_points != player.points:
		wait_time = calculate_point_update_wait_error(wait_time);
		timer.wait_time = wait_time * Config.GAME_SPEED_MULTIPLIER;
	if is_player_one:
		your_point_update_wait = wait_time;
		your_shown_points = shown_points;
	else:
		opponents_point_update_wait = wait_time;
		opponents_shown_points = shown_points;
	if shown_points != player.points:
		timer.start();
	else:
		timer.stop();

func calculate_point_update_wait_error(wait_time : float) -> float:
	wait_time /= POINT_UPDATE_SPEED_UP;
	return clamp(wait_time + (System.Random.direction() * POINT_UPDATE_WAIT_ERROR if wait_time > POINT_UPDATE_WAIT_ERROR else 0), MIN_POINT_UPDATE_WAIT, MAX_POINT_UPDATE_WAIT);
