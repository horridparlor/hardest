static func determine_winner(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var you_have_negative_multiplier : bool = card and card.multiply_advantage < 0;
	var opponent_has_negative_multiplier : bool = enemy and enemy.multiply_advantage < 0;
	var is_reversed : bool = (card and card.has_victim()) or (enemy and enemy.has_victim());
	if you_have_negative_multiplier and !opponent_has_negative_multiplier:
		return opponent_wins if !is_reversed else you_win;
	if opponent_has_negative_multiplier and !you_have_negative_multiplier:
		return you_win if !is_reversed else opponent_wins;
	if you_have_negative_multiplier and opponent_has_negative_multiplier:
		return tie;
	if card == null and enemy == null:
		return tie;
	if card == null:
		return opponent_wins;
	if enemy == null:
		return you_win;
	var winner_a : GameplayEnums.Controller = check_winner_from_side(card, enemy);
	var winner_b : GameplayEnums.Controller = GameplayEnums.flip_player(check_winner_from_side(enemy, card));
	if is_reversed:
		winner_a = reverse_winner(winner_a);
		winner_b = reverse_winner(winner_b);
	if winner_a == winner_b:
		return winner_a;
	elif winner_a == tie:
		return winner_b;
	elif winner_b == tie:
		return winner_a;
	return tie;

static func reverse_winner(winner : GameplayEnums.Controller) -> GameplayEnums.Controller:
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			return GameplayEnums.Controller.PLAYER_TWO;
		GameplayEnums.Controller.PLAYER_TWO:
			return GameplayEnums.Controller.PLAYER_ONE;
	return winner;

static func check_winner_from_side(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
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

static func check_pre_types_keywords(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	if card.has_secrets() and enemy.has_spy():
		return opponent_wins;
	elif enemy.has_secrets() and card.has_spy():
		return you_win;
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
	if card.keywords.size() < enemy.keywords.size() and enemy.has_cooties():
		return opponent_wins;
	elif enemy.keywords.size() < card.keywords.size() and card.has_cooties():
		return you_win;
	if card.has_undead() and enemy.has_divine():
		return opponent_wins;
	elif enemy.has_undead() and card.has_divine():
		return you_win;
	return not_determined;

static func check_type_results(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
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

static func check_post_types_keywords(card : CardData, enemy : CardData) -> GameplayEnums.Controller:
	var card_type : CardEnums.CardType = card.card_type;
	var enemy_type : CardEnums.CardType = enemy.card_type;
	var you_win : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_ONE;
	var opponent_wins : GameplayEnums.Controller = GameplayEnums.Controller.PLAYER_TWO;
	var tie : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
	var not_determined : GameplayEnums.Controller = GameplayEnums.Controller.UNDEFINED;
	var card_advantage : int = card.multiply_advantage * get_card_continuous_advantage(card);
	var enemy_advantage : int = enemy.multiply_advantage * get_card_continuous_advantage(enemy);
	if card.stopped_time_advantage > 1:
		return you_win;
	elif enemy.stopped_time_advantage > 1:
		return opponent_wins;
	if card_advantage > 100000 and enemy_advantage > 100000:
		if System.Random.chance(2):
			card_advantage -= 1;
		else:
			enemy_advantage -= 1;
	if card_advantage > enemy_advantage:
		return you_win;
	elif enemy_advantage > card_advantage:
		return opponent_wins;
	if card.has_pair():
		if !enemy.has_pair():
			return you_win;
	elif enemy.has_pair():
		if !card.has_pair():
			return opponent_wins;
	return not_determined;

static func get_card_continuous_advantage(card : CardData) -> int:
	var advantage : int = 1;
	if !card:
		return advantage;
	if card.has_skibbidy():
		advantage *= pow(2, card.controller.count_hand_without(card));
	return advantage;

static func calculate_base_points(card : CardData, enemy : CardData, did_win : bool = false, add_advantages : bool = true) -> int:
	var points : int = 1;
	if card and card.has_spy() and enemy and enemy.has_secrets():
		points = 3;
	if card and card.has_champion():
		points *= 2;
	if enemy and enemy.has_champion():
		points *= 2;
	if add_advantages:
		points *= get_card_continuous_advantage(card);
		if card and card.stopped_time_advantage > 1:
			points *= card.stopped_time_advantage;
		if card and abs(card.multiply_advantage) > 1:
			points *= abs(card.multiply_advantage);
		if enemy and enemy.multiply_advantage != 0:
			points *= abs(enemy.multiply_advantage)
		if enemy:
			points *= abs(get_card_continuous_advantage(enemy));
	if !did_win:
		return points;
	if card and card.has_rare_stamp():
		points *= 2;
	if card and card.is_holographic:
		points *= 2;
	if card and card.is_god() and points < 10:
		points = 10;
	return points;

static func determine_winning_player(player : Player, opponent : Player) -> GameplayEnums.Controller:
	return determine_winner(player.get_field_card(), opponent.get_field_card());

static func no_reason_to_counterspell(player : Player, opponent : Player) -> bool:
	var winner : GameplayEnums.Controller = determine_winning_player(player, opponent);
	return (player.get_field_card() and player.get_field_card().has_cursed()) or winner == GameplayEnums.Controller.PLAYER_ONE;

static func determine_points_result(card : CardData, enemy : CardData) -> int:
	var winner : GameplayEnums.Controller = determine_winner(card, enemy);
	var win_points : int = get_win_points(card, enemy);
	var lose_points : int = get_lose_points(card, enemy);
	match winner:
		GameplayEnums.Controller.PLAYER_ONE:
			return win_points;
		GameplayEnums.Controller.PLAYER_TWO:
			return lose_points;
	return 0;

static func get_win_points(card : CardData, enemy : CardData) -> int:
	var points : int = calculate_base_points(card, enemy, true);
	var points_to_steal : int = calculate_points_to_steal(card, enemy);
	return points + points_to_steal;

static func get_lose_points(card : CardData, enemy : CardData) -> int:
	var points : int = calculate_base_points(card, enemy, false, false);
	var points_to_lose : int = calculate_points_to_steal(enemy, card);
	return -(points + points_to_lose);

static func calculate_points_to_steal(card : CardData, enemy : CardData) -> int:
	var points : int;
	if card.has_vampire():
		points += 1;
	if enemy.has_salty():
		points += 1;
	return min(points, enemy.controller.points);
