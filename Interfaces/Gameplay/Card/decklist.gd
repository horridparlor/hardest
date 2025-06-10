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
	if Config.DEBUG_CARD != 0:
		return System.Data.load_card(Config.DEBUG_CARD);
	if typeof(card) == TYPE_FLOAT:
		return System.Data.load_card(card);
	return System.Data.load_card(card.id);

func to_json() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"cards": cards
	};

func get_deck() -> Array:
	cards.shuffle();
	return cards;
