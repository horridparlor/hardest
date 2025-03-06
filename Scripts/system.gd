extends Node

const Dictionaries : GDScript = preload("res://Scripts/System/dictionaries.gd");
const Display : int = 1;
const Instance : GDScript = preload("res://Scripts/System/instance.gd");
const Json : GDScript = preload("res://Scripts/System/json.gd");
const Random : GDScript = preload("res://Scripts/System/random.gd");
const Vectors : GDScript = preload("res://Scripts/System/vectors.gd");
const Window_ : Vector2 = Vector2(1920, 1080);

var random : RandomNumberGenerator = RandomNumberGenerator.new();

static func create_directories() -> void:
	Json.create_directory();
