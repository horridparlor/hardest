extends GlowSticks

@onready var left_rattle : Rattle = $LeftStick;
@onready var right_rattle : Rattle = $RightStick;
@onready var left_stick : Sprite2D = $"LeftStick/Pink-glow-stick";
@onready var right_stick : Sprite2D = $"RightStick/Blue-glow-stick";

func _ready() -> void:
	left_rattle.slow_down(12);
	right_rattle.slow_down(12);
	scale *= 3;

func get_shader_layers() -> Array:
	return [
		left_stick,
		right_stick
	];

func set_material_for_sprites(material : ShaderMaterial) -> void:
	for sprite in get_shader_layers():
		sprite.material = material;

func _process(delta: float) -> void:
	if !System.Instance.exists(left_stick) and !System.Instance.exists(right_stick):
		queue_free();
