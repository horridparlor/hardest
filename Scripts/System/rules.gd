const DECK_SIZE : int = 15;
const HAND_SIZE : int = 3;
const MAX_HAND_SIZE : int = 8;
const VICTORY_POINTS : int = 300 if Config.AUTO_LEVEL > 0 else 3;
const CLOSE_TO_WINNING_POINTS : float = 0.8;
const MAX_LEVELS : int = 6;
const MAX_KEYWORDS : int = 3;

#Keyword specific
const UNDEAD_LIMIT : int = 3;
const HYDRA_KEYWORDS : int = 3;
const STOPPED_TIME_MIN_SHOTS : int = 2;
const STOPPED_TIME_MAX_SHOTS : int = 5;
const NUTS_TO_COLLECT : int = 3;
const OCEAN_DWELLER_TURNS_WAIT : int = 2;

#Roguelike
const STARTING_LIVES : int = 3;
const STARTING_MONEY : int = 5;
const HOUSES_COUNT : int = 5;
const STARTING_HOUSES_COUNT : int = 2;
const MIN_RARE_CHANCE : int = 3;
const MAX_RARE_CHANCE : int = 7;
const SCAM_DROP_CHANCE : int = 128;
const DEFAULT_CARDS : Array = [];
const CARD_CHOICES : int = 3;
const CARD_GOAL : int = 30;
const CHANCE_FOR_RARE_OPPONENT : int = 32;
const CARD_PICKS_PER_ROUND : int = 3;
const POINT_GOAL_MULTIPLIER : float = 1.5;
const MIN_POINT_INCREASE : int = 3;
const OPPONENT_MAX_POINT_GOAL : float = 10;
const STAMP_CHANCE : int = 8;
const RARE_STAMP_CHANCE_MULTIPLIER : int = 2;
const RARE_STAMP_BECOMES_COMMON_AFTER_ROUND : int = 8;
const STAMP_CHANCE_LESSENS_BY_ROUND : int = 1;
const CHANCE_FOR_EXTRA_HOUSE : int = 20;
