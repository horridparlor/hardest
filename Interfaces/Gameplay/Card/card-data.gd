extends Node
class_name CardData

var default_type : CardEnums.CardType

var card_id : int;
var card_name : String;
var card_type : CardEnums.CardType = CardEnums.CardType.ROCK;
var keywords : Array;
var bullet_id : int;

var controller : Player;
var instance_id : int;
var zone : CardEnums.Zone = CardEnums.Zone.DECK;
var is_buried : bool;

func _init() -> void:
	instance_id = System.Random.instance_id();

static func from_json(data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.eat_json(data);
	return card;

func eat_json(data : Dictionary) -> void:
	card_id = data.id;
	card_name = data.name;
	card_type = CardEnums.TranslateCardType[data.type];
	default_type = CardEnums.TranslateCardType[data.override_type];
	keywords = [];
	for key in data.keywords:
		add_keyword(CardEnums.TranslateKeyword[key] if CardEnums.TranslateKeyword.has(key) else "?");
	bullet_id = data.bullet;

func add_keyword(keyword : CardEnums.Keyword) -> bool:
	var upgrade_to_keys : Array;
	match keyword:
		CardEnums.Keyword.MULTI_SPY:
			upgrade_to_keys = [CardEnums.Keyword.SPY];
	for key in upgrade_to_keys:
		if keywords.has(key):
			keywords[keywords.find(key)] = keyword;
	if keyword == CardEnums.Keyword.NULL or keywords.size() == System.Rules.MAX_KEYWORDS or \
	has_keyword(keyword):
		return false;
	keywords.append(keyword);
	return true;

func has_keyword(keyword : CardEnums.Keyword) -> bool:
	var duplicate_keys : Array = [keyword];
	match keyword:
		CardEnums.Keyword.SPY:
			duplicate_keys += [CardEnums.Keyword.MULTI_SPY];
	for key in duplicate_keys:
		if keywords.has(key):
			return true;
	return false;

func to_json() -> Dictionary:
	return {
		"id": card_id,
		"name": card_name,
		"type": CardEnums.CardTypeName[default_type].to_lower(),
		"override_type": CardEnums.CardTypeName[card_type].to_lower(),
		"keywords": get_keywords_json(),
		"bullet": bullet_id
	};

func get_keywords_json() -> Array:
	var source : Array;
	for keyword in keywords:
		source.append(CardEnums.KeywordNames[keyword].to_lower().replace(" ", "-"));
	return source;

func clone() -> CardData:
	var card_data : CardData = CardData.new();
	card_data.eat_json(to_json());
	card_data.controller = controller;
	return card_data;

func has_buried() -> bool:
	return has_keyword(CardEnums.Keyword.BURIED);

func has_celebrate() -> bool:
	return has_keyword(CardEnums.Keyword.CELEBRATE);

func has_chameleon() -> bool:
	return has_keyword(CardEnums.Keyword.CHAMELEON);

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
	
func has_emp() -> bool:
	return has_keyword(CardEnums.Keyword.EMP);

func has_extra_salty() -> bool:
	return has_keyword(CardEnums.Keyword.EXTRA_SALTY);

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

func has_multi_spy() -> bool:
	return has_keyword(CardEnums.Keyword.MULTI_SPY);

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

func has_secrets() -> bool:
	return has_keyword(CardEnums.Keyword.SECRETS);

func has_silver() -> bool:
	return has_keyword(CardEnums.Keyword.SILVER);

func has_soul_hunter() -> bool:
	return has_keyword(CardEnums.Keyword.SOUL_HUNTER);

func has_spy() -> bool:
	return has_keyword(CardEnums.Keyword.SPY);

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

func is_gun() -> bool:
	return card_type == CardEnums.CardType.GUN;
