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

const BasicIds : Dictionary = {
	CardType.ROCK: 1,
	CardType.PAPER: 2,
	CardType.SCISSORS: 3,
	CardType.MIMIC: 4,
	CardType.GUN: 5
}

const BasicNames : Dictionary = {
	CardType.ROCK: "a Pebble",
	CardType.PAPER: "a Scribble Paper",
	CardType.SCISSORS: "Paper Scissors",
	CardType.MIMIC: "a Lesser Mimic",
	CardType.GUN: "The Gun"
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
	COOTIES,
	COPYCAT,
	DIVINE,
	GREED,
	HIGH_GROUND,
	INFLUENCER,
	PAIR,
	PAIR_BREAKER,
	RUST,
	UNDEAD
}

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.CELEBRATION : "Celebration",
	Keyword.CHAMPION : "Champion",
	Keyword.COOTIES : "Cooties",
	Keyword.COPYCAT : "Copycat",
	Keyword.DIVINE : "Divine",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.INFLUENCER : "Influencer",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.RUST : "Rust",
	Keyword.UNDEAD : "Undead"
}

const KeywordTranslate : Dictionary = {
	"buried" : Keyword.BURIED,
	"celebration" : Keyword.CELEBRATION,
	"champion" : Keyword.CHAMPION,
	"cooties" : Keyword.COOTIES,
	"copycat" : Keyword.COPYCAT,
	"divine" : Keyword.DIVINE,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"influencer" : Keyword.INFLUENCER,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"rust" : Keyword.RUST,
	"undead" : Keyword.UNDEAD
}

var KeywordHints : Dictionary = {
	Keyword.BURIED : "Played face-down.",
	Keyword.CELEBRATION : "Shuffle your hand into deck, then draw 1.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.COOTIES : "Defeats any card without an effect.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.GREED : "If loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.INFLUENCER : "Opponent's top card becomes SAME_BASIC.",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair.",
	Keyword.RUST : "Defeats any gun.",
	Keyword.UNDEAD : "While you have %s SAME_TYPES in your grave, turns into a gun; if wins, purge the SAME_TYPES." % [System.Rules.UNDEAD_LIMIT]
}
