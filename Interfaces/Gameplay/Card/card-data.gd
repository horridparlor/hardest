extends Node
class_name CardData

var card_id : int;
var card_name : String;
var card_type : CardEnums.CardType = CardEnums.CardType.ROCK;
var keywords : Array;

var instance_id : int = System.Random.instance_id();
var zone : CardEnums.Zone = CardEnums.Zone.DECK;
var is_buried : bool;

static func eat_json(card_data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.card_id = card_data.id;
	card.card_name = card_data.name;
	card.card_type = CardEnums.TranslateCardType[card_data.type];
	for key in card_data.keywords:
		card.keywords.append(CardEnums.KeywordTranslate[key] if CardEnums.KeywordTranslate.has(key) else "?");
	return card;

func has_keyword(keyword : CardEnums.Keyword) -> bool:
	return keywords.has(keyword);

func has_buried() -> bool:
	return has_keyword(CardEnums.Keyword.BURIED);

func has_copycat() -> bool:
	return has_keyword(CardEnums.Keyword.COPYCAT);
	
func has_greed() -> bool:
	return has_keyword(CardEnums.Keyword.GREED);

func has_influencer() -> bool:
	return has_keyword(CardEnums.Keyword.INFLUENCER);

func has_pair() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR);

func has_pair_breaker() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR_BREAKER);

func has_rust() -> bool:
	return has_keyword(CardEnums.Keyword.RUST);
