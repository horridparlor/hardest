extends Poppet

@onready var blue_sprite : Sprite2D = $BlueSprite;
@onready var red_sprite : Sprite2D = $RedSprite;
@onready var gold_sprite : Sprite2D = $GoldSprite;
@onready var rainbow_sprite : Sprite2D = $RainbowSprite;

func off() -> void:
	for sprite in get_sprites():
		sprite.visible = false;
		
func on(color_ : PoppetColor = color) -> void:
	var sprite : Sprite2D;
	match color:
		PoppetColor.BLUE:
			sprite = blue_sprite;
		PoppetColor.RED:
			sprite = red_sprite;
		PoppetColor.GOLD:
			sprite = gold_sprite;
		PoppetColor.RAINBOW:
			sprite = rainbow_sprite;
	off();
	sprite.visible = true;

func get_sprites() -> Array:
	return [
		blue_sprite,
		red_sprite,
		gold_sprite,
		rainbow_sprite	
	];
