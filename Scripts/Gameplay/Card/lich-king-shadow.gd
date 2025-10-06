extends LichKingShadow

@onready var sprite : Sprite2D = $Sprite2D;

func get_shader_layers() -> Array:
	return [
		sprite
	];
