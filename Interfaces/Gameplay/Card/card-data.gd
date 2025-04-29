extends Node
class_name CardData

var default_type : CardEnums.CardType

var card_id : int;
var card_name : String;
var card_type : CardEnums.CardType = CardEnums.CardType.ROCK;
var keywords : Array;
var controller : Player;

var instance_id : int = System.Random.instance_id();
var zone : CardEnums.Zone = CardEnums.Zone.DECK;
var is_buried : bool;

static func eat_json(card_data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.card_id = card_data.id;
	card.card_name = card_data.name;
	card.card_type = CardEnums.TranslateCardType[card_data.type];
	card.default_type = card.card_type;
	for key in card_data.keywords:
		card.keywords.append(CardEnums.KeywordTranslate[key] if CardEnums.KeywordTranslate.has(key) else "?");
	return card;

func has_keyword(keyword : CardEnums.Keyword) -> bool:
	return keywords.has(keyword);

func has_buried() -> bool:
	return has_keyword(CardEnums.Keyword.BURIED);

func has_celebration() -> bool:
	return has_keyword(CardEnums.Keyword.CELEBRATION);

func has_champion() -> bool:
	return has_keyword(CardEnums.Keyword.CHAMPION);

func has_cooties() -> bool:
	return has_keyword(CardEnums.Keyword.COOTIES);

func has_copycat() -> bool:
	return has_keyword(CardEnums.Keyword.COPYCAT);

func has_divine() -> bool:
	return has_keyword(CardEnums.Keyword.DIVINE);
	
func has_greed() -> bool:
	return has_keyword(CardEnums.Keyword.GREED);

func has_high_ground() -> bool:
	return has_keyword(CardEnums.Keyword.HIGH_GROUND);

func has_influencer() -> bool:
	return has_keyword(CardEnums.Keyword.INFLUENCER);

func has_pair() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR);

func has_pair_breaker() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR_BREAKER);

func has_rust() -> bool:
	return has_keyword(CardEnums.Keyword.RUST);

func has_undead(needs_to_be_active : bool = false) -> bool:
	if !has_keyword(CardEnums.Keyword.UNDEAD):
		return false;
	if !needs_to_be_active:
		return true;
	return controller.count_grave_type(default_type) >= System.Rules.UNDEAD_LIMIT;

func has_vampire() -> bool:
	return has_keyword(CardEnums.Keyword.VAMPIRE);

func is_vanilla() -> bool:
	return keywords.is_empty();
