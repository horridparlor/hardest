extends Node

const VERSION : String = "0.9";

const DEV_MODE : bool = false;
const MAX_SONG_ID : int = 21;
const MAX_CARD_ID : int = 126;
const WAIT_BEFORE_SONG_TO_REPEAT : int = min(MAX_SONG_ID - 3, 20);

const AUTO_PLAY : bool = false if DEV_MODE else false;
const AUTO_START : bool = false if DEV_MODE else false;
const AUTO_LEVEL : int = 44 if DEV_MODE else 0;
const SHOWCASE_CARD_ID : int = 0 if DEV_MODE else 0;
const SHOWCASE_STAMP : CardEnums.Stamp = CardEnums.Stamp.NULL if DEV_MODE else CardEnums.Stamp.NULL;
const DEBUG_KEYWORD : CardEnums.Keyword = CardEnums.Keyword.NULL if DEV_MODE else CardEnums.Keyword.NULL;
const DEBUG_CARD : int = 0 if DEV_MODE else 0;
const SPAWNED_CARD : int = 106 if DEV_MODE else 1;
const GAME_SPEED : float = 1 if DEV_MODE else 1;
const GAME_SPEED_MULTIPLIER : float = 1 / GAME_SPEED;
const AUTO_HOUSE : CollectionEnums.House = CollectionEnums.House.NULL if DEV_MODE else CollectionEnums.House.NULL;

const MUTE : bool = false if DEV_MODE else false;
const MUTE_MUSIC : bool = (false if DEV_MODE else false) or MUTE;
const MUTE_SFX : bool = (false if DEV_MODE else false) or MUTE;
const VOLUME : int = 0 if DEV_MODE else 0;
const MUSIC_VOLUME : int = 0 if DEV_MODE else 0;
const SFX_VOLUME : int = -10 if DEV_MODE else -10;
const THROWABLE_SFX_VOLUME : int = 0 if DEV_MODE else 0;
const GUN_VOLUME : int = 10;
const NO_VOLUME : int = -80;
const MIN_PITCH : float = 0.1;
const MIN_BULLET_PITCH : float = 1;
const MIN_GAME_SPEED : float = 0.1;
const MUSIC_NIGHTCORE_PITCH : float = 1.2;

#Marketing
const TEXTLESS_CARDS : bool = false if DEV_MODE else false;
const SHOW_TITLE : bool = false if DEV_MODE else false;
const DO_ROTATE_SCREEN : bool = true if DEV_MODE else true;
