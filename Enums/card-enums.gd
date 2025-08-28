extends Node

enum CardType {
	NULL,
	ROCK,
	PAPER,
	SCISSORS,
	GUN,
	MIMIC,
	GOD,
	BEDROCK,
	ZIPPER,
	ROCKSTAR
}

const CardTypeName : Dictionary = {
	CardType.ROCK: "Rock",
	CardType.PAPER: "Paper",
	CardType.SCISSORS: "Scissor",
	CardType.GUN: "Gun",
	CardType.MIMIC: "Mimic",
	CardType.GOD: "God",
	CardType.BEDROCK: "Bedrock",
	CardType.ZIPPER: "Zipper",
	CardType.ROCKSTAR: "Rockstar"
}

const BasicIds : Dictionary = {
	CardType.ROCK: 1,
	CardType.PAPER: 2,
	CardType.SCISSORS: 3,
	CardType.GUN: 4,
	CardType.MIMIC: 5,
	CardType.GOD: 42,
	CardType.BEDROCK: 96,
	CardType.ZIPPER: 97,
	CardType.ROCKSTAR: 98
}

const BASIC_COLORS : Dictionary = {
	CardType.ROCK: null,
	CardType.PAPER: null,
	CardType.SCISSORS: null
}

const DUAL_COLORS : Dictionary = {
	CardType.BEDROCK: null,
	CardType.ZIPPER: null,
	CardType.ROCKSTAR: null
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
	CardType.GOD: "The Zescanor",
	CardType.BEDROCK: "Mountain",
	CardType.ZIPPER: "Loose Shirt",
	CardType.ROCKSTAR: "Pop-Star-Mic"
}

const TranslateCardType : Dictionary = {
	"rock": CardType.ROCK,
	"paper": CardType.PAPER,
	"scissor": CardType.SCISSORS,
	"gun": CardType.GUN,
	"mimic": CardType.MIMIC,
	"god": CardType.GOD,
	"bedrock": CardType.BEDROCK,
	"zipper": CardType.ZIPPER,
	"rockstar": CardType.ROCKSTAR
}

enum Zone {
	NULL,
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
	Stamp.BLUETOOTH : "Counterspell from hand. [i](Replaces your card.)[/i]",
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
	AURA_FARMING,
	AUTO_HYDRA,
	BERSERK,
	BROTHERHOOD,
	BURIED,
	CARROT_EATER,
	CELEBRATE,
	CHAMELEON,
	CHAMPION,
	CLONING,
	CONTAGIOUS,
	COOTIES,
	COPYCAT,
	CURSED,
	DEVOUR,
	DEVOW,
	DIGITAL,
	DIRT,
	DIVINE,
	ELECTROCUTE,
	EMP,
	EXTRA_SALTY,
	GREED,
	HIGH_GROUND,
	HIGH_NUT,
	HIVEMIND,
	HORSE_GEAR,
	HYDRA,
	INCINERATE,
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
	SABOTAGE,
	SALTY,
	SCAMMER,
	SECRETS,
	SHADOW_REPLACE,
	SHARED_NUT,
	SILVER,
	SINFUL,
	SKIBBIDY,
	SOUL_HUNTER,
	SPRING_ARRIVES,
	SPY,
	TIDAL,
	TIME_STOP,
	UNDEAD,
	VAMPIRE,
	VERY_NUTTY,
	WEREWOLF,
	WRAPPED
}

func get_hand_hydra_keywords() -> Array:
	return [
		Keyword.ALPHA_WEREWOLF,
		Keyword.BROTHERHOOD,
		Keyword.COOTIES,
		Keyword.DIGITAL,
		Keyword.ELECTROCUTE,
		Keyword.HIGH_GROUND,
		Keyword.HIVEMIND,
		Keyword.MULTIPLY,
		Keyword.NOVEMBER,
		Keyword.NUT_STEALER,
		Keyword.OCEAN_DWELLER,
		Keyword.PAIR_BREAKER,
		Keyword.SILVER,
		Keyword.SOUL_HUNTER,
		Keyword.VERY_NUTTY,
		Keyword.WEREWOLF
	];

func get_hydra_keywords() -> Array:
	return [
		Keyword.BERSERK,
		Keyword.BURIED,
		Keyword.CARROT_EATER,
		Keyword.CELEBRATE,
		Keyword.CHAMELEON,
		Keyword.CHAMPION,
		Keyword.CLONING,
		Keyword.CONTAGIOUS,
		Keyword.COPYCAT,
		Keyword.CURSED,
		Keyword.DEVOUR,
		Keyword.DIRT,
		Keyword.DIVINE,
		Keyword.EMP,
		Keyword.GREED,
		Keyword.HIGH_NUT,
		Keyword.HORSE_GEAR,
		Keyword.INCINERATE,
		Keyword.INFLUENCER,
		Keyword.MULTI_SPY,
		Keyword.NUT,
		Keyword.NUT_COLLECTOR,
		Keyword.OCEAN,
		Keyword.PAIR,
		Keyword.PERFECT_CLONE,
		Keyword.POSITIVE,
		Keyword.RAINBOW,
		Keyword.RELOAD,
		Keyword.RUST,
		Keyword.SABOTAGE,
		Keyword.SHARED_NUT,
		Keyword.SKIBBIDY,
		Keyword.SPY,
		Keyword.TIDAL,
		Keyword.TIME_STOP,
		Keyword.UNDEAD,
		Keyword.VAMPIRE,
		Keyword.WRAPPED
	];

func get_rare_hydra_keywords() -> Array:
	return [
		Keyword.DEVOW,
		Keyword.SPRING_ARRIVES,
	];

const KeywordNames : Dictionary = {
	Keyword.ALPHA_WEREWOLF : "Alpha-werewolf",
	Keyword.AURA_FARMING : "Aura Farming",
	Keyword.AUTO_HYDRA : "Auto-hydra",
	Keyword.BERSERK : "Berserk",
	Keyword.BROTHERHOOD : "Brotherhood",
	Keyword.BURIED : "Buried",
	Keyword.CARROT_EATER : "Carrot-eater",
	Keyword.CELEBRATE : "Celebrate",
	Keyword.CHAMELEON : "Chameleon",
	Keyword.CHAMPION : "Champion",
	Keyword.CLONING : "Cloning",
	Keyword.CONTAGIOUS : "Contagious",
	Keyword.COOTIES : "Cooties",
	Keyword.COPYCAT : "Copycat",
	Keyword.CURSED : "Cursed",
	Keyword.DEVOUR : "Devour",
	Keyword.DEVOW : "Devow",
	Keyword.DIGITAL : "Digital",
	Keyword.DIRT : "Dirt",
	Keyword.DIVINE : "Divine",
	Keyword.ELECTROCUTE : "Electrocute",
	Keyword.EMP : "EMP",
	Keyword.EXTRA_SALTY : "Extra-salty",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.HIGH_NUT : "High-nut",
	Keyword.HIVEMIND : "Hivemind",
	Keyword.HORSE_GEAR : "Horse-gear",
	Keyword.HYDRA : "Hydra",
	Keyword.INCINERATE : "Incinerate",
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
	Keyword.SABOTAGE : "Sabotage",
	Keyword.SALTY : "Salty",
	Keyword.SCAMMER : "Scammer",
	Keyword.SECRETS : "Secrets",
	Keyword.SHADOW_REPLACE : "Shadow-replace",
	Keyword.SHARED_NUT : "Shared Nut",
	Keyword.SILVER : "Silver",
	Keyword.SINFUL : "Sinful",
	Keyword.SKIBBIDY : "Skibbidy",
	Keyword.SOUL_HUNTER : "Soul Hunter",
	Keyword.SPRING_ARRIVES : "Spring Arrives",
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
	"aura-farming" : Keyword.AURA_FARMING,
	"auto-hydra" : Keyword.AUTO_HYDRA,
	"berserk" : Keyword.BERSERK,
	"brotherhood" : Keyword.BROTHERHOOD,
	"buried" : Keyword.BURIED,
	"carrot-eater" : Keyword.CARROT_EATER,
	"celebrate" : Keyword.CELEBRATE,
	"chameleon" : Keyword.CHAMELEON,
	"champion" : Keyword.CHAMPION,
	"cloning" : Keyword.CLONING,
	"contagious" : Keyword.CONTAGIOUS,
	"cooties" : Keyword.COOTIES,
	"copycat" : Keyword.COPYCAT,
	"cursed" : Keyword.CURSED,
	"devour" : Keyword.DEVOUR,
	"devow" : Keyword.DEVOW,
	"digital" : Keyword.DIGITAL,
	"dirt" : Keyword.DIRT,
	"divine" : Keyword.DIVINE,
	"electrocute" : Keyword.ELECTROCUTE,
	"emp" : Keyword.EMP,
	"extra-salty" : Keyword.EXTRA_SALTY,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"high-nut" : Keyword.HIGH_NUT,
	"hivemind" : Keyword.HIVEMIND,
	"horse-gear" : Keyword.HORSE_GEAR,
	"hydra" : Keyword.HYDRA,
	"incinerate" : Keyword.INCINERATE,
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
	"sabotage" : Keyword.SABOTAGE,
	"salty" : Keyword.SALTY,
	"scammer" : Keyword.SCAMMER,
	"secrets" : Keyword.SECRETS,
	"shadow-replace" : Keyword.SHADOW_REPLACE,
	"shared-nut" : Keyword.SHARED_NUT,
	"silver" : Keyword.SILVER,
	"sinful" : Keyword.SINFUL,
	"skibbidy" : Keyword.SKIBBIDY,
	"soul-hunter" : Keyword.SOUL_HUNTER,
	"spring-arrives" : Keyword.SPRING_ARRIVES,
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
	Keyword.AURA_FARMING : "aura-farming",
	Keyword.AUTO_HYDRA : "auto-hydra",
	Keyword.BERSERK : "berserk",
	Keyword.BROTHERHOOD : "brotherhood",
	Keyword.BURIED : "buried",
	Keyword.CARROT_EATER : "carrot-eater",
	Keyword.CELEBRATE : "celebrate",
	Keyword.CHAMELEON : "chameleon",
	Keyword.CHAMPION : "champion",
	Keyword.CLONING : "cloning",
	Keyword.CONTAGIOUS : "contagious",
	Keyword.COOTIES : "cooties",
	Keyword.COPYCAT : "copycat",
	Keyword.CURSED : "cursed",
	Keyword.DEVOUR : "devour",
	Keyword.DEVOW : "devow",
	Keyword.DIGITAL : "digital",
	Keyword.DIRT : "dirt",
	Keyword.DIVINE : "divine",
	Keyword.ELECTROCUTE : "electrocute",
	Keyword.EMP : "emp",
	Keyword.EXTRA_SALTY : "extra-salty",
	Keyword.GREED : "greed",
	Keyword.HIGH_GROUND : "high-ground",
	Keyword.HIGH_NUT : "high-nut",
	Keyword.HIVEMIND : "hivemind",
	Keyword.HORSE_GEAR : "horse-gear",
	Keyword.HYDRA : "hydra",
	Keyword.INCINERATE : "incinerate",
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
	Keyword.SABOTAGE : "sabotage",
	Keyword.SALTY : "salty",
	Keyword.SCAMMER : "scammer",
	Keyword.SECRETS : "secrets",
	Keyword.SHADOW_REPLACE : "shadow-replace",
	Keyword.SHARED_NUT : "shared-nut",
	Keyword.SILVER : "silver",
	Keyword.SINFUL : "sinful",
	Keyword.SKIBBIDY : "skibbidy",
	Keyword.SOUL_HUNTER : "soul-hunter",
	Keyword.SPRING_ARRIVES : "spring-arrives",
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
	Keyword.AURA_FARMING : "[i](Cannot be drawn unless you have played 10 SAME_TYPES in a row.)[/i]",
	Keyword.AUTO_HYDRA : "When drawn, gains 3 random keywords.",
	Keyword.BERSERK : "Fights top card of opponent's deck. If wins, repeat.",
	Keyword.BROTHERHOOD : "Double multiplier for each brotherhood member played this game.",
	Keyword.BURIED : "Played face-down.",
	Keyword.CARROT_EATER : "Eats a random keyword from enemy.",
	Keyword.CELEBRATE : "Discard your hand, then draw 1.",
	Keyword.CHAMELEON : "Whenever opponent gets a card, changes color.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.CLONING : "Create a permanent copy of a card in hand.",
	Keyword.CONTAGIOUS : "A card in hand permanently becomes a SAME_TYPE.",
	Keyword.COOTIES : "Defeats any card without an effect.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.CURSED : "Cannot be replaced or destroyed.",
	Keyword.DEVOUR : "Eats the first card opponent plays.",
	Keyword.DEVOW : "Permanently eats the first card opponent plays, and becomes a negative copy of it.",
	Keyword.DIGITAL : "Counterspell from hand. [i](Replaces your card.)[/i]",
	Keyword.DIRT : "Give a card in opponent's hand a negative multiplier. [i]Multiply by 2 for each card of the same type they have played in a row.[/i]",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.ELECTROCUTE : "Defeats any ocean card.",
	Keyword.EMP : "Negates digital and bluetooth stamp.",
	Keyword.EXTRA_SALTY : "If loses, lose 3 points.",
	Keyword.GREED : "If loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.HIGH_NUT : "Nuts on any face-down card.",
	Keyword.HIVEMIND : "If an effect would affect a card in a hand, it affects all the cards in the hand instead.",
	Keyword.HORSE_GEAR : "Draw a horse.",
	Keyword.HYDRA : "Gains 3 random keywords.",
	Keyword.INCINERATE : "Permanently destroys defeated cards.",
	Keyword.INFLUENCER : "Opponent's top card becomes SAME_BASIC.",
	Keyword.MULTI_SPY : "Fights up to 3 random cards in opponent's hand.",
	Keyword.MULTIPLY : "Double multiplier for each SAME_TYPE played in a row.",
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
	Keyword.PERFECT_CLONE : "Create a perfect copy of a card in hand.",
	Keyword.PICK_UP : "End of turn, discard this card from your hand.",
	Keyword.POSITIVE : "Double your points.",
	Keyword.RAINBOW : "Each card in opponent's hand becomes a random card of same type.",
	Keyword.RELOAD : "Shuffle a random gun into your deck.",
	Keyword.RUST : "Defeats any gun.",
	Keyword.SABOTAGE : "Destroy a random card in opponent's hand.",
	Keyword.SALTY : "If loses, lose a point.",
	Keyword.SCAMMER : "100 points!",
	Keyword.SECRETS : "Loses to spies and gives them 3 points.",
	Keyword.SHADOW_REPLACE : "Counterspell from top of deck. [i](Replaces your card.)[/i]",
	Keyword.SHARED_NUT : "Both players nut.",
	Keyword.SILVER : "Defeats any werewolf.",
	Keyword.SINFUL : "If loses, permanently destroy this card.",
	Keyword.SKIBBIDY : "Double multiplier for each card in your hand.",
	Keyword.SOUL_HUNTER : "You get the cards this defeats at the start of next game.",
	Keyword.SPRING_ARRIVES : "Fill your hand. [i]Double multiplier for each card drawn.[/i]",
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
	18: null,
	20: null,
	22: null
}

const HORSE_CARD_IDS : Array = [
	79,
	81
]
