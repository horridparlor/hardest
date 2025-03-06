extends Node

const HUNTED_LEVELS : Array = [1, 4, 7, -2];
const SLOW_LEVEL : int = 2;
const GIANT_LEVEL : int = 3;
const FAST_LEVEL : int = 4;
const SUPERMAN_LEVEL : int = 5;
const CARS_LEVEL : int = 6;
const RAPIDFIRE_LEVEL : int = 7;
const SUPERSONIC_LEVEL : int = 8;
const LAST_LEVEL : int = 9;

const GIANTS_SECRET_LEVEL : int = -1;
const GHOSTS_SECRET_LEVEL : int = -2;

enum GlowState {
	GLOW,
	SHUTTER
}

enum EnemyColor {
	BLUE,
	PINK,
	YELLOW
}

enum GirlfriendState {
	YES,
	NO,
	LATE
}
