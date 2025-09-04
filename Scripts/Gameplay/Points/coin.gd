extends Coin

@onready var coin_sprite : Sprite2D = $CoinSprite;

func _process(delta : float) -> void:
	if is_flipping:
		flip_frame(coin_sprite, delta);
