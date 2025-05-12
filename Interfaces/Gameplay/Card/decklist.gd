extends Node
class_name Decklist

const DEFAULT_GUN_CHANCE : int = 4;
const DEFAULT_MIMIC_CHANCE : int = 1;
const DEFAULT_GOD_CHANCE : int = 0;
const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"cards": [],
	"gunChance": DEFAULT_GUN_CHANCE,
	"mimicChance": DEFAULT_MIMIC_CHANCE,
	"godChance": DEFAULT_GOD_CHANCE
}

var id : int;
var cards : Dictionary = {
	CardEnums.CardType.ROCK: [],
	CardEnums.CardType.PAPER: [],
	CardEnums.CardType.SCISSORS: [],
	CardEnums.CardType.GUN: [],
	CardEnums.CardType.MIMIC: [],
	CardEnums.CardType.GOD: []
}
var gun_chance : int = DEFAULT_GUN_CHANCE;
var mimic_chance : int = DEFAULT_MIMIC_CHANCE;
var god_chance : int = DEFAULT_GOD_CHANCE;
var starting_cards : Dictionary;

static func from_json(data : Dictionary) -> Decklist:
	var decklist : Decklist = Decklist.new();
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	decklist.id = data.id;
	decklist.gun_chance = data.gunChance;
	decklist.mimic_chance = data.mimicChance;
	decklist.god_chance = data.godChance;
	decklist.eat_cards(data.cards);
	return decklist;

func eat_cards(source : Array) -> void:
	var card_type : CardEnums.CardType;
	var card_data : CardData;
	for card in source:
		card_data = System.Data.load_card(card);
		card_type = card_data.card_type;
		if card_data.has_horse_gear():
			starting_cards[card_type] = card;
			card_data.queue_free();
			continue;
		card_data.queue_free();
		cards[card_type].append(card);

func to_json() -> Dictionary:
	return {
		"id": id,
		"cards": cards,
		"gunChance": gun_chance,
		"mimicChance": mimic_chance,
		"godChance": god_chance
	};

func generate_cards(amount : int = 1) -> Array:
	var ids : Array;
	var card_type : CardEnums.CardType;
	for i in range(amount):
		card_type = get_random_collection_type();
		ids.append(System.Random.item(cards[card_type] + ([CardEnums.BasicIds[card_type]] if cards[card_type].is_empty() else [])));
	return ids;

func get_random_collection_type() -> CardEnums.CardType:
	var result : int = System.random.randi_range(0, 39);
	var threshold : int = god_chance;
	if result < threshold:
		return CardEnums.CardType.GOD;
	threshold += gun_chance;
	if result < threshold:
		return CardEnums.CardType.GUN;
	threshold += mimic_chance;
	if result < threshold:
		return CardEnums.CardType.MIMIC;
	return System.Random.item([
		CardEnums.CardType.ROCK,
		CardEnums.CardType.PAPER,
		CardEnums.CardType.SCISSORS
	]);
