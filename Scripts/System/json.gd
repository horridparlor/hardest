const SAVE_WRITE_PATH_PREFIX : String = "user://json-data/";
const DATA_WRITE_PATH_PREFIX : String = "res://Data/";
const ERROR_KEY : String = "SYSTEM_RESERVER_KEY_ERROR";
const ERROR : Dictionary = {
	ERROR_KEY: ERROR_KEY
}
const SCREENSHOTS_PATH : String = "user://screenshots/";

static func success(json_data : Dictionary) -> bool:
	return not is_error(json_data);

static func is_error(json_data : Dictionary) -> bool:
	return json_data.has(ERROR_KEY);

static func create_directory() -> void:
	var dir: DirAccess;
	for path in [
		SAVE_WRITE_PATH_PREFIX,
		SAVE_WRITE_PATH_PREFIX + System.Data.SOUL_BANKS_SAVE_PATH,
		SCREENSHOTS_PATH,
		SAVE_WRITE_PATH_PREFIX + System.Data.DECKLIST_FOLDER_PATH
	]:
		dir = DirAccess.open(path);
		if dir == null:
			DirAccess.make_dir_recursive_absolute(path);

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

static func read(file_name: String, do_debug : bool = false) -> Dictionary:
	var json_data : Dictionary;
	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ);
	if do_debug:
		print("Reading: %s \n%s" % [file_name, not not file]);
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

static func read_data(file_name: String, do_debug: bool = false) -> Dictionary:
	return read(get_data_file_path(file_name), do_debug);

static func write_data(json_data: Dictionary, file_name: String) -> void:
	write(json_data, get_data_file_path(file_name));

static func take_screenshot(node : Node2D) -> void:
	var image : Image = node.get_viewport().get_texture().get_image();
	var file_path = "user://screenshots/%s.png" % Time.get_datetime_string_from_system();
	var error = image.save_png(file_path);
	if error == OK:
		print("Screenshot saved to: ", file_path);
	else:
		print("Error saving screenshot");
