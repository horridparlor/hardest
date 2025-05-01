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

static func from_json(data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.eat_json(data);
	return card;

func eat_json(data : Dictionary) -> void:
	var card_type_ : CardEnums.CardType = CardEnums.TranslateCardType[data.type];
	card_id = data.id;
	card_name = data.name;
	card_type = card_type_;
	default_type = card_type_;
	keywords = [];
	for key in data.keywords:
		keywords.append(CardEnums.KeywordTranslate[key] if CardEnums.KeywordTranslate.has(key) else "?");

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

func has_cursed() -> bool:
	return has_keyword(CardEnums.Keyword.CURSED);

func has_devour() -> bool:
	return has_keyword(CardEnums.Keyword.DEVOUR);

func has_digital() -> bool:
	return has_keyword(CardEnums.Keyword.DIGITAL);

func has_divine() -> bool:
	return has_keyword(CardEnums.Keyword.DIVINE);
	
func has_greed() -> bool:
	return has_keyword(CardEnums.Keyword.GREED);

func has_horse_gear() -> bool:
	return has_keyword(CardEnums.Keyword.HORSE_GEAR);

func has_high_ground() -> bool:
	return has_keyword(CardEnums.Keyword.HIGH_GROUND);

func has_hydra() -> bool:
	return has_keyword(CardEnums.Keyword.HYDRA);

func has_influencer() -> bool:
	return has_keyword(CardEnums.Keyword.INFLUENCER);

func has_pair() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR);

func has_pair_breaker() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR_BREAKER);

func has_pick_up() -> bool:
	return has_keyword(CardEnums.Keyword.PICK_UP);

func has_rainbow() -> bool:
	return has_keyword(CardEnums.Keyword.RAINBOW);

func has_reload() -> bool:
	return has_keyword(CardEnums.Keyword.RELOAD);

func has_rust() -> bool:
	return has_keyword(CardEnums.Keyword.RUST);

func has_salty() -> bool:
	return has_keyword(CardEnums.Keyword.SALTY);

func has_silver() -> bool:
	return has_keyword(CardEnums.Keyword.SILVER);

func has_soul_hunter() -> bool:
	return has_keyword(CardEnums.Keyword.SOUL_HUNTER);

func has_undead(needs_to_be_active : bool = false) -> bool:
	if !has_keyword(CardEnums.Keyword.UNDEAD):
		return false;
	if !needs_to_be_active:
		return true;
	return controller.count_grave_type(default_type, instance_id) >= System.Rules.UNDEAD_LIMIT;

func has_vampire() -> bool:
	return has_keyword(CardEnums.Keyword.VAMPIRE);

func is_vanilla() -> bool:
	return keywords.is_empty();

func has_wrapped() -> bool:
	return has_keyword(CardEnums.Keyword.WRAPPED);
