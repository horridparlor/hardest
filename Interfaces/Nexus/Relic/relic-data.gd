extends Node
class_name RelicData

const DEFAULT_DATA : Dictionary = {
	
};

var id : int;
var relic_name : String;
var duration : int;
var times : int;
var effect : RelicEnums.RelicEffect;
var cards : Array;
var keywords : Array;
var target_cards : Array;
var target_keywords : Array;

static func from_json(data : Dictionary) -> RelicData:
	var relic : RelicData = RelicData.new();
	relic.eat_json(data);
	return relic;

func eat_json(data : Dictionary) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	id = data.id;
	relic_name = data.name;
	duration = data.duration;
	times = data.times;
	effect = RelicEnums.TranslateRelicEffect[data.effect];
	cards = data.cards;
	keywords = CardEnums.translate_keywords(data.keywords);
	target_cards = data.targetCards;
	target_keywords = CardEnums.translate_keywords(data.targetKeywords)

func to_json() -> Dictionary:
	return {
		"id": id,
		"name": relic_name,
		"duration": duration,
		"times": times,
		"effect": RelicEnums.TranslateRelicEffectBack[effect],
		"cards": cards,
		"keywords": CardEnums.translate_keywords_back(keywords),
		"targetCards": target_cards,
		"targetKeywords": CardEnums.translate_keywords_back(target_keywords)
	};
