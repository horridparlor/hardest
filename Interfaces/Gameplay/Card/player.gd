extends Node
class_name Player

var cards_in_deck : Array;
var cards_in_hand : Array;
var cards_on_field : Array;
var cards_in_grave : Array;
var points : int;
var grave_type_counts : Dictionary = {
	CardEnums.CardType.ROCK: 0,
	CardEnums.CardType.PAPER: 0,
	CardEnums.CardType.SCISSORS: 0,
	CardEnums.CardType.GUN: 0,
	CardEnums.CardType.MIMIC: 0,
	CardEnums.CardType.GOD: 0
}
var character : GameplayEnums.Character;
var controller : GameplayEnums.Controller;
var gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL;
var cards_played_this_turn : int;
var field_position : Vector2;
var visit_point : Vector2;
var extra_draws : int;
var decklist : Decklist;
var going_first : bool;

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

func hand_empty() -> bool:
	return count_hand() == 0;

func count_grave() -> int:
	return cards_in_grave.size();

func hand_size_reached() -> bool:
	return cards_in_hand.size() >= System.Rules.HAND_SIZE;

func draw_hand() -> void:
	while true:
		draw();
		if hand_size_reached():
			break;
	for i in range(extra_draws):
		draw();
	extra_draws = 0;

func draw_cards(amount : int = 1) -> void:
	for i in range(amount):
		if !draw():
			return;

func draw() -> bool:
	var card : CardData;
	if count_hand() == System.Rules.MAX_HAND_SIZE:
		return false;
	card = cards_in_deck.pop_back();
	cards_in_hand.append(card);
	card.zone = CardEnums.Zone.HAND;
	generate_deck();
	return true;

func celebrate() -> void:
	discard_hand();
	draw();

func discard_hand() -> void:
	for card in cards_in_hand.duplicate():
		discard_from_hand(card);

func play_card(card : CardData, is_digital_speed : bool = false) -> void:
	cards_in_hand.erase(card);
	cards_on_field.append(card);
	card.zone = CardEnums.Zone.FIELD;
	if is_digital_speed:
		return;
	card.add_keyword(gained_keyword);
	gained_keyword = CardEnums.Keyword.NULL;
	if !is_digital_speed:
		cards_played_this_turn += 1;

func eat_decklist(decklist_id : int = 0,
	character_id : GameplayEnums.Character = GameplayEnums.Character.PEITSE
) -> void:
	decklist = System.Data.read_decklist(decklist_id);
	character = character_id;
	generate_deck();
	add_always_start_cards();

func generate_deck() -> void:
	var card_data : Dictionary;
	var card : CardData;
	var amount = System.Rules.DECK_SIZE - count_deck();
	if amount <= 0:
		return;
	for card_id in decklist.generate_cards(amount):
		card_data = System.Data.read_card(card_id);
		card = CardData.from_json(card_data)
		card.controller = self;
		cards_in_deck.append(card);

func add_always_start_cards() -> void:
	var horse_gear_rock : CardData = find_horse_gear_card(CardEnums.CardType.ROCK, true);
	var horse_gear_paper : CardData = find_horse_gear_card(CardEnums.CardType.PAPER, true);
	var horse_gear_scissor : CardData = find_horse_gear_card(CardEnums.CardType.SCISSORS, true);
	var rock_card : CardData = System.Data.get_basic_card(CardEnums.CardType.ROCK) \
		if horse_gear_rock == null else horse_gear_rock;
	var paper_card : CardData = System.Data.get_basic_card(CardEnums.CardType.PAPER) \
		if horse_gear_paper == null else horse_gear_paper;
	var scissor_card : CardData = System.Data.get_basic_card(CardEnums.CardType.SCISSORS) \
		if horse_gear_scissor == null else horse_gear_scissor;
	var card_souls : Array = System.Data.load_card_souls_for_character(character);
	var always_cards : Array = [
		rock_card,
		paper_card,
		scissor_card
	] + card_souls;
	always_cards.reverse();
	for card in always_cards:
		cards_in_deck.append(card);
	extra_draws = card_souls.size();

func find_horse_gear_card(card_type : CardEnums.CardType, do_remove_from_deck : bool = false) -> CardData:
	var card : CardData;
	if decklist.starting_cards.has(card_type):
		return System.Data.load_card(decklist.starting_cards[card_type]);
	return null;

func shuffle_hand() -> void:
	cards_in_hand.shuffle();

func get_field_card() -> CardData:
	return cards_on_field[0] if !field_empty() else null;

func gain_points(amount : int = 1) -> void:
	points += amount;

func lose_points(amount : int = 1) -> void:
	points -= amount;
	if points < 0 or amount < 0:
		points = 0;

func end_of_turn_clear(did_win : bool) -> void:
	clear_field(did_win);
	clear_pick_ups();
	cards_played_this_turn = 0;

func clear_field(did_win : bool = false) -> void:
	var card : CardData;
	for c in cards_on_field.duplicate():
		card = c;
		send_from_field_to_grave(card, did_win)

func clear_pick_ups() -> void:
	var card : CardData;
	for c in cards_in_hand.duplicate():
		card = c;
		if !card.has_pick_up():
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

func add_to_grave(card : CardData, did_win : bool = false) -> void:
	if !card:
		return;
	card.zone = CardEnums.Zone.GRAVE;
	card.card_type = card.default_type;
	if did_win and card.has_undead(true):
		purge_undead_materials(card.default_type);
	cards_in_grave.append(card);
	grave_type_counts[card.default_type] += 1;

func purge_undead_materials(card_type : CardEnums.CardType) -> void:
	var cards_to_purge : int = System.Rules.UNDEAD_LIMIT;
	for card in cards_in_grave.duplicate():
		if card.card_type == card_type:
			purge_from_grave(card);
			cards_to_purge -= 1;
			if cards_to_purge == 0:
				return;

func purge_from_grave(card : CardData) -> void:
	cards_in_grave.erase(card);
	grave_type_counts[card.default_type] -= 1;
	card.queue_free();

func is_close_to_winning() -> bool:
	return points >= System.Rules.CLOSE_TO_WINNING_POINTS;

func count_grave_type(card_type : CardEnums.CardType, instance_id_of_replacement : int = 0) -> int:
	var added_count : int = get_added_count_from_replacing_field(instance_id_of_replacement, card_type);
	return added_count + grave_type_counts[card_type];

func get_added_count_from_replacing_field(instance_id : int, card_type : CardEnums.CardType) -> int:
	var count : int = 0;
	var field_card : CardData;
	if instance_id == 0:
		return count;
	field_card = get_field_card();
	if field_card and field_card.instance_id != instance_id and field_card.default_type == card_type:
		count += 1;
	return count;

func get_active_cards() -> Array:
	return cards_in_hand + cards_on_field;

func get_cards() -> Array:
	return cards_in_deck + get_active_cards();

func shuffle_random_card_to_deck(card_type : CardEnums.CardType) -> CardData:
	var card : CardData = CardData.from_json(CollectionEnums.get_random_card(card_type));
	cards_in_deck.append(card);
	cards_in_deck.shuffle();
	return card; 

func get_rainbowed() -> void:
	var card : CardData;
	for c in cards_in_hand:
		card = c;
		card.eat_json(CollectionEnums.get_random_card(card.default_type));

func build_hydra(card : CardData) -> void:
	var keywords : Array = CardEnums.get_keywords();
	var keyword : CardEnums.Keyword;
	card.keywords = [] if Config.DEBUG_KEYWORD == CardEnums.Keyword.NULL else [Config.DEBUG_KEYWORD];
	for i in range(System.Rules.HYDRA_KEYWORDS):
		keyword = System.Random.item(keywords);
		keywords.erase(keyword);
		card.add_keyword(keyword);

func devour_card(eater : CardData, card : CardData) -> void:
	if eater.is_buried:
		eater.is_buried = false;
	eater.card_type = card.card_type;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.UNDEAD:
				if eater.is_gun():
					continue;
		if eater.has_keyword(keyword) or [CardEnums.Keyword.BURIED, CardEnums.Keyword.DEVOUR].has(keyword):
			continue;
		if eater.keywords.size() == System.Rules.MAX_KEYWORDS:
			if eater.keywords.has(CardEnums.Keyword.BURIED):
				eater.keywords.erase(CardEnums.Keyword.BURIED);
			elif eater.keywords.has(CardEnums.Keyword.DEVOUR):
				eater.keywords.erase(CardEnums.Keyword.DEVOUR);
			else:
				return;
		eater.add_keyword(keyword);

func steal_card_soul(card : CardData) -> void:
	System.Data.add_card_soul_to_character(character, card);

func trigger_opponent_placed_effects() -> void:
	var card : CardData = get_field_card();
	if !card:
		return;
	for keyword in card.keywords:
		match keyword:
			CardEnums.Keyword.CHAMELEON:
				trigger_chameleon(card);

func trigger_chameleon(card : CardData) -> void:
	var card_type : CardEnums.CardType = card.card_type;
	match card_type:
		CardEnums.CardType.ROCK:
			card_type = CardEnums.CardType.SCISSORS;
		CardEnums.CardType.PAPER:
			card_type = CardEnums.CardType.ROCK;
		CardEnums.CardType.SCISSORS:
			card_type = CardEnums.CardType.PAPER;
		CardEnums.CardType.MIMIC:
			card_type = System.Random.item([
				CardEnums.CardType.ROCK,
				CardEnums.CardType.PAPER,
				CardEnums.CardType.SCISSORS
			]);
	card.card_type = card_type;
