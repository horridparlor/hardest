extends Node
class_name FightResult

enum ResultState {
	VICTORY,
	LOSS,
	TIE
}

var attacker : CardData;
var defender : CardData;
var result : ResultState;
var points : int;

func _init(attacker_ : CardData = null, defender_ : CardData = null, result_ : ResultState = ResultState.TIE, points_ : int = 0) -> void:
	attacker = attacker_;
	defender = defender_;
	result = result_;
	points = points_;

func is_victory() -> bool:
	return result == ResultState.VICTORY;

func is_loss() -> bool:
	return result == ResultState.LOSS;

func is_tie() -> bool:
	return result == ResultState.TIE;

func set_victory(challenger : CardData, points : int):
	attacker = challenger;
	result = FightResult.ResultState.VICTORY;
	points = points;
