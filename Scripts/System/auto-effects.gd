static func make_card_wet(card : CardData, gameplay : Gameplay, do_trigger : bool = true, fully_moist : bool = true) -> bool:
	var player : Player;
	var would_trigger : bool;
	var did_gain_keywords : bool;
	var has_hivemind_for : bool;
	if !card or card.is_buried:
		return would_trigger;
	player = card.controller;
	has_hivemind_for = card.is_in_hand() and player.has_hivemind_for(CardEnums.Keyword.OCEAN_DWELLER);
	if (has_hivemind_for or card.has_ocean_dweller()) and (card.controller == gameplay.player_one or card.is_on_the_field()):
		if do_trigger:
			System.EndOfTurn.trigger_ocean_dweller(card, player, gameplay);
		would_trigger = true;
	if card.has_tidal() and !card.is_gun():
		if do_trigger:
			card.set_card_type(CardEnums.CardType.GUN);
			gameplay.update_alterations_for_card(card);
			if gameplay.get_card(card):
				gameplay.get_card(card).wet_effect();
			gameplay.start_wet_wait()
		would_trigger = true;
	if !fully_moist:
		return would_trigger;
	has_hivemind_for = player.has_hivemind_for_type(CardEnums.CardType.SCISSORS);
	if (card.is_scissor() and !card.is_aquatic() and card.add_keyword(CardEnums.Keyword.RUST, false, do_trigger)):
		did_gain_keywords = true;
	has_hivemind_for = player.has_hivemind_for_type(CardEnums.CardType.PAPER);
	if (card.is_paper() and !card.is_aquatic() and card.add_keyword(CardEnums.Keyword.MUSHY, false, do_trigger)):
		did_gain_keywords = true;
	if did_gain_keywords:
		if do_trigger:
			gameplay.update_alterations_for_card(card);
			if gameplay.get_card(card):
				gameplay.get_card(card).wet_effect();
			gameplay.start_wet_wait();
		would_trigger = true;
	return would_trigger;

static func bury_card(card : GameplayCard, gameplay : Gameplay) -> void:
	var card_data : CardData = card.card_data;
	var keywords : Array = card_data.keywords.filter(func(keyword: int): return keyword != CardEnums.Keyword.BURIED_ALIVE);
	var hydra_keywords : Array = CardEnums.get_hydra_keywords();
	var if_hydra_keywords : Array;
	if card_data.has_buried_alive():
		card_data.controller.rainbow_a_card(card_data);
		for keyword in keywords:
			if card_data.has_max_keywords() and card_data.has_buried():
				card_data.keywords.erase(CardEnums.Keyword.BURIED);
				card_data.keywords.erase(CardEnums.Keyword.BURIED_ALIVE);
			card_data.add_keyword(keyword);
			if keyword in hydra_keywords:
				if_hydra_keywords.append(keyword);
		if_hydra_keywords.reverse();
		card_data.if_hydra_keywords = if_hydra_keywords;
		if card_data.has_tidal() and !card_data.is_god():
			card_data.set_card_type(CardEnums.CardType.GUN);
	card.bury();
	gameplay.show_multiplier_bar(card);

static func check_for_devoured(card : GameplayCard, player : Player, opponent : Player, gameplay : Gameplay, is_digital_speed : bool = false) -> bool:
	var enemy : CardData = opponent.get_field_card();
	var eater_was_face_down : bool;
	var devoured_keywords : Array;
	var has_devow : bool = enemy and enemy.has_devow(true);
	if is_digital_speed:
		return false;
	if enemy and enemy.has_devour(true) and player.cards_played_this_turn == 1:
		eater_was_face_down = enemy.is_buried;
		devoured_keywords = opponent.devour_card(enemy, card.card_data);
		if has_devow:
			gameplay.turn_card_into_another(enemy);
			card.burn_effect();
			player.burn_card(card.card_data);
		player.send_from_field_to_grave(card.card_data);
		if eater_was_face_down:
			System.PlayEffects.trigger_play_effects(enemy, opponent, player, gameplay);
		else:
			for keyword in devoured_keywords:
				System.PlayEffects.trigger_play_effects(enemy, opponent, player, gameplay, keyword);
		gameplay.update_alterations_for_card(enemy);
		gameplay.spawn_tongue(card, gameplay.get_card(enemy));
		gameplay.erase_card(card, opponent.field_position + Vector2(0, -GameplayCard.SIZE.y * 0.1 \
			if player.controller == GameplayEnums.Controller.PLAYER_ONE else 0));
		return true;
	return false;
