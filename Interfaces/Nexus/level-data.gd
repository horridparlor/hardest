extends Node
class_name LevelData

var id : int;
var title : String;
var player : GameplayEnums.Character;
var opponent : GameplayEnums.Character;
var player_variant : int;
var opponent_variant : int;
var deck_id : int;
var deck2_id : int;
var song_id : int;
var background_id : int;
var unlocks_level : int;
var is_roguelike : bool;
var point_goal : int;

var position : Vector2;
var is_locked : bool;

const DEFAULT_DATA : Dictionary = {
	"id": 1,
	"title": "",
	"player": "Peitse",
	"opponent": "Peitse",
	"deck": 1,
	"deck2": 1,
	"song": 1,
	"background": 1,
	"unlocks": 1,
	"variant": 0,
	"variant2": 0,
	"isRoguelike": false,
	"pointGoal": System.Rules.VICTORY_POINTS
}

static func from_json(data : Dictionary) -> LevelData:
	var level_data : LevelData = LevelData.new();
	level_data.eat_json(data);
	return level_data;

func eat_json(data : Dictionary) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	id = data.id;
	title = data.title;
	player = translate_character(data.player);
	opponent = translate_character(data.opponent);
	deck_id = data.deck;
	deck2_id = data.deck2;
	song_id = data.song;
	background_id = data.background;
	unlocks_level = data.unlocks;
	player_variant = GameplayEnums.CharacterToId[player] if data.variant2 == 0 else data.variant2;
	opponent_variant = GameplayEnums.CharacterToId[opponent] if data.variant == 0 else data.variant;
	is_roguelike = data.isRoguelike;
	point_goal = data.pointGoal;

static func translate_character(character_name : String) -> GameplayEnums.Character:
	return GameplayEnums.TranslateCharacter[character_name] \
		if GameplayEnums.TranslateCharacter.has(character_name) \
		else GameplayEnums.Character.PEITSE;
