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
	COPYCAT,
	GREED,
	INFLUENCER,
	PAIR,
	PAIR_BREAKER,
	RUST
}

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.COPYCAT : "Copycat",
	Keyword.GREED : "Greed",
	Keyword.INFLUENCER : "Influencer",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.RUST : "Rust"
}

const KeywordTranslate : Dictionary = {
	"buried" : Keyword.BURIED,
	"copycat" : Keyword.COPYCAT,
	"greed" : Keyword.GREED,
	"influencer" : Keyword.INFLUENCER,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"rust" : Keyword.RUST
}

const KeywordHints : Dictionary = {
	Keyword.BURIED : "This card is played face-down.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.GREED : "If this card loses, draw 2 cards.",
	Keyword.INFLUENCER : "Top card of opponent's deck becomes a Pebble.",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair.",
	Keyword.RUST : "Defeats any gun."
}
