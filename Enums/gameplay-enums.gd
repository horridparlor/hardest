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
	PETE
}

const TranslateCharacter : Dictionary = {
	"Erika": Character.ERIKA,
	"Korvek": Character.KORVEK,
	"Lotte": Character.LOTTE,
	"Mark": Character.MARK,
	"Peitse": Character.PEITSE,
	"Pete": Character.PETE
}

const CharacterToId : Dictionary = {
	Character.PEITSE: 1,
	Character.ERIKA: 2,
	Character.PETE: 3,
	Character.LOTTE: 4,
	Character.MARK: 5,
	Character.KORVEK: 6
}
