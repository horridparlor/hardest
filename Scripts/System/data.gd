const CARDS_FOLDER_PATH : String = "Cards/";
const DECKLIST_FOLDER_PATH : String = "Decklists/";

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

static func read_card(card_id : int) -> Dictionary:
	return System.Dictionaries.make_safe(
		System.Json.read_data(CARDS_FOLDER_PATH + str(card_id)), DEFAULT_CARD
	);

static func read_decklist(decklist_id : int) -> Dictionary:
	var data : Dictionary = System.Json.read_data(DECKLIST_FOLDER_PATH + str(decklist_id));
	System.Dictionaries.make_safe(data, DEFAULT_DECKLIST);
	var main_deck : Dictionary = fill_decklist(data.main);
	var extra_deck : Dictionary = fill_decklist(data.extra);
	return {
		"main": main_deck,
		"extra": extra_deck
	};

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
