extends Node

const Data : GDScript = preload("res://Scripts/System/data.gd");
const Dictionaries : GDScript = preload("res://Scripts/System/dictionaries.gd");
const Display : int = 2;
const Instance : GDScript = preload("res://Scripts/System/instance.gd");
const Json : GDScript = preload("res://Scripts/System/json.gd");
const Random : GDScript = preload("res://Scripts/System/random.gd");
const Rules : GDScript = preload("res://Scripts/System/rules.gd");
const Scale : GDScript = preload("res://Scripts/System/scale.gd");
const Vectors : GDScript = preload("res://Scripts/System/vectors.gd");
const Window_ : Vector2 = Vector2(1080, 1920);

var random : RandomNumberGenerator = RandomNumberGenerator.new();

static func create_directories() -> void:
	Json.create_directory();
