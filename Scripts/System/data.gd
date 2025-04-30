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

const DEFAULT_DECKLIST : Dictionary = {
	"id": 0,
	"main": [],
	"extra": []
}

const DEFAULT_LEVEL : Dictionary = {
	"id": 0,
	"opponent": GameplayEnums.Character.PETE,
	"deck": 1,
	"deck2": 1
}

const DEFAULT_SAVE_DATA : Dictionary = {
	"levels_unlocked": 1
};

static func read_card(card_id : int, player : Player = null) -> CardData:
	var card : CardData = CardData.from_json(System.Dictionaries.make_safe(
		System.Json.read_data(CARDS_FOLDER_PATH + str(card_id)), DEFAULT_CARD
	));
	card.controller = player;
	return card;

static func get_basic_card(card_type : CardEnums.CardType, player : Player = null) -> CardData:
	return read_card(CardEnums.BasicIds[card_type], player);

static func read_decklist(decklist_id : int) -> Dictionary:
	var data : Dictionary = System.Json.read_data(DECKLIST_FOLDER_PATH + str(decklist_id));
	System.Dictionaries.make_safe(data, DEFAULT_DECKLIST);
	var main_deck : Dictionary = fill_decklist(data.main);
	var extra_deck : Dictionary = fill_decklist(data.extra);
	return {
		"main": main_deck,
		"extra": extra_deck
	};

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
