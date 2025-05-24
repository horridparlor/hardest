extends Node
class_name EventData

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"name": "",
	"type": "null",
	"multiplier": 1,
	"keyword": "null",
	"card": 1
};

var id : int;
var event_name : String;
var type : EventEnums.EventType;
var multiplier : int;
var keyword : CardEnums.Keyword;
var card_id : int

static func from_json(data : Dictionary) -> EventData:
	var event : EventData = EventData.new();
	event.eat_json(data);
	return event;

func eat_json(data : Dictionary) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	id = data.id;
	event_name = data.name;
	type = EventEnums.TranslateEventType[data.event];
	multiplier = data.multiplier;
	keyword = CardEnums.TranslateKeyword[data.keyword];
	card_id = data.card;

func to_json() -> Dictionary:
	return {
		"id": id,
		"name": event_name,
		"type": EventEnums.TranslateEventTypeBack[type],
		"multiplier": multiplier,
		"keyword": CardEnums.TranslateKeywordBack[keyword],
		"card": card_id
	};
