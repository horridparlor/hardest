extends Gameplay

@onready var cards_layer : Node2D = $CardsLayer;
@onready var cards_layer2 : Node2D = $CardsLayer2;
@onready var field_lines : Node2D = $FieldLines;
@onready var round_results_timer : Timer = $Timers/RoundResultsTimer;
@onready var round_end_timer : Timer = $Timers/RoundEndTimer;
@onready var game_over_timer : Timer = $Timers/GameOverTimer;
@onready var points_click_timer : Timer = $Timers/PointsClickTimer;
@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var background_music : AudioStreamPlayer2D = $Background/BackgroundMusic;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;

func _ready() -> void:
	player_one.eat_decklist(1);
	player_two.eat_decklist(1);
	init_layers();
	init_timers();
	going_first = true;#System.Random.boolean();
	start_round();

func init_timers() -> void:
	round_results_timer.wait_time = ROUND_RESULTS_WAIT;
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
		card = cards[card_data.instance_id];
		card.goal_position = position;
		card.is_moving = true;
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
	put_other_cards_behind(card);
	if !can_play_card:
		return;
	field_lines_visible = true;
	fading_field_lines = true;
	field_lines.modulate.a = min(1, max(0, field_lines.modulate.a));

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
	return cards[card_a.instance_id].position.x < cards[card_b.instance_id].position.x;

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
	card.goal_position = FIELD_POSITION;
	reorder_hand();
	can_play_card = false;
	if going_first:
		opponents_turn();
	else:
		go_to_results();

func opponents_turn() -> void:
	var card : CardData;
	player_two.cards_in_hand.sort_custom(best_to_play);
	#for car in player_two.cards_in_hand:
		#print(car.card_name, " ", get_result_for_playing(car));
	#print("-----");
	card = player_two.cards_in_hand.back();
	player_two.play_card(card);
	spawn_card(card, true);
	show_opponents_field();
	if going_first:
		go_to_results();
	else:
		your_turn();

func go_to_results() -> void:
	transform_mimics(player_one.cards_on_field, player_two.cards_on_field);
	transform_mimics(player_two.cards_on_field, player_one.cards_on_field);
	round_results_timer.start();

func transform_mimics(your_cards : Array, enemies : Array) -> void:
	var card : CardData;
	for c in your_cards:
		card = c;
		if card.card_type == CardEnums.CardType.MIMIC:
			card.card_type = enemies[0].card_type;
			cards[card.instance_id].update_visuals();

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
	if player_one.field_empty():
		return get_value_to_threaten(card);
	winner = determine_winner(card, player_one.cards_on_field[0]);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			return 1;
		GameplayEnums.Controller.PLAYER_TWO:
			return -1;
	return 0;

func get_value_to_threaten(card : CardData) -> int:
	var value : int = get_card_value(card);
	if value < 10:
		value *= 10;
	return value;

func round_results() -> void:
	var round_winner : GameplayEnums.Controller = determine_winner(
		player_one.cards_on_field[0],
		player_two.cards_on_field[0]
	);
	match round_winner:
		GameplayEnums.Controller.PLAYER_ONE:
			player_one.gain_point();
			click_your_points();
		GameplayEnums.Controller.PLAYER_TWO:
			player_two.gain_point();
			click_opponents_points();
		GameplayEnums.Controller.NULL:
			play_point_sfx(TIE_SOUND_PATH);
	your_points.text = str(player_one.points);
	opponents_points.text = str(player_two.points);
	if round_winner == GameplayEnums.Controller.NULL:
		end_round();
		return;
	round_end_timer.start();

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
	match enemy_type:
		CardEnums.CardType.MIMIC:
			if card_type != CardEnums.CardType.MIMIC:
				return you_win;
		CardEnums.CardType.GUN:
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
			if enemy_type != CardEnums.CardType.GUN:
				return you_win;
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
		card.is_moving = true;

func _process(delta : float) -> void:
	if fading_field_lines:
		fade_field_lines(delta);

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
