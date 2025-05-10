extends Node
class_name SaveData

var level : int;

static func from_json(data : Dictionary) -> SaveData:
	var save : SaveData = SaveData.new();
	save.level = data.leve;
	return save;

func to_json() -> Dictionary:
	return {
		"level": level
	}
