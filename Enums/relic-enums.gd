extends Node

enum RelicEffect {
	GIVE_KEYWORD,
	START_WITH,
	TURN_GUN
}

const TranslateRelicEffect : Dictionary = {
	"giveKeyword": RelicEffect.GIVE_KEYWORD,
	"startWith": RelicEffect.START_WITH,
	"turnGun": RelicEffect.TURN_GUN
};

const TranslateRelicEffectBack : Dictionary = {
	RelicEffect.GIVE_KEYWORD: "giveKeyword",
	RelicEffect.START_WITH: "startWith",
	RelicEffect.TURN_GUN: "turnGun"
}
