extends Gameplay

@onready var cards_layer : Node2D = $CardsLayer;
@onready var cards_layer2 : Node2D = $CardsLayer2;
@onready var field_lines : Node2D = $FieldLines;
@onready var round_results_timer : Timer = $Timers/RoundResultsTimer;
@onready var pre_results_timer : Timer = $Timers/PreResultsTimer;
@onready var round_end_timer : Timer = $Timers/RoundEndTimer;
@onready var game_over_timer : Timer = $Timers/GameOverTimer;
@onready var points_click_timer : Timer = $Timers/PointsClickTimer;
@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var background_music : AudioStreamPlayer2D = $Background/BackgroundMusic;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;
@onready var cards_shadow : Node2D = $CardsShadow;
@onready var points_layer : Node = $Points;
@onready var keywords_hints : RichTextLabel = $CardsShadow/KeywordsHints;

func _ready() -> void:
	player_one.eat_decklist(1);
	player_two.eat_decklist(1);
	init_layers();
	init_timers();
	going_first = System.Random.boolean();
	start_round();

func init_timers() -> void:
	round_results_timer.wait_time = ROUND_RESULTS_WAIT;
	pre_results_timer.wait_time = PRE_RESULTS_WAIT;
	round_end_timer.wait_time = ROUND_END_WAIT;
	game_over_timer.wait_time = GAME_OVER_WAIT;
	points_click_timer.wait_time = POINTS_CLICK_WAIT;

func have_you_won() -> bool:
	return player_one.points >= System.Rules.VICTORY_POINTS;

func has_opponent_won() -> bool:
	return player_two.points >= System.Rules.VICTORY_POINTS;

func start_round() -> void:
	if have_you_won() or has_opponent_won():
		start_game_over();
		return;
	player_one.draw_hand();
	player_two.draw_hand();
	player_two.shuffle_hand();
	if player_one.hand_empty() or player_two.hand_empty():
		start_game_over();
		return;
	if going_first:
		your_turn();
	else:
		opponents_turn();

func start_game_over() -> void:
	game_over_timer.start();

func end_game() -> void:
	emit_signal("game_over");

func your_turn() -> void:
	show_hand();
	can_play_card = true;

func init_layers() -> void:
	field_lines.modulate.a = 0;

func show_hand() -> void:
	for card in player_one.cards_in_hand:
		spawn_card(card);
	reorder_hand();

func reorder_hand() -> void:
	var card : GameplayCard;
	var position : Vector2 = HAND_POSITION;
	player_one.cards_in_hand.sort_custom(sort_by_card_position);
	position.x -= HAND_MARGIN * ((player_one.count_hand() - 1) / 2.0);
	for card_data in player_one.cards_in_hand:
		if System.Instance.exists(active_card) and active_card.card_data.instance_id == card_data.instance_id:
			position.x += HAND_MARGIN;
			continue;
		if !cards.has(card_data.instance_id):
			continue;
		card = cards[card_data.instance_id];
		card.goal_position = position;
		card.move();
		position.x += HAND_MARGIN;

func spawn_card(card_data : CardData, spawn_for_opponent : bool = false) -> GameplayCard:
	if cards.has(card_data.instance_id):
		return cards[card_data.instance_id];
	var card : GameplayCard = System.Instance.load_child(CARD_PATH, cards_layer);
	card.card_data = card_data;
	card.init();
	cards[card.card_data.instance_id] = card;
	card.position = -CARD_STARTING_POSITION if spawn_for_opponent else CARD_STARTING_POSITION;
	card.pressed.connect(_on_card_pressed);
	card.released.connect(_on_card_released);
	card.despawned.connect(_on_card_despawned);
	return card;

func _on_card_pressed(card : GameplayCard) -> void:
	if System.Instance.exists(active_card) or card.card_data.zone != CardEnums.Zone.HAND:
		return;
	active_card = card;
	card.toggle_follow_mouse();
	update_keywords_hints(card);
	cards_shadow.visible = true;
	points_layer.visible = false;
	put_other_cards_behind(card);
	if !can_play_card:
		return;
	field_lines_visible = true;
	fading_field_lines = true;
	field_lines.modulate.a = min(1, max(0, field_lines.modulate.a));

func update_keywords_hints(card : GameplayCard) -> void:
	var hints_text : String;
	for keyword in card.card_data.keywords:
		var hint_text : String = CardEnums.KeywordHints[keyword] if CardEnums.KeywordHints.has(keyword) else "";
		hints_text += KEYWORD_HINT_LINE % [CardEnums.KeywordNames[keyword], hint_text];
	keywords_hints.text = hints_text;

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
	cards_shadow.visible = false;
	points_layer.visible = true;
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
	cards.erase(card.card_data.instance_id);
	card.queue_free();

func check_if_played(card : GameplayCard) -> void:
	var mouse_position : Vector2 = get_local_mouse_position();
	var card_margin : int = GameplayCard.SIZE.y;
	if !(can_play_card and mouse_position.y + card_margin >= FIELD_START_LINE and mouse_position.y - card_margin <= FIELD_END_LINE):
		return;
	play_card(player_one, card);

func play_card(player : Player, card : GameplayCard) -> void:
	player.play_card(card.card_data);
	if card.card_data.has_buried():
		card.bury();
	if card.card_data.has_celebration():
		celebrate(player);
	if player == player_two:
		return;
	card.goal_position = FIELD_POSITION;
	reorder_hand();
	can_play_card = false;
	if going_first:
		opponents_turn();
	else:
		go_to_pre_results();

func celebrate(player : Player) -> void:
	var cards_where_in_hand : Array = player.cards_in_hand;
	player.celebrate();
	for card in cards_where_in_hand:
		if cards.has(card.instance_id) and !player.cards_in_hand.has(card):
			cards[card.instance_id].despawn();
	show_hand();

func opponents_turn() -> void:
	var card : CardData;
	player_two.cards_in_hand.sort_custom(best_to_play);
	#for car in player_two.cards_in_hand:
		#print(car.card_name, " ", get_result_for_playing(car));
	#print("-----");
	card = player_two.cards_in_hand.back();
	play_card(player_two, spawn_card(card, true));
	show_opponents_field();
	if going_first:
		go_to_pre_results();
	else:
		your_turn();

func go_to_results() -> void:
	if !player_two.get_field_card().has_high_ground():
		transform_mimics(player_one.cards_on_field, player_two);
	if !player_one.get_field_card().has_high_ground():
		transform_mimics(player_two.cards_on_field, player_one);
	round_results_timer.start();

func go_to_pre_results() -> void:
	if no_mimics():
		go_to_results();
		return;
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

func transform_mimics(your_cards : Array, opponent : Player) -> void:
	var card : CardData;
	for c in your_cards:
		card = c;
		if card.has_influencer():
			influence_opponent(opponent);
		if card.is_buried:
			card.is_buried = false;
		if card.card_type == CardEnums.CardType.MIMIC:
			card.card_type = opponent.cards_on_field[0].card_type;
		cards[card.instance_id].update_visuals();

func influence_opponent(opponent : Player) -> void:
	if opponent.deck_empty():
		return;
	opponent.cards_in_deck[opponent.cards_in_deck.size() - 1] = CardData.eat_json(System.Data.read_card(1));

func best_to_play(card_a : CardData, card_b : CardData) -> int:
	var a_value : int = get_result_for_playing(card_a);
	var b_value : int = get_result_for_playing(card_b);
	if a_value == b_value:
		return most_valuable(card_a, card_b);
	return a_value < b_value;

func most_valuable(card_a : CardData, card_b : CardData) -> int:
	return -get_card_value(card_a, -1) < -get_card_value(card_b, -1);

func get_card_value(card : CardData, direction : int = 1) -> int:
	var value : int = 10 * get_card_base_value(card);
	var card_data : CardData;
	for c in player_two.cards_in_hand:
		card_data = c;
		if card_data.card_type == card.card_type:
			value += direction * 1;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.BURIED:
				value += 5;
			CardEnums.Keyword.CELEBRATION:
				value += 0;
			CardEnums.Keyword.COPYCAT:
				value += 1;
			CardEnums.Keyword.DIVINE:
				value += 0;
			CardEnums.Keyword.GREED:
				value += 10;
			CardEnums.Keyword.HIGH_GROUND:
				value += 2;
			CardEnums.Keyword.INFLUENCER:
				value += 1;
			CardEnums.Keyword.PAIR:
				value += 3;
			CardEnums.Keyword.PAIR_BREAKER:
				value += 1;
			CardEnums.Keyword.RUST:
				value += 1;
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

func get_result_for_playing(card : CardData) -> int:
	var winner : GameplayEnums.Controller;
	var first_face_up_card : CardData = get_first_face_up_card(player_one.cards_on_field);
	var value : int = 1;
	if !first_face_up_card:
		return get_value_to_threaten(card);
	if card.has_champion():
		value *= 2;
	if first_face_up_card.has_champion():
		value *= 2;
	winner = determine_winner(card, first_face_up_card);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			if first_face_up_card.has_greed() and !player_two.is_close_to_winning():
				return -2;
			return value;
		GameplayEnums.Controller.PLAYER_TWO:
			if card.has_greed() and !player_one.is_close_to_winning():
				return 2;
			return -value;
	return 0;

func get_first_face_up_card(source : Array) -> CardData:
	for card in source:
		if !card.is_buried:
			return card;
	return null;

func get_value_to_threaten(card : CardData) -> int:
	var value : int;
	if card.has_champion():
		return 0;
	value = get_card_value(card);
	return value;

func round_results() -> void:
	var card : CardData = player_one.cards_on_field[0];
	var enemy : CardData = player_two.cards_on_field[0];
	var round_winner : GameplayEnums.Controller = determine_winner(
		card,
		enemy
	);
	var points : int = 1;
	if card.has_champion():
		points *= 2;
	if enemy.has_champion():
		points *= 2;
	match round_winner:
		GameplayEnums.Controller.PLAYER_ONE:
			player_one.gain_points(points);
			click_your_points();
			check_lose_effects(enemy, player_two);
		GameplayEnums.Controller.PLAYER_TWO:
			player_two.gain_points(points);
			click_opponents_points();
			check_lose_effects(card, player_one);
		GameplayEnums.Controller.NULL:
			play_point_sfx(TIE_SOUND_PATH);
	your_points.text = str(player_one.points);
	opponents_points.text = str(player_two.points);
	if round_winner == GameplayEnums.Controller.NULL:
		end_round();
		return;
	round_end_timer.start();

func check_lose_effects(card : CardData, player : Player) -> void:
	if card.has_greed():
		player.draw(2);

func click_your_points() -> void:
	your_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(YOUR_POINT_SOUND_PATH);
	if have_you_won():
		return;
	points_click_timer.start();

func play_point_sfx(file_path : String) -> void:
	var sound_file : Resource = load(file_path);
	point_streamer.stream = sound_file;
	point_streamer.play();

func click_opponents_points() -> void:
	opponents_points.add_theme_color_override("font_color", Color.YELLOW);
	play_point_sfx(OPPONENTS_POINT_SOUND_PATH);
	if has_opponent_won():
		return;
	points_click_timer.start();

func determine_winner(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	if card.has_pair() and enemy.has_pair_breaker():
		return opponent_wins;
	if enemy.has_pair() and card.has_pair_breaker():
		return you_win;
	if card.is_buried and !enemy.is_buried and enemy_type != CardEnums.CardType.MIMIC:
		return opponent_wins;
	if enemy.is_buried and !card.is_buried and card_type != CardEnums.CardType.MIMIC:
		return you_win;
	match enemy_type:
		CardEnums.CardType.MIMIC:
			if card_type != CardEnums.CardType.MIMIC:
				return you_win;
		CardEnums.CardType.GUN:
			if card.has_rust():
				return you_win;
			if card_type != CardEnums.CardType.GUN:
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
		CardEnums.CardType.MIMIC:
			if enemy_type != CardEnums.CardType.MIMIC:
				return opponent_wins;
		CardEnums.CardType.GUN:
			if enemy.has_rust():
				return opponent_wins;
			if enemy_type != CardEnums.CardType.GUN:
				return you_win;
	if card.has_pair():
		if !enemy.has_pair():
			return you_win;
	elif enemy.has_pair():
		if !card.has_pair():
			return opponent_wins;
	return tie;

func end_round() -> void:
	clear_field();
	going_first = !going_first;
	start_round();

func clear_field() -> void:
	clear_players_field(player_one);
	clear_players_field(player_two);

func clear_players_field(player : Player) -> void:
	var card : CardData;
	for c in player.cards_on_field:
		card = c;
		cards[card.instance_id].despawn();
	player.clear_field();

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

func fade_field_lines(delta : float) -> void:
	var direction : int = 1 if field_lines_visible else -1;
	field_lines.modulate.a += direction * delta * (FIELD_LINES_FADE_IN_SPEED if field_lines_visible else FIELD_LINES_FADE_OUT_SPEED);
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

func _on_background_music_finished() -> void:
	background_music.play();

func _on_pre_results_timer_timeout() -> void:
	pre_results_timer.stop();
	go_to_results();
