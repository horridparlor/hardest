extends Node
class_name Decklist

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"title": "",
	"cards": [],
	"startWith": []
}

var id : int;
var title : String;
var cards : Array;
var start_with : Array;
var burned_cards : Array;
var created_cards : Array;
var altered_cards : Dictionary;

static func from_json(data : Dictionary) -> Decklist:
	var decklist : Decklist = Decklist.new();
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	decklist.id = data.id;
	decklist.title = data.title;
	decklist.eat_cards(data.cards, data.startWith);
	return decklist;

func eat_cards(source_cards : Array, source_starting_cards : Array) -> void:
	var card_type : CardEnums.CardType;
	var starting_type : CardEnums.CardType;
	if source_cards.size() == 0:
		source_cards = [1, 2, 3];
	while source_cards.size() < 3:
		source_cards.append(System.Random.item(source_cards));
	for card in source_cards:
		cards.append(parse_card_or_id(card));
	for card in source_starting_cards:
		start_with.append(parse_card_or_id(card));
	fill_start_with();

func fill_start_with() -> void:
	var default_start_cards : Array = [
		System.Data.load_card(CardEnums.BasicIds[CardEnums.CardType.ROCK]),
		System.Data.load_card(CardEnums.BasicIds[CardEnums.CardType.PAPER]),
		System.Data.load_card(CardEnums.BasicIds[CardEnums.CardType.SCISSORS])
	];
	if start_with.size() == 0:
		start_with = default_start_cards;
		return;
	while start_with.size() < System.Rules.HAND_SIZE:
		default_start_cards.shuffle();
		start_with.append(default_start_cards.pop_back());

func parse_card_or_id(card) -> CardData:
	var card_data : CardData;
	if Config.DEBUG_CARD != 0:
		return System.Data.load_card(Config.DEBUG_CARD);
	if typeof(card) == TYPE_FLOAT or typeof(card) == TYPE_INT:
		return System.Data.load_card(card);
	card_data = System.Data.load_card(card.id);
	card_data.eat_spawn_json(card);
	return card_data;

func to_json() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"cards": cards
	};

func get_deck() -> Array:
	cards.shuffle();
	return cards;

func burn_card(spawn_id : int) -> void:
	for card in cards.duplicate():
		if card.spawn_id == spawn_id:
			cards.erase(card);
			card.queue_free();
			break;
	burned_cards.append(spawn_id);

func make_new_card_permanent(card : CardData) -> void:
	cards.append(card);
	created_cards.append(card.to_json());

func make_card_alterations_permanent(card : CardData) -> void:
	for c in cards.duplicate():
		if c.spawn_id == card.spawn_id:
			cards.erase(c);
			break;
	cards.append(card);
	altered_cards[card.spawn_id] = card.to_json();
