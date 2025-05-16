extends DivineJudgment

@onready var animation_player : AnimationPlayer = $AnimationPlayer;

func stop_animation() -> void:
	animation_player.stop();

func start_animation() -> void:
	animation_player.speed_scale = 2;
	animation_player.play("Active");
