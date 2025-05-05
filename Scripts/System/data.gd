const CARDS_FOLDER_PATH : String = "Cards/";
const DECKLIST_FOLDER_PATH : String = "Decklists/";
const LEVEL_FOLDER_PATH : String = "Levels/";
const SAVE_DATA_PATH : String = "save-data";
const SOUL_BANKS_SAVE_PATH : String = "card-souls/";

const DEFAULT_CARD : Dictionary = {
	"id": 0,
	"name": "Name",
	"type": "Mimic",
	"override_type": null,
	"keywords": []
}

const DEFAULT_RANDOM_KEYWORDS : Array = [
	"buried",
	"celebration",
	"champion",
	"cooties",
	"copycat",
	"cursed",
	"devour",
	"digital",
	"divine",
	"greed",
	"high-ground",
	"horse-gear",
	"hydra",
	"influencer",
	"pair",
	"pair-breaker",
	"pick-up",
	"rainbow",
	"reload",
	"rust",
	"salty",
	"silver",
	"soul-hunter",
	"undead",
	"vampire",
	"wrapped"
]

const DEFAULT_RANDOM_CARDS : Dictionary = {
	"rock": [
		1,
		6,
		9,
		12,
		15,
		23,
		25,
		31,
		35,
		36
	],
	"paper": [
		2,
		7,
		10,
		13,
		16,
		20,
		22,
		26,
		28,
		32,
		34,
		37
	],
	"scissor": [
		3,
		8,
		11,
		14,
		17,
		21,
		24,
		29,
		30,
		33,
		38,
		41
	],
	"gun": [
		4,
		18,
		19,
		27,
		39
	],
	"mimic": [
		5,
		40
	],
	"god": [
		42
	]
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
	"player": "Peitse",
	"opponent": "Peitse",
	"deck": 1,
	"deck2": 1
}

const DEFAULT_SAVE_DATA : Dictionary = {
	"levels_unlocked": 0
};

static func read_card(card_id : int) -> Dictionary:
	var data : Dictionary = System.Dictionaries.make_safe(
		System.Json.read_data(CARDS_FOLDER_PATH + str(card_id)), DEFAULT_CARD
	);
	if data.override_type == null:
		data.override_type = data.type;
	return data;

static func load_card(card_id : int) -> CardData:
	return CardData.from_json(read_card(card_id));

static func get_basic_card(card_type : CardEnums.CardType) -> CardData:
	return CardData.from_json(read_card(CardEnums.BasicIds[card_type]));

static func read_decklist(decklist_id : int) -> Decklist:
	var data : Dictionary = System.Json.read_data(DECKLIST_FOLDER_PATH + str(decklist_id));
	if System.Json.is_error(data):
		data = System.Json.read_data(DECKLIST_FOLDER_PATH + str(1));
	System.Dictionaries.make_safe(data, DEFAULT_DECKLIST);
	var main_deck : Dictionary = fill_decklist(data.main);
	var extra_deck : Dictionary = fill_decklist(data.extra);
	var random_keywords : Array = read_random_keywords(data.random_keywords);
	var random_cards : Dictionary = read_random_cards(data.random_cards);
	return Decklist.new(main_deck, extra_deck, random_keywords, random_cards);

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

static func add_card_soul_to_character(character_id : GameplayEnums.Character, card : CardData) -> void:
	var soul_bank : CardSoulBank = get_soul_bank(character_id);
	soul_bank.add_card(card);
	soul_bank.save();

static func get_soul_bank(character_id : GameplayEnums.Character) -> CardSoulBank:
	var soul_bank : CardSoulBank;
	var json : Dictionary = System.Json.read_save(SOUL_BANKS_SAVE_PATH + str(character_id));
	if System.Json.is_error(json):
		soul_bank = CardSoulBank.new(character_id);
	else:
		soul_bank = CardSoulBank.from_json(json);
	return soul_bank;

static func load_card_souls_for_character(character_id : int,
	amount : int = System.Rules.MAX_HAND_SIZE - System.Rules.HAND_SIZE
) -> Array:
	var soul_bank : CardSoulBank = get_soul_bank(character_id);
	var card_souls : Array = soul_bank.pull_cards(amount);
	soul_bank.save();
	return card_souls;

static func save_soul_bank(soul_bank : CardSoulBank) -> void:
	System.Json.write_save(soul_bank.to_json(), SOUL_BANKS_SAVE_PATH + str(soul_bank.character_id));
	print(222);
