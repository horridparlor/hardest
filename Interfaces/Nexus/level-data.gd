extends Node
class_name LevelData

var id : int;
var opponent : GameplayEnums.Character;
var deck_id : int;
var deck2_id : int;

static func eat_json(data : Dictionary) -> LevelData:
	var level_data : LevelData = LevelData.new();
	level_data.id = data.id;
	level_data.opponent = GameplayEnums.TranslateCharacter[data.opponent] if GameplayEnums.TranslateCharacter.has(data.opponent) else GameplayEnums.Character.PEITSE;
	level_data.deck_id = data.deck;
	level_data.deck2_id = data.deck2;
	return level_data;
