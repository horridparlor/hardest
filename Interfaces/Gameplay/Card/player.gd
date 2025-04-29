extends Node
class_name Player

var cards_in_deck : Array;
var cards_in_extra_deck : Array;
var cards_in_hand : Array;
var cards_on_field : Array;
var cards_in_grave : Array;
var points : int;
var grave_type_counts : Dictionary = {
	CardEnums.CardType.ROCK: 0,
	CardEnums.CardType.PAPER: 0,
	CardEnums.CardType.SCISSORS: 0,
	CardEnums.CardType.MIMIC: 0,
	CardEnums.CardType.GUN: 0,
}

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
	while !deck_empty():
		draw();
		if hand_size_reached():
			break;

func draw(amount : int = 1) -> void:
	var card : CardData;
	if deck_empty() or count_hand() == System.Rules.MAX_HAND_SIZE:
		return;
	card = cards_in_deck.pop_back();
	cards_in_hand.append(card);
	card.zone = CardEnums.Zone.HAND;

func celebrate() -> void:
	shuffle_hand_to_deck();
	draw();

func shuffle_hand_to_deck() -> void:
	for card in cards_in_hand:
		cards_in_deck.append(card);
	cards_in_hand = [];
	cards_in_deck.shuffle();

func play_card(card : CardData) -> void:
	cards_in_hand.erase(card);
	cards_on_field.append(card);
	card.zone = CardEnums.Zone.FIELD;

func eat_decklist(decklist_id : int = 0) -> void:
	var decklist_data : Dictionary = System.Data.read_decklist(decklist_id);
	var card_data : Dictionary;
	for card in decklist_data.main:
		card_data = System.Data.read_card(card);
		for i in range(decklist_data.main[card]):
			cards_in_deck.append(CardData.eat_json(card_data));
	cards_in_deck.shuffle();
	add_always_start_cards();

func add_always_start_cards() -> void:
	var always_cards : Array = [
		System.Data.read_card(3),
		System.Data.read_card(2),
		System.Data.read_card(1)
	]
	for card in always_cards:
		cards_in_deck.append(CardData.eat_json(card));

func shuffle_hand() -> void:
	cards_in_hand.shuffle();

func get_field_card() -> CardData:
	return cards_on_field[0] if !field_empty() else null;

func gain_points(amount : int = 1) -> void:
	points += amount;

func clear_field(did_win : bool) -> void:
	var card : CardData;
	for c in cards_on_field:
		card = c;
		cards_on_field.erase(card);
		add_to_grave(card, did_win);

func add_to_grave(card : CardData, did_win : bool = false) -> void:
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

func count_grave_type(card_type : CardEnums.CardType) -> int:
	return grave_type_counts[card_type];
