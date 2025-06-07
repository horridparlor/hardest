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
	MARK,
	MERITUULI,
	PEITSE,
	PETE,
	RAISEN,
	SIMOONI,
	SWARMYARD
}

const TranslateCharacter : Dictionary = {
	"Agent": Character.AGENT,
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
	"Swarmyard": Character.SWARMYARD
}

const TranslateCharacterBack : Dictionary = {
	Character.AGENT: "Agent",
	Character.ERIKA: "Erika",
	Character.JUKULIUS: "Jukulius",
	Character.KORVEK: "Korvek",
	Character.LOTTE: "Lotte",
	Character.MARK: "Mark",
	Character.MERITUULI: "Merituuli",
	Character.PEITSE: "Peitse",
	Character.PETE: "Pete",
	Character.RAISEN: "Raisen",
	Character.SIMOONI: "Simooni",
	Character.SWARMYARD: "Swarmyard"
}

const CharacterShowcaseName : Dictionary = {
	Character.AGENT: "Agent 47",
	Character.ERIKA : "Erika",
	Character.JUKULIUS : "Jukulius",
	Character.KORVEK : "Korvek",
	Character.LOTTE : "Anne-Lotte",
	Character.MARK : "Mark Mudwater",
	Character.MERITUULI : "Merituuli",
	Character.PEITSE : "Peitse",
	Character.PETE : "Farty-Pete",
	Character.RAISEN : "Raisen",
	Character.SIMOONI : "Simooni",
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
	Character.AGENT: 12,
	Character.SWARMYARD: 13
}
