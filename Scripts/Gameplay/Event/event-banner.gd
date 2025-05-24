extends EventBanner

@onready var sprite : Sprite2D = $Sprite2D;

func init(event_id : int) -> void:
	var texture : Resource = load(System.Paths.EVENT_ART % event_id);
	sprite.texture = texture;
