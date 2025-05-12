extends Node

const VERSION : String = "0.1";

const DEV_MODE : bool = false;
const MAX_SONG_ID : int = 11
const WAIT_BEFORE_SONG_TO_REPEAT : int = min(MAX_SONG_ID / 2, 10);

const AUTO_PLAY : bool = true if DEV_MODE else false;
const AUTO_START : bool = true if DEV_MODE else false;
const SHOWCASE_CARD_ID : int = 0 if DEV_MODE else 0;
const GAME_SPEED : float = 1 if DEV_MODE else 1;
const GAME_SPEED_MULTIPLIER : float = 1 / GAME_SPEED;

const MUTE : bool = false if DEV_MODE else false;
const MUTE_MUSIC : bool = (false if DEV_MODE else false) or MUTE;
const MUTE_SFX : bool = (false if DEV_MODE else false) or MUTE;
const VOLUME : int = 0 if DEV_MODE else 0;
const MUSIC_VOLUME : int = 0 if DEV_MODE else 0;
const SFX_VOLUME : int = -10 if DEV_MODE else -10;
