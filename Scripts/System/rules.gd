const DECK_SIZE : int = 15;
const HAND_SIZE : int = 3;
const MAX_HAND_SIZE : int = 10;
const VICTORY_POINTS : int = 300 if Config.AUTO_LEVEL > 0 else 3;
const CLOSE_TO_WINNING_POINTS : float = 0.8;
const MAX_LEVELS : int = 6;
const MAX_KEYWORDS : int = 3;

#Keyword specific
const UNDEAD_LIMIT : int = 3;
const HYDRA_KEYWORDS : int = 3;
const HYDRA_RARE_KEYWORDS_CHANCE : int = 10;
const STOPPED_TIME_MIN_SHOTS : int = 2;
const STOPPED_TIME_MAX_SHOTS : int = 5;
const NUTS_TO_COLLECT : int = 3;
const OCEAN_DWELLER_TURNS_WAIT : int = 2;
const SALTY_POINTS_LOST : int = 1;
const EXTRA_SALTY_POINTS_LOST : int = 3;
const MAX_BERSERKER_SHOTS : int = 99;
const MAX_TIME_STOP_CARDS_PLAYED : int = 20;
const AURA_FARMIN_COUNT : int = 10;

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
#Negative Chance
const BASE_NEGATIVE_CARD_CHANCE : int = 60;
const NEGATIVE_CARD_CHANCE_MULTIPLIER : int = 30;
const NEGATIVE_BASE_CHANCE_EASING_PER_ROUND : int = 5;
const NEGATIVE_MIN_BASE_CHANCE : int = 10;
const NEGATIVE_MULTIPLIER_EASING_PER_ROUND : int = 4;
const NEGATIVE_MIN_MULTIPLIER : int = 6;
#Foil Chance
const HOLO_BASE_CHANCE : int = 21;
const HOLO_CHANCE_MULTIPLIER : int = 5;
const HOLO_CHANCE_EASING : int = 6;
const MIN_HOLO_CHANCE : int = 5;
#Gods
const ZESCANOR_CHANCE : int = 1000;
const MIN_GOD_CHANCE : int = 100;
const GOD_CHANCE_EASING : int = 20;
