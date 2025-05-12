extends Node

const AUTO_PLAY : bool = true;
const AUTO_START : bool = true;
const MUTE : bool = false;
const MUTE_MUSIC : bool = false;
const MUTE_SFX : bool = true;
const GAME_SPEED : float = 5;
const GAME_SPEED_MULTIPLIER : float = 1 / GAME_SPEED;

const MAX_SONG_ID : int = 11
const WAIT_BEFORE_SONG_TO_REPEAT : int = min(MAX_SONG_ID / 2, 10);
