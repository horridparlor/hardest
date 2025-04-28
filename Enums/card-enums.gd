extends Node

enum CardType {
	ROCK,
	PAPER,
	SCISSORS,
	MIMIC,
	GUN
}

const CardTypeName : Dictionary = {
	CardType.ROCK: "Rock",
	CardType.PAPER: "Paper",
	CardType.SCISSORS: "Scissor",
	CardType.MIMIC: "Mimic",
	CardType.GUN: "Gun"
}

const TranslateCardType : Dictionary = {
	CardTypeName[CardType.ROCK]: CardType.ROCK,
	CardTypeName[CardType.PAPER]: CardType.PAPER,
	CardTypeName[CardType.SCISSORS]: CardType.SCISSORS,
	CardTypeName[CardType.MIMIC]: CardType.MIMIC,
	CardTypeName[CardType.GUN]: CardType.GUN
}

enum Zone {
	DECK,
	HAND,
	FIELD,
	GRAVE
}

enum Keyword {
	BURIED,
	CELEBRATION,
	CHAMPION,
	COPYCAT,
	DIVINE,
	GREED,
	HIGH_GROUND,
	INFLUENCER,
	PAIR,
	PAIR_BREAKER,
	RUST
}

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.CELEBRATION : "Celebration",
	Keyword.CHAMPION : "Champion",
	Keyword.COPYCAT : "Copycat",
	Keyword.DIVINE : "Divine",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.INFLUENCER : "Influencer",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.RUST : "Rust"
}

const KeywordTranslate : Dictionary = {
	"buried" : Keyword.BURIED,
	"celebration" : Keyword.CELEBRATION,
	"champion" : Keyword.CHAMPION,
	"copycat" : Keyword.COPYCAT,
	"divine" : Keyword.DIVINE,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"influencer" : Keyword.INFLUENCER,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"rust" : Keyword.RUST
}

const KeywordHints : Dictionary = {
	Keyword.BURIED : "Played face-down.",
	Keyword.CELEBRATION : "Shuffle your hand into deck, then draw 1.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.GREED : "If this card loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.INFLUENCER : "Opponent's top card becomes a Pebble.",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair.",
	Keyword.RUST : "Defeats any gun."
}
