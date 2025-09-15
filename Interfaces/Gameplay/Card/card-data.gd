extends Node
class_name CardData

enum ShootingType {
	BULLETS,
	TENTACLES
}

const DEFAULT_DATA : Dictionary = {
	"id": 0,
	"spawn_id": 0,
	"name": "Name",
	"type": "mimic",
	"override_type": null,
	"keywords": [],
	"bullet": 1,
	"stamp": "null",
	"variant": "regular",
	"is_holographic": false
}

var default_type : CardEnums.CardType

var card_id : int;
var card_name : String;
var card_type : CardEnums.CardType = CardEnums.CardType.ROCK;
var card_types : Array;
var keywords : Array;
var bullet_id : int;
var stamp : CardEnums.Stamp;
var variant : CardEnums.CardVariant;
var is_holographic : bool;
var is_foil : bool;
var spawn_id : int;

var controller : Player;
var instance_id : int;
var zone : CardEnums.Zone = CardEnums.Zone.DECK;
var is_buried : bool;
var stopped_time_advantage : int = 1;
var multiply_advantage : int = 1;
var nuts : int;
var nuts_stolen : int;
var is_burned : bool;
var if_hydra_keywords : Array;

func _init() -> void:
	update_instance_id();

func update_instance_id() -> void:
	instance_id = System.Random.instance_id();

static func from_json(data : Dictionary) -> CardData:
	var card : CardData = CardData.new();
	card.eat_json(data);
	return card;

func eat_json(data : Dictionary, do_eat_spawn_json : bool = true, keep_spawn_id : bool = false) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	card_id = data.id;
	card_name = data.name;
	set_card_type(CardEnums.TranslateCardType[data.type]);
	default_type = card_type if data.override_type == null else CardEnums.TranslateCardType[data.override_type];
	keywords = [];
	for key in data.keywords:
		add_keyword(CardEnums.TranslateKeyword[key] if CardEnums.TranslateKeyword.has(key) else CardEnums.Keyword.NULL);
	add_keyword(Config.DEBUG_KEYWORD);
	bullet_id = data.bullet;
	is_foil = CollectionEnums.FOIL_CARDS.has(card_id);
	if !do_eat_spawn_json:
		return;
	eat_spawn_json(data, keep_spawn_id);

func set_card_type(type : CardEnums.CardType) -> void:
	card_type = type;
	card_types = break_card_type(type);

static func expand_type(type : CardEnums.CardType) -> Array:
	match type:
		CardEnums.CardType.ROCK:
			return [
				CardEnums.CardType.BEDROCK,
				CardEnums.CardType.ROCKSTAR
			];
		CardEnums.CardType.PAPER:
			return [
				CardEnums.CardType.BEDROCK,
				CardEnums.CardType.ZIPPER
			];
		CardEnums.CardType.SCISSORS:
			return [
				CardEnums.CardType.ZIPPER,
				CardEnums.CardType.ROCKSTAR
			];
	return [];

static func break_card_type(type : CardEnums.CardType) -> Array:
	match type:
		CardEnums.CardType.BEDROCK:
			return [
				CardEnums.CardType.ROCK,
				CardEnums.CardType.PAPER
			];
		CardEnums.CardType.ZIPPER:
			return [
				CardEnums.CardType.SCISSORS,
				CardEnums.CardType.PAPER
			];
		CardEnums.CardType.ROCKSTAR:
			return [
				CardEnums.CardType.ROCK,
				CardEnums.CardType.SCISSORS
			];
	return [type];

func eat_spawn_json(data : Dictionary, keep_spawn_id : bool = false) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	stamp = CardEnums.TranslateStamp[data.stamp];
	variant = CardEnums.TranslateVariant[data.variant];
	is_holographic = data.is_holographic;
	if keep_spawn_id:
		return;
	spawn_id = data.spawn_id;
	if spawn_id == 0:
		spawn_id = System.random.randi();

func add_keyword(keyword : CardEnums.Keyword, ignore_max_keywords : bool = false, do_add : bool = true) -> bool:
	var upgrade_to_keys : Array;
	match keyword:
		CardEnums.Keyword.BURIED:
			if stamp == CardEnums.Stamp.MOLE:
				return false;
		CardEnums.Keyword.DIGITAL:
			if stamp == CardEnums.Stamp.BLUETOOTH:
				return false;
		CardEnums.Keyword.PAIR:
			if stamp == CardEnums.Stamp.DOUBLE:
				return false;
		CardEnums.Keyword.NULL:
			return false;
		CardEnums.Keyword.ALPHA_WEREWOLF:
			upgrade_to_keys = [CardEnums.Keyword.WEREWOLF];
		CardEnums.Keyword.BURIED_ALIVE:
			upgrade_to_keys = [CardEnums.Keyword.BURIED];
		CardEnums.Keyword.DEVOW:
			upgrade_to_keys = [CardEnums.Keyword.DEVOUR];
		CardEnums.Keyword.EXTRA_SALTY:
			upgrade_to_keys = [CardEnums.Keyword.SALTY];
		CardEnums.Keyword.MULTI_SPY:
			upgrade_to_keys = [CardEnums.Keyword.SPY];
		CardEnums.Keyword.PERFECT_CLONE:
			upgrade_to_keys = [CardEnums.Keyword.CLONING];
		CardEnums.Keyword.SOUL_ROBBER:
			upgrade_to_keys = [CardEnums.Keyword.SOUL_HUNTER];
	for key in upgrade_to_keys:
		if keywords.has(key):
			keywords[keywords.find(key)] = keyword;
	if keyword == CardEnums.Keyword.NULL or (has_max_keywords() and !ignore_max_keywords) or \
	has_keyword(keyword):
		return false;
	if do_add:
		keywords.append(keyword);
	return true;

func has_keyword(keyword : CardEnums.Keyword, may_be_buried : bool = false) -> bool:
	var duplicate_keys : Array = [keyword];
	if is_buried and !may_be_buried:
		return false;
	match keyword:
		CardEnums.Keyword.BURIED:
			duplicate_keys += [CardEnums.Keyword.BURIED_ALIVE];
		CardEnums.Keyword.CLONING:
			duplicate_keys += [CardEnums.Keyword.PERFECT_CLONE];
		CardEnums.Keyword.DEVOUR:
			duplicate_keys += [CardEnums.Keyword.DEVOW];
		CardEnums.Keyword.SALTY:
			duplicate_keys += [CardEnums.Keyword.EXTRA_SALTY];
		CardEnums.Keyword.SOUL_HUNTER:
			duplicate_keys += [CardEnums.Keyword.SOUL_ROBBER];
		CardEnums.Keyword.SPY:
			duplicate_keys += [CardEnums.Keyword.MULTI_SPY];
		CardEnums.Keyword.WEREWOLF:
			duplicate_keys += [CardEnums.Keyword.ALPHA_WEREWOLF];
	for key in duplicate_keys:
		if keywords.has(key):
			return true;
	return false;

func to_json() -> Dictionary:
	return {
		"id": card_id,
		"spawn_id": spawn_id,
		"name": card_name,
		"type": CardEnums.CardTypeName[default_type].to_lower(),
		"override_type": CardEnums.CardTypeName[card_type].to_lower(),
		"keywords": get_keywords_json(),
		"bullet": bullet_id,
		"stamp": CardEnums.TranslateStampBack[stamp],
		"variant": CardEnums.TranslateVariantBack[variant],
		"is_holographic": is_holographic
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

func has_alpha_werewolf() -> bool:
	return has_keyword(CardEnums.Keyword.ALPHA_WEREWOLF);

func is_aquatic() -> bool:
	return has_ocean() or has_ocean_dweller();

func has_aura_farming() -> bool:
	return has_keyword(CardEnums.Keyword.AURA_FARMING);

func has_auto_hydra() -> bool:
	return has_keyword(CardEnums.Keyword.AUTO_HYDRA);

func has_berserk() -> bool:
	return has_keyword(CardEnums.Keyword.BERSERK);

func has_brotherhood() -> bool:
	return has_keyword(CardEnums.Keyword.BROTHERHOOD);

func has_buried() -> bool:
	return has_keyword(CardEnums.Keyword.BURIED) or stamp == CardEnums.Stamp.MOLE;

func has_buried_alive() -> bool:
	return has_keyword(CardEnums.Keyword.BURIED_ALIVE);

func has_carrot_eater() -> bool:
	return has_keyword(CardEnums.Keyword.CARROT_EATER);

func has_celebrate() -> bool:
	return has_keyword(CardEnums.Keyword.CELEBRATE);

func has_chameleon() -> bool:
	return has_keyword(CardEnums.Keyword.CHAMELEON);

func has_champion() -> bool:
	return has_keyword(CardEnums.Keyword.CHAMPION);

func has_cloning() -> bool:
	return has_keyword(CardEnums.Keyword.CLONING);

func has_coin_flip() -> bool:
	return has_keyword(CardEnums.Keyword.COIN_FLIP);

func has_contagious() -> bool:
	return has_keyword(CardEnums.Keyword.CONTAGIOUS);

func has_cooties() -> bool:
	return has_keyword(CardEnums.Keyword.COOTIES);

func has_copycat() -> bool:
	return has_keyword(CardEnums.Keyword.COPYCAT);

func has_cursed() -> bool:
	return has_keyword(CardEnums.Keyword.CURSED);

func has_devour(may_be_buried : bool = false) -> bool:
	return has_keyword(CardEnums.Keyword.DEVOUR, may_be_buried);

func has_devow(may_be_buried : bool = false) -> bool:
	return has_keyword(CardEnums.Keyword.DEVOW, may_be_buried);

func has_rare_stamp() -> bool:
	return stamp == CardEnums.Stamp.RARE;

func has_digital() -> bool:
	return has_keyword(CardEnums.Keyword.DIGITAL) or stamp == CardEnums.Stamp.BLUETOOTH;

func has_dirt() -> bool:
	return has_keyword(CardEnums.Keyword.DIRT);

func has_divine() -> bool:
	return has_keyword(CardEnums.Keyword.DIVINE);

func is_multi_type() -> bool:
	return CardEnums.is_multi_type(card_type);

func has_electrocute() -> bool:
	return has_keyword(CardEnums.Keyword.ELECTROCUTE);

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

func has_high_nut() -> bool:
	return has_keyword(CardEnums.Keyword.HIGH_NUT);

func has_hivemind() -> bool:
	return has_keyword(CardEnums.Keyword.HIVEMIND);

func has_hydra() -> bool:
	return has_keyword(CardEnums.Keyword.HYDRA);

func has_incinerate() -> bool:
	return has_keyword(CardEnums.Keyword.INCINERATE);

func has_influencer() -> bool:
	return has_keyword(CardEnums.Keyword.INFLUENCER);

func has_max_keywords() -> bool:
	return keywords.size() == System.Rules.MAX_KEYWORDS;

func has_multi_spy() -> bool:
	return has_keyword(CardEnums.Keyword.MULTI_SPY);

func has_multiply() -> bool:
	return has_keyword(CardEnums.Keyword.MULTIPLY);

func has_mushy() -> bool:
	return has_keyword(CardEnums.Keyword.MUSHY);

func has_negative() -> bool:
	return has_keyword(CardEnums.Keyword.NEGATIVE);

func is_negative_variant() -> bool:
	return variant == CardEnums.CardVariant.NEGATIVE;

func has_november() -> bool:
	return has_keyword(CardEnums.Keyword.NOVEMBER);
	
func has_nut() -> bool:
	return has_keyword(CardEnums.Keyword.NUT);

func has_nut_collector() -> bool:
	return has_keyword(CardEnums.Keyword.NUT_COLLECTOR);

func has_nut_stealer() -> bool:
	return has_keyword(CardEnums.Keyword.NUT_STEALER);

func is_nut_tied() -> bool:
	return has_nut_collector() or has_nut_stealer() or has_very_nutty() or get_max_nuts() > 0;

func has_ocean() -> bool:
	return has_keyword(CardEnums.Keyword.OCEAN);
	
func has_ocean_dweller() -> bool:
	return has_keyword(CardEnums.Keyword.OCEAN_DWELLER);

func has_pair() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR) or stamp == CardEnums.Stamp.DOUBLE;

func has_pair_breaker() -> bool:
	return has_keyword(CardEnums.Keyword.PAIR_BREAKER);

func has_perfect_clone() -> bool:
	return has_keyword(CardEnums.Keyword.PERFECT_CLONE);

func has_pick_up() -> bool:
	return has_keyword(CardEnums.Keyword.PICK_UP);

func has_positive() -> bool:
	return has_keyword(CardEnums.Keyword.POSITIVE);

func has_rainbow() -> bool:
	return has_keyword(CardEnums.Keyword.RAINBOW);

func has_reload() -> bool:
	return has_keyword(CardEnums.Keyword.RELOAD);

func has_rust() -> bool:
	return has_keyword(CardEnums.Keyword.RUST);

func has_sabotage() -> bool:
	return has_keyword(CardEnums.Keyword.SABOTAGE);

func has_salty() -> bool:
	return has_keyword(CardEnums.Keyword.SALTY);

func has_scammer() -> bool:
	return has_keyword(CardEnums.Keyword.SCAMMER);

func has_secrets() -> bool:
	return has_keyword(CardEnums.Keyword.SECRETS);

func has_shadow_replace() -> bool:
	return has_keyword(CardEnums.Keyword.SHADOW_REPLACE);

func has_shared_nut() -> bool:
	return has_keyword(CardEnums.Keyword.SHARED_NUT);

func has_silver() -> bool:
	return has_keyword(CardEnums.Keyword.SILVER);

func has_sinful() -> bool:
	return has_keyword(CardEnums.Keyword.SINFUL);

func has_skibbidy() -> bool:
	return has_keyword(CardEnums.Keyword.SKIBBIDY);

func has_soul_hunter() -> bool:
	return has_keyword(CardEnums.Keyword.SOUL_HUNTER);

func has_soul_robber() -> bool:
	return has_keyword(CardEnums.Keyword.SOUL_ROBBER);

func has_spring_arrives() -> bool:
	return has_keyword(CardEnums.Keyword.SPRING_ARRIVES);

func has_spy() -> bool:
	return has_keyword(CardEnums.Keyword.SPY);

func has_tidal() -> bool:
	return has_keyword(CardEnums.Keyword.TIDAL);

func has_time_stop() -> bool:
	return has_keyword(CardEnums.Keyword.TIME_STOP);

func has_undead(needs_to_be_active : bool = false) -> bool:
	if !has_keyword(CardEnums.Keyword.UNDEAD):
		return false;
	if !needs_to_be_active:
		return true;
	return controller.count_grave_type(default_type, instance_id) >= System.Rules.UNDEAD_LIMIT;

func has_vampire() -> bool:
	return has_keyword(CardEnums.Keyword.VAMPIRE);

func has_very_nutty() -> bool:
	return has_keyword(CardEnums.Keyword.VERY_NUTTY);

func is_vanilla() -> bool:
	return keywords.is_empty();

func has_werewolf() -> bool:
	return has_keyword(CardEnums.Keyword.WEREWOLF);

func has_wrapped() -> bool:
	return has_keyword(CardEnums.Keyword.WRAPPED);

func is_rock() -> bool:
	return card_types.has(CardEnums.CardType.ROCK);
	
func is_paper() -> bool:
	return card_types.has(CardEnums.CardType.PAPER);
	
func is_scissor() -> bool:
	return card_types.has(CardEnums.CardType.SCISSORS);

func is_gun() -> bool:
	return card_type == CardEnums.CardType.GUN;

func is_mimic() -> bool:
	return card_type == CardEnums.CardType.MIMIC;

func is_god() -> bool:
	return card_type == CardEnums.CardType.GOD;

func prevents_opponents_reveal() -> bool:
	return !is_buried and (has_high_ground() or has_high_nut() or stopped_time_advantage > 1);

func can_nut(opponent_shares_a_nut : bool = false) -> bool:
	return get_max_nuts(opponent_shares_a_nut) > 0 and nuts < max(1, get_max_nuts(opponent_shares_a_nut));

func get_max_nuts(opponent_shares_a_nut : bool = false) -> int:
	var max_nuts : int;
	if has_nut():
		max_nuts += 1;
	if has_high_nut():
		max_nuts += 1;
	if has_shared_nut():
		max_nuts += 1;
	if opponent_shares_a_nut:
		max_nuts += 1;
	return max_nuts;

func does_shoot() -> bool:
	return is_gun() or CollectionEnums.NON_GUN_SHOOTING_CARDS.has(card_id);

func shoots_wet_bullets() -> bool:
	return shoots_bullets() and CardEnums.WET_BULLETS.has(bullet_id);

func shoots_bullets() -> bool:
	return get_shooting_type() == ShootingType.BULLETS;

func shoots_tentacles() -> bool:
	return has_tidal() and !CollectionEnums.NON_GUN_SHOOTING_CARDS.has(card_id);

func get_shooting_type() -> ShootingType:
	if shoots_tentacles():
		return ShootingType.TENTACLES;
	return ShootingType.BULLETS;

func get_keywords() -> Array:
	var words : Array;
	for keyword in keywords:
		if is_negative_variant():
			words.append(give_negative_of_keyword(keyword));
		else:
			words.append(keyword);
	return words;

func give_negative_of_keyword(keyword : CardEnums.Keyword) -> CardEnums.Keyword:
	match keyword:
		CardEnums.Keyword.NEGATIVE:
			return CardEnums.Keyword.POSITIVE;
	return keyword;

func is_in_zone(target_zone : CardEnums.Zone) -> bool:
	return zone == target_zone;

func is_in_hand() -> bool:
	return is_in_zone(CardEnums.Zone.HAND);

func is_on_the_field() -> bool:
	return is_in_zone(CardEnums.Zone.FIELD);

func is_in_grave() -> bool:
	return is_in_zone(CardEnums.Zone.GRAVE);

func is_in_deck() -> bool:
	return is_in_zone(CardEnums.Zone.DECK);
