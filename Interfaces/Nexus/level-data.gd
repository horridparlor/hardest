extends Node
class_name LevelData

var id : int;
var player : GameplayEnums.Character;
var opponent : GameplayEnums.Character;
var player_variant : int;
var opponent_variant : int;
var deck_id : int;
var deck2_id : int;
var song_id : int;
var background_id : int;
var unlocks_level : int;

var position : Vector2;
var is_locked : bool;

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"player": "Peitse",
	"opponent": "Peitse",
	"deck": 1,
	"deck2": 1,
	"song": 1,
	"background": 1,
	"unlocks": 1,
	"variant": 0,
	"variant2": 0
}

static func eat_json(data : Dictionary) -> LevelData:
	var level_data : LevelData = LevelData.new();
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	level_data.id = data.id;
	level_data.player = translate_character(data.player);
	level_data.opponent = translate_character(data.opponent);
	level_data.deck_id = data.deck;
	level_data.deck2_id = data.deck2;
	level_data.song_id = data.song;
	level_data.background_id = data.background;
	level_data.unlocks_level = data.unlocks;
	level_data.player_variant = GameplayEnums.CharacterToId[level_data.player] if data.variant2 == 0 else data.variant2;
	level_data.opponent_variant = GameplayEnums.CharacterToId[level_data.opponent] if data.variant == 0 else data.variant;
	return level_data;

static func translate_character(character_name : String) -> GameplayEnums.Character:
	return GameplayEnums.TranslateCharacter[character_name] \
		if GameplayEnums.TranslateCharacter.has(character_name) \
		else GameplayEnums.Character.PEITSE;
