extends Node
class_name CardSoulBank

var character_id : GameplayEnums.Character;
var controller : GameplayEnums.Controller;
var card_souls : Array;

func _init(character_id_ : GameplayEnums.Character, controller_ : GameplayEnums.Controller) -> void:
	character_id = character_id_;
	controller = controller_;

func add_card(card : CardData) -> void:
	card_souls.append(card);

func pull_cards(amount : int = System.Rules.MAX_HAND_SIZE - System.Rules.HAND_SIZE) -> Array:
	var cards : Array;
	var card : CardData;
	for i in range(amount):
		if card_souls.is_empty():
			break;
		card = card_souls[0];
		cards.append(card);
		card_souls.erase(card);
	return cards;

func to_json() -> Dictionary:
	return {
		"character_id": character_id,
		"controller": controller,
		"card_souls": get_card_souls_json()
	};

func save() -> void:
	System.Data.save_soul_bank(self);

static func from_json(json : Dictionary) -> CardSoulBank:
	var soul_bank : CardSoulBank;
	json = System.Dictionaries.make_safe(json, {
		"controller": GameplayEnums.Controller.PLAYER_TWO
	});
	soul_bank = CardSoulBank.new(json.character_id, json.controller);
	for card in json.card_souls:
		soul_bank.card_souls.append(CardData.from_json(card));
	return soul_bank;
	
func get_card_souls_json() -> Array:
	var souls : Array;
	for card in card_souls:
		souls.append(card.to_json());
	return souls;
