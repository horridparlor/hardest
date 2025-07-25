extends Node

enum Rarity {
	COMMON,
	RARE
}

enum House {
	NULL,
	CHAMPION,
	DELUSIONAL,
	DEMONIC,
	HIGHTECH,
	KAWAII,
	GOD,
	SCAM,
	SCISSOR
}

const CARDS_TO_COLLECT : Dictionary = {
	House.CHAMPION: {
		Rarity.COMMON: [
			15,
			16,
			17,
			20,
			50,
			51,
			52,
			96,
			104,
		],
		Rarity.RARE: [
			55,
			58,
			59,
			60,
			61,
			77,
			87,
			105,
			106,
			111,
		]
	},
	House.DELUSIONAL: {
		Rarity.COMMON: [
			6,
			7,
			8,
			13,
			40,
			70,
			92,
			93,
			94,
			97,
			101,
			102
		],
		Rarity.RARE: [
			14,
			19,
			54,
			63,
			64,
			66,
			79,
			100,
		]
	},
	House.DEMONIC: {
		Rarity.COMMON: [
			23,
			24,
			25,
			26,
			29,
			37,
			56,
			68,
			72,
			82,
			83,
		],
		Rarity.RARE: [
			41,
			43,
			57,
			62,
			65,
			78,
			86,
			89,
		]
	},
	House.HIGHTECH: {
		Rarity.COMMON: [
			12,
			31,
			32,
			33,
			34,
			36,
			47,
			48,
			49,
			80,
			103,
		],
		Rarity.RARE: [
			27,
			39,
			46,
			53,
			81,
			88,
			90,
			99,
		]
	},
	House.KAWAII: {
		Rarity.COMMON: [
			9,
			10,
			11,
			21,
			22,
			28,
			30,
			38,
			44,
			45,
			69,
			73,
			98,
			113,
		],
		Rarity.RARE: [
			18,
			35,
			67,
			74,
			75,
			84,
			85,
			91,
		]
	},
	House.SCISSOR: {
		Rarity.COMMON: [
			3,
			8,
			11,
			17,
			21,
			24,
			29,
			30,
			33,
			52,
			56,
			73,
			80,
			94,
			97,
			98,
			103,
		],
		Rarity.RARE: [
			14,
			38,
			41,
			55,
			59,
			64,
			84,
			89,
			100,
			105,
			107,
			111,
		]
	},
	House.GOD: [
		42,
		95,
		110,
	],
}
const ONLY_PLAYER_CARDS_TO_COLLECT : Dictionary = {
	House.CHAMPION: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		]
	},
	House.DELUSIONAL: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
			112,
		]
	},
	House.DEMONIC: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		]
	},
	House.HIGHTECH: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		]
	},
	House.KAWAII: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
			71,
		]
	},
	House.SCAM: [
		1,
		2,
		3,
		4,
		5,
		76,
		107,
		108,
		109,
	]
}

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
		50,
		53,
		60,
		62,
		68,
		71,
		82,
		85,
		87,
		92,
		101,
		104,
		109,
		112,
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
		51,
		54,
		58,
		63,
		69,
		72,
		78,
		83,
		88,
		93,
		102,
		108,
		113,
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
		52,
		55,
		56,
		59,
		64,
		70,
		73,
		80,
		84,
		89,
		94,
		103,
		107,
	],
	CardEnums.CardType.GUN: [
		4,
		18,
		19,
		27,
		39,
		46,
		57,
		65,
		74,
		77,
		81,
		90,
		106,
		110,
		111,
	],
	CardEnums.CardType.MIMIC: [
		5,
		40,
		61,
		66,
		67,
		75,
		79,
		86,
		91
	],
	CardEnums.CardType.GOD: [
		42,
		95,
	],
	CardEnums.CardType.BEDROCK: [
		96,
		99,
	],
	CardEnums.CardType.ZIPPER: [
		97,
		100,
	],
	CardEnums.CardType.ROCKSTAR: [
		98,
		105,
	]
}

static func get_random_card(card_type : CardEnums.CardType = CardEnums.CardType.NULL) -> Dictionary:
	return System.Data.read_card(System.Random.item(RANDOM_CARDS[card_type]));

const FOIL_CARDS : Dictionary = {
	14: null,
	18: null,
	46: null,
	57: null,
	65: null,
	71: null,
	77: null,
	78: null,
	81: null,
	85: null,
	90: null,
	91: null,
	95: null,
	99: null,
	100: null,
	106: null,
	110: null,
	111: null,
	112: null
}

const NON_GUN_SHOOTING_CARDS : Dictionary = {
	78: null,
	111: null,
}

const TRIPLE_SHOOTING_CARDS : Dictionary = {
	37: null,
	78: null
}
