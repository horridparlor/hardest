const NUT_WAIT_MULTIPLIER : float = 1.6;

static func go_to_results(gameplay : Gameplay) -> void:
	#This structure waits and comes back everytime some action is done
	#So that player has time to see animation and react mentally.
	#Better structure to use enum for the phase and make it not crawl
	#The whole structure like this. Fix, if this ever gets longer than
	#Let's say 100 lines :D
	if gameplay.is_time_stopped:
		return gameplay.start_results();
	if gameplay.cannot_go_to_results():
		return gameplay.results_wait();
	if gameplay.results_phase < 2:
		if mimics_phase(gameplay):
			return gameplay.results_wait();
	if gameplay.results_phase < 4:
		if nut_phase(gameplay):
			return gameplay.results_wait(NUT_WAIT_MULTIPLIER - 0.2 * gameplay.nut_combo);
	if gameplay.results_phase < 6:
		if digitals_phase(gameplay):
			return gameplay.results_wait();
	if gameplay.results_phase < 8:
		if shadow_replace_phase(gameplay):
			return gameplay.results_wait();
	gameplay.show_multiplier_bar(gameplay.get_card(gameplay.player_one.get_field_card()));
	gameplay.show_multiplier_bar(gameplay.get_card(gameplay.player_two.get_field_card()));
	gameplay.start_results();

static func mimics_phase(gameplay : Gameplay) -> bool:
	if gameplay.going_first:
		if gameplay.results_phase < 1:
			gameplay.results_phase = 1;
			if transform_your_mimics(gameplay):
				return true;
		if gameplay.results_phase < 2:
			gameplay.results_phase = 2;
			if transform_opponents_mimics(gameplay):
				return true;
	else:
		if gameplay.results_phase < 1:
			gameplay.results_phase = 1;
			if transform_opponents_mimics(gameplay):
				return true;
		if gameplay.results_phase < 2:
			gameplay.results_phase = 2;
			if transform_your_mimics(gameplay):
				return true;
	return false;

static func transform_your_mimics(gameplay : Gameplay) -> bool:
	var enemy : CardData = gameplay.player_two.get_field_card();
	if enemy and enemy.prevents_opponents_reveal():
		return false;
	return transform_mimics(gameplay.player_one.cards_on_field, gameplay.player_one, gameplay.player_two, gameplay);

static func transform_opponents_mimics(gameplay : Gameplay) -> bool:
	var enemy : CardData = gameplay.player_one.get_field_card();
	if enemy and enemy.prevents_opponents_reveal():
		return false;
	return transform_mimics(gameplay.player_two.cards_on_field, gameplay.player_two, gameplay.player_one, gameplay);

static func transform_mimics(your_cards : Array, player : Player, opponent : Player, gameplay : Gameplay) -> bool:
	var card : CardData;
	var transformed_any : bool;
	for c in your_cards:
		card = c;
		if card.is_buried:
			card.is_buried = false;
			if card.has_hydra() or card.has_auto_hydra():
				player.build_hydra(card, false, false);
			System.PlayEffects.trigger_play_effects(card, player, opponent, gameplay);
			gameplay.show_multiplier_bar(gameplay.get_card(card));
			transformed_any = true;
		if card.has_copycat() and opponent.get_field_card():
			card.set_card_type(opponent.get_field_card().card_type);
		if gameplay.get_card(card):
			gameplay.update_alterations_for_card(card, true);
	return transformed_any;

static func nut_phase(gameplay : Gameplay) -> bool:
	if gameplay.going_first:
		if gameplay.results_phase < 3:
			gameplay.results_phase = 3;
			if nut_your_nuts(gameplay):
				gameplay.results_phase = 2;
				return true;
		if gameplay.results_phase < 4:
			gameplay.results_phase = 4;
			if nut_opponents_nuts(gameplay):
				gameplay.results_phase = 3;
				return true;
	else:
		if gameplay.results_phase < 3:
			gameplay.results_phase = 3;
			if nut_opponents_nuts(gameplay):
				gameplay.results_phase = 2;
				return true;
		if gameplay.results_phase < 4:
			gameplay.results_phase = 4;
			if nut_your_nuts(gameplay):
				gameplay.results_phase = 3;
				return true;
	gameplay.nut_combo = 0;
	return false;

static func nut_your_nuts(gameplay : Gameplay) -> bool:
	return nut_players_nuts(gameplay.player_one, gameplay.player_two, gameplay);

static func nut_opponents_nuts(gameplay : Gameplay) -> bool:
	return nut_players_nuts(gameplay.player_two, gameplay.player_one, gameplay);

static func nut_players_nuts(player : Player, opponent : Player, gameplay : Gameplay) -> bool:
	var card : CardData = player.get_field_card();
	var enemy : CardData = opponent.get_field_card();
	if !card or (enemy and enemy.stopped_time_advantage > 1):
		return false;
	var can_nut : bool = (card.get_max_nuts() > 0) or (!card.has_november() and enemy and enemy.has_shared_nut());
	var can_steal_nut : bool = card.has_nut_stealer() and enemy and enemy.can_nut(card.has_shared_nut());
	var nut_prevented : bool = enemy and (enemy.has_november() or enemy.has_nut_stealer());
	if card.has_copycat() and enemy:
		card.set_card_type(enemy.card_type);
		gameplay.update_alterations_for_card(card);
	if can_nut and !nut_prevented and card.can_nut(enemy and enemy.has_shared_nut()):
		if nut_with_card(card, enemy, player, gameplay):
			return true;
	if can_steal_nut and !nut_prevented and card.nuts_stolen < 2 * max(1, enemy.get_max_nuts(card.has_shared_nut())):
		if nut_with_card(card, enemy, player, gameplay):
			card.nuts -= 1;
			card.nuts_stolen += 1;
			return true;
	return false;

static func nut_with_card(card : CardData, enemy : CardData, player : Player, gameplay : Gameplay) -> bool:
	var multiplier : int = System.Fighting.calculate_base_points(card, enemy, true, false);
	var points : int = player.points;
	card.nuts += 1;
	if player.do_nut(multiplier):
		points = player.points - points;
		System.EyeCandy.spawn_poppets(points, card, player, gameplay);
		if gameplay.get_card(card):
			gameplay.get_card(card).recoil(gameplay.get_card(card).position);
			var sound : Resource = load("res://Assets/SFX/CardSounds/Bursts/bottle-shake.wav");
			gameplay.play_sfx(sound, Config.SFX_VOLUME, System.game_speed * pow(1.1, gameplay.nut_combo));
			gameplay.emit_signal("quick_zoom_to", gameplay.get_card(card).position);
			gameplay.nut_combo += 1;
		gameplay.gain_points_effect(player);
		return true;
	return false;

static func digitals_phase(gameplay : Gameplay) -> bool:
	var card : CardData = gameplay.player_one.get_field_card();
	var enemy : CardData = gameplay.player_two.get_field_card();
	if (card and card.has_emp()) or (enemy and enemy.has_emp()):
		return false;
	if gameplay.going_first:
		if gameplay.results_phase < 5:
			gameplay.results_phase = 5;
			if play_your_digitals(gameplay):
				return true;
		if gameplay.results_phase < 6:
			gameplay.results_phase = 6;
			if play_opponents_digitals(gameplay):
				gameplay.results_phase = 2;
				return true;
	else:
		if gameplay.results_phase < 5:
			gameplay.results_phase = 5;
			if play_opponents_digitals(gameplay):
				return true;
		if gameplay.results_phase < 6:
			gameplay.results_phase = 6;
			if play_your_digitals(gameplay):
				gameplay.results_phase = 2;
				return true;
	return false;

static func play_your_digitals(gameplay : Gameplay) -> bool:
	return play_digitals(gameplay.player_one, gameplay.player_two, gameplay);

static func play_opponents_digitals(gameplay : Gameplay) -> bool:
	return play_digitals(gameplay.player_two, gameplay.player_one, gameplay);

static func play_digitals(player : Player, opponent : Player, gameplay : Gameplay) -> bool:
	var cards : Array;
	var enemy : CardData;
	var digital_to_play : CardData;
	var winner : GameplayEnums.Controller = System.Fighting.determine_winning_player(player, opponent);
	if System.Fighting.no_reason_to_counterspell(player, opponent):
		return false;
	if player.has_hivemind_for(CardEnums.Keyword.DIGITAL):
		cards = player.cards_in_hand;
	else:
		cards = player.cards_in_hand.filter(func(card : CardData): return card.has_digital());
	enemy = opponent.get_field_card();
	if cards.size() == 0:
		return false;
	cards.sort_custom(
		func(card_a : CardData, card_b : CardData):
			return System.Fighting.determine_points_result(card_a, enemy) < System.Fighting.determine_points_result(card_b, enemy);
	);
	digital_to_play = cards.back();
	if [winner, GameplayEnums.Controller.PLAYER_TWO].has(System.Fighting.determine_winner(digital_to_play, enemy)):
		return false;
	gameplay.play_digital_sound();
	gameplay.replace_played_card(digital_to_play);
	return true;

static func shadow_replace_phase(gameplay : Gameplay) -> bool:
	if gameplay.going_first:
		if gameplay.results_phase < 7:
			gameplay.results_phase = 7;
			if play_your_shadows(gameplay):
				return true;
		if gameplay.results_phase < 8:
			gameplay.results_phase = 8;
			if play_opponents_shadows(gameplay):
				gameplay.results_phase = 2;
				return true;
	else:
		if gameplay.results_phase < 7:
			gameplay.results_phase = 7;
			if play_opponents_shadows(gameplay):
				return true;
		if gameplay.results_phase < 8:
			gameplay.results_phase = 8;
			if play_your_shadows(gameplay):
				gameplay.results_phase = 2;
				return true;
	return false;

static func play_your_shadows(gameplay : Gameplay) -> bool:
	return play_shadows(gameplay.player_one, gameplay.player_two, gameplay);

static func play_opponents_shadows(gameplay : Gameplay) -> bool:
	return play_shadows(gameplay.player_two, gameplay.player_one, gameplay);

static func play_shadows(player : Player, opponent : Player, gameplay : Gameplay) -> bool:
	var shadow_card : CardData;
	var card : CardData = player.get_field_card();
	var enemy : CardData = opponent.get_field_card();
	var winner : GameplayEnums.Controller = System.Fighting.determine_winning_player(player, opponent);
	if System.Fighting.no_reason_to_counterspell(player, opponent) or player.deck_empty():
		return false;
	for i in range(player.count_deck()):
		var c : CardData = player.cards_in_deck[player.count_deck() - (1 + i)];
		if !c.has_aura_farming() or (c.has_shadow_replace() and ![winner, GameplayEnums.Controller.PLAYER_TWO].has(System.Fighting.determine_winner(c, enemy))):
			if (card and card.has_shadow_replace()) or c.has_shadow_replace():
				shadow_card = c;
	if shadow_card == null:
		return false;
	if [winner, GameplayEnums.Controller.PLAYER_TWO].has(System.Fighting.determine_winner(shadow_card, enemy)):
		return false;
	gameplay.replace_played_card(shadow_card);
	return true;
