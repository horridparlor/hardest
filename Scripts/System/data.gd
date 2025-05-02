const CARDS_FOLDER_PATH : String = "Cards/";
const DECKLIST_FOLDER_PATH : String = "Decklists/";
const LEVEL_FOLDER_PATH : String = "Levels/";
const SAVE_DATA_PATH : String = "save-data";

const DEFAULT_CARD : Dictionary = {
	"id": 0,
	"name": "Name",
	"type": "Mimic",
	"keywords": []
}

const DEFAULT_RANDOM_KEYWORDS : Array = [
	"buried",
	"pair",
	"rust"
]

const DEFAULT_RANDOM_CARDS : Dictionary = {
	"rock": [1],
	"paper": [2],
	"scissor": [3],
	"gun": [4],
	"mimic": [5],
	"god": [42]
}

const DEFAULT_DECKLIST : Dictionary = {
	"id": 0,
	"main": [],
	"extra": [],
	"random_keywords": DEFAULT_RANDOM_KEYWORDS,
	"random_cards": DEFAULT_RANDOM_CARDS
}

const DEFAULT_LEVEL : Dictionary = {
	"id": 1,
	"opponent": GameplayEnums.Character.PETE,
	"deck": 1,
	"deck2": 1
}

const DEFAULT_SAVE_DATA : Dictionary = {
	"levels_unlocked": 0
};

static func read_card(card_id : int) -> Dictionary:
	return System.Dictionaries.make_safe(
		System.Json.read_data(CARDS_FOLDER_PATH + str(card_id)), DEFAULT_CARD
	);

static func get_basic_card(card_type : CardEnums.CardType) -> CardData:
	return CardData.from_json(read_card(CardEnums.BasicIds[card_type]));

static func read_decklist(decklist_id : int) -> Dictionary:
	var data : Dictionary = System.Json.read_data(DECKLIST_FOLDER_PATH + str(decklist_id));
	if System.Json.is_error(data):
		data = System.Json.read_data(DECKLIST_FOLDER_PATH + str(1));
	System.Dictionaries.make_safe(data, DEFAULT_DECKLIST);
	var main_deck : Dictionary = fill_decklist(data.main);
	var extra_deck : Dictionary = fill_decklist(data.extra);
	var random_keywords : Array = read_random_keywords(data.random_keywords);
	var random_cards : Dictionary = read_random_cards(data.random_cards);
	return {
		"main": main_deck,
		"extra": extra_deck,
		"random_keywords": random_keywords,
		"random_cards": random_cards
	};

static func read_random_keywords(source : Array) -> Array:
	var random_keywords : Array;
	for keyword_name in source:
		random_keywords.append(CardEnums.TranslateKeyword[keyword_name]);
	return random_keywords;

static func read_random_cards(source : Dictionary) -> Dictionary:
	var random_cards : Dictionary;
	for card_type_name in source:
		random_cards[CardEnums.TranslateCardType[card_type_name]] = source[card_type_name];
	return System.Dictionaries.make_safe(random_cards, DEFAULT_RANDOM_CARDS);

static func read_level(level_id : int) -> LevelData:
	return LevelData.eat_json(System.Dictionaries.make_safe(
		System.Json.read_data(LEVEL_FOLDER_PATH + str(level_id)), DEFAULT_LEVEL
	));

static func fill_decklist(cards : Array) -> Dictionary:
	var decklist : Dictionary;
	for card in cards:
		match typeof(card):
			TYPE_DICTIONARY:
				if !decklist.has(card):
					decklist[card.id] = card.count;
				else:
					decklist[card.id] += card.count;
			TYPE_FLOAT:
				if !decklist.has(card):
					decklist[card] = 1;
				else:
					decklist[card] += 1;
	return decklist;

static func read_save_data() -> Dictionary:
	var save_data : Dictionary = System.Json.read_save(SAVE_DATA_PATH);
	if System.Json.is_error(save_data):
		write_save_data(DEFAULT_SAVE_DATA);
	return System.Dictionaries.make_safe(save_data, DEFAULT_SAVE_DATA);

static func write_save_data(data : Dictionary) -> void:
	System.Json.write_save(data, SAVE_DATA_PATH);
