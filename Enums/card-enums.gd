extends Node

enum CardType {
	NULL,
	ROCK,
	PAPER,
	SCISSORS,
	GUN,
	MIMIC,
	GOD
}

const CardTypeName : Dictionary = {
	CardType.ROCK: "Rock",
	CardType.PAPER: "Paper",
	CardType.SCISSORS: "Scissor",
	CardType.GUN: "Gun",
	CardType.MIMIC: "Mimic",
	CardType.GOD: "God"
}

const BasicIds : Dictionary = {
	CardType.ROCK: 1,
	CardType.PAPER: 2,
	CardType.SCISSORS: 3,
	CardType.GUN: 4,
	CardType.MIMIC: 5,
	CardType.GOD: 42
}

const BASIC_COLORS : Dictionary = {
	CardType.ROCK: null,
	CardType.PAPER: null,
	CardType.SCISSORS: null
}

const NUT_IDS : Array = [
	58,
	59,
	60,
	61,
	62,
	63,
	64,
	65
];

const BasicNames : Dictionary = {
	CardType.ROCK: "Pebble",
	CardType.PAPER: "Scribble Paper",
	CardType.SCISSORS: "Paper Scissors",
	CardType.MIMIC: "Lesser Mimic",
	CardType.GUN: "The Gun",
	CardType.GOD: "The Zescanor"
}

const TranslateCardType : Dictionary = {
	"rock": CardType.ROCK,
	"paper": CardType.PAPER,
	"scissor": CardType.SCISSORS,
	"gun": CardType.GUN,
	"mimic": CardType.MIMIC,
	"god": CardType.GOD
}

enum Zone {
	DECK,
	HAND,
	FIELD,
	GRAVE
}

enum CardVariant {
	REGULAR,
	NEGATIVE
}

const TranslateVariant : Dictionary = {
	"regular": CardVariant.REGULAR,
	"negative": CardVariant.NEGATIVE	
}

const TranslateVariantBack : Dictionary = {
	CardVariant.REGULAR : "regular",
	CardVariant.NEGATIVE : "negative"	
}

const VariantHints : Dictionary = {
	CardVariant.REGULAR : "Normal version",
	CardVariant.NEGATIVE : "While in hand, increases hand size by 1."
}

enum Stamp {
	NULL,
	BLUETOOTH,
	DOUBLE,
	MOLE,
	RARE
}

const TranslateStampBack : Dictionary = {
	Stamp.NULL : "null",
	Stamp.BLUETOOTH : "bluetooth",
	Stamp.DOUBLE : "double",
	Stamp.MOLE : "mole",
	Stamp.RARE : "rare"
};

const StampHints : Dictionary = {
	Stamp.BLUETOOTH : "Counterspell from hand. [i](Replaces the card.)[/i]",
	Stamp.DOUBLE : "Wins in a tie.",
	Stamp.MOLE : "Played face-down.",
	Stamp.RARE : "Scores double."
}

const TranslateStamp : Dictionary = {
	"null" : Stamp.NULL,
	"bluetooth" : Stamp.BLUETOOTH,
	"double" : Stamp.DOUBLE,
	"mole" : Stamp.MOLE,
	"rare" : Stamp.RARE
};

enum Keyword {
	NULL,
	ALPHA_WEREWOLF,
	AUTO_HYDRA,
	BURIED,
	CARROT_EATER,
	CELEBRATE,
	CHAMELEON,
	CHAMPION,
	CLONING,
	COOTIES,
	COPYCAT,
	CURSED,
	DEVOUR,
	DIGITAL,
	DIVINE,
	ELECTROCUTE,
	EMP,
	EXTRA_SALTY,
	GREED,
	HIGH_GROUND,
	HIGH_NUT,
	HORSE_GEAR,
	HYDRA,
	INFLUENCER,
	MULTI_SPY,
	MULTIPLY,
	MUSHY,
	NEGATIVE,
	NOVEMBER,
	NUT,
	NUT_COLLECTOR,
	NUT_STEALER,
	OCEAN,
	OCEAN_DWELLER,
	PAIR,
	PAIR_BREAKER,
	PERFECT_CLONE,
	PICK_UP,
	POSITIVE,
	RAINBOW,
	RELOAD,
	RUST,
	SALTY,
	SCAMMER,
	SECRETS,
	SHARED_NUT,
	SILVER,
	SOUL_HUNTER,
	SPY,
	TIDAL,
	TIME_STOP,
	UNDEAD,
	VAMPIRE,
	VERY_NUTTY,
	WEREWOLF,
	WRAPPED
}

func get_hydra_keywords() -> Array:
	return [
		Keyword.BURIED,
		Keyword.CARROT_EATER,
		Keyword.CELEBRATE,
		Keyword.CHAMELEON,
		Keyword.CHAMPION,
		Keyword.CLONING,
		Keyword.COOTIES,
		Keyword.COPYCAT,
		Keyword.CURSED,
		Keyword.DEVOUR,
		Keyword.DIVINE,
		Keyword.EMP,
		Keyword.GREED,
		Keyword.HIGH_GROUND,
		Keyword.HIGH_NUT,
		Keyword.HORSE_GEAR,
		Keyword.INFLUENCER,
		Keyword.MULTI_SPY,
		Keyword.MULTIPLY,
		Keyword.NOVEMBER,
		Keyword.NUT,
		Keyword.NUT_COLLECTOR,
		Keyword.NUT_STEALER,
		Keyword.OCEAN,
		Keyword.PAIR,
		Keyword.PAIR_BREAKER,
		Keyword.PERFECT_CLONE,
		Keyword.POSITIVE,
		Keyword.RAINBOW,
		Keyword.RELOAD,
		Keyword.RUST,
		Keyword.SHARED_NUT,
		Keyword.SILVER,
		Keyword.SOUL_HUNTER,
		Keyword.SPY,
		Keyword.TIME_STOP,
		Keyword.UNDEAD,
		Keyword.VAMPIRE,
		Keyword.VERY_NUTTY,
		Keyword.WRAPPED
	];

const KeywordNames : Dictionary = {
	Keyword.ALPHA_WEREWOLF : "Alpha-werewolf",
	Keyword.AUTO_HYDRA : "Auto-hydra",
	Keyword.BURIED : "Buried",
	Keyword.CARROT_EATER : "Carrot-eater",
	Keyword.CELEBRATE : "Celebrate",
	Keyword.CHAMELEON : "Chameleon",
	Keyword.CHAMPION : "Champion",
	Keyword.CLONING : "Cloning",
	Keyword.COOTIES : "Cooties",
	Keyword.COPYCAT : "Copycat",
	Keyword.CURSED : "Cursed",
	Keyword.DEVOUR : "Devour",
	Keyword.DIGITAL : "Digital",
	Keyword.DIVINE : "Divine",
	Keyword.ELECTROCUTE : "Electrocute",
	Keyword.EMP : "EMP",
	Keyword.EXTRA_SALTY : "Extra-salty",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.HIGH_NUT : "High-nut",
	Keyword.HORSE_GEAR : "Horse-gear",
	Keyword.HYDRA : "Hydra",
	Keyword.INFLUENCER : "Influencer",
	Keyword.MULTI_SPY : "Multi-spy",
	Keyword.MULTIPLY : "Multiply",
	Keyword.MUSHY : "Mushy",
	Keyword.NEGATIVE : "Negative",
	Keyword.NOVEMBER : "November",
	Keyword.NUT : "Nut",
	Keyword.NUT_COLLECTOR : "Nut Collector",
	Keyword.NUT_STEALER : "Nut Stealer",
	Keyword.OCEAN : "Ocean",
	Keyword.OCEAN_DWELLER : "Ocean Dweller",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.PERFECT_CLONE : "Perfect Clone",
	Keyword.PICK_UP : "Pick-up",
	Keyword.POSITIVE : "Positive",
	Keyword.RAINBOW : "Rainbow",
	Keyword.RELOAD : "Reload",
	Keyword.RUST : "Rust",
	Keyword.SALTY : "Salty",
	Keyword.SCAMMER : "Scammer",
	Keyword.SECRETS : "Secrets",
	Keyword.SHARED_NUT : "Shared Nut",
	Keyword.SILVER : "Silver",
	Keyword.SOUL_HUNTER : "Soul Hunter",
	Keyword.SPY : "Spy",
	Keyword.TIDAL : "Tidal",
	Keyword.TIME_STOP : "Time-stop",
	Keyword.UNDEAD : "Undead",
	Keyword.VAMPIRE : "Vampire",
	Keyword.VERY_NUTTY : "Very Nutty",
	Keyword.WEREWOLF : "Werewolf",
	Keyword.WRAPPED : "Wrapped"
}

const TranslateKeyword : Dictionary = {
	"alpha-werewolf" : Keyword.ALPHA_WEREWOLF,
	"auto-hydra" : Keyword.AUTO_HYDRA,
	"buried" : Keyword.BURIED,
	"carrot-eater" : Keyword.CARROT_EATER,
	"celebrate" : Keyword.CELEBRATE,
	"chameleon" : Keyword.CHAMELEON,
	"champion" : Keyword.CHAMPION,
	"cloning" : Keyword.CLONING,
	"cooties" : Keyword.COOTIES,
	"copycat" : Keyword.COPYCAT,
	"cursed" : Keyword.CURSED,
	"devour" : Keyword.DEVOUR,
	"digital" : Keyword.DIGITAL,
	"divine" : Keyword.DIVINE,
	"electrocute" : Keyword.ELECTROCUTE,
	"emp" : Keyword.EMP,
	"extra-salty" : Keyword.EXTRA_SALTY,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"high-nut" : Keyword.HIGH_NUT,
	"horse-gear" : Keyword.HORSE_GEAR,
	"hydra" : Keyword.HYDRA,
	"influencer" : Keyword.INFLUENCER,
	"multi-spy" : Keyword.MULTI_SPY,
	"multiply" : Keyword.MULTIPLY,
	"mushy" : Keyword.MUSHY,
	"negative" : Keyword.NEGATIVE,
	"november" : Keyword.NOVEMBER,
	"nut" : Keyword.NUT,
	"nut-collector" : Keyword.NUT_COLLECTOR,
	"nut-stealer" : Keyword.NUT_STEALER,
	"ocean" : Keyword.OCEAN,
	"ocean-dweller" : Keyword.OCEAN_DWELLER,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"perfect-clone" : Keyword.PERFECT_CLONE,
	"pick-up" : Keyword.PICK_UP,
	"positive" : Keyword.POSITIVE,
	"rainbow" : Keyword.RAINBOW,
	"reload" : Keyword.RELOAD,
	"rust" : Keyword.RUST,
	"salty" : Keyword.SALTY,
	"scammer" : Keyword.SCAMMER,
	"secrets" : Keyword.SECRETS,
	"shared-nut" : Keyword.SHARED_NUT,
	"silver" : Keyword.SILVER,
	"soul-hunter" : Keyword.SOUL_HUNTER,
	"spy" : Keyword.SPY,
	"tidal" : Keyword.TIDAL,
	"time-stop" : Keyword.TIME_STOP,
	"undead" : Keyword.UNDEAD,
	"vampire" : Keyword.VAMPIRE,
	"very-nutty" : Keyword.VERY_NUTTY,
	"werewolf" : Keyword.WEREWOLF,
	"wrapped" : Keyword.WRAPPED
}

const TranslateKeywordBack: Dictionary = {
	Keyword.ALPHA_WEREWOLF : "alpha-werewolf",
	Keyword.AUTO_HYDRA : "auto-hydra",
	Keyword.BURIED : "buried",
	Keyword.CARROT_EATER : "carrot-eater",
	Keyword.CELEBRATE : "celebrate",
	Keyword.CHAMELEON : "chameleon",
	Keyword.CHAMPION : "champion",
	Keyword.CLONING : "cloning",
	Keyword.COOTIES : "cooties",
	Keyword.COPYCAT : "copycat",
	Keyword.CURSED : "cursed",
	Keyword.DEVOUR : "devour",
	Keyword.DIGITAL : "digital",
	Keyword.DIVINE : "divine",
	Keyword.ELECTROCUTE : "electrocute",
	Keyword.EMP : "emp",
	Keyword.EXTRA_SALTY : "extra-salty",
	Keyword.GREED : "greed",
	Keyword.HIGH_GROUND : "high-ground",
	Keyword.HIGH_NUT : "high-nut",
	Keyword.HORSE_GEAR : "horse-gear",
	Keyword.HYDRA : "hydra",
	Keyword.INFLUENCER : "influencer",
	Keyword.MULTI_SPY : "multi-spy",
	Keyword.MULTIPLY : "multiply",
	Keyword.MUSHY : "mushy",
	Keyword.NEGATIVE : "negative",
	Keyword.NOVEMBER : "november",
	Keyword.NUT : "nut",
	Keyword.NUT_COLLECTOR : "nut-collector",
	Keyword.NUT_STEALER : "nut-stealer",
	Keyword.OCEAN : "ocean",
	Keyword.OCEAN_DWELLER : "ocean-dweller",
	Keyword.PAIR : "pair",
	Keyword.PAIR_BREAKER : "pair-breaker",
	Keyword.PERFECT_CLONE : "perfect-clone",
	Keyword.PICK_UP : "pick-up",
	Keyword.POSITIVE : "positive",
	Keyword.RAINBOW : "rainbow",
	Keyword.RELOAD : "reload",
	Keyword.RUST : "rust",
	Keyword.SALTY : "salty",
	Keyword.SCAMMER : "scammer",
	Keyword.SECRETS : "secrets",
	Keyword.SHARED_NUT : "shared-nut",
	Keyword.SILVER : "silver",
	Keyword.SOUL_HUNTER : "soul-hunter",
	Keyword.SPY : "spy",
	Keyword.TIDAL : "tidal",
	Keyword.TIME_STOP : "time-stop",
	Keyword.UNDEAD : "undead",
	Keyword.VAMPIRE : "vampire",
	Keyword.VERY_NUTTY : "very-nutty",
	Keyword.WEREWOLF : "werewolf",
	Keyword.WRAPPED : "wrapped"
}

var KeywordHints : Dictionary = {
	Keyword.ALPHA_WEREWOLF : "End of turn, werewolfs in hand become the color you played, and gain multiply.",
	Keyword.AUTO_HYDRA : "When drawn, gains 3 random keywords.",
	Keyword.BURIED : "Played face-down.",
	Keyword.CARROT_EATER : "Eats a random keyword from enemy.",
	Keyword.CELEBRATE : "Discard your hand, then draw 1.",
	Keyword.CHAMELEON : "Whenever opponent gets a card, changes color.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.CLONING : "Create a copy of a random card in your hand.",
	Keyword.COOTIES : "Defeats any card without an effect.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.CURSED : "Cannot be replaced or destroyed.",
	Keyword.DEVOUR : "Eats the first card opponent plays.",
	Keyword.DIGITAL : "Counterspell from hand. [i](Replaces the card you played.)[/i]",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.ELECTROCUTE : "Defeats any wet card.",
	Keyword.EMP : "Negates digital and bluetooth stamp",
	Keyword.EXTRA_SALTY : "If loses, lose 3 points.",
	Keyword.GREED : "If loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.HIGH_NUT : "Nuts on any face-down card.",
	Keyword.HORSE_GEAR : "Draw a horse.",
	Keyword.HYDRA : "Gains 3 random keywords.",
	Keyword.INFLUENCER : "Opponent's top card becomes SAME_BASIC.",
	Keyword.MULTI_SPY : "Fights up to 3 random cards in opponent's hand.",
	Keyword.MULTIPLY : "Double the value for each SAME_TYPE played in a row.",
	Keyword.MUSHY : "Loses to any rock.",
	Keyword.NEGATIVE : "While in hand, increases hand size by 1.",
	Keyword.NOVEMBER : "Defeats any nut.",
	Keyword.NUT : "Point for every turn since your last nut.",
	Keyword.NUT_COLLECTOR : "Shuffle 3 nuts into your deck.",
	Keyword.NUT_STEALER : "If opponent would nut, you nut twice instead.",
	Keyword.OCEAN : "[i]When wet, scissors gain rust, papers gain mushy.[/i]",
	Keyword.OCEAN_DWELLER : "If stays in hand, gain a point. [i](Also triggers if becomes wet.)[/i]",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair or a double stamp.",
	Keyword.PERFECT_CLONE : "Create a perfect copy of a random card in your hand.",
	Keyword.PICK_UP : "End of turn, discard this card from your hand.",
	Keyword.POSITIVE : "Double your points.",
	Keyword.RAINBOW : "Each card in opponent's hand becomes a random card of same type.",
	Keyword.RELOAD : "Shuffle a random gun into your deck.",
	Keyword.RUST : "Defeats any gun.",
	Keyword.SALTY : "If loses, lose a point.",
	Keyword.SCAMMER : "100 points!",
	Keyword.SECRETS : "Loses to spies and gives them 3 points.",
	Keyword.SHARED_NUT : "Both players nut.",
	Keyword.SILVER : "Defeats any werewolf.",
	Keyword.SOUL_HUNTER : "You get the cards this defeats at the start of next game.",
	Keyword.SPY : "Fights a random card in opponent's hand.",
	Keyword.TIDAL : "If wet, turns into a gun.",
	Keyword.TIME_STOP : "Extends your turn.",
	Keyword.UNDEAD : "Takes %s SAME_TYPES from your grave and turns into a gun." % [System.Rules.UNDEAD_LIMIT],
	Keyword.VAMPIRE : "If wins, drains the points from opponent.",
	Keyword.VERY_NUTTY : "Doubles your next nut.",
	Keyword.WEREWOLF : "End of turn, changes color. [i](In hand.)[/i]",
	Keyword.WRAPPED : "Next card you play, gains buried."
}

static func translate_keywords(source : Array) -> Array:
	var translated : Array;
	for keyword in source:
		translated.append(TranslateKeyword[keyword]);
	return translated;

static func translate_keywords_back(source : Array) -> Array:
	var translated : Array;
	for keyword in source:
		translated.append(TranslateKeywordBack[keyword]);
	return translated;

const WET_BULLETS : Dictionary = {
	3: null
}

const PLAY_SFX_FULLY_BULLETS : Dictionary = {
	8: null,
	18: null
}

const HORSE_CARD_IDS : Array = [
	79
]
