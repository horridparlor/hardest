extends Node2D
class_name Home

const GAMEPLAY_PATH : String = "res://Prefabs/Scenes/gameplay.tscn";
const NEXUS_PATH : String = "res://Prefabs/Scenes/nexus.tscn";
const SAVE_FILE_NAME : String = "save";
const MAX_BASE_ROTATION : float = 5;
const BASE_RATION_SPEED : float = 2.4;
const BASE_ROTATION_ERROR : float = 0.01;

var gameplay : Gameplay;
var nexus : Nexus;
var save_data : SaveData;
var level_data : LevelData;
var base_rotation_direction : int = System.Random.direction();
var base_rotation_right_speed_error : float = 1;
var base_rotation_left_speed_error : float = 1;
var min_base_rotation_error : float = 1;
var max_base_rotation_error : float = 1;

func _ready() -> void:
	System.random.randomize();
	System.create_directories();
	DisplayServer.window_set_current_screen(System.Display);
	set_process_input(true);
	save_data = System.Data.load_save_data();
	init();

func init() -> void:
	pass;
