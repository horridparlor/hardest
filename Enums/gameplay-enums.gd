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

enum Character {
	ERIKA,
	KORVEK,
	LOTTE,
	MARK,
	PEITSE,
	PETE,
	RAISEN,
	SIMOONI
}

const TranslateCharacter : Dictionary = {
	"Erika": Character.ERIKA,
	"Korvek": Character.KORVEK,
	"Lotte": Character.LOTTE,
	"Mark": Character.MARK,
	"Peitse": Character.PEITSE,
	"Pete": Character.PETE,
	"Raisen": Character.RAISEN,
	"Simooni": Character.SIMOONI
}

const CharacterShowcaseName : Dictionary = {
	Character.ERIKA : "Erika",
	Character.KORVEK : "Korvek",
	Character.LOTTE : "Anne-Lotte",
	Character.MARK : "Mark Mudwater",
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
	Character.SIMOONI: 8
}
