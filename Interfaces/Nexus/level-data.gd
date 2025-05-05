extends Node
class_name LevelData

var id : int;
var player : GameplayEnums.Character;
var opponent : GameplayEnums.Character;
var deck_id : int;
var deck2_id : int;

static func eat_json(data : Dictionary) -> LevelData:
	var level_data : LevelData = LevelData.new();
	level_data.id = data.id;
	level_data.player = translate_character(data.player);
	level_data.opponent = translate_character(data.opponent);
	level_data.deck_id = data.deck;
	level_data.deck2_id = data.deck2;
	return level_data;

static func translate_character(character_name : String) -> GameplayEnums.Character:
	return GameplayEnums.TranslateCharacter[character_name] \
		if GameplayEnums.TranslateCharacter.has(character_name) \
		else GameplayEnums.Character.PEITSE;
