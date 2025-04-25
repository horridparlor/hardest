extends Node
class_name CardData

var card_id : int;
var card_name : String;
var card_type : CardEnums.CardType = CardEnums.CardType.ROCK;

var instance_id : int = System.Random.instance_id();
var zone : CardEnums.Zone = CardEnums.Zone.DECK;

static func eat_json(card_data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.card_id = card_data.id;
	card.card_name = card_data.name;
	card.card_type = CardEnums.TranslateCardType[card_data.type];
	return card;
