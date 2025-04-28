const SAVE_WRITE_PATH_PREFIX : String = "user://json-data/";
const DATA_WRITE_PATH_PREFIX : String = "res://Data/";
const ERROR_KEY : String = "SYSTEM_RESERVER_KEY_ERROR";
const ERROR : Dictionary = {
	ERROR_KEY: ERROR_KEY
}

static func success(json_data : Dictionary) -> bool:
	return not is_error(json_data);

static func is_error(json_data : Dictionary) -> bool:
	return json_data.has(ERROR_KEY);

static func create_directory() -> void:
	var dir: DirAccess = DirAccess.open(SAVE_WRITE_PATH_PREFIX);
	if dir == null:
		DirAccess.make_dir_recursive_absolute(SAVE_WRITE_PATH_PREFIX);

static func get_file_path(file_prefix : String, file_name : String) -> String:
	return file_prefix + file_name + SystemEnums.get_json_extension();

static func get_save_file_path(file_name : String) -> String:
	return get_file_path(SAVE_WRITE_PATH_PREFIX, file_name);

static func get_data_file_path(file_name : String) -> String:
	return get_file_path(DATA_WRITE_PATH_PREFIX, file_name);

static func write(json_data: Dictionary, file_name: String) -> void:
	var file: FileAccess = FileAccess.open(file_name, FileAccess.WRITE);
	if not file:
		return;
	file.store_string(JSON.stringify(json_data));
	file.close();

static func read(file_name: String) -> Dictionary:
	var json_data : Dictionary;
	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ);
	if not file:
		return ERROR;
	json_data = parse(file.get_as_text());
	file.close();
	return json_data;

static func parse(json_string : String) -> Dictionary:
	var json : JSON = JSON.new();
	var json_data = json.parse_string(json_string);
	if not json_data:
		return ERROR;
	return json_data;

static func read_save(file_name: String) -> Dictionary:
	return read(get_save_file_path(file_name));

static func write_save(json_data: Dictionary, file_name: String) -> void:
	write(json_data, get_save_file_path(file_name));

static func read_data(file_name: String) -> Dictionary:
	return read(get_data_file_path(file_name));

static func write_data(json_data: Dictionary, file_name: String) -> void:
	write(json_data, get_data_file_path(file_name));
