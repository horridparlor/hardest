extends Node
class_name SaveData

const DEFAULT_DATA : Dictionary = {
	"tutorial_levels_won": -1,
	"current_song": 1,
	"last_played_songs": [],
	"next_song": 0,
	"open_page": Nexus.NexusPage.TUTORIAL,
	"roguelike_data": null
};

var tutorial_levels_won : int;
var current_song : int;
var last_played_songs : Array;
var next_song : int;
var open_page : Nexus.NexusPage;
var roguelike_data : RoguelikeData;

func _init() -> void:
	tutorial_levels_won = DEFAULT_DATA.tutorial_levels_won;
	current_song = DEFAULT_DATA.current_song;
	last_played_songs = DEFAULT_DATA.last_played_songs;
	next_song = DEFAULT_DATA.next_song;
	open_page = DEFAULT_DATA.open_page;
	roguelike_data = RoguelikeData.new();

static func from_json(data : Dictionary) -> SaveData:
	var save : SaveData = SaveData.new();
	save.eat_json(data);
	return save;

func eat_json(data : Dictionary) -> void:
	data = System.Dictionaries.make_safe(data, DEFAULT_DATA);
	tutorial_levels_won = data.tutorial_levels_won;
	current_song = data.current_song;
	last_played_songs = data.last_played_songs;
	next_song = data.next_song;
	open_page = data.open_page;
	if !data.roguelike_data:
		roguelike_data = RoguelikeData.new();
	else:
		roguelike_data = RoguelikeData.from_json(data.roguelike_data);

func to_json() -> Dictionary:
	return {
		"tutorial_levels_won": tutorial_levels_won,
		"current_song": current_song,
		"last_played_songs": last_played_songs,
		"next_song": next_song,
		"open_page": open_page,
		"roguelike_data": roguelike_data.to_json()
	}

func write() -> void:
	System.Data.write_save_data(to_json());
