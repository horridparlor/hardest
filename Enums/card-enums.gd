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
	CardType.MIMIC: 5,
	CardType.GUN: 4
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
	NULL,
	BURIED,
	CELEBRATION,
	CHAMPION,
	COOTIES,
	COPYCAT,
	DIGITAL,
	DIVINE,
	GREED,
	HIGH_GROUND,
	HORSE_GEAR,
	INFLUENCER,
	PAIR,
	PAIR_BREAKER,
	PICK_UP,
	RUST,
	SALTY,
	UNDEAD,
	VAMPIRE,
	WRAPPED
}

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.CELEBRATION : "Celebration",
	Keyword.CHAMPION : "Champion",
	Keyword.COOTIES : "Cooties",
	Keyword.COPYCAT : "Copycat",
	Keyword.DIGITAL : "Digital",
	Keyword.DIVINE : "Divine",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.HORSE_GEAR : "Horse-gear",
	Keyword.INFLUENCER : "Influencer",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.PICK_UP : "Pick-up",
	Keyword.RUST : "Rust",
	Keyword.SALTY : "Salty",
	Keyword.UNDEAD : "Undead",
	Keyword.VAMPIRE : "Vampire",
	Keyword.WRAPPED : "Wrapped"
}

const KeywordTranslate : Dictionary = {
	"buried" : Keyword.BURIED,
	"celebration" : Keyword.CELEBRATION,
	"champion" : Keyword.CHAMPION,
	"cooties" : Keyword.COOTIES,
	"copycat" : Keyword.COPYCAT,
	"digital" : Keyword.DIGITAL,
	"divine" : Keyword.DIVINE,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"horse-gear" : Keyword.HORSE_GEAR,
	"influencer" : Keyword.INFLUENCER,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"pick-up" : Keyword.PICK_UP,
	"rust" : Keyword.RUST,
	"salty" : Keyword.SALTY,
	"undead" : Keyword.UNDEAD,
	"vampire" : Keyword.VAMPIRE,
	"wrapped" : Keyword.WRAPPED
}

var KeywordHints : Dictionary = {
	Keyword.BURIED : "Played face-down.",
	Keyword.CELEBRATION : "Shuffle your hand into deck, then draw 1.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.COOTIES : "Defeats any card without an effect.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.DIGITAL : "If you would not win: If better, this card from hand replaces the card you played.",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.GREED : "If loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.HORSE_GEAR : "Starts in your opening hand.",
	Keyword.INFLUENCER : "Opponent's top card becomes SAME_BASIC.",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair.",
	Keyword.PICK_UP : "End of turn, discard this card from your hand.",
	Keyword.RUST : "Defeats any gun.",
	Keyword.SALTY : "If loses, lose a point.",
	Keyword.UNDEAD : "While you have %s SAME_TYPES in your grave, turns into a gun: If wins, purge the 3 SAME_TYPES from your grave." % [System.Rules.UNDEAD_LIMIT],
	Keyword.VAMPIRE : "If wins, drains the point from opponent.",
	Keyword.WRAPPED : "Next card you play, gains buried."
}
