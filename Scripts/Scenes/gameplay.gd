extends Gameplay

@onready var cards_layer : Node2D = $CardsLayer;
@onready var cards_layer2 : Node2D = $CardsLayer2;
@onready var field_lines : Node2D = $FieldLines;
@onready var starting_hints : JumpingText = $Background/StartingHints;
@onready var victory_banner : JumpingText = $VictoryBanner;
@onready var victory_banner_sprite : Sprite2D = $VictoryBanner/Sprite2D;

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

@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;
@onready var sfx_player : AudioStreamPlayer2D = $Background/SfxPlayer;
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

func init(level_data_ : LevelData) -> void:
	level_data = level_data_;
	init_player(player_one, GameplayEnums.Controller.PLAYER_ONE, level_data.deck2_id);
	init_player(player_two, GameplayEnums.Controller.PLAYER_TWO, level_data.deck_id);
	init_layers();
	set_going_first(System.Random.boolean());
	highlight_face(false);
	start_round();
	update_character_faces();
	initialize_background_pattern();
	cards_shadow.modulate.a = 0;
	trolling_sprite.visible = false;
	spawn_leds();
	init_audio();
	victory_banner.stop();
	victory_banner.modulate.a = 0;

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

func init_player(player : Player, controller : GameplayEnums.Controller, deck_id : int) -> void:
	var card : CardData;
	var character_id : GameplayEnums.Character = \
		level_data.player if controller == GameplayEnums.Controller.PLAYER_ONE else level_data.opponent;
	player.controller = controller;
	player.eat_decklist(deck_id, character_id);
	for c in player.cards_in_deck:
		card = c;
		card.controller = player;
	player.field_position = FIELD_POSITION if controller == GameplayEnums.Controller.PLAYER_ONE else -FIELD_POSITION;
	player.visit_point = VISIT_POSITION if controller == GameplayEnums.Controller.PLAYER_ONE else -VISIT_POSITION;
	
func initialize_background_pattern() -> void:
	var pattern : Resource = load(LEVEL_BACKGROUND_PATH % [level_data.background_id]);
	background_pattern.texture = pattern;
	
func update_character_faces() -> void:
	var your_face_texture : Resource = load_face_texture(level_data.player_variant);
	var opponent_face_texture : Resource = load_face_texture(level_data.opponent_variant);
	var troll_texture : Resource = load(CHARACTER_FULL_ART_PATH % level_data.opponent_variant);
	your_face.texture = your_face_texture;
	opponents_face.texture = opponent_face_texture;
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
	troll_timer.wait_time = System.random.randf_range(TROLL_MIN_WAIT, TROLL_MAX_WAIT) * System.game_speed_multiplier;

func have_you_won() -> bool:
	var result : bool = player_one.points >= System.Rules.VICTORY_POINTS;
	if result:
		_on_you_won();
	return result;

func _on_you_won() -> void:
	highlight_face();

func has_opponent_won() -> bool:
	var result : bool = player_two.points >= System.Rules.VICTORY_POINTS;
	if result:
		_on_opponent_wins();
	return result;

func _on_opponent_wins() -> void:
	pass;

func start_round() -> void:
	if have_you_won() or has_opponent_won():
		start_game_over();
		return;
	player_one.draw_hand();
	player_two.draw_hand();
	show_hand();
	player_two.shuffle_hand();
	if going_first:
		your_turn();
	else:
		opponents_turn();

func start_game_over() -> void:
	victory_banner.fade_in();
	init_victory_banner_sprite();
	game_over_timer.wait_time = GAME_OVER_WAIT * System.game_speed_multiplier;
	game_over_timer.start();

func init_victory_banner_sprite() -> void:
	var texture : Resource = load("res://Assets/Art/VictoryBanners/%s.png" % ["champion" if did_win else "loser"]);
	victory_banner_sprite.texture = texture;

func end_game() -> void:
	emit_signal("game_over", did_win);

func your_turn() -> void:
	if is_spying:
		you_play_wait.wait_time = YOU_TO_PLAY_WAIT * System.game_speed_multiplier;
		return you_play_wait.start();
	led_direction = YOUR_LED_DIRECTION if started_playing else OFF_LED_DIRECTION;
	led_color = IDLE_LED_COLOR if started_playing else OFF_LED_DIRECTION;
	show_hand();
	highlight_face();
	if player_one.hand_empty():
		_on_your_turn_end() if going_first else _on_opponent_turns_end();
		return;
	can_play_card = true;
	if !Config.AUTO_PLAY:
		return;
	auto_play_timer.wait_time = System.random.randf_range(AUTO_PLAY_MIN_WAIT, AUTO_PLAY_MAX_WAIT) * System.game_speed_multiplier;
	auto_play_timer.start()

func init_layers() -> void:
	field_lines.modulate.a = 0;

func show_hand() -> void:
	var card : CardData;
	for c in player_one.cards_in_hand:
		card = c;
		spawn_card(card);
	reorder_hand();

func get_card(card : CardData) -> GameplayCard:
	return cards[card.instance_id] if card and cards.has(card.instance_id) else null;

func reorder_hand(do_shuffle : bool = false) -> void:
	var card : GameplayCard;
	var position : Vector2 = HAND_POSITION;
	if do_shuffle:
		player_one.cards_in_hand.shuffle()
	else:
		player_one.cards_in_hand.sort_custom(sort_by_card_position);
	position.x -= HAND_MARGIN * ((player_one.count_hand() - 1) / 2.0);
	for card_data in player_one.cards_in_hand:
		if System.Instance.exists(active_card) and active_card.card_data.instance_id == card_data.instance_id:
			position.x += HAND_MARGIN;
			continue;
		if !get_card(card_data) or get_card(card_data).is_despawning:
			continue;
		card = cards[card_data.instance_id];
		card.goal_position = position;
		card.move();
		position.x += HAND_MARGIN;

func spawn_card(card_data : CardData) -> GameplayCard:
	update_alterations_for_card(card_data);
	if cards.has(card_data.instance_id):
		return cards[card_data.instance_id];
	var card : GameplayCard = System.Instance.load_child(System.Paths.CARD, cards_layer if active_card == null else cards_layer2);
	card.card_data = card_data;
	card.instance_id = card_data.instance_id;
	card.init(card_data.controller.gained_keyword);
	cards[card.card_data.instance_id] = card;
	card.position = CARD_STARTING_POSITION if card_data.controller == player_one else -CARD_STARTING_POSITION;
	if !Config.AUTO_PLAY:
		card.pressed.connect(_on_card_pressed);
		card.released.connect(_on_card_released);
	card.despawned.connect(_on_card_despawned);
	card.visited.connect(_on_card_visited);
	return card;

func _on_card_visited(card : GameplayCard) -> void:
	if is_spying:
		resolve_spying(card);
		
func resolve_spying(spy_target : GameplayCard) -> void:
	var enemy : CardData = spy_target.card_data;
	var opponent : Player = enemy.controller;
	var player : Player = get_opponent(enemy);
	var card : CardData = player.get_field_card();
	var winner : GameplayEnums.Controller = determine_winner(card, enemy);
	var points : int = 1;
	if enemy.has_secrets():
		winner = GameplayEnums.Controller.PLAYER_ONE;
		points = 3;
	if card and card.is_gun():
		play_shooting_animation(card, enemy);
	if enemy and enemy.is_gun():
		play_shooting_animation(enemy, card);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			trigger_winner_loser_effects(card, enemy, player, opponent, points);
			opponent.discard_from_hand(enemy);
			spy_target.despawn();
			if cards_to_spy > 0:
				if spy_opponent(card, player, opponent, cards_to_spy):
					return;
		GameplayEnums.Controller.PLAYER_TWO:
			trigger_winner_loser_effects(enemy, card, opponent, player);
			player.send_from_field_to_grave(card);
			if get_card(card):
				get_card(card).despawn();
			match player.controller:
				GameplayEnums.Controller.PLAYER_ONE:
					spy_target.despawn(-CARD_STARTING_POSITION);
					if !player.hand_empty():
						opponents_play_wait.stop();
						pre_results_timer.stop();
						stop_spying();
						you_play_wait.start();
						return;
				GameplayEnums.Controller.PLAYER_TWO:
					reorder_hand();
					if !opponent.hand_empty():
						you_play_wait.stop();
						stop_spying();
						opponents_play_wait.start();
						return;
		GameplayEnums.Controller.NULL:
			play_tie_sound();
			if opponent.controller == GameplayEnums.Controller.PLAYER_TWO:
				spy_target.despawn(-CARD_STARTING_POSITION)
			else:
				reorder_hand();
	spying_timer.wait_time = SPY_WAIT_TIME * System.game_speed_multiplier;
	spying_timer.start();

func stop_spying() -> void:
	is_spying = false;

func update_card_alterations() -> void:
	for card in player_one.get_active_cards() + player_two.get_active_cards():
		update_alterations_for_card(card);

func update_alterations_for_card(card_data : CardData) -> void:
	var card : GameplayCard = get_card(card_data);
	if card_data.has_undead():
		if card_data.has_undead(true):
			card_data.card_type = CardEnums.CardType.GUN;
		else:
			card_data.card_type = card_data.default_type;
	if card:
		card.update_visuals(card.card_data.controller.gained_keyword);

func _on_card_pressed(card : GameplayCard) -> void:
	if System.Instance.exists(active_card) or card.card_data.zone != CardEnums.Zone.HAND:
		return;
	if !started_playing:
		_on_started_playing();
	active_card = card;
	card.toggle_follow_mouse();
	update_keywords_hints(card);
	card_focus_timer.wait_time = CARD_FOCUS_WAIT * System.game_speed_multiplier;
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
	var hints_text : String;
	var keywords : Array = card.card_data.keywords.duplicate();
	var gained_keyword : CardEnums.Keyword = card.card_data.controller.gained_keyword;
	if  gained_keyword != CardEnums.Keyword.NULL and keywords.size() < System.Rules.MAX_KEYWORDS:
		keywords.append(gained_keyword);
	for keyword in keywords:
		var hint_text : String = CardEnums.KeywordHints[keyword] if CardEnums.KeywordHints.has(keyword) else "";
		hint_text = enrich_hint(hint_text, card);
		hints_text += KEYWORD_HINT_LINE % [CardEnums.KeywordNames[keyword] if CardEnums.KeywordNames.has(keyword) else "?", hint_text];
	keywords_hints.text = hints_text;

func enrich_hint(message : String, card : GameplayCard, ) -> String:
	message = message \
		.replace("SAME_TYPES", CardEnums.CardTypeName[card.card_data.default_type].to_lower() + "s") \
		.replace("SAME_BASIC", "[b]%s[/b]" % CardEnums.BasicNames[card.card_data.default_type]);
	return message;

func put_other_cards_behind(card : GameplayCard) -> void:
	for instance_id in cards:
		if instance_id == card.card_data.instance_id:
			continue;
		cards_layer.remove_child(cards[instance_id]);
		cards_layer2.add_child(cards[instance_id]);

func _on_card_released(card : GameplayCard) -> void:
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
	check_if_played(card);

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
	cards.erase(card.instance_id);
	card.queue_free();

func check_if_played(card : GameplayCard) -> void:
	var mouse_position : Vector2 = get_local_mouse_position();
	var card_margin : int = GameplayCard.SIZE.y;
	if !(can_play_card and mouse_position.y + card_margin >= FIELD_START_LINE and mouse_position.y - card_margin <= FIELD_END_LINE):
		return;
	play_card(card, player_one, player_two);

func replace_played_card(card : CardData) -> void:
	var player : Player = card.controller;
	var opponent : Player = get_opponent(card);
	get_card(player.get_field_card()).despawn();
	player.clear_field();
	play_card(spawn_card(card), player, opponent, true);

func play_card(card : GameplayCard, player : Player, opponent : Player, is_digital_speed : bool = false) -> bool:
	player.play_card(card.card_data, is_digital_speed);
	if card.card_data.has_hydra() and !card.card_data.has_buried():
		player.build_hydra(card.card_data);
	if card.card_data.has_buried():
		if !is_digital_speed:
			card.bury();
	else:
		trigger_play_effects(card.card_data, player, opponent);
	opponent.trigger_opponent_placed_effects();
	update_card_alterations();
	if check_for_devoured(card, player, opponent):
		reorder_hand();
		if player == player_one and Config.AUTO_PLAY:
			auto_play_timer.wait_time = System.random.randf_range(AUTO_PLAY_MIN_WAIT, AUTO_PLAY_MAX_WAIT) * System.game_speed_multiplier;
			auto_play_timer.start();
		return false;
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
		_on_your_turn_end(card.card_data.has_devour());
	else:
		_on_opponent_turns_end();
	return true;

func _on_your_turn_end(do_extend_wait : bool = false) -> void:
	wait_opponent_to_play();

func _on_opponent_turns_end() -> void:
	go_to_pre_results();

func check_for_devoured(card : GameplayCard, player : Player, opponent : Player, is_digital_speed : bool = false) -> bool:
	var enemy : CardData = opponent.get_field_card();
	var eater_was_face_down : bool;
	if is_digital_speed:
		return false;
	if enemy and enemy.has_devour() and player.cards_played_this_turn == 1:
		eater_was_face_down = enemy.is_buried;
		opponent.devour_card(enemy, card.card_data);
		player.send_from_field_to_grave(card.card_data);
		if eater_was_face_down:
			trigger_play_effects(enemy, opponent, player);
		get_card(enemy).update_visuals();
		erase_card(card, opponent.field_position + Vector2(0, -GameplayCard.SIZE.y * (2.85/4.0) \
			if player.controller == GameplayEnums.Controller.PLAYER_ONE else 0));
		return true;
	return false;

func erase_card(card : GameplayCard, despawn_position : Vector2 = System.Vectors.default()) -> void:
	cards.erase(card.instance_id);
	cards_layer.remove_child(card);
	cards_layer2.add_child(card);
	card.despawn(despawn_position);

func trigger_play_effects(card : CardData, player : Player, opponent : Player) -> void:
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.CELEBRATION:
				celebrate(player);
			CardEnums.Keyword.INFLUENCER:
				influence_opponent(opponent, card.default_type);
			CardEnums.Keyword.MULTI_SPY:
				spy_opponent(card, player, opponent, 3);
			CardEnums.Keyword.RAINBOW:
				opponent.get_rainbowed();
				update_card_alterations();
			CardEnums.Keyword.RELOAD:
				player.shuffle_random_card_to_deck(CardEnums.CardType.GUN).controller = player;
			CardEnums.Keyword.SPY:
				spy_opponent(card, player, opponent);
			CardEnums.Keyword.WRAPPED:
				player.gained_keyword = CardEnums.Keyword.BURIED;

func spy_opponent(card : CardData, player : Player, opponent : Player, chain : int = 1) -> bool:
	var spied_card_data : CardData;
	var spied_card : GameplayCard
	if opponent.hand_empty():
		return false;
	spied_card_data = determine_spied_card(opponent);
	spawn_card(spied_card_data);
	spied_card = get_card(spied_card_data);
	spied_card.go_visit_point(opponent.visit_point);
	cards_to_spy = chain - 1;
	is_spying = true;
	return true;

func determine_spied_card(opponent : Player) -> CardData:
	var cards_with_secret : Array = opponent.cards_in_hand.filter(func(card : CardData):
		return card.has_secrets();	
	);
	return System.Random.item(cards_with_secret if cards_with_secret.size() else opponent.cards_in_hand);

func celebrate(player : Player) -> void:
	var cards_where_in_hand : Array = player.cards_in_hand;
	player.celebrate();
	for card in cards_where_in_hand:
		if cards.has(card.instance_id) and !player.cards_in_hand.has(card):
			if get_card(card):
				get_card(card).despawn();
	show_hand();

func opponents_turn() -> void:
	var card : CardData;
	if is_spying:
		return wait_opponent_to_play();
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
	if going_first:
		go_to_pre_results();
	else:
		your_turn();

func wait_opponent_to_play(do_extend : bool = false) -> void:
	opponents_play_wait.wait_time = OPPONENT_TO_PLAY_WAIT * (2 if do_extend else 1);
	opponents_play_wait.start();

func wait_opponent_playing() -> void:
	opponents_play_wait.wait_time = OPPONENTS_PLAY_WAIT;
	opponents_play_wait.start();

func go_to_results() -> void:
	#This structure waits and comes back everytime some action is done
	#So that player has time to see animation and react mentally.
	#Better structure to use enum for the phase and make it not crawl
	#The whole structure like this. Fix, if this ever gets longer than
	#Let's say 100 lines :D
	if is_spying:
		return results_wait();
	if results_phase < 2:
		if mimics_phase():
			return results_wait();
	if results_phase < 4:
		if digitals_phase():
			return results_wait();
	round_results_timer.wait_time = ROUND_RESULTS_WAIT * System.game_speed_multiplier;
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

func digitals_phase() -> bool:
	var card : CardData = player_one.get_field_card();
	var enemy : CardData = player_two.get_field_card();
	if (card and card.has_emp()) or (enemy and enemy.has_emp()):
		return false;
	if going_first:
		if results_phase < 3:
			results_phase = 3;
			if play_your_digitals():
				return true;
		if results_phase < 4:
			results_phase = 4;
			if play_opponents_digitals():
				results_phase = 2;
				return true;
	else:
		if results_phase < 3:
			results_phase = 3;
			if play_opponents_digitals():
				return true;
		if results_phase < 4:
			results_phase = 4;
			if play_your_digitals():
				results_phase = 2;
				return true;
	return false;

func transform_your_mimics() -> bool:
	var card : CardData = player_two.get_field_card();
	if card and card.has_high_ground():
		return false;
	return transform_mimics(player_one.cards_on_field, player_one, player_two);

func transform_opponents_mimics() -> bool:
	var card : CardData = player_one.get_field_card();
	if card and card.has_high_ground():
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
	if (player.get_field_card() and player.get_field_card().has_cursed()) or winner == GameplayEnums.Controller.PLAYER_ONE:
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
	var points : int = calculate_base_points(card, enemy);
	var points_to_steal : int = calculate_points_to_steal(card, enemy);
	return points + points_to_steal;

func get_lose_points(card : CardData, enemy : CardData) -> int:
	var points : int = calculate_base_points(card, enemy);
	var points_to_lose : int = calculate_points_to_steal(enemy, card);
	return -(points + points_to_lose);

func calculate_base_points(card : CardData, enemy : CardData) -> int:
	var points : int = 1;
	if card.has_champion():
		points *= 2;
	if enemy.has_champion():
		points *= 2;
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

func results_wait() -> void:
	pre_results_timer.wait_time = PRE_RESULTS_WAIT * System.game_speed_multiplier;
	pre_results_timer.start();

func no_mimics() -> bool:
	var card_data : CardData;
	if player_one.get_field_card().has_high_ground() or player_two.get_field_card().has_high_ground():
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
		if card.has_copycat():
			card.card_type = opponent.cards_on_field[0].card_type;
		if get_card(card):
			get_card(card).update_visuals(card.controller.gained_keyword);
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
		return most_valuable(card_a, card_b, player, opponent);
	return a_value < b_value;

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
			CardEnums.Keyword.BURIED:
				value += 5;
			CardEnums.Keyword.CELEBRATION:
				value += 0;
			CardEnums.Keyword.CHAMELEON:
				value += 1;
			CardEnums.Keyword.COOTIES:
				value += 1;
			CardEnums.Keyword.COPYCAT:
				value += 1;
			CardEnums.Keyword.CURSED:
				value += 1;
			CardEnums.Keyword.DEVOUR:
				value += 5 if player.going_first else -1;
			CardEnums.Keyword.DIGITAL:
				value += 5;
			CardEnums.Keyword.DIVINE:
				value += 0;
			CardEnums.Keyword.EMP:
				value += 2;
			CardEnums.Keyword.EXTRA_SALTY:
				value += 6 if player.points == 0 else 2;
			CardEnums.Keyword.GREED:
				value += 10;
			CardEnums.Keyword.HIGH_GROUND:
				value += 2;
			CardEnums.Keyword.HORSE_GEAR:
				value += 0;
			CardEnums.Keyword.HYDRA:
				value += 2;
			CardEnums.Keyword.INFLUENCER:
				value -= 1;
			CardEnums.Keyword.MULTI_SPY:
				value += 3;
			CardEnums.Keyword.PAIR:
				value += 3;
			CardEnums.Keyword.PAIR_BREAKER:
				value += 1;
			CardEnums.Keyword.PICK_UP:
				value += 0;
			CardEnums.Keyword.RAINBOW:
				value += 1;
			CardEnums.Keyword.RELOAD:
				value += 1;
			CardEnums.Keyword.RUST:
				value += 1;
			CardEnums.Keyword.SALTY:
				value += 5 if player.points == 0 else 1;
			CardEnums.Keyword.SECRETS:
				value += 0;
			CardEnums.Keyword.SILVER:
				value += 1;
			CardEnums.Keyword.SOUL_HUNTER:
				value += 1;
			CardEnums.Keyword.SPY:
				value += 2;
			CardEnums.Keyword.UNDEAD:
				value -= 1;
			CardEnums.Keyword.VAMPIRE:
				value += 5 if opponent.points > 0 else 0;
			CardEnums.Keyword.WRAPPED:
				value += 0 if player.going_first else 1;
	if card.has_champion() :
		value *= 2;
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
			return 2;
	return 0;

func get_result_for_playing(card : CardData, player : Player, opponent : Player) -> int:
	var winner : GameplayEnums.Controller;
	var enemy : CardData = get_enemy_card_truth(opponent);
	var value : int = 1;
	if card.has_champion():
		value *= 2;
	if enemy and enemy.has_champion():
		value *= 2;
	if player.going_first and opponent.gained_keyword == CardEnums.Keyword.BURIED and card.has_high_ground():
		return value;
	if !enemy:
		return get_value_to_threaten(card, player, opponent);
	winner = determine_winner(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			if enemy.has_greed() and !player.is_close_to_winning():
				return -2;
			return value;
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
	led_direction = YOUR_LED_DIRECTION;
	led_color = YOUR_LED_COLOR if round_winner == GameplayEnums.Controller.PLAYER_ONE else IDLE_LED_COLOR;
	if card and card.is_gun():
		is_motion_shooting = true;
		play_shooting_animation(card, enemy, round_winner != GameplayEnums.Controller.NULL or System.Random.chance(2));
	if enemy and enemy.is_gun():
		is_motion_shooting = true;
		play_shooting_animation(enemy, card, true);
	if round_winner == GameplayEnums.Controller.PLAYER_TWO:
		led_direction = OPPONENTS_LED_DIRECTION;
		led_color = OPPONENTS_LED_COLOR;
		if !is_motion_shooting and (System.Random.chance(TROLL_CHANCE) or player_two.points >= System.Rules.VICTORY_POINTS - 1):
			opponent_trolling_effect();
			led_direction = WARNING_LED_DIRECTION;
			led_color = WARNING_LED_COLOR;
	match round_winner:
		GameplayEnums.Controller.PLAYER_ONE:
			trigger_winner_loser_effects(card, enemy, player_one, player_two);
			if !player_one.is_close_to_winning() and !System.Random.chance(YOUR_POINTS_ZOOM_CHANCE):
				emit_signal("quick_zoom_to", your_points.position);
		GameplayEnums.Controller.PLAYER_TWO:
			trigger_winner_loser_effects(enemy, card, player_two, player_one);
			if !player_two.is_close_to_winning() and !System.Random.chance(OPPONENTS_POINTS_ZOOM_CHANCE):
				emit_signal("quick_zoom_to", opponents_points.position);
		GameplayEnums.Controller.NULL:
			play_tie_sound()
	if round_winner == GameplayEnums.Controller.NULL:
		end_round();
		return;
	round_end_timer.wait_time = ROUND_END_WAIT * System.game_speed_multiplier;
	round_end_timer.start();

func play_tie_sound() -> void:
	play_point_sfx(TIE_SOUND_PATH);

func update_point_visuals() -> void:
	your_points.text = str(player_one.points);
	opponents_points.text = str(player_two.points);
 
func trigger_winner_loser_effects(card : CardData, enemy : CardData,
	player : Player, opponent : Player, points : int = 1
) -> void:
	if card and card.has_champion():
		points *= 2;
	if enemy and enemy.has_champion():
		points *= 2;
	player.gain_points(points);
	click_your_points() \
		if player.controller == GameplayEnums.Controller.PLAYER_ONE \
		else click_opponents_points();
	check_lose_effects(enemy, opponent);
	if card:
		for keyword in card.keywords:
			match keyword:
				CardEnums.Keyword.SOUL_HUNTER:
					player.steal_card_soul(enemy);
				CardEnums.Keyword.VAMPIRE:
					opponent.lose_points();
	if enemy:
		for keyword in enemy.keywords:
			match keyword:
				CardEnums.Keyword.EXTRA_SALTY:
					opponent.lose_points(-1);
				CardEnums.Keyword.SALTY:
					opponent.lose_points();
	update_point_visuals();

func play_shooting_animation(card : CardData, enemy : CardData, do_zoom : bool = false) -> void:
	var bullet : Bullet;
	var enemy_position : Vector2 = get_card(enemy).get_recoil_position() if enemy else -get_card(card).get_recoil_position();
	var bullets : int = 1;
	if card.has_champion():
		bullets = System.random.randi_range(3, 5)
	elif card.has_pair():
		bullets = 2;
	for i in range(bullets):
		if i > 0:
			enemy_position += System.Random.vector(100, 200);
		bullet = System.Data.load_bullet(card.bullet_id, cards_layer);
		bullet.init(enemy_position - get_card(card).get_recoil_position(), i < 2);
		if do_zoom and i == 0:
			zoom_to_bullet(bullet);
	get_card(card).recoil(enemy_position);

func zoom_to_bullet(bullet : Bullet) -> void:
	emit_signal("zoom_to", bullet, true);

func check_lose_effects(card : CardData, player : Player) -> void:
	if card and card.has_greed():
		player.draw_cards(2);

func click_your_points() -> void:
	your_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(YOUR_POINT_SOUND_PATH);
	if have_you_won():
		did_win = true;
		return;
	points_click_timer.wait_time = POINTS_CLICK_WAIT * System.game_speed_multiplier;
	points_click_timer.start();

func play_point_sfx(file_path : String) -> void:
	var sound_file : Resource = load(file_path);
	point_streamer.stream = sound_file;
	if Config.MUTE_SFX:
		return;
	point_streamer.pitch_scale = max(Config.MIN_PITCH, System.game_speed);
	point_streamer.play();

func click_opponents_points() -> void:
	opponents_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(OPPONENTS_POINT_SOUND_PATH);
	if has_opponent_won():
		return;
	points_click_timer.wait_time = POINTS_CLICK_WAIT * System.game_speed_multiplier;
	points_click_timer.start();

func opponent_trolling_effect() -> void:
	trolling_sprite.position = System.Vectors.default();
	trolling_sprite.visible = true;
	trolling_sprite.rotation_degrees *= System.Random.direction();
	is_trolling = true;
	get_troll_wait();
	troll_timer.start();

func determine_winner(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
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
	match card_type:
		CardEnums.CardType.ROCK:
			match enemy_type:
				CardEnums.CardType.SCISSORS:
					return you_win;
				CardEnums.CardType.PAPER:
					return opponent_wins;
		CardEnums.CardType.PAPER:
			match enemy_type:
				CardEnums.CardType.ROCK:
					return you_win;
				CardEnums.CardType.SCISSORS:
					return opponent_wins;
		CardEnums.CardType.SCISSORS:
			match enemy_type:
				CardEnums.CardType.PAPER:
					return you_win;
				CardEnums.CardType.ROCK:
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
	return not_determined;

func check_post_types_keywords(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	if card.has_pair():
		if !enemy.has_pair():
			return you_win;
	elif enemy.has_pair():
		if !card.has_pair():
			return opponent_wins;
	return not_determined;

func end_round() -> void:
	clear_field();
	set_going_first(!going_first);
	start_round();

func clear_field() -> void:
	clear_players_field(player_one, round_winner == GameplayEnums.Controller.PLAYER_ONE);
	clear_players_field(player_two, round_winner == GameplayEnums.Controller.PLAYER_TWO);

func clear_players_field(player : Player, did_win : bool) -> void:
	var card : CardData;
	var gameplay_card : GameplayCard;
	for c in player.cards_on_field:
		card = c;
		gameplay_card = get_card(card);
		if gameplay_card:
			gameplay_card.despawn();
	for c in player.cards_in_hand:
		card = c;
		if !card.has_pick_up():
			continue;
		gameplay_card = get_card(card);
		if gameplay_card:
			gameplay_card.despawn();
	player.end_of_turn_clear(did_win);

func show_opponents_field() -> void:
	var card : GameplayCard;
	for card_data in player_two.cards_on_field:
		card = cards[card_data.instance_id];
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
	player_one.shuffle_hand();
	player_one.cards_in_hand.sort_custom(best_to_play_for_you);
	card = player_one.cards_in_hand.back();
	spawn_card(card)
	play_card(get_card(card), player_one, player_two);
