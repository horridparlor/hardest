extends TouchScreenButton
class_name SpringButton

signal triggered();

const MAX_RANGE_FROM_PRESSED : int = 40;
const MAX_PRESS_TIME : float = 0.9;

var pressed_position : Vector2;
var pressed_time : float;
var is_pressing : bool;
