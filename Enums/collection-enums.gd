extends Node

enum CardRarity {
	COMMON,
	RARE,
	OP_RARE,
	STUPID_OP_RARE
}

enum CollectionType {
	ROCK,
	PAPER,
	SCISSORS,
	SPECIAL
}

const RockCollection : Dictionary = {
	CardRarity.COMMON: [
		6,
		9,
		12,
		15,
		25,
		47,
		50
	],
	CardRarity.RARE: [
		23,
		31,
		35,
		43
	],
	CardRarity.OP_RARE: [
		36
	],
	CardRarity.STUPID_OP_RARE: [
		
	]
};

const PaperCollection : Dictionary = {
	CardRarity.COMMON: [
		7,
		10,
		13,
		16,
		22,
		26,
		28,
		44,
		48,
		51
	],
	CardRarity.RARE: [
		20,
		32,
		37
	],
	CardRarity.OP_RARE: [
		34
	],
	CardRarity.STUPID_OP_RARE: [
		
	]
};

const ScissorsCollection : Dictionary = {
	CardRarity.COMMON: [
		8,
		11,
		17,
		21,
		24,
		30,
		45,
		49,
		52
	],
	CardRarity.RARE: [
		14,
		29,
		33,
		38,
		41
	],
	CardRarity.OP_RARE: [
		
	],
	CardRarity.STUPID_OP_RARE: [
		
	]
};

const SpecialsCollection : Dictionary = {
	CardRarity.COMMON: [
		19,
		27,
		40
	],
	CardRarity.RARE: [
		18
	],
	CardRarity.OP_RARE: [
		39,
		42,
		46
	],
	CardRarity.STUPID_OP_RARE: [
		
	]
};

const RANDOM_CARDS : Dictionary = {
	CardEnums.CardType.ROCK: [
		1,
		6,
		9,
		12,
		15,
		23,
		25,
		31,
		35,
		36,
		43,
		47,
		50
	],
	CardEnums.CardType.PAPER: [
		2,
		7,
		10,
		13,
		16,
		20,
		22,
		26,
		28,
		32,
		34,
		37,
		44,
		48,
		51
	],
	CardEnums.CardType.SCISSORS: [
		3,
		8,
		11,
		14,
		17,
		21,
		24,
		29,
		30,
		33,
		38,
		41,
		45,
		49,
		52
	],
	CardEnums.CardType.GUN: [
		4,
		18,
		19,
		27,
		39,
		46
	],
	CardEnums.CardType.MIMIC: [
		5,
		40
	],
	CardEnums.CardType.GOD: [
		42
	]
}

static func get_random_card(card_type : CardEnums.CardType = CardEnums.CardType.NULL) -> Dictionary:
	return System.Data.read_card(System.Random.item(RANDOM_CARDS[card_type]));
