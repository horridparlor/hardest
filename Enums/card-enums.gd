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
	RUST
}

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.RUST : "Rust"
}

const KeywordTranslate : Dictionary = {
	"buried" : Keyword.BURIED,
	"rust" : Keyword.RUST
}

const KeywordHints : Dictionary = {
	Keyword.BURIED : "This card is played face-down.",
	Keyword.RUST : "Defeats any gun."
}
