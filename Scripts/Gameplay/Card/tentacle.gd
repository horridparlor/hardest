extends Tentacle

@onready var tentacle1 : Sprite2D = $Tentacle1;
@onready var tentacle2 : Sprite2D = $Tentacle2;
@onready var tentacle3 : Sprite2D = $Tentacle3;
@onready var tentacle4 : Sprite2D = $Tentacle4;

func get_sprites() -> Array:
	return [
		tentacle1,
		tentacle2,
		tentacle3,
		tentacle4
	];

func init_sprite() -> void:
	var tentacles : Array = [tentacle1, tentacle2];
	if System.Random.chance(4):
		tentacles = [tentacle3, tentacle4];
	var sprite : Sprite2D = System.Random.item(tentacles);
	for tentacle in get_sprites():
		tentacle.visible = false;
	sprite.visible = true;
	sprite.flip_h = System.Random.boolean();
	sprite.scale *= System.random.randf_range(0.8, 1.2);
