extends Node
class_name BattleRoyale

var winner : GameplayEnums.Controller = GameplayEnums.Controller.NULL;
var results : Array;

func _init(attackers : Array, defenders : Array, has_priority : bool) -> void:
	if has_priority:
		calculate_results(attackers, defenders);
	else:
		calculate_results(defenders, attackers);

func calculate_results(attackers : Array, defenders : Array) -> void:
	var card : CardData;
	var fight_result : FightResult;
	var counter_attackers : Array;
	var survivors : Array;
	if attackers.is_empty() || defenders.is_empty():
		if attackers.is_empty() and !defenders.is_empty():
			winner = GameplayEnums.Controller.PLAYER_TWO;
		elif defenders.is_empty() and !attackers.is_empty():
			winner = GameplayEnums.Controller.PLAYER_ONE;
		return;
	for c in defenders:
		card = c;
		fight_result = get_fight_result(card, attackers);
		if fight_result.is_victory():
			results.append(fight_result);
		else:
			counter_attackers.append(card);
	if counter_attackers.is_empty():
		winner = GameplayEnums.Controller.PLAYER_ONE;
		return;
	for c in attackers:
		card = c;
		fight_result = get_fight_result(card, counter_attackers);
		if fight_result.is_victory():
			results.append(fight_result);
		else:
			survivors.append(card);
	if survivors.is_empty():
		winner = GameplayEnums.Controller.PLAYER_TWO;

func get_fight_result(defender : CardData, attackers : Array) -> FightResult:
	var fight_result : FightResult = FightResult.new(null, defender);
	var challenger : CardData;
	var points : int;
	var winner : GameplayEnums.Controller;
	for ch in attackers:
		challenger = ch;
		winner = System.Fighting.determine_winner(defender, challenger);
		if winner == GameplayEnums.Controller.PLAYER_TWO:
			points = System.Fighting.calculate_base_points(challenger, defender, true);
			if fight_result.is_tie() or points > fight_result.points:
				fight_result.set_victory(challenger, points);
	return fight_result;
