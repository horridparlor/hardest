extends Node

const VERSION : String = "0.3";

const DEV_MODE : bool = false;
const MAX_SONG_ID : int = 18;
const MAX_CARD_ID : int = 57;
const MAX_EVENT_ID : int = 7;
const WAIT_BEFORE_SONG_TO_REPEAT : int = min(MAX_SONG_ID / 2, 10);

const AUTO_PLAY : bool = true if DEV_MODE else false;
const AUTO_START : bool = true if DEV_MODE else false;
const AUTO_LEVEL : int = 0 if DEV_MODE else 0;
const SHOWCASE_CARD_ID : int = 0 if DEV_MODE else 0;
const DEBUG_KEYWORD : CardEnums.Keyword = CardEnums.Keyword.NULL if DEV_MODE else CardEnums.Keyword.NULL;
const DEBUG_CARD : int = 0 if DEV_MODE else 0;
const SPAWNED_CARD : int = 4 if DEV_MODE else 1;
const GAME_SPEED : float = 1 if DEV_MODE else 1;
const GAME_SPEED_MULTIPLIER : float = 1 / GAME_SPEED;
const GUN_CHANCE : int = 1 if DEV_MODE else 1;
const MIMIC_CHANCE : int = 1 if DEV_MODE else 1;
const MUSIC_NIGHTCORE_PITCH : float = 1.2;

const MUTE : bool = false if DEV_MODE else false;
const MUTE_MUSIC : bool = (false if DEV_MODE else false) or MUTE;
const MUTE_SFX : bool = (false if DEV_MODE else false) or MUTE;
const VOLUME : int = 0 if DEV_MODE else 0;
const MUSIC_VOLUME : int = 0 if DEV_MODE else 0;
const SFX_VOLUME : int = -10 if DEV_MODE else -10;
const GUN_VOLUME : int = 10;
const NO_VOLUME : int = -80;
const MIN_PITCH : float = 0.1;
const MIN_GAME_SPEED : float = 0.1;
