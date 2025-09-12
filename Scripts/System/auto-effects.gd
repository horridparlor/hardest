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
