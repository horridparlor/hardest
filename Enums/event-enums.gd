extends Node

enum EventType {
	NULL,
	ADD_CARD,
	GET_KEYWORD,
	LOSE_KEYWORDS,
	MULTIPLY_BULLETS,
	STOP_TIME,
	WINNIE
}

const TranslateEventType : Dictionary = {
	"null": EventType.NULL,
	"addCard": EventType.ADD_CARD,
	"getKeyword": EventType.GET_KEYWORD,
	"loseKeywords": EventType.LOSE_KEYWORDS,
	"multiplyBullets": EventType.MULTIPLY_BULLETS,
	"stopTime": EventType.STOP_TIME,
	"winnie": EventType.WINNIE
}

const TranslateEventTypeBack : Dictionary = {
	EventType.NULL: "null",
	EventType.ADD_CARD: "addCard",
	EventType.GET_KEYWORD: "getKeyword",
	EventType.LOSE_KEYWORDS: "loseKeywords",
	EventType.MULTIPLY_BULLETS: "multiplyBullets",
	EventType.STOP_TIME: "stopTime",
	EventType.WINNIE: "winnie"
}
