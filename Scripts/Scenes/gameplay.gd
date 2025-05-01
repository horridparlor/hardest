extends Gameplay

@onready var cards_layer : Node2D = $CardsLayer;
@onready var cards_layer2 : Node2D = $CardsLayer2;
@onready var field_lines : Node2D = $FieldLines;

@onready var round_results_timer : Timer = $Timers/RoundResultsTimer;
@onready var pre_results_timer : Timer = $Timers/PreResultsTimer;
@onready var round_end_timer : Timer = $Timers/RoundEndTimer;
@onready var game_over_timer : Timer = $Timers/GameOverTimer;
@onready var points_click_timer : Timer = $Timers/PointsClickTimer;
@onready var card_focus_timer : Timer = $Timers/CardFocusTimer;

@onready var your_points : Label = $Points/YourPoints;
@onready var opponents_points : Label = $Points/OpponentsPoints;
@onready var background_music : AudioStreamPlayer2D = $Background/BackgroundMusic;
@onready var point_streamer : AudioStreamPlayer2D = $Background/PointStreamer;
@onready var cards_shadow : Node2D = $CardsShadow;
@onready var points_layer : Node = $Points;
@onready var keywords_hints : RichTextLabel = $CardsShadow/KeywordsHints;
@onready var character_face : Sprite2D = $Points/CharacterFace;
@onready var enemy_name : Label = $Points/CharacterFace/EnemyName;
@onready var your_face : Sprite2D = $Points/YourFace;
@onready var your_name : Label = $Points/YourFace/YourName;
@onready var background_pattern : Sprite2D = $Background/Pattern;


func init(level_data_ : LevelData) -> void:
	level_data = level_data_;
	init_player(player_one, GameplayEnums.Controller.PLAYER_ONE, level_data.deck_id);
	init_player(player_two, GameplayEnums.Controller.PLAYER_TWO, level_data.deck2_id);
	init_layers();
	init_timers();
	going_first = System.Random.boolean();
	your_face.modulate.a = INACTIVE_CHARACTER_VISIBILITY;
	character_face.modulate.a = ACTIVE_CHARACTER_VISIBILITY;
	start_round();
	update_character_face();
	initialize_background_music();
	initialize_background_pattern();
	cards_shadow.modulate.a = 0;

func init_player(player : Player, controller : GameplayEnums.Controller, deck_id : int) -> void:
	var card : CardData;
	player.controller = controller;
	player.eat_decklist(deck_id);
	for c in player.cards_in_deck:
		card = c;
		card.controller = player;

func initialize_background_music() -> void:
	var music_file : Resource = load(LEVEL_THEME_PATH % [level_data.id]);
	background_music.stream = music_file;
	background_music.play();
	
func initialize_background_pattern() -> void:
	var pattern : Resource = load(LEVEL_BACKGROUND_PATH % [level_data.id]);
	background_pattern.texture = pattern;
	
func update_character_face() -> void:
	var face_texture : Resource = load(LevelButton.CHARACTER_FACE_PATH % [GameplayEnums.CharacterToId[level_data.opponent]]);
	character_face.texture = face_texture;
	enemy_name.text = GameplayEnums.CharacterShowcaseName[level_data.opponent] if GameplayEnums.CharacterShowcaseName.has(level_data.opponent) else "?";

func init_timers() -> void:
	round_results_timer.wait_time = ROUND_RESULTS_WAIT;
	pre_results_timer.wait_time = PRE_RESULTS_WAIT;
	round_end_timer.wait_time = ROUND_END_WAIT;
	game_over_timer.wait_time = GAME_OVER_WAIT;
	points_click_timer.wait_time = POINTS_CLICK_WAIT;
	card_focus_timer.wait_time = CARD_FOCUS_WAIT;

func have_you_won() -> bool:
	var result : bool = player_one.points >= System.Rules.VICTORY_POINTS;
	if result:
		_on_you_won();
	return result;

func _on_you_won() -> void:
	var save_data : Dictionary;
	save_data = System.Data.read_save_data();
	if save_data.levels_unlocked == level_data.id:
		save_data.levels_unlocked += 1;
		System.Data.write_save_data(save_data);
	your_face.modulate.a = ACTIVE_CHARACTER_VISIBILITY;
	character_face.modulate.a = INACTIVE_CHARACTER_VISIBILITY;

func has_opponent_won() -> bool:
	return player_two.points >= System.Rules.VICTORY_POINTS;

func start_round() -> void:
	if have_you_won() or has_opponent_won():
		start_game_over();
		return;
	player_one.draw_hand();
	player_two.draw_hand();
	player_two.shuffle_hand();
	if (player_one.hand_empty() and player_one.deck_empty()) or (player_two.hand_empty() and player_two.deck_empty()):
		start_game_over(true);
		return;
	if going_first:
		your_turn();
	else:
		opponents_turn();

func start_game_over(extend_wait : bool = false) -> void:
	if extend_wait:
		game_over_timer.wait_time *= 3;
		if player_one.hand_empty() and player_one.deck_empty():
			your_name.text = "DECK OUT";
			your_name.add_theme_font_size_override("font_size", 64);
		elif player_two.hand_empty() and player_two.deck_empty():
			enemy_name.text = "DECK OUT";
			enemy_name.add_theme_font_size_override("font_size", 64);
			_on_you_won();
	game_over_timer.start();

func end_game() -> void:
	emit_signal("game_over");

func your_turn() -> void:
	show_hand();
	character_face.modulate.a = INACTIVE_CHARACTER_VISIBILITY;
	your_face.modulate.a = ACTIVE_CHARACTER_VISIBILITY;
	can_play_card = true;

func init_layers() -> void:
	field_lines.modulate.a = 0;

func show_hand() -> void:
	var card : CardData;
	for c in player_one.cards_in_hand:
		card = c;
		spawn_card(card);
	reorder_hand();

func get_card(card : CardData) -> GameplayCard:
	return cards[card.instance_id] if cards.has(card.instance_id) else null;

func reorder_hand() -> void:
	var card : GameplayCard;
	var position : Vector2 = HAND_POSITION;
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
	var card : GameplayCard = System.Instance.load_child(CARD_PATH, cards_layer if active_card == null else cards_layer2);
	card.card_data = card_data;
	card.instance_id = card_data.instance_id;
	card.init(card_data.controller.gained_keyword);
	cards[card.card_data.instance_id] = card;
	card.position = CARD_STARTING_POSITION if card_data.controller == player_one else -CARD_STARTING_POSITION;
	card.pressed.connect(_on_card_pressed);
	card.released.connect(_on_card_released);
	card.despawned.connect(_on_card_despawned);
	return card;

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
	active_card = card;
	card.toggle_follow_mouse();
	update_keywords_hints(card);
	card_focus_timer.start();
	put_other_cards_behind(card);

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

func play_card(card : GameplayCard, player : Player, opponent : Player, is_digital_speed : bool = false) -> void:
	player.play_card(card.card_data, is_digital_speed);
	if card.card_data.has_hydra() and !card.card_data.has_buried():
		player.build_hydra(card.card_data);
	if card.card_data.has_buried():
		if !is_digital_speed:
			card.bury();
	else:
		trigger_play_effects(card.card_data, player, opponent);
	update_card_alterations();
	if player == player_two:
		show_opponents_field();
		return;
	card.goal_position = FIELD_POSITION;
	card.is_moving = true;
	reorder_hand();
	if is_digital_speed:
		return;
	can_play_card = false;
	character_face.modulate.a = ACTIVE_CHARACTER_VISIBILITY;
	your_face.modulate.a = INACTIVE_CHARACTER_VISIBILITY;
	if going_first:
		opponents_turn();
	else:
		go_to_pre_results();

func trigger_play_effects(card : CardData, player : Player, opponent : Player) -> void:
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.CELEBRATION:
				celebrate(player);
			CardEnums.Keyword.INFLUENCER:
				influence_opponent(opponent, card.default_type);
			CardEnums.Keyword.RAINBOW:
				opponent.get_rainbowed();
				update_card_alterations();
			CardEnums.Keyword.RELOAD:
				player.shuffle_random_card_to_deck(CardEnums.CardType.GUN).controller = player;
			CardEnums.Keyword.WRAPPED:
				player.gained_keyword = CardEnums.Keyword.BURIED;

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
	play_card(spawn_card(card), player_two, player_one);
	if going_first:
		go_to_pre_results();
	else:
		your_turn();

func go_to_results() -> void:
	#This structure waits and comes back everytime some action is done
	#So that player has time to see animation and react mentally.
	#Better structure to use enum for the phase and make it not crawl
	#The whole structure like this. Fix, if this ever gets longer than
	#Let's say 100 lines :D
	if results_phase < 2:
		if mimics_phase():
			return results_wait();
	if results_phase < 4:
		if digitals_phase():
			return results_wait();
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
	if player_two.get_field_card().has_high_ground():
		return false;
	return transform_mimics(player_one.cards_on_field, player_one, player_two);

func transform_opponents_mimics() -> bool:
	if player_one.get_field_card().has_high_ground():
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
	if player.get_field_card().has_cursed() or winner == GameplayEnums.Controller.PLAYER_ONE:
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
		cards[card.instance_id].update_visuals(card.controller.gained_keyword);
	return transformed_any;

func influence_opponent(opponent : Player, card_type : CardEnums.CardType) -> void:
	if opponent.deck_empty():
		return;
	opponent.cards_in_deck[opponent.cards_in_deck.size() - 1].eat_json(System.Data.read_card(CardEnums.BasicIds[card_type]));

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
			CardEnums.Keyword.COOTIES:
				value += 1;
			CardEnums.Keyword.COPYCAT:
				value += 1;
			CardEnums.Keyword.CURSED:
				value += 1;
			CardEnums.Keyword.DEVOUR:
				value += 3;
			CardEnums.Keyword.DIGITAL:
				value += 5;
			CardEnums.Keyword.DIVINE:
				value += 0;
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
				value += 5 if player_two.points == 0 else 1;
			CardEnums.Keyword.SILVER:
				value += 1;
			CardEnums.Keyword.SOUL_HUNTER:
				value += 1;
			CardEnums.Keyword.UNDEAD:
				value -= 1;
			CardEnums.Keyword.VAMPIRE:
				value += 5 if player_one.points > 0 else 0;
			CardEnums.Keyword.WRAPPED:
				value -= 5 if going_first else 0;
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
	if card.has_champion():
		value *= 2;
	if first_face_up_card and first_face_up_card.has_champion():
		value *= 2;
	if going_first == false and player_one.gained_keyword == CardEnums.Keyword.BURIED and card.has_high_ground():
		return value;
	if !first_face_up_card:
		return get_value_to_threaten(card);
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
	round_winner = determine_winner(
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
			if card.has_vampire():
				player_two.lose_points();
			if enemy.has_salty():
				player_two.lose_points();
		GameplayEnums.Controller.PLAYER_TWO:
			player_two.gain_points(points);
			click_opponents_points();
			check_lose_effects(card, player_one);
			if enemy.has_vampire():
				player_one.lose_points();
			if card.has_salty():
				player_one.lose_points();
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
		player.draw_cards(2);

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
	going_first = !going_first;
	start_round();

func clear_field() -> void:
	clear_players_field(player_one, round_winner == GameplayEnums.Controller.PLAYER_ONE);
	clear_players_field(player_two, round_winner == GameplayEnums.Controller.PLAYER_TWO);

func clear_players_field(player : Player, did_win : bool) -> void:
	var card : CardData;
	for c in player.cards_on_field:
		card = c;
		get_card(card).despawn();
	for c in player.cards_in_hand:
		card = c;
		if !card.has_pick_up():
			continue;
		if get_card(card):
			get_card(card).despawn();
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

func update_points_visibility(delta : float) -> void:
	points_layer.modulate.a = System.Scale.baseline(
		points_layer.modulate.a,
		points_goal_visibility,
		(POINTS_FADE_IN_SPEED if points_goal_visibility == 1 else POINTS_FADE_OUT_SPEED) * delta
	);
	cards_shadow.modulate.a = System.Scale.baseline(
		cards_shadow.modulate.a,
		shadow_goal_visibility,
		(SHADOW_FADE_IN_SPEED if shadow_goal_visibility == 1 else SHADOW_FADE_OUT_SPEED) * delta
	);
	if System.Scale.equal(points_layer.modulate.a, points_goal_visibility):
		points_layer.modulate.a = points_goal_visibility;
		cards_shadow.modulate.a = shadow_goal_visibility;
		is_updating_points_visibility = false;

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

func _on_card_focus_timer_timeout() -> void:
	card_focus_timer.stop();
	toggle_points_visibility(false);
	if !can_play_card:
		return;
	field_lines_visible = true;
	fading_field_lines = true;
	field_lines.modulate.a = min(1, max(0, field_lines.modulate.a));
