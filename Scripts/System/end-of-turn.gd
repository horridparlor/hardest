static func clear_field(gameplay : Gameplay) -> bool:
	var did_trigger_clear_field_effects : bool;
	if clear_players_field(gameplay.player_one, gameplay.round_winner == GameplayEnums.Controller.PLAYER_ONE, gameplay.round_winner == GameplayEnums.Controller.PLAYER_TWO, gameplay):
		did_trigger_clear_field_effects = true;
	if clear_players_field(gameplay.player_two, gameplay.round_winner == GameplayEnums.Controller.PLAYER_TWO, gameplay.round_winner == GameplayEnums.Controller.PLAYER_ONE, gameplay):
		did_trigger_clear_field_effects = true;
	return did_trigger_clear_field_effects;

static func clear_players_field(player : Player, did_win : bool, did_lose : bool, gameplay : Gameplay) -> bool:
	var card : CardData;
	var gameplay_card : GameplayCard;
	var starting_points : int = player.points;
	var did_trigger_ocean : bool;
	var triggered_by_hivemind : bool;
	var pick_up_by_hivemind = player.has_hivemind_for(CardEnums.Keyword.PICK_UP);
	for c in player.cards_on_field:
		if !System.Instance.exists(c):
			continue;
		card = c;
		gameplay_card = gameplay.get_card(card);
		if gameplay_card:
			gameplay_card.despawn();
	triggered_by_hivemind = player.has_hivemind_for(CardEnums.Keyword.WEREWOLF);
	for c in player.cards_in_hand:
		card = c;
		if triggered_by_hivemind or card.has_werewolf():
			trigger_werewolf(card, gameplay);
	triggered_by_hivemind = player.has_hivemind_for(CardEnums.Keyword.ALPHA_WEREWOLF);
	for c in player.cards_in_hand:
		card = c;
		if triggered_by_hivemind or card.has_alpha_werewolf():
			trigger_alpha_werewolf(player, gameplay);
	if player.played_alpha_werewolf:
		trigger_alpha_werewolf(player, gameplay);
		player.played_alpha_werewolf = false;
	triggered_by_hivemind = player.has_hivemind_for(CardEnums.Keyword.OCEAN_DWELLER);
	for c in player.cards_in_hand.duplicate():
		card = c;
		gameplay_card = gameplay.get_card(card);
		if (triggered_by_hivemind or card.has_ocean_dweller()) and card.controller == gameplay.player_one:
			trigger_ocean_dweller(card, player, gameplay)
			if gameplay_card and !gameplay_card.is_visiting:
				gameplay_card.recoil();
			did_trigger_ocean = true;
		if (!pick_up_by_hivemind and !card.has_pick_up()) or card.just_spawned_dont_discard:
			continue;
		if gameplay_card:
			gameplay_card.despawn();
	player.end_of_turn_clear(did_win);
	return true;

static func trigger_alpha_werewolf(player : Player, gameplay : Gameplay) -> void:
	var played_color : CardEnums.CardType = player.true_last_type_played;
	var card : CardData;
	var has_hivemind_for_werefolf : bool = player.has_hivemind_for();
	for c in player.cards_in_hand:
		card = c;
		if !has_hivemind_for_werefolf and !card.has_werewolf():
			continue;
		card.set_card_type(played_color);
	for c in player.cards_in_hand:
		card = c;
		if !has_hivemind_for_werefolf and !card.has_werewolf():
			continue;
		card.add_keyword(CardEnums.Keyword.MULTIPLY);
		gameplay.update_alterations_for_card(card);

static func trigger_werewolf(card : CardData, gameplay : Gameplay) -> void:
	card.controller.trigger_chameleon(card);
	gameplay.update_alterations_for_card(card);

static func trigger_ocean_dweller(card : CardData, player : Player, gameplay : Gameplay) -> void:
	var points : int = System.Fighting.calculate_base_points(card, null, true, false) * abs(card.get_multiplier());
	if card.multiply_advantage < 0:
		points *= -1;
	player.gain_points(points);
	gameplay.gain_points_effect(player, points < 0);
	if gameplay.get_card(card):
		gameplay.get_card(card).wet_effect();
	System.EyeCandy.spawn_poppets(max(0, points), card, player, gameplay);
