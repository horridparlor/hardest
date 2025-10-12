extends Node

enum Rarity {
	COMMON,
	RARE,
	SUPER_RARE
}

enum House {
	NULL,
	CHAMPION,
	DELUSIONAL,
	DEMONIC,
	DIVINE,
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
			50,
			51,
			52,
			96,
			104,
			117,
			142,
			144,
		],
		Rarity.RARE: [
			53,
			55,
			58,
			59,
			60,
			61,
			77,
			87,
			105,
			111,
			145,
		],
		Rarity.SUPER_RARE: [
			106,
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
			102,
			122,
			124,
			135,
			137,
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
			120,
			140,
		],
		Rarity.SUPER_RARE: [
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
			43,
			56,
			68,
			72,
			82,
			83,
			147,
			148,
			149,
			151,
		],
		Rarity.RARE: [
			41,
			62,
			78,
			86,
			89,
			128,
			139,
		],
		Rarity.SUPER_RARE: [
			57,
			65,
			110,
		]
	},
	House.DIVINE: {
		Rarity.COMMON: [
			20,
			114,
			118,
			129,
			130,
			132,
			133,
			136,
			150,
		],
		Rarity.RARE: [
			115,
			121,
			125,
		],
		Rarity.SUPER_RARE: [
			116,
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
			81,
			88,
			99,
			126,
			134,
		],
		Rarity.SUPER_RARE: [
			90,
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
			138,
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
			119,
			123,
			127,
			131,
			141,
			146,
		],
		Rarity.SUPER_RARE: [
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
			122,
			132,
			133,
			136,
			144,
			147,
			151,
		],
		Rarity.RARE: [
			14,
			38,
			41,
			55,
			59,
			64,
			77,
			84,
			89,
			100,
			105,
			107,
			111,
			115,
			119,
			126,
			127,
			128,
			139,
			141,
			146,
		],
		Rarity.SUPER_RARE: [
		]
	},
	House.GOD: [
		42,
		95,
	],
}
const ONLY_PLAYER_CARDS_TO_COLLECT : Dictionary = {
	House.CHAMPION: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		],
		Rarity.SUPER_RARE: [
		]
	},
	House.DELUSIONAL: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
			112,
		],
		Rarity.SUPER_RARE: [
			108,
		]
	},
	House.DEMONIC: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		],
		Rarity.SUPER_RARE: [
			109,
			143,
		]
	},
	House.DIVINE: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		],
		Rarity.SUPER_RARE: [
		]
	},
	House.HIGHTECH: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
		],
		Rarity.SUPER_RARE: [
			107,
		]
	},
	House.KAWAII: {
		Rarity.COMMON: [
		],
		Rarity.RARE: [
			71,
		],
		Rarity.SUPER_RARE: [
		]
	},
	House.SCAM: [
		1,
		2,
		3,
		4,
		5,
		76,
	]
}

const RANDOM_CARDS : Dictionary = {
	CardEnums.CardType.ROCK: [
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
		117,
		118,
		125,
		130,
		138,
		143,
		149,
		150,
	],
	CardEnums.CardType.PAPER: [
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
		114,
		124,
		129,
		135,
		137,
		142,
		148,
	],
	CardEnums.CardType.SCISSORS: [
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
		77,
		80,
		84,
		89,
		94,
		103,
		107,
		119,
		122,
		128,
		132,
		133,
		136,
		144,
		147,
		151,
	],
	CardEnums.CardType.GUN: [
		18,
		19,
		27,
		39,
		46,
		57,
		65,
		74,
		81,
		90,
		106,
		110,
		111,
		116,
		131,
		134,
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
		91,
		120,
		123,
		140,
	],
	CardEnums.CardType.GOD: [
		42,
		95,
	],
	CardEnums.CardType.BEDROCK: [
		99,
		121,
		145,
	],
	CardEnums.CardType.ZIPPER: [
		100,
		126,
		127,
		141,
	],
	CardEnums.CardType.ROCKSTAR: [
		105,
		115,
		139,
		146,
	]
}

const RARE_RANDOM_CARDS : Dictionary = {
	CardEnums.CardType.ROCK: [
		1
	],
	CardEnums.CardType.PAPER: [
		2,
		76
	],
	CardEnums.CardType.SCISSORS: [
		3
	],
	CardEnums.CardType.GUN: [
		4
	],
	CardEnums.CardType.MIMIC: [],
	CardEnums.CardType.GOD: [],
	CardEnums.CardType.BEDROCK: [
		96
	],
	CardEnums.CardType.ZIPPER: [
		97
	],
	CardEnums.CardType.ROCKSTAR: [
		98
	]
}

static func get_random_card(card_type : CardEnums.CardType = CardEnums.CardType.NULL, avoid_id : int = 0) -> Dictionary:
	var card_id : int;
	var source : Array = RANDOM_CARDS[card_type];
	if System.Random.chance(System.Rules.RARE_RANDOM_CARD_CHANCE):
		source += RARE_RANDOM_CARDS[card_type];
	while true:
		card_id = System.Random.item(source);
		if card_id != avoid_id:
			break;
	return System.Data.read_card(card_id);

const FOIL_CARDS : Dictionary = {
	14: null,
	18: null,
	46: null,
	57: null,
	65: null,
	71: null,
	78: null,
	81: null,
	90: null,
	91: null,
	95: null,
	99: null,
	100: null,
	106: null,
	110: null,
	111: null,
	112: null,
	120: null,
	125: null,
	128: null,
	131: null,
	139: null,
	143: null,
	145: null,
	146: null
}

const NON_GUN_SHOOTING_CARDS : Dictionary = {
	77: null,
	78: null,
	121: null,
	133: null,
	139: null,
	141: null,
}

const TRIPLE_SHOOTING_CARDS : Dictionary = {
	37: null,
	78: null,
	141: null,
}

const TURRET_SHOOTING_CARDS : Dictionary = {
	134: null,
	148: null
}
