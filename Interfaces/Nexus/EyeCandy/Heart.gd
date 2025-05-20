extends Node2D
class_name Heart

enum HeartColor {
	OFF,
	RED,
	PINK,
	YELLOW
}

func off() -> void:
	pass;

func on(color : HeartColor = HeartColor.RED) -> void:
	pass
