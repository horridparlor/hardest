extends Node2D
class_name Nexus

signal enter_level(level_data);

const LEVEL_BUTTON_PATH : String = "res://Prefabs/Nexus/Buttons/level-button.tscn";
const LEVEL_BUTTON_X_MARGIN : int = 340;
const LEVEL_BUTTON_Y_MARGIN : int = 400;
const LEVEL_BUTTONS_STARTING_POSITION : Vector2 = Vector2(-LEVEL_BUTTON_X_MARGIN, -240);
const LEVEL_BUTTONS_PER_ROW : int = 3;

var is_active : bool;
