extends Led

@onready var off_sprite : Sprite2D = $"led-off";
@onready var blue_sprite : Sprite2D = $"led-blue";
@onready var red_sprite : Sprite2D = $"led-red";
@onready var yellow_sprite : Sprite2D = $"led-yellow";
@onready var white_sprite : Sprite2D = $"led-white";

func _ready() -> void:
	off();

func reset() -> void:
	for sprite in get_sprites():
		sprite.visible = false;

func off() -> void:
	on(LedColor.OFF);

func on(color : LedColor = LedColor.WHITE) -> void:
	reset();
	match color:
		LedColor.OFF:
			off_sprite.visible = true;
		LedColor.BLUE:
			red_sprite.visible = true;
		LedColor.RED:
			red_sprite.visible = true;
		LedColor.YELLOW:
			yellow_sprite.visible = true;
		LedColor.WHITE:
			white_sprite.visible = true;

func get_sprites() -> Array:
	return [
		off_sprite,
		blue_sprite,
		red_sprite,
		yellow_sprite,
		white_sprite
	];
