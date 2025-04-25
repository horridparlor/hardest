extends Node

enum CardType {
	ROCK,
	PAPER,
	SCISSORS,
	UNKNOWN,
	GUN
}

const CardTypeName : Dictionary = {
	CardType.ROCK: "Rock",
	CardType.PAPER: "Paper",
	CardType.SCISSORS: "Scissors",
	CardType.UNKNOWN: "Unknown",
	CardType.GUN: "Gun"
}

const TranslateCardType : Dictionary = {
	CardTypeName[CardType.ROCK]: CardType.ROCK,
	CardTypeName[CardType.PAPER]: CardType.PAPER,
	CardTypeName[CardType.SCISSORS]: CardType.SCISSORS,
	CardTypeName[CardType.UNKNOWN]: CardType.UNKNOWN,
	CardTypeName[CardType.GUN]: CardType.GUN
}

enum Zone {
	DECK,
	HAND,
	FIELD,
	GRAVE
}
