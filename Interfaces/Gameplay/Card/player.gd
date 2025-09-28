extends Node
class_name Player

signal card_added

var cards_in_deck : Array;
var cards_in_hand : Array;
var cards_on_field : Array;
var cards_in_grave : Array;
var points : int = 0;
var grave_type_counts : Dictionary = {
	CardEnums.CardType.ROCK: 0,
	CardEnums.CardType.PAPER: 0,
	CardEnums.CardType.SCISSORS: 0,
	CardEnums.CardType.GUN: 0,
	CardEnums.CardType.MIMIC: 0,
	CardEnums.CardType.GOD: 0,
	CardEnums.CardType.BEDROCK: 0,
	CardEnums.CardType.ZIPPER: 0,
	CardEnums.CardType.ROCKSTAR: 0
}
var character : GameplayEnums.Character;
var controller : GameplayEnums.Controller;
var opponent : Player;
var gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL;
var cards_played_this_turn : int;
var field_position : Vector2;
var visit_point : Vector2;
var extra_draws : int;
var decklist : Decklist;
var going_first : bool;
var turns_waited_to_nut : int;
var did_nut : bool;
var nut_multiplier : int = 1;
var point_goal : int;
var is_roguelike : bool;
var last_type_played : CardEnums.CardType = CardEnums.CardType.NULL;
var true_last_type_played : CardEnums.CardType = CardEnums.CardType.NULL;
var played_same_type_in_a_row : int;
var played_alpha_werewolf : bool;
var brotherhood_multiplier : int = 1;
var recycle_cards : Array;
var soon_to_be_recycle_cards : Array;

func count_deck() -> int:
	return cards_in_deck.size();

func deck_empty() -> bool:
	return count_deck() == 0;

func count_field() -> int:
	return cards_on_field.size();

func field_empty() -> bool:
	return count_field() == 0;

func count_hand() -> int:
	return cards_in_hand.size();

func count_hand_without(card : CardData) -> int:
	var count : int = count_hand();
	if count > 0 and cards_in_hand.has(card):
		return count - 1;
	return count;

func hand_empty() -> bool:
	return count_hand() == 0;

func count_grave() -> int:
	return cards_in_grave.size();

func hand_size_reached() -> bool:
	return cards_in_hand.size() == System.Rules.MAX_HAND_SIZE \
	or cards_in_hand.size() - count_negatives_in_hand() >= System.Rules.HAND_SIZE;

func count_negatives_in_hand() -> int:
	var count : int;
	var card : CardData;
	for c in cards_in_hand:
		card = c
		if card.has_negative() or card.is_negative_variant():
			count += 1;
	return count;

func draw_hand() -> void:
	var card : CardData;
	while true:
		draw();
		if hand_size_reached():
			break;
	for i in range(extra_draws):
		draw();
	extra_draws = 0;
	for c in cards_in_hand:
		card = c;
		card.just_spawned_dont_discard = false;

func fill_hand() -> void:
	while count_hand() < System.Rules.MAX_HAND_SIZE:
		draw();

func draw_cards(amount : int = 1) -> void:
	for i in range(amount):
		if !draw():
			return;

func hand_full() -> bool:
	return count_hand() == System.Rules.MAX_HAND_SIZE;

func draw() -> bool:
	var card : CardData;
	if hand_full():
		return false;
	card = get_card_to_draw();
	cards_in_hand.append(card);
	card.zone = CardEnums.Zone.HAND;
	if card.has_auto_hydra():
		build_hydra(card);
	if deck_empty():
		generate_deck();
	return true;

func get_card_to_draw() -> CardData:
	var card : CardData;
	var index : int;
	var has_non_aura_farmers : bool;
	for c in cards_in_deck:
		if !c.has_aura_farming():
			has_non_aura_farmers = true;
			break;
	if deck_empty() or !has_non_aura_farmers:
		generate_deck();
	for i in range(cards_in_deck.size()):
		index = cards_in_deck.size() - (1 + i);
		card = cards_in_deck[index];
		if card.has_aura_farming() and (get_matching_type(card.default_type, last_type_played) == CardEnums.CardType.NULL or played_same_type_in_a_row + 1 < System.Rules.AURA_FARMIN_COUNT):
			continue;
		cards_in_deck.remove_at(index);
		return card;
	refill_deck();
	return cards_in_deck.pop_back();

func get_top_deck() -> CardData:
	if deck_empty():
		generate_deck();
	return cards_in_deck.back();

func refill_deck() -> void:
	var ids : Array;
	var deck_original_size : int = count_deck();
	for i in range(12):
		ids.append(CardEnums.BasicIds[CardEnums.CardType.ROCK]);
		ids.append(CardEnums.BasicIds[CardEnums.CardType.PAPER]);
		ids.append(CardEnums.BasicIds[CardEnums.CardType.SCISSORS]);
	if is_roguelike:
		for i in range(3):
			ids.append(CardEnums.BasicIds[CardEnums.CardType.GUN]);
		ids.append(CardEnums.BasicIds[CardEnums.CardType.MIMIC]);
	ids.shuffle();
	for id in ids:
		spawn_card(System.Data.load_card(id));
	slide_deck(deck_original_size);

func celebrate() -> void:
	discard_hand();
	draw();

func get_nostalgic(card : CardData) -> void:
	var used_types : Array
	var extra_chance : int;
	if card.is_multi_type() or card.is_gun() or card.is_god():
		extra_chance += 1;
	if card.is_holographic:
		extra_chance += 1;
	if card.is_negative_variant():
		extra_chance += 1;
	if card.has_rare_stamp():
		extra_chance += 1;
	discard_hand();
	for i in range(System.Rules.NOSTALGIA_DRAWS):
		if !draw_a_basic(used_types, extra_chance, [CardEnums.Keyword.PICK_UP]):
			break;
	cards_in_hand.sort_custom(func(card_a : CardData, card_b : CardData):
		return get_index_by_card_type(card_a) < get_index_by_card_type(card_b);
	);
	
func get_index_by_card_type(card : CardData) -> int:
	match card.card_type:
		CardEnums.CardType.ROCK:
			return 1;
		CardEnums.CardType.PAPER:
			return 3;
		CardEnums.CardType.SCISSORS:
			return 5;
		CardEnums.CardType.BEDROCK:
			return 2;
		CardEnums.CardType.ZIPPER:
			return 4;
		CardEnums.CardType.ROCKSTAR:
			return 6;
		CardEnums.CardType.GUN:
			return 7;
		CardEnums.CardType.MIMIC:
			return 8;
		CardEnums.CardType.GOD:
			return 9;
	return 0;

func draw_a_basic(used_types : Array, extra_chance : int = 0, keywords_to_add : Array = []) -> bool:
	var basic_id : int;
	const multi_chance : int = 6;
	var pool : Array = [
		CardEnums.CardType.BEDROCK if System.Random.chance(multi_chance - extra_chance) else CardEnums.CardType.ROCK,
		CardEnums.CardType.ZIPPER if System.Random.chance(multi_chance - extra_chance) else CardEnums.CardType.PAPER,
		CardEnums.CardType.ROCKSTAR if System.Random.chance(multi_chance - extra_chance) else CardEnums.CardType.SCISSORS
	];
	var chosen_type : CardEnums.CardType;
	var card : CardData;
	if hand_full():
		return false;
	if System.Random.chance(8 - extra_chance):
		pool.append(CardEnums.CardType.GUN);
	if System.Random.chance(10 - extra_chance):
		pool.append(CardEnums.CardType.MIMIC);
	if System.Random.chance(100 - pow(extra_chance, 2)):
		pool.append(CardEnums.CardType.GOD);
	for item in used_types:
		pool.erase(item);
		pool.erase(CardEnums.get_base_type(item));
	if pool.is_empty():
		return false;
	chosen_type = System.Random.item(pool);
	used_types.append(chosen_type);
	if CardEnums.BASIC_COLORS.keys().has(chosen_type):
		used_types.append(CardEnums.get_multi_variant(chosen_type))
	basic_id = CardEnums.BasicIds[chosen_type];
	card = draw_spawn_a_card(basic_id, keywords_to_add);
	return true;

func discard_hand() -> void:
	for card in cards_in_hand.duplicate():
		discard_from_hand(card);

func play_card(card : CardData, is_digital_speed : bool = false) -> void:
	match card.zone:
		CardEnums.Zone.HAND:
			cards_in_hand.erase(card);
		CardEnums.Zone.DECK:
			cards_in_deck.erase(card);
		CardEnums.Zone.GRAVE:
			remove_from_grave(card);
	cards_on_field.append(card);
	card.zone = CardEnums.Zone.FIELD;
	if is_digital_speed:
		return;
	card.add_keyword(gained_keyword);
	gained_keyword = CardEnums.Keyword.NULL;
	trigger_play_multipliers(card);
	if !is_digital_speed:
		cards_played_this_turn += 1;

func trigger_play_multipliers(card : CardData) -> void:
	var matching_type : CardEnums.CardType = get_matching_type(card.card_type, last_type_played);
	if matching_type != CardEnums.CardType.NULL:
		last_type_played = matching_type;
		played_same_type_in_a_row += 1;
	else:
		played_same_type_in_a_row = 0;
		last_type_played = card.card_type;
	true_last_type_played = card.card_type;
	if card.has_brotherhood():
		trigger_brotherhood(card);

func trigger_brotherhood(card : CardData) -> void:
	card.multiply_advantage *= brotherhood_multiplier;
	brotherhood_multiplier *= 2;

func get_matching_type(new_type : CardEnums.CardType, base_type : CardEnums.CardType = last_type_played) -> CardEnums.CardType:
	var base_types : Array = CardData.break_card_type(base_type);
	if base_type == CardEnums.CardType.NULL:
		return CardEnums.CardType.NULL;
	elif new_type == base_type:
		return new_type;
	for type in CardData.break_card_type(new_type):
		if base_types.has(type):
			return type;
	return CardEnums.CardType.NULL;

func eat_decklist(decklist_id : int = 0,
	character_id : GameplayEnums.Character = GameplayEnums.Character.PEITSE
) -> void:
	decklist = System.Data.read_decklist(decklist_id);
	character = character_id;
	generate_deck();
	add_start_cards();

func generate_deck() -> void:
	var cards : Array = decklist.get_deck();
	var deck_original_size : int = count_deck();
	if cards.is_empty():
		refill_deck();
		return;
	for card in cards:
		if !System.Instance.exists(card):
			continue;
		spawn_card(card);
	slide_deck(deck_original_size);

func slide_deck(index : int) -> void:
	cards_in_deck.append_array(cards_in_deck.slice(0, index))
	cards_in_deck = cards_in_deck.slice(index);

func spawn_card(card_data : CardData, spawn_to : CardEnums.Zone = CardEnums.Zone.DECK) -> CardData:
	var card : CardData = CardData.from_json(card_data.to_json());
	card.controller = self;
	card.just_spawned_dont_discard = true;
	match spawn_to:
		CardEnums.Zone.DECK:
			cards_in_deck.append(card);
		CardEnums.Zone.HAND:
			card.zone = CardEnums.Zone.HAND;
			cards_in_hand.append(card);
	return card;

func spawn_card_from_id(card_id : int) -> void:
	spawn_card(System.Data.load_card(card_id));

func add_start_cards() -> void:
	var card_souls : Array = System.Data.load_card_souls_for_character(character, controller);
	var start_cards : Array = decklist.start_with;
	if decklist.cards.size() > 0:
		start_cards = [];
		for i in range(System.Rules.HAND_SIZE):
			start_cards.append(cards_in_deck.pop_back());
	start_cards += card_souls;
	start_cards.reverse();
	for card in start_cards:
		cards_in_deck.append(card);
	extra_draws = card_souls.size();

func shuffle_hand() -> void:
	cards_in_hand.shuffle();

func shuffle_deck() -> void:
	cards_in_deck.shuffle();

func get_field_card() -> CardData:
	return cards_on_field[0] if !field_empty() else null;

func gain_points(amount : int = 1, actually_gain : bool = true) -> int:
	amount = max(0, amount);
	if !actually_gain:
		return amount;
	points += amount;
	return amount;

func lose_points(amount : int = 1, can_go_negative : bool = false) -> int:
	var original_points : int = points;
	points -= amount;
	if points < 0 and points < original_points:
		points = min(0, original_points);
		if can_go_negative:
			points = min(points, -amount);
	return points - original_points;

func end_of_turn_clear(did_win : bool) -> void:
	clear_field(did_win);
	clear_pick_ups();
	cards_played_this_turn = 0;
	end_of_turn_updates();
	
func end_of_turn_updates() -> void:
	end_of_turn_nut_update();
	cards_in_grave_turn_increment();

func end_of_turn_nut_update() -> void:
	if did_nut:
		did_nut = false;
		reset_nut();
	turns_waited_to_nut += 1;

func cards_in_grave_turn_increment() -> void:
	recycle_cards = soon_to_be_recycle_cards;
	soon_to_be_recycle_cards = [];

func reset_nut() -> void:
	turns_waited_to_nut = 0;
	nut_multiplier = 1;

func clear_field(did_win : bool = false) -> void:
	var card : CardData;
	for c in cards_on_field.duplicate():
		card = c;
		send_from_field_to_grave(card, did_win)

func has_hivemind_for(keyword : CardEnums.Keyword = CardEnums.Keyword.HIVEMIND) -> bool:
	var has_hivemind : bool = field_has_hivemind();
	var has_keyword : bool = keyword == CardEnums.Keyword.HIVEMIND;
	var card : CardData;
	for c in cards_in_hand:
		card = c;
		if card.has_hivemind():
			has_hivemind = true;
		if card.has_keyword(keyword):
			has_keyword = true;
		if has_hivemind and has_keyword:
			return true;
	return false;

func field_has_hivemind() -> bool:
	var card : CardData;
	for c in cards_on_field + opponent.cards_on_field:
		if !System.Instance.exists(c):
			continue;
		card = c;
		if card.has_hivemind():
			return true;
	return false;

func has_hivemind_for_type(card_type : CardEnums.CardType) -> bool:
	var has_hivemind : bool = field_has_hivemind();
	var has_type : bool;
	var card : CardData;
	for c in cards_in_hand:
		card = c;
		if card.has_hivemind():
			has_hivemind = true;
		if get_matching_type(card.card_type, card_type) != CardEnums.CardType.NULL:
			has_type = true;
		if has_hivemind and has_type:
			return true;
	return false;

func clear_pick_ups() -> void:
	var card : CardData;
	var has_hivemind : bool = has_hivemind_for(CardEnums.Keyword.PICK_UP);
	for c in cards_in_hand.duplicate():
		card = c;
		if (!has_hivemind and !card.has_pick_up()) or card.just_spawned_dont_discard:
			card.just_spawned_dont_discard = false;
			continue;
		cards_in_hand.erase(card);
		add_to_grave(card);

func send_from_field_to_grave(card : CardData, did_win : bool = false) -> void:
	cards_on_field.erase(card);
	add_to_grave(card, did_win);

func not_played_this_turn() -> bool:
	return cards_played_this_turn == 0;

func discard_from_hand(card : CardData) -> void:
	cards_in_hand.erase(card);
	add_to_grave(card);

func mill_from_deck(card : CardData) -> void:
	cards_in_deck.erase(card);
	add_to_grave(card);

func random_discard(do_destroy : bool = false) -> CardData:
	var card : CardData;
	var source : Array;
	for c in cards_in_hand:
		card = c;
		if !do_destroy or !card.has_cursed():
			source.append(card);
	if source.size() == 0:
		return null;
	card = System.Random.item(source);
	discard_from_hand(card);
	return card;

func add_to_grave(card : CardData, did_win : bool = false) -> void:
	if !card:
		return;
	card.zone = CardEnums.Zone.GRAVE;
	card.multiply_advantage = 1;
	card.value_increment = 0;
	card.set_card_type(card.default_type);
	card.turns_in_grave = 0;
	recycle_cards.erase(card);
	soon_to_be_recycle_cards.append(card);
	if did_win and card.has_undead(true):
		purge_undead_materials(card.default_type);
	if card.is_burned:
		return;
	cards_in_grave.append(card);
	grave_type_counts[card.default_type] += 1;

func purge_undead_materials(card_type : CardEnums.CardType) -> void:
	var cards_to_purge : int = System.Rules.UNDEAD_LIMIT;
	for card in cards_in_grave.duplicate():
		if get_matching_type(card.card_type, card_type) != CardEnums.CardType.NULL:
			purge_from_grave(card);
			cards_to_purge -= 1;
			if cards_to_purge == 0:
				return;

func purge_from_grave(card : CardData) -> void:
	remove_from_grave(card);
	card.queue_free();

func remove_from_grave(card : CardData) -> void:
	cards_in_grave.erase(card);
	recycle_cards.erase(card);
	soon_to_be_recycle_cards.erase(card);
	grave_type_counts[card.default_type] -= 1;

func is_close_to_winning() -> bool:
	return points >= System.Rules.CLOSE_TO_WINNING_POINTS * point_goal;

func count_grave_type(card_type : CardEnums.CardType, instance_id_of_replacement : int = 0) -> int:
	var added_count : int = get_added_count_from_replacing_field(instance_id_of_replacement, card_type);
	var grave_count : int = grave_type_counts[card_type];
	if CardEnums.BASIC_COLORS.has(card_type):
		for type in CardData.expand_type(card_type):
			grave_count += grave_type_counts[type];
	elif CardEnums.is_multi_type(card_type):
		for type in CardData.break_card_type(card_type):
			grave_count += grave_type_counts[type];
	return added_count + grave_count;

func get_added_count_from_replacing_field(instance_id : int, card_type : CardEnums.CardType) -> int:
	var count : int = 0;
	var field_card : CardData;
	if instance_id == 0:
		return count;
	field_card = get_field_card();
	if field_card and field_card.instance_id != instance_id and get_matching_type(field_card.default_type, card_type) != CardEnums.CardType.NULL:
		count += 1;
	return count;

func get_active_cards() -> Array:
	return cards_in_hand + cards_on_field;

func get_cards() -> Array:
	return cards_in_deck + get_active_cards();

func shuffle_random_card_to_deck(card_type : CardEnums.CardType) -> CardData:
	var card : CardData = CardData.from_json(CollectionEnums.get_random_card(card_type));
	shuffle_to_deck(card);
	return card; 

func shuffle_to_deck(card : CardData) -> void:
	cards_in_deck.append(card);
	shuffle_deck();

func get_rainbowed() -> void:
	var card : CardData;
	for c in cards_in_hand:
		card = c;
		rainbow_a_card(card);
		if card.has_auto_hydra():
			build_hydra(card, true);

func rainbow_a_card(card : CardData, card_type : CardEnums.CardType = CardEnums.CardType.NULL):
	if card_type == CardEnums.CardType.NULL:
		card_type = card.default_type;
	card.eat_json(CollectionEnums.get_random_card(card_type, card.card_id), false);
	card.set_card_type(card_type);

func build_hydra(card : CardData, include_hand_keywords : bool = false, allow_buried : bool = true) -> void:
	var keywords : Array = CardEnums.get_hydra_keywords();
	if include_hand_keywords:
		keywords += CardEnums.get_hand_hydra_keywords();
	if System.Random.chance(System.Rules.HYDRA_RARE_KEYWORDS_CHANCE):
		keywords += CardEnums.get_rare_hydra_keywords();
	if allow_buried:
		keywords += CardEnums.get_face_down_hydra_keywords();
	var keyword : CardEnums.Keyword;
	card.keywords = [] if Config.DEBUG_KEYWORD == CardEnums.Keyword.NULL else [Config.DEBUG_KEYWORD];
	while card.keywords.size() < System.Rules.HYDRA_KEYWORDS:
		if card.if_hydra_keywords.is_empty():
			keyword = System.Random.item(keywords);
		else:
			keyword = card.if_hydra_keywords.pop_back();
		keywords.erase(keyword);
		card.add_keyword(keyword);
	if card.has_tidal() and !card.is_god():
		card.set_card_type(CardEnums.CardType.GUN);

func devour_card(eater : CardData, card : CardData) -> Array:
	var devoured_keywords : Array;
	var original_stamp : CardEnums.Stamp = eater.stamp;
	var original_variant : CardEnums.CardVariant = eater.variant;
	var original_is_holograpic : bool = eater.is_holographic;
	if eater.is_buried:
		eater.is_buried = false;
	if eater.has_devow():
		eater.eat_json(card.to_json(), true, true);
		eater.stamp = original_stamp if card.stamp == CardEnums.Stamp.NULL else card.stamp;
		eater.variant = CardEnums.CardVariant.NEGATIVE;
		eater.is_holographic = original_is_holograpic if card.is_holographic == false else card.is_holographic;
		eater.is_foil = card.is_foil;
		return eater.keywords;
	eater.set_card_type(card.card_type);
	eater.stamp = original_stamp if card.stamp == CardEnums.Stamp.NULL else card.stamp;
	eater.variant = original_variant if card.variant == CardEnums.CardVariant.REGULAR else card.variant;
	eater.is_holographic = original_is_holograpic if card.is_holographic == false else card.is_holographic;
	eater.is_foil = card.is_foil if !eater.is_foil else eater.is_foil;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.UNDEAD:
				if eater.is_gun():
					continue;
		if eater.has_keyword(keyword) or [CardEnums.Keyword.BURIED, CardEnums.Keyword.BURIED_ALIVE, CardEnums.Keyword.DEVOUR].has(keyword):
			continue;
		if eater.keywords.size() == System.Rules.MAX_KEYWORDS:
			if eater.keywords.has(CardEnums.Keyword.BURIED):
				eater.keywords.erase(CardEnums.Keyword.BURIED);
			if eater.keywords.has(CardEnums.Keyword.BURIED_ALIVE):
				eater.keywords.erase(CardEnums.Keyword.BURIED_ALIVE);
			elif eater.keywords.has(CardEnums.Keyword.DEVOUR):
				eater.keywords.erase(CardEnums.Keyword.DEVOUR);
			else:
				return devoured_keywords;
		if eater.add_keyword(keyword):
			devoured_keywords.append(keyword);
	return devoured_keywords;

func steal_card_soul(card : CardData) -> void:
	System.Data.add_card_soul_to_character(character, controller, card);

func steal_card(card : CardData) -> void:
	var new_card : CardData;
	new_card = CardData.from_json(card.to_json());
	new_card.controller = self;
	card.controller.burn_card(card);
	shuffle_to_deck(new_card);
	make_new_card_permanent(new_card);

func trigger_opponent_placed_effects() -> void:
	var card : CardData = get_field_card();
	if !card or card.is_buried:
		return;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.CHAMELEON:
				trigger_chameleon(card);

func trigger_chameleon(card : CardData) -> void:
	var card_type : CardEnums.CardType = card.default_type;
	if CardEnums.is_multi_type(card_type) and !CardEnums.is_multi_type(card.card_type):
		match card.card_type:
			CardEnums.CardType.MIMIC:
				card.card_type = System.Random.item(CardEnums.BASIC_COLORS.keys());
		match card.card_type:
			CardEnums.CardType.ROCK:
				card.card_type = CardEnums.CardType.BEDROCK;
			CardEnums.CardType.PAPER:
				card.card_type = CardEnums.CardType.ZIPPER;
			CardEnums.CardType.SCISSORS:
				card.card_type = CardEnums.CardType.ROCKSTAR;
	match card.card_type:
		CardEnums.CardType.ROCK:
			card_type = CardEnums.CardType.SCISSORS;
		CardEnums.CardType.PAPER:
			card_type = CardEnums.CardType.ROCK;
		CardEnums.CardType.SCISSORS:
			card_type = CardEnums.CardType.PAPER;
		CardEnums.CardType.MIMIC:
			card_type = System.Random.item(CardEnums.BASIC_COLORS.keys());
		CardEnums.CardType.BEDROCK:
			card_type = CardEnums.CardType.ROCKSTAR;
		CardEnums.CardType.ZIPPER:
			card_type = CardEnums.CardType.BEDROCK;
		CardEnums.CardType.ROCKSTAR:
			card_type = CardEnums.CardType.ZIPPER;
	card.set_card_type(card_type);

func do_nut(multiplier : int = 1) -> bool:
	var gained : int = turns_waited_to_nut * multiplier * nut_multiplier;
	points += gained
	did_nut = true;
	return gained > 0;

func log_deck() -> void:
	var card : CardData;
	var i : int;
	print("Cards in deck");
	for c in cards_in_deck:
		card = c;
		i += 1;
		print("%s: %s – %s" % [i, card.card_id, card.card_name]);
	print("---");

func draw_horse() -> bool:
	var horse_id : int;
	if hand_full():
		return false;
	horse_id = System.Random.item(CardEnums.HORSE_CARD_IDS);
	draw_spawn_a_card(horse_id);
	return true;

func draw_spawn_a_card(card_id : int, keywords_to_add : Array = []) -> CardData:
	var card : CardData = System.Data.load_card(card_id);
	if System.Random.chance(128):
		card.variant = CardEnums.CardVariant.NEGATIVE;
	if System.Random.chance(32):
		card.is_holographic = true;
	if System.Random.chance(16):
		card.stamp = System.Random.item(CardEnums.Stamp.values());
	for keyword in keywords_to_add:
		card.add_keyword(keyword);
	spawn_card(card);
	draw();
	return card;

func burn_card(card : CardData) -> void:
	var spawn_id : int = card.spawn_id;
	card.is_burned = true;
	for other_card in cards_in_grave.duplicate():
		if other_card.spawn_id == spawn_id:
			purge_from_grave(other_card);
	for other_card in cards_in_deck.duplicate():
		if other_card.spawn_id == spawn_id:
			cards_in_deck.erase(other_card);
	decklist.burn_card(spawn_id);

func make_new_card_permanent(card : CardData) -> void:
	decklist.make_new_card_permanent(card);
	emit_signal("card_added");

func make_card_alterations_permanent(card : CardData) -> void:
	var index : int;
	var spawned_card : CardData;
	var original_card_type : CardEnums.CardType;
	for c in cards_in_deck:
		if c.spawn_id == card.spawn_id:
			spawned_card = spawn_card(card, CardEnums.Zone.NULL);
			spawned_card.zone = CardEnums.Zone.DECK;
			spawned_card.set_card_type(spawned_card.default_type);
			cards_in_deck[index] = spawned_card;
		index += 1;
	index = 0;
	for c in cards_in_grave:
		if c.spawn_id == card.spawn_id:
			original_card_type = c.default_type;
			spawned_card = spawn_card(card, CardEnums.Zone.NULL);
			spawned_card.zone = CardEnums.Zone.GRAVE;
			spawned_card.set_card_type(spawned_card.default_type);
			cards_in_grave[index] = spawned_card;
			if original_card_type != spawned_card.default_type:
				grave_type_counts[original_card_type] -= 1
				grave_type_counts[spawned_card.default_type] += 1
		index += 1;
	decklist.make_card_alterations_permanent(card);
