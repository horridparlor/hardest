extends Node

enum GlowState {
	GLOW,
	SHUTTER
}

enum Controller {
	PLAYER_ONE,
	PLAYER_TWO,
	NULL,
	UNDEFINED
}

func flip_player(controller : Controller) -> Controller:
	match controller:
		Controller.PLAYER_ONE:
			return Controller.PLAYER_TWO;
		Controller.PLAYER_TWO:
			return Controller.PLAYER_ONE;
	return controller;

enum Character {
	NULL,
	AGENT,
	ERIKA,
	JUKULIUS,
	KORVEK,
	LOTTE,
	LOTTE_ANT_QUEEN,
	MARK,
	MERITUULI,
	PEITSE,
	PETE,
	PETE_BADASS,
	RAISEN,
	SIMOONI,
	SISTERS,
	SWARMYARD
}

const TranslateCharacter : Dictionary = {
	"Agent": Character.AGENT,
	"AntQueen": Character.LOTTE_ANT_QUEEN,
	"Badass": Character.PETE_BADASS,
	"Erika": Character.ERIKA,
	"Jukulius": Character.JUKULIUS,
	"Korvek": Character.KORVEK,
	"Lotte": Character.LOTTE,
	"Mark": Character.MARK,
	"Merituuli": Character.MERITUULI,
	"Peitse": Character.PEITSE,
	"Pete": Character.PETE,
	"Raisen": Character.RAISEN,
	"Simooni": Character.SIMOONI,
	"Sisters": Character.SISTERS,
	"Swarmyard": Character.SWARMYARD
}

const TranslateCharacterBack : Dictionary = {
	Character.AGENT: "Agent",
	Character.ERIKA: "Erika",
	Character.JUKULIUS: "Jukulius",
	Character.KORVEK: "Korvek",
	Character.LOTTE: "Lotte",
	Character.LOTTE_ANT_QUEEN: "AntQueen",
	Character.MARK: "Mark",
	Character.MERITUULI: "Merituuli",
	Character.PEITSE: "Peitse",
	Character.PETE: "Pete",
	Character.PETE_BADASS: "Badass",
	Character.RAISEN: "Raisen",
	Character.SIMOONI: "Simooni",
	Character.SISTERS: "Sisters",
	Character.SWARMYARD: "Swarmyard"
}

const CharacterShowcaseName : Dictionary = {
	Character.AGENT: "Agent 47",
	Character.ERIKA : "Erika",
	Character.JUKULIUS : "Jukulius",
	Character.KORVEK : "Korvek",
	Character.LOTTE : "Anne-Lotte",
	Character.LOTTE_ANT_QUEEN : "Anne-Lotte",
	Character.MARK : "Mark Mudwater",
	Character.MERITUULI : "Merituuli",
	Character.PEITSE : "Peitse",
	Character.PETE : "Farty-Pete",
	Character.PETE_BADASS : "Farty-Pete",
	Character.RAISEN : "Raisen",
	Character.SIMOONI : "Simooni",
	Character.SISTERS : "Sisters",
	Character.SWARMYARD : "Shop Owner"
}

const CharacterToId : Dictionary = {
	Character.PEITSE: 1,
	Character.ERIKA: 2,
	Character.PETE: 3,
	Character.LOTTE: 4,
	Character.MARK: 5,
	Character.KORVEK: 6,
	Character.RAISEN: 7,
	Character.SIMOONI: 8,
	Character.JUKULIUS: 9,
	Character.MERITUULI: 10,
	Character.PETE_BADASS: 11,
	Character.AGENT: 12,
	Character.SWARMYARD: 13,
	Character.SISTERS: 14,
	Character.LOTTE_ANT_QUEEN: 15,
}

enum AnimationType {
	NULL,
	INFINITE_VOID,
	OCEAN,
	POSITIVE
}

enum SpyType {
	DIRT,
	FIGHT
}
