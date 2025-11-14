extends SplashParticle

@onready var sprite : Sprite2D = $SplashSprite;

func make_negative() -> void:
	var shader : ShaderMaterial = System.Shaders.negative();
	sprite.material = shader;
	
