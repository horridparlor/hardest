extends Node
class_name SaveData

var tutorial_levels_won : int;
var current_song : int;
var last_played_songs : Array;

static func from_json(data : Dictionary) -> SaveData:
	var save : SaveData = SaveData.new();
	save.tutorial_levels_won = data.tutorial_levels_won;
	save.current_song = data.current_song;
	save.last_played_songs = data.last_played_songs;
	return save;

func to_json() -> Dictionary:
	return {
		"tutorial_levels_won": tutorial_levels_won,
		"current_song": current_song,
		"last_played_songs": last_played_songs
	}

func write() -> void:
	System.Data.write_save_data(to_json());
