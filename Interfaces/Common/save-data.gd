extends Node
class_name SaveData

var tutorial_levels_won : int;
var current_song : int;
var last_played_songs : Array;
var next_song : int;
var open_page : Nexus.NexusPage;
var roguelike_data : RoguelikeData;

static func from_json(data : Dictionary) -> SaveData:
	var save : SaveData = SaveData.new();
	save.tutorial_levels_won = data.tutorial_levels_won;
	save.current_song = data.current_song;
	save.last_played_songs = data.last_played_songs;
	save.next_song = data.next_song;
	save.open_page = data.open_page;
	if !data.roguelike_data:
		save.roguelike_data = RoguelikeData.new();
	else:
		save.roguelike_data = RoguelikeData.from_json(data.roguelike_data);
	return save;

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
