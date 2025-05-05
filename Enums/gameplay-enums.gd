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
	ERIKA,
	JUKULIUS,
	KORVEK,
	LOTTE,
	MARK,
	MERITUULI,
	PEITSE,
	PETE,
	RAISEN,
	SIMOONI
}

const TranslateCharacter : Dictionary = {
	"Erika": Character.ERIKA,
	"Jukulius": Character.JUKULIUS,
	"Korvek": Character.KORVEK,
	"Lotte": Character.LOTTE,
	"Mark": Character.MARK,
	"Merituuli": Character.MERITUULI,
	"Peitse": Character.PEITSE,
	"Pete": Character.PETE,
	"Raisen": Character.RAISEN,
	"Simooni": Character.SIMOONI
}

const CharacterShowcaseName : Dictionary = {
	Character.ERIKA : "Erika",
	Character.JUKULIUS : "Jukulius",
	Character.KORVEK : "Korvek",
	Character.LOTTE : "Anne-Lotte",
	Character.MARK : "Mark Mudwater",
	Character.MERITUULI : "Merituuli",
	Character.PEITSE : "Peitse",
	Character.PETE : "Farty-Pete",
	Character.RAISEN : "Raisen",
	Character.SIMOONI : "Simooni"
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
	Character.MERITUULI: 10
}
