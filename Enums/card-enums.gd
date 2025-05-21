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

const BasicNames : Dictionary = {
	CardType.ROCK: "a Pebble",
	CardType.PAPER: "a Scribble Paper",
	CardType.SCISSORS: "Paper Scissors",
	CardType.MIMIC: "a Lesser Mimic",
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

enum Keyword {
	NULL,
	BURIED,
	CELEBRATE,
	CHAMELEON,
	CHAMPION,
	COOTIES,
	COPYCAT,
	CURSED,
	DEVOUR,
	DIGITAL,
	DIVINE,
	EMP,
	EXTRA_SALTY,
	GREED,
	HIGH_GROUND,
	HORSE_GEAR,
	HYDRA,
	INFLUENCER,
	MULTI_SPY,
	PAIR,
	PAIR_BREAKER,
	PICK_UP,
	RAINBOW,
	RELOAD,
	RUST,
	SALTY,
	SECRETS,
	SILVER,
	SOUL_HUNTER,
	SPY,
	TIME_STOP,
	UNDEAD,
	VAMPIRE,
	WRAPPED
}

func get_hydra_keywords() -> Array:
	return [
		Keyword.BURIED,
		Keyword.CELEBRATE,
		Keyword.CHAMELEON,
		Keyword.CHAMPION,
		Keyword.COOTIES,
		Keyword.COPYCAT,
		Keyword.CURSED,
		Keyword.DEVOUR,
		Keyword.DIVINE,
		Keyword.EMP,
		Keyword.EXTRA_SALTY,
		Keyword.GREED,
		Keyword.HIGH_GROUND,
		Keyword.INFLUENCER,
		Keyword.MULTI_SPY,
		Keyword.PAIR,
		Keyword.PAIR_BREAKER,
		Keyword.RAINBOW,
		Keyword.RELOAD,
		Keyword.RUST,
		Keyword.SALTY,
		Keyword.SILVER,
		Keyword.SOUL_HUNTER,
		Keyword.SPY,
		Keyword.TIME_STOP,
		Keyword.UNDEAD,
		Keyword.VAMPIRE,
		Keyword.WRAPPED
	];

const KeywordNames : Dictionary = {
	Keyword.BURIED : "Buried",
	Keyword.CELEBRATE : "Celebrate",
	Keyword.CHAMELEON : "Chameleon",
	Keyword.CHAMPION : "Champion",
	Keyword.COOTIES : "Cooties",
	Keyword.COPYCAT : "Copycat",
	Keyword.CURSED : "Cursed",
	Keyword.DEVOUR : "Devour",
	Keyword.DIGITAL : "Digital",
	Keyword.DIVINE : "Divine",
	Keyword.EMP : "EMP",
	Keyword.EXTRA_SALTY : "Extra-salty",
	Keyword.GREED : "Greed",
	Keyword.HIGH_GROUND : "High-ground",
	Keyword.HORSE_GEAR : "Horse-gear",
	Keyword.HYDRA : "Hydra",
	Keyword.INFLUENCER : "Influencer",
	Keyword.MULTI_SPY : "Multi-spy",
	Keyword.PAIR : "Pair",
	Keyword.PAIR_BREAKER : "Pair-breaker",
	Keyword.PICK_UP : "Pick-up",
	Keyword.RAINBOW : "Rainbow",
	Keyword.RELOAD : "Reload",
	Keyword.RUST : "Rust",
	Keyword.SALTY : "Salty",
	Keyword.SECRETS : "Secrets",
	Keyword.SILVER : "Silver",
	Keyword.SOUL_HUNTER : "Soul Hunter",
	Keyword.SPY : "Spy",
	Keyword.TIME_STOP : "Time-stop",
	Keyword.UNDEAD : "Undead",
	Keyword.VAMPIRE : "Vampire",
	Keyword.WRAPPED : "Wrapped"
}

const TranslateKeyword : Dictionary = {
	"buried" : Keyword.BURIED,
	"celebrate" : Keyword.CELEBRATE,
	"chameleon" : Keyword.CHAMELEON,
	"champion" : Keyword.CHAMPION,
	"cooties" : Keyword.COOTIES,
	"copycat" : Keyword.COPYCAT,
	"cursed" : Keyword.CURSED,
	"devour" : Keyword.DEVOUR,
	"digital" : Keyword.DIGITAL,
	"divine" : Keyword.DIVINE,
	"emp" : Keyword.EMP,
	"extra-salty" : Keyword.EXTRA_SALTY,
	"greed" : Keyword.GREED,
	"high-ground" : Keyword.HIGH_GROUND,
	"horse-gear" : Keyword.HORSE_GEAR,
	"hydra" : Keyword.HYDRA,
	"influencer" : Keyword.INFLUENCER,
	"multi-spy" : Keyword.MULTI_SPY,
	"pair" : Keyword.PAIR,
	"pair-breaker" : Keyword.PAIR_BREAKER,
	"pick-up" : Keyword.PICK_UP,
	"rainbow" : Keyword.RAINBOW,
	"reload" : Keyword.RELOAD,
	"rust" : Keyword.RUST,
	"salty" : Keyword.SALTY,
	"secrets" : Keyword.SECRETS,
	"silver" : Keyword.SILVER,
	"soul-hunter" : Keyword.SOUL_HUNTER,
	"spy" : Keyword.SPY,
	"time-stop" : Keyword.TIME_STOP,
	"undead" : Keyword.UNDEAD,
	"vampire" : Keyword.VAMPIRE,
	"wrapped" : Keyword.WRAPPED
}

var KeywordHints : Dictionary = {
	Keyword.BURIED : "Played face-down.",
	Keyword.CELEBRATE : "Discard your hand, then draw 1.",
	Keyword.CHAMELEON : "Whenever opponent gets a card, changes color.",
	Keyword.CHAMPION : "Games with this card give double points.",
	Keyword.COOTIES : "Defeats any card without an effect.",
	Keyword.COPYCAT : "Copies opponent's card type.",
	Keyword.CURSED : "Cannot be replaced or destroyed.",
	Keyword.DEVOUR : "Eats the first card opponent plays.",
	Keyword.DIGITAL : "Counterspell from hand.",
	Keyword.DIVINE : "Defeats any undead.",
	Keyword.EMP : "Negates digital.",
	Keyword.EXTRA_SALTY : "If loses, lose all your points.",
	Keyword.GREED : "If loses, draw 2.",
	Keyword.HIGH_GROUND : "Automatically defeats any face-down card.",
	Keyword.HORSE_GEAR : "Starts in your opening hand.",
	Keyword.HYDRA : "Gains 3 random keywords.",
	Keyword.INFLUENCER : "Opponent's top card becomes SAME_BASIC.",
	Keyword.MULTI_SPY : "Fights up to 3 random cards in opponent's hand.",
	Keyword.PAIR : "Wins in a tie.",
	Keyword.PAIR_BREAKER : "Defeats any card with pair.",
	Keyword.PICK_UP : "End of turn, discard this card from your hand.",
	Keyword.RAINBOW : "Each card in opponent's hand becomes a random card of same type.",
	Keyword.RELOAD : "Shuffle a random gun into your deck.",
	Keyword.RUST : "Defeats any gun.",
	Keyword.SALTY : "If loses, lose a point.",
	Keyword.SECRETS : "Loses to spies and gives them 3 points.",
	Keyword.SILVER : "Defeats any werewolf.",
	Keyword.SOUL_HUNTER : "You get the cards this defeats at the start of next game.",
	Keyword.SPY : "Fights a random card in opponent's hand.",
	Keyword.TIME_STOP : "Extends your turn.",
	Keyword.UNDEAD : "Takes %s SAME_TYPES from your grave and turns into a gun." % [System.Rules.UNDEAD_LIMIT],
	Keyword.VAMPIRE : "If wins, drains the points from opponent.",
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
		translated.append(CardEnums.KeywordNames[keyword].to_lower().replace(" ", "-"));
	return translated;
