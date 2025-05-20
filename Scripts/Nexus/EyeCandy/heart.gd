extends Heart

@onready var off_sprite : Sprite2D = $OffSprite;
@onready var red_sprite : Sprite2D = $RedSprite;
@onready var pink_sprite : Sprite2D = $PinkSprite;
@onready var yellow_sprite : Sprite2D = $YellowSprite;

func _ready() -> void:
	off();

func get_sprites() -> Array:
	return [
		off_sprite,
		red_sprite,
		pink_sprite,
		yellow_sprite	
	];

func reset() -> void:
	for sprite in get_sprites():
		sprite.visible = false;

func off() -> void:
	reset();
	on(HeartColor.OFF);

func on(color : HeartColor = HeartColor.RED) -> void:
	var sprite : Sprite2D;
	match color:
		HeartColor.OFF:
			sprite = off_sprite;
		HeartColor.RED:
			sprite = red_sprite;
		HeartColor.PINK:
			sprite = pink_sprite;
		HeartColor.YELLOW:
			sprite = yellow_sprite;
	sprite.visible = true;
