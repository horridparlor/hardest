const JSON_WRITE_PATH_PREFIX : String = "user://json-data/";
const ERROR_KEY : String = 'SYSTEM_RESERVER_KEY_ERROR';
const ERROR : Dictionary = {
	ERROR_KEY: ERROR_KEY
}

static func success(json_data : Dictionary) -> bool:
	return not is_error(json_data);

static func is_error(json_data : Dictionary) -> bool:
	return json_data.has(ERROR_KEY);

static func create_directory() -> void:
	var dir: DirAccess = DirAccess.open(JSON_WRITE_PATH_PREFIX);
	if dir == null:
		DirAccess.make_dir_recursive_absolute(JSON_WRITE_PATH_PREFIX);

static func get_file_path(file_name : String) -> String:
	return JSON_WRITE_PATH_PREFIX + file_name + SystemEnums.get_json_extension();

static func write(json_data: Dictionary, file_name: String) -> void:
	var file: FileAccess = FileAccess.open(get_file_path(file_name), FileAccess.WRITE);
	if not file:
		return;
	file.store_string(JSON.stringify(json_data));
	file.close();

static func read(file_name: String) -> Dictionary:
	var json_data : Dictionary;
	var file: FileAccess = FileAccess.open(get_file_path(file_name), FileAccess.READ);
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
