extends Node2D
class_name Led

enum LedColor {
	OFF,
	BLUE,
	RED,
	YELLOW,
	WHITE
}

func off() -> void:
	pass;

func on(color : LedColor = LedColor.WHITE) -> void:
	pass
