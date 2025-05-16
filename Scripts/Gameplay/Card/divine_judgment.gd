extends DivineJudgment

@onready var animation_player : AnimationPlayer = $AnimationPlayer;

func _ready() -> void:
	animation_player.speed_scale = 2;
	animation_player.play("Active");
