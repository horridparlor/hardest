static func trigger_play_effects(card : CardData, player : Player, opponent : Player, gameplay : Gameplay, only_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	var enemy : CardData = opponent.get_field_card();
	var keywords : Array = [only_keyword] if only_keyword != CardEnums.Keyword.NULL else card.get_keywords();
	if enemy and enemy.has_carrot_eater() and !gameplay.is_time_stopped:
		eat_carrot(enemy, gameplay);
	for keyword in keywords:
		match keyword:
			CardEnums.Keyword.ALPHA_WEREWOLF:
				player.played_alpha_werewolf = true;
			CardEnums.Keyword.CELEBRATE:
				celebrate(card, player, gameplay);
			CardEnums.Keyword.CLONING:
				trigger_cloning(card, player, gameplay);
			CardEnums.Keyword.COIN_FLIP:
				trigger_coin_flip(card, gameplay);
			CardEnums.Keyword.CONTAGIOUS:
				trigger_contagious(card, player, gameplay);
			CardEnums.Keyword.FRESH_WATER:
				trigger_fresh_water(card, player, gameplay);
			CardEnums.Keyword.HORSE_GEAR:
				draw_horse_card(player, gameplay);
			CardEnums.Keyword.INFLUENCER:
				influence_opponent(opponent, card.card_type, gameplay);
			CardEnums.Keyword.LICH_KING:
				trigger_lich_king(card, gameplay);
			CardEnums.Keyword.NOSTALGIA:
				trigger_nostalgia(card, player, gameplay);
			CardEnums.Keyword.NOVEMBER:
				november_opponent(opponent, gameplay);
			CardEnums.Keyword.PERFECT_CLONE:
				trigger_cloning(card, player, gameplay, true);
			CardEnums.Keyword.RAINBOW:
				opponent.get_rainbowed();
				gameplay.update_card_alterations(true);
			CardEnums.Keyword.RELOAD:
				player.shuffle_random_card_to_deck(CardEnums.CardType.GUN).controller = player;
			CardEnums.Keyword.SABOTAGE:
				trigger_sabotage(opponent, gameplay);
			CardEnums.Keyword.SCAMMER:
				System.EyeCandy.spawn_poppets(player.lose_points(100, true), card, player, gameplay);
				gameplay.gain_points_effect(player);
			CardEnums.Keyword.SPRING_ARRIVES:
				trigger_spring_arrives(card, player, gameplay);
			CardEnums.Keyword.VERY_NUTTY:
				if !enemy or !enemy.has_november():
					player.nut_multiplier *= 2;
			CardEnums.Keyword.VICTIM:
				System.EyeCandy.victim_effect(card, gameplay);
			CardEnums.Keyword.WRAPPED:
				player.gained_keyword = CardEnums.Keyword.BURIED;
	if gameplay.is_time_stopped:
		return;
	if card.has_time_stop():
		activate_time_stop(card, gameplay);
		return;
	for keyword in keywords:
		match keyword:
			CardEnums.Keyword.BERSERK:
				spy_opponent(card, player, opponent, gameplay, System.Rules.MAX_BERSERKER_SHOTS, CardEnums.Zone.DECK);
			CardEnums.Keyword.CARROT_EATER:
				eat_carrot(card, gameplay);
			CardEnums.Keyword.DIRT:
				spy_opponent(card, player, opponent, gameplay, 1, CardEnums.Zone.HAND, GameplayEnums.SpyType.DIRT);
			CardEnums.Keyword.INFINITE_VOID:
				trigger_infinite_void(card, enemy, player, opponent, gameplay);
			CardEnums.Keyword.MULTI_SPY:
				spy_opponent(card, player, opponent, gameplay, 3);
			CardEnums.Keyword.NUT_COLLECTOR:
				if !enemy or !enemy.has_november():
					collect_nuts(player, gameplay);
			CardEnums.Keyword.OCEAN:
				trigger_ocean(card, gameplay);
			CardEnums.Keyword.POSITIVE:
				trigger_positive(card, enemy, player, gameplay);
			CardEnums.Keyword.SPY:
				spy_opponent(card, player, opponent, gameplay);

static func november_opponent(opponent : Player, gameplay : Gameplay) -> void:
	opponent.reset_nut();

static func trigger_coin_flip(card : CardData, gameplay : Gameplay) -> void:
	var wins : int;
	var base_odds : int = 2;
	var odds : int;
	var super_luck : int;
	var boosted_luck : int;
	var permanent_luck : int;
	if card.is_foil:
		super_luck += 1;
		boosted_luck += 2;
	if card.is_holographic:
		super_luck += 2;
		boosted_luck += 1;
	if card.is_foil and card.is_holographic:
		permanent_luck += 1;
		if card.has_rare_stamp():
			permanent_luck += 1;
			if card.is_negative_variant():
				permanent_luck += 1;
		elif card.is_negative_variant():
			boosted_luck += 1;
	if card.is_negative_variant():
		boosted_luck += 2;
	if card.has_rare_stamp():
		super_luck += 1;
	elif card.stamp != CardEnums.Stamp.NULL:
		boosted_luck += 1;
	if card.has_max_keywords():
		boosted_luck += 1;
	if card.is_gun() or card.is_multi_type():
		super_luck += 1;
		boosted_luck += 1;
	while true:
		odds = base_odds + permanent_luck;
		if super_luck > 0:
			odds += 2;
			super_luck -= 1;
		elif boosted_luck > 0:
			odds += 1;
			boosted_luck -= 1;
		if System.Random.chance(odds):
			break;
		wins += 1;
	card.multiply_advantage *= pow(2, wins);
	card.fix_multiply_advantage();
	if wins > 0:
		show_coin_flip_effect(wins, card.controller.controller, gameplay);
	else:
		spawn_a_coin(gameplay, false, card.controller.controller);
		gameplay.play_coin_lose_sound();

static func show_coin_flip_effect(coins_to_spawn : int, controller : GameplayEnums.Controller, gameplay : Gameplay) -> void:
	var scales : Array;
	var max_scale : float = 1.0;
	if coins_to_spawn >= 100:
		max_scale = 1.6;
	elif coins_to_spawn >= 50:
		max_scale = 1.5;
	elif coins_to_spawn >= 20:
		max_scale = 1.4;
	elif coins_to_spawn >= 10:
		max_scale = 1.3;
	elif coins_to_spawn >= 5:
		max_scale = 1.2;
	elif coins_to_spawn > 1:
		max_scale = 1.1;
	for i in range(coins_to_spawn):
		scales.append(Coin.get_base_scale(max_scale));
	scales.sort();
	scales.reverse();
	for scale in scales:
		spawn_a_coin(gameplay, true, controller, scale);
	gameplay.play_coin_flip_sound();

static func spawn_a_coin(gameplay : Gameplay, did_win : bool = true, controller : GameplayEnums.Controller = GameplayEnums.Controller.NULL, overwrite_scale : float = -1) -> void:
	var coin : Coin = System.Instance.load_child(System.Paths.COIN, gameplay.above_cards_layer);
	match controller:
		GameplayEnums.Controller.PLAYER_ONE:
			coin.position.x = -abs(coin.position.x);
		GameplayEnums.Controller.PLAYER_TWO:
			coin.position.x = abs(coin.position.x);
	if overwrite_scale > 0:
		coin.base_sprite_scale = overwrite_scale;
	if did_win:
		coin.init();
	else:
		coin.lose_init();

static func trigger_sabotage(opponent : Player, gameplay : Gameplay) -> void:
	var enemy : CardData;
	var source : Array = opponent.cards_in_hand.filter(func(card : CardData): return !card.has_cursed());
	var count : int = source.size();
	var max_margin_value : int = min(Gameplay.WHOLE_HAND_MAX_SPY_MARGIN.x, (count - 1) * Gameplay.WHOLE_HAND_SPY_MARGIN.x) * System.Floats.direction(opponent.visit_point.y);
	var max_margin : Vector2 = Vector2(max_margin_value, max_margin_value * (Gameplay.WHOLE_HAND_SPY_MARGIN.y / Gameplay.WHOLE_HAND_SPY_MARGIN.x));
	var margin : Vector2 = -max_margin / 2;
	var margin_increment : Vector2 = max_margin / (count - 1);
	if count == 0:
		return;
	gameplay.play_sabotage_sound();
	if opponent.has_hivemind_for():
		for c in source:
			enemy = c;
			opponent.discard_from_hand(enemy);
			inflict_sabotage_on_card(enemy, opponent, gameplay, margin);
			margin += margin_increment;
		return;
	enemy = opponent.random_discard(true);
	inflict_sabotage_on_card(enemy, opponent, gameplay);

static func inflict_sabotage_on_card(card : CardData, player : Player, gameplay : Gameplay, margin : Vector2 = Vector2.ZERO) -> void:
	var gameplay_card : GameplayCard;
	if !System.Instance.exists(card):	
		return;
	gameplay_card = System.CardManager.spawn_card(card, gameplay);
	gameplay_card.sabotage_effect();
	if player == gameplay.player_one:
		gameplay.show_hand();
		gameplay_card.go_visit_point(Gameplay.VISIT_POSITION + margin);
		gameplay.cards_to_dissolve[card.instance_id] = card;
	else:
		gameplay_card = System.CardManager.spawn_card(card, gameplay);
		gameplay_card.go_visit_point(-Gameplay.VISIT_POSITION + margin);
		gameplay.cards_to_dissolve[card.instance_id] = card;

static func trigger_spring_arrives(card : CardData, player : Player, gameplay : Gameplay) -> void:
	var hand_size : int = player.count_hand();
	player.fill_hand();
	for i in range(System.Rules.MAX_HAND_SIZE - hand_size):
		card.multiply_advantage *= 2;
	if player == gameplay.player_one:
		gameplay.show_hand();

static func trigger_contagious(source_card : CardData, player : Player, gameplay : Gameplay) -> void:
	var card_type : CardEnums.CardType = source_card.card_type;
	var source : Array;
	var card : CardData;
	for c in player.cards_in_hand:
		card = c;
		if !card.card_types.has(card_type):
			source.append(card);
	if source.is_empty():
		return;
	if player.has_hivemind_for():
		for c in source.duplicate():
			card = c;
			inflict_contagious_on_card(card, card_type, player, gameplay);
		return;
	card = System.Random.item(source);
	inflict_contagious_on_card(card, card_type, player, gameplay);

static func inflict_contagious_on_card(card : CardData, card_type : CardEnums.CardType, player : Player, gameplay : Gameplay) -> void:
	if card.is_multi_type() and CardEnums.BASIC_COLORS.has(card_type):
		card_type = System.Random.item(CardData.expand_type(card_type));
	player.rainbow_a_card(card, card_type);
	gameplay.turn_card_into_another(card);
	if gameplay.get_card(card):
		gameplay.play_perfect_contagious_sound() if [CardEnums.CardType.GUN, CardEnums.CardType.GOD].has(card_type) else gameplay.play_contagious_sound();

static func draw_horse_card(player : Player, gameplay : Gameplay) -> void:
	if player.draw_horse():
		gameplay.show_hand();

static func trigger_nostalgia(card : CardData, player : Player, gameplay : Gameplay) -> void:
	player.get_nostalgic(card);
	gameplay.show_hand();

static func trigger_ocean(card : CardData, gameplay : Gameplay) -> void:
	var enemy : CardData = gameplay.get_opponent(card).get_field_card();
	var cards_to_wet : Array = gameplay.player_one.cards_in_hand.duplicate() + gameplay.player_two.cards_in_hand.duplicate() + ([enemy] if enemy else []) + [card];
	var wait_per_card_trigger : float;
	var triggers : int;
	var instance_id : int;
	for c in cards_to_wet:
		if System.AutoEffects.make_card_wet(c, gameplay, false) and (c.controller == gameplay.player_one or c.is_on_the_field()):
			triggers += 1;
	gameplay.has_ocean_wet_self = false;
	instance_id = gameplay.wait_for_animation(card, GameplayEnums.AnimationType.OCEAN);
	wait_per_card_trigger = gameplay.animation_wait_timer.wait_time / (triggers + 2);
	await System.wait(wait_per_card_trigger * 1.9);
	for c in cards_to_wet:
		if !System.Instance.exists(gameplay) or gameplay.animation_instance_id != instance_id:
			return;
		if c == card:
			gameplay.has_ocean_wet_self = true;
		if System.AutoEffects.make_card_wet(c, gameplay):
			await System.wait(wait_per_card_trigger);

static func eat_carrot(card : CardData, gameplay : Gameplay) -> void:
	var enemy : CardData = gameplay.get_opponent(card).get_field_card();
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
			gameplay.play_sfx(sound);
			trigger_play_effects(card, card.controller, gameplay.get_opponent(card), gameplay, keyword);
			break;

static func activate_time_stop(card : CardData, gameplay : Gameplay) -> void:
	if gameplay.time_stopping_player != null or gameplay.times_time_stopped_this_round == 10:
		return;
	gameplay.time_stopping_player = card.controller;
	gameplay.times_time_stopped_this_round += 1;
	System.TimeStop.time_stop_effect_in(gameplay);

static func celebrate(card : CardData, player : Player, gameplay : Gameplay) -> void:
	var cards_where_in_hand : Array = player.cards_in_hand.duplicate();
	player.celebrate();
	for c in cards_where_in_hand:
		if gameplay.get_card(c):
			gameplay.get_card(c).despawn();
	gameplay.play_celebrate_sound();
	if gameplay.get_card(card):
		gameplay.get_card(card).celebrate_effect();
	gameplay.show_hand();

static func trigger_cloning(card : CardData, player : Player, gameplay : Gameplay, is_perfect_clone : bool = false) -> void:
	var card_to_clone : CardData;
	if player.hand_empty() or player.hand_full():
		return;
	if player.has_hivemind_for():
		for c in player.cards_in_hand.duplicate():
			card_to_clone = c;
			clone_card(card_to_clone, player, gameplay, is_perfect_clone);
			if player.hand_full():
				break;
		gameplay.show_hand();
		return;
	card_to_clone = System.Random.item(player.cards_in_hand);
	clone_card(card_to_clone, player, gameplay, is_perfect_clone);
	gameplay.show_hand();

static func clone_card(card_to_clone : CardData, player : Player, gameplay : Gameplay, is_perfect_clone : bool = false) -> void:
	var cloned_card : CardData;
	var gameplay_card : GameplayCard;
	cloned_card = player.spawn_card(card_to_clone, CardEnums.Zone.HAND);
	cloned_card.spawn_id = System.random.randi();
	if is_perfect_clone:
		cloned_card.is_holographic = true;
		cloned_card.stamp = CardEnums.Stamp.RARE;
	if cloned_card.controller == gameplay.player_two:
		return;
	gameplay_card = System.CardManager.spawn_card(cloned_card, gameplay);
	player.make_new_card_permanent(cloned_card);
	if gameplay.get_card(card_to_clone):
		var pos : Vector2 = gameplay.get_card(card_to_clone).position;
		gameplay_card.position = pos + Vector2(-2, 0);
		System.EyeCandy.card_shine_effect(gameplay_card, gameplay);
		if is_perfect_clone:
			gameplay.play_perfect_clone_sound();
		else:
			gameplay.play_clone_sound();

static func trigger_positive(card : CardData, enemy : CardData, player : Player, gameplay : Gameplay) -> void:
	var multiplier : int = System.Fighting.calculate_base_points(card, enemy, true, false);
	var points_gained : int = player.gain_points(player.points * multiplier * abs(card.get_multiplier()), false);
	if points_gained == 0 or card.get_multiplier() < 0:
		await play_movement_wait();
		if gameplay.get_card(card) and card.is_on_the_field():
			gameplay.get_card(card).recoil();
		gameplay.gain_points_effect(player, true);
		return;
	gameplay.wait_for_animation(card, GameplayEnums.AnimationType.POSITIVE, {
		"points": points_gained,
		"card": card,
		"player": player
	});

static func influence_opponent(opponent : Player, card_type : CardEnums.CardType, gameplay : Gameplay) -> void:
	opponent.cards_in_deck[opponent.cards_in_deck.size() - 1].eat_json(System.Data.read_card(CardEnums.BasicIds[card_type]));

static func collect_nuts(player : Player, gameplay : Gameplay) -> void:
	for i in range(System.Rules.NUTS_TO_COLLECT):
		player.spawn_card_from_id(System.Random.item(CardEnums.NUT_IDS));
	player.shuffle_deck();

static func spy_opponent(card : CardData, player : Player, opponent : Player, gameplay : Gameplay, chain : int = 1, zone : CardEnums.Zone = CardEnums.Zone.HAND, spy_type : GameplayEnums.SpyType = GameplayEnums.SpyType.FIGHT) -> bool:
	var spied_card_data : CardData;
	if gameplay.is_spying:
		gameplay.spy_stack.append(
			SpyData.new(card, player, opponent, chain, zone, spy_type)	
		);
		return false;
	gameplay.spy_zone = zone;
	var do_spy_hand : bool = gameplay.spy_zone == CardEnums.Zone.HAND;
	if do_spy_hand and opponent.hand_empty():
		return false;
	match spy_type:
		GameplayEnums.SpyType.DIRT:
			gameplay.play_dirt_sound();
		GameplayEnums.SpyType.FIGHT:
			match zone:
				CardEnums.Zone.HAND:
					gameplay.play_spy_sound();
				CardEnums.Zone.DECK:
					gameplay.play_berserk_sound();
	gameplay.current_spy_type = spy_type;
	gameplay.spying_instance_id = System.Random.instance_id();
	gameplay.is_spying_whole_hand = do_spy_hand and opponent.has_hivemind_for();
	if gameplay.is_spying_whole_hand:
		spy_whole_hand(opponent, gameplay);
		return true;
	spied_card_data = determine_spied_card(opponent, gameplay) if do_spy_hand else opponent.get_top_deck();
	gameplay.send_card_to_be_spied(spied_card_data, opponent);
	gameplay.cards_to_spy = chain - 1;
	gameplay.is_spying = true;
	return true;

static func spy_whole_hand(opponent : Player, gameplay : Gameplay) -> void:
	var card : CardData;
	var spied_card : GameplayCard;
	var count : int = opponent.count_hand();
	var max_margin_value : int = min(Gameplay.WHOLE_HAND_MAX_SPY_MARGIN.x, (count - 1) * Gameplay.WHOLE_HAND_SPY_MARGIN.x) * System.Floats.direction(opponent.visit_point.y);
	var max_margin : Vector2 = Vector2(max_margin_value, max_margin_value * (Gameplay.WHOLE_HAND_SPY_MARGIN.y / Gameplay.WHOLE_HAND_SPY_MARGIN.x));
	var margin : Vector2 = -max_margin / 2;
	var margin_increment : Vector2 = max_margin / (count - 1);
	for c in opponent.cards_in_hand:
		card = c;
		gameplay.send_card_to_be_spied(card, opponent, margin);
		margin += margin_increment;
	gameplay.cards_to_spy = 0;
	gameplay.is_spying = true;

static func determine_spied_card(opponent : Player, gameplay : Gameplay) -> CardData:
	var cards_with_secret : Array = opponent.cards_in_hand.filter(func(card : CardData):
		return card.has_secrets();	
	);
	var source : Array = cards_with_secret if gameplay.current_spy_type == GameplayEnums.SpyType.FIGHT and cards_with_secret.size() else opponent.cards_in_hand.duplicate();
	return System.Random.item(source);

static func trigger_infinite_void(card : CardData, enemy : CardData, player : Player, opponent : Player, gameplay : Gameplay) -> void:
	const wait_per_suck_min : float = 0.02 * Config.GAME_SPEED_MULTIPLIER;
	const wait_per_suck_max : float = 0.79 * Config.GAME_SPEED_MULTIPLIER;
	const initial_wait_min : float = 0.07;
	const initial_wait_max : float = 0.085;
	var other_card : CardData;
	var gameplay_card : GameplayCard;
	var instance_id : int = gameplay.wait_for_animation(card, GameplayEnums.AnimationType.INFINITE_VOID);
	var cards_taken : Array;
	var poppet : Poppet;
	await System.wait_range(initial_wait_min, initial_wait_max);
	for i in range(30):
		if !System.Instance.exists(gameplay) or gameplay.animation_instance_id != instance_id:
			return;
		card.value_increment += System.EyeCandy.spawn_negative_drained_poppet(card, opponent, gameplay);
		await System.wait_range(initial_wait_min, initial_wait_max);
	while true:
		if !System.Instance.exists(gameplay):
			return;
		await System.wait(clamp(gameplay.animation_wait_timer.time_left / gameplay.animation_wait_timer.wait_time, wait_per_suck_min, wait_per_suck_max));
		if !System.Instance.exists(gameplay) or gameplay.animation_instance_id != instance_id:
			return;
		cards_taken = (player.cards_in_hand + opponent.cards_in_hand + opponent.cards_on_field).filter(func(card : CardData):
			return !card.has_cursed() and !card.is_god());
		if cards_taken.is_empty():
			return;
		cards_taken.shuffle();
		cards_taken.sort_custom(func(card_a : CardData, card_b : CardData): return card_a.zone < card_b.zone);
		other_card = cards_taken.back();
		card.multiply_advantage *= other_card.get_multiplier();
		card.fix_multiply_advantage();
		card.value_increment += other_card.get_base_value();
		gameplay_card = System.CardManager.spawn_card(other_card, gameplay);
		gameplay.loser_dissolve_effect(other_card, card);
		if other_card.is_in_hand():
			other_card.controller.discard_from_hand(other_card);
			if gameplay.get_card(other_card):
				gameplay._on_card_released(gameplay.get_card(other_card), true);
			gameplay.show_hand();
		elif other_card.is_on_the_field():
			other_card.controller.send_from_field_to_grave(other_card);
		if System.Instance.exists(gameplay_card) and gameplay.get_card(card):
			gameplay.erase_card(gameplay_card, player.field_position + Vector2(0, -GameplayCard.SIZE.y * 0.1 \
			if player.controller == GameplayEnums.Controller.PLAYER_TWO else 0));
			gameplay.show_multiplier_bar(gameplay.get_card(card));

static func trigger_fresh_water(card : CardData, player : Player, gameplay : Gameplay) -> void:
	await play_movement_wait();
	if !card.is_on_the_field() or gameplay.is_time_stopped:
		return;
	if gameplay.get_card(card):
		gameplay.get_card(card).recoil();
	player.draw_until(System.Rules.FRESH_WATER_CARDS);
	gameplay.show_hand();
	for card_in_hand in player.cards_in_hand:
		System.AutoEffects.make_card_wet(card_in_hand, gameplay);

static func play_movement_wait() -> void:
	const min_trigger_wait : float = 0.37 * Config.GAME_SPEED_MULTIPLIER;
	const max_trigger_wait : float = 0.45 * Config.GAME_SPEED_MULTIPLIER;
	await System.wait_range(min_trigger_wait, max_trigger_wait);

static func trigger_lich_king(card, gameplay) -> void:
	var lich_king_advantage : int;
	await play_movement_wait();
	if !card.is_on_the_field() or gameplay.is_time_stopped:
		return;
	lich_king_advantage = System.Fighting.get_lich_king_advantage(card);
	if lich_king_advantage == 1 or !gameplay.get_card(card):
		return;
	gameplay.get_card(card).lich_king_effect();
