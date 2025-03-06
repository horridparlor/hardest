extends Node

enum DataFileType {
	SAVE
}

static var DataFileExtension = {
	DataFileType.SAVE: 'save'
}

static func get_data_file_extension(type: DataFileType) -> String:
	return '.' + DataFileExtension[type];

static func get_json_extension() -> String:
	return get_data_file_extension(DataFileType.SAVE);
