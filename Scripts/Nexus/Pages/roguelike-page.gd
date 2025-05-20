extends RoguelikePage

@onready var progress_label : Label = $BasicInfo/ProgressBar/ProgressLabel;
@onready var green_panel : Panel = $BasicInfo/ProgressBar/GreenPanel;
@onready var heart1 : Heart = $BasicInfo/Hearts/Heart;
@onready var heart2 : Heart = $BasicInfo/Hearts/Heart2;
@onready var heart3 : Heart = $BasicInfo/Hearts/Heart3;
@onready var sfx_player : AudioStreamPlayer2D = $BasicInfo/Hearts/SfxPlayer;

func init(roguelike_data : RoguelikeData):
	data = roguelike_data;
	origin_point = position;
	update_progress_label();
	update_hearts();

func update_progress_label() -> void:
	var progress : float = float(data.cards_bought) / float(data.card_goal);
	progress_label.text = "%s / %s cards" % [data.cards_bought, data.card_goal];
	green_panel.size.x = progress * PROGRESS_PANEL_SIZE.x;
	if progress == 1:
		green_panel.add_theme_stylebox_override("panel", get_full_progress_style());

func get_full_progress_style() -> StyleBoxFlat:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = "#34aa04";
	style.border_width_bottom = 4;
	style.border_width_left = 4;
	style.border_width_right = 4;
	style.border_width_top = 4;
	style.border_color = "#205814";
	style.border_blend = true;
	style.corner_radius_bottom_left = 13;
	style.corner_radius_bottom_right = 13;
	style.corner_radius_top_left = 13;
	style.corner_radius_top_right = 13;
	return style;

func get_hearts() -> Array:
	return [
		heart1,
		heart2,
		heart3	
	];

func update_hearts() -> void:
	for i in range(data.lives_left):
		get_hearts()[i].on(Heart.HeartColor.RED if data.has_max_life(1 if data.lost_heart else 0) else Heart.HeartColor.PINK);
	if data.lost_heart and !data.has_max_life():
		heart_losing_effect();

func heart_losing_effect() -> void:
	var sound : Resource = load("res://Assets/SFX/LifeLoss/live-loss%s.wav" % System.random.randi_range(1, 3));
	sfx_player.stream = sound;
	get_hearts()[data.lives_left].on(Heart.HeartColor.RED if data.has_max_life(1) else Heart.HeartColor.PINK);
	await System.wait(System.random.randf_range(0.5, 0.9));
	play_heart_lose_sound();
	get_hearts()[data.lives_left].on(Heart.HeartColor.YELLOW);

func play_heart_lose_sound() -> void:
	if Config.MUTE_SFX:
		return;
	sfx_player.volume_db = Config.NO_VOLUME if Config.MUTE_SFX else Config.SFX_VOLUME + Config.GUN_VOLUME;
	sfx_player.pitch_scale = System.game_speed;
	sfx_player.play();
	sfx_player.finished.connect( func():
		get_hearts()[data.lives_left].off();
		for i in range(data.lives_left):
			get_hearts()[i].on(Heart.HeartColor.PINK);	
		if data.lives_left == 0:
			emit_signal("death");
	)
