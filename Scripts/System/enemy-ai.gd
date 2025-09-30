static func best_to_play_for_you(card_a : CardData, card_b : CardData, gameplay : Gameplay) -> int:
	return best_to_play(card_a, card_b, gameplay.player_one, gameplay.player_two, gameplay);

static func best_to_play_for_opponent(card_a : CardData, card_b : CardData, gameplay : Gameplay) -> int:
	return best_to_play(card_a, card_b, gameplay.player_two, gameplay.player_one, gameplay);

static func best_to_play(card_a : CardData, card_b : CardData, player : Player, opponent : Player, gameplay) -> int:
	var a_value : int = get_result_for_playing(card_a, player, opponent, gameplay);
	var b_value : int = get_result_for_playing(card_b, player, opponent, gameplay);
	var enemy : CardData = opponent.get_field_card();
	var do_play_weakest : bool = gameplay.time_stopping_player == player or (opponent.going_first and (opponent.field_empty() or (player.cards_played_this_turn == 0 and enemy and enemy.has_devour())));
	if a_value == b_value:
		return most_valuable(card_a, card_b, player, opponent, gameplay) * (-1 if gameplay.time_stopping_player == player else 1);
	return a_value < b_value if !do_play_weakest else a_value > b_value;

static func most_valuable(card_a : CardData, card_b : CardData, player : Player, opponent : Player, gameplay : Gameplay) -> int:
	return -get_card_value(card_a, player, opponent, gameplay, -1) < -get_card_value(card_b, player, opponent, gameplay, -1);

static func get_card_value(card : CardData, player : Player, opponent : Player, gameplay : Gameplay, direction : int = 1) -> int:
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
			CardEnums.Keyword.BURIED_ALIVE:
				value += 5;
			CardEnums.Keyword.CELEBRATE:
				value += 0;
			CardEnums.Keyword.CHAMELEON:
				value += 1;
			CardEnums.Keyword.CLONING:
				value += player.cards_in_hand.size();
			CardEnums.Keyword.COIN_FLIP:
				value += 3;
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
			CardEnums.Keyword.DEVOW:
				value += 6 if player.going_first else -1;
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
			CardEnums.Keyword.FRESH_WATER:
				value += max(0, System.Rules.FRESH_WATER_CARDS - player.count_hand());
			CardEnums.Keyword.GREED:
				value += 10;
			CardEnums.Keyword.HIGH_GROUND:
				value += 2;
			CardEnums.Keyword.HIGH_NUT:
				value += 2 * player.turns_waited_to_nut * player.nut_multiplier;
			CardEnums.Keyword.HIVEMIND:
				value += 0;
			CardEnums.Keyword.HORSE_GEAR:
				value += 4;
			CardEnums.Keyword.HYDRA:
				value += 2;
			CardEnums.Keyword.INCINERATE:
				value += 1;
			CardEnums.Keyword.INFINITE_VOID:
				value += 10;
			CardEnums.Keyword.INFLUENCER:
				value -= 1;
			CardEnums.Keyword.MULTI_SPY:
				value += 3;
			CardEnums.Keyword.MULTIPLY:
				value += 0;
			CardEnums.Keyword.MUSHY:
				value -= 1;
			CardEnums.Keyword.NOSTALGIA:
				value += 0;
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
			CardEnums.Keyword.RECYCLE:
				value += player.recycle_cards.size();
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
			CardEnums.Keyword.SKIBBIDY:
				value += 2 * player.count_hand();
			CardEnums.Keyword.SOUL_HUNTER:
				value += 1;
			CardEnums.Keyword.SOUL_ROBBER:
				value -= 1;
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
			CardEnums.Keyword.VICTIM:
				value += 1;
			CardEnums.Keyword.WEREWOLF:
				value += 0;
			CardEnums.Keyword.WRAPPED:
				value += 0 if player.going_first else 1;
	if player.going_first and card.has_buried() and card.has_devour():
		value += 5;
	value *= System.Fighting.calculate_base_points(card, null, true);
	if value < 0:
		return value;
	if card.is_gun and !card.has_buried() and (gameplay.time_stopping_player == player or (gameplay.time_stopping_player == null and card.has_time_stop())):
		value *= (System.Rules.STOPPED_TIME_MIN_SHOTS + System.Rules.STOPPED_TIME_MAX_SHOTS) / 2;
	return value;

static func get_card_base_value(card : CardData) -> int:
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

static func get_result_for_playing(card : CardData, player : Player, opponent : Player, gameplay : Gameplay) -> int:
	var winner : GameplayEnums.Controller;
	var enemy : CardData = get_card_truth(opponent.get_field_card(), card, opponent, gameplay, true);
	if opponent.get_field_card() and opponent.get_field_card().is_buried:
		enemy = null;
	card = get_card_truth(card, enemy, opponent, gameplay);
	var value : int = 1;
	var multiplier : int = System.Fighting.calculate_base_points(card, enemy, true);
	if player.going_first and opponent.gained_keyword == CardEnums.Keyword.BURIED and card.prevents_opponents_reveal():
		return value * multiplier;
	if card.has_nut_stealer() and enemy and enemy.get_max_nuts() > 0:
		return value * multiplier * player.turns_waited_to_nut * player.nut_multiplier * 2;
	if !enemy:
		return get_value_to_threaten(card, player, opponent, gameplay);
	winner = System.Fighting.determine_winner(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			if enemy.has_greed() and !player.is_close_to_winning():
				return -2;
			elif card.has_soul_hunter() and enemy.has_infinite_void():
				value += 10;
			return value * multiplier;
		GameplayEnums.Controller.PLAYER_TWO:
			if card.has_greed() and !opponent.is_close_to_winning():
				return 2;
			return -value;
	return 0;

static func get_card_truth(card : CardData, enemy : CardData, player : Player, gameplay : Gameplay, is_already_on_field : bool = false) -> CardData:
	var new_card : CardData = enemy if is_already_on_field else card;
	if !card:
		return null;
	card = card.clone();
	if card.has_chameleon() and is_already_on_field:
		player.trigger_chameleon(card);
	if (card.has_ocean() or (enemy and enemy.has_ocean())) and !(gameplay.is_time_stopped or new_card.has_time_stop() or new_card.has_positive()):
		System.AutoEffects.make_card_wet(card, gameplay, true, true, true);
	if ((card.has_time_stop() or (gameplay.time_stopping_player == player and card == new_card)) and (card.is_gun() and !card.has_buried())) and (is_already_on_field or !gameplay.is_time_stopped):
		card.stopped_time_advantage = 2;
	return card;

static func get_first_face_up_card(source : Array) -> CardData:
	for card in source:
		if !card.is_buried:
			return card;
	return null;

static func get_value_to_threaten(card : CardData, player : Player, opponent : Player, gameplay : Gameplay) -> int:
	var value : int;
	if card.has_digital():
		return -1;
	if card.has_champion():
		return 0;
	value = get_card_value(card, player, opponent, gameplay);
	return value;
