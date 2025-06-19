extends Node

enum Rarity {
	COMMON,
	RARE
}

enum House {
	CHAMPION,
	DELUSIONAL,
	DEMONIC,
	HIGHTECH,
	KAWAII,
	GOD,
	SCAM
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
		],
		Rarity.RARE: [
			55,
			58,
			59,
			60,
			61,
			77,
			87,
		]
	},
	House.DELUSIONAL: {
		Rarity.COMMON: [
			6,
			7,
			8,
			13,
			28,
			70,
			92,
			93,
			94,
		],
		Rarity.RARE: [
			14,
			19,
			40,
			54,
			63,
			64,
			66,
			79,
		]
	},
	House.DEMONIC: {
		Rarity.COMMON: [
			23,
			24,
			25,
			26,
			29,
			56,
			68,
			72,
			82,
		],
		Rarity.RARE: [
			37,
			41,
			43,
			57,
			62,
			65,
			78,
			83,
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
		],
		Rarity.RARE: [
			27,
			39,
			46,
			53,
			81,
			88,
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
			30,
			44,
			45,
			69,
			73,
		],
		Rarity.RARE: [
			18,
			35,
			38,
			67,
			74,
			75,
			84,
			85,
			91,
		]
	},
	House.GOD: [
		42,
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
		92
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
		93
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
		94
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
		90
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
		42
	]
}

static func get_random_card(card_type : CardEnums.CardType = CardEnums.CardType.NULL) -> Dictionary:
	return System.Data.read_card(System.Random.item(RANDOM_CARDS[card_type]));

const FOIL_CARDS : Dictionary = {
	14: null,
	18: null,
	42: null,
	46: null,
	57: null,
	65: null,
	71: null,
	77: null,
	78: null,
	81: null,
	85: null,
	90: null,
	91: null
}

const NON_GUN_SHOOTING_CARDS : Dictionary = {
	78: null
}

const TRIPLE_SHOOTING_CARDS : Dictionary = {
	37: null,
	78: null
}
