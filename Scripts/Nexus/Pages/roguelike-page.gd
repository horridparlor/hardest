extends RoguelikePage

@onready var progress_label : Label = $BasicInfo/ProgressBar/ProgressLabel;
@onready var green_panel : Panel = $BasicInfo/ProgressBar/GreenPanel;
@onready var heart1 : Heart = $BasicInfo/Hearts/Heart;
@onready var heart2 : Heart = $BasicInfo/Hearts/Heart2;
@onready var heart3 : Heart = $BasicInfo/Hearts/Heart3;
@onready var sfx_player : AudioStreamPlayer2D = $BasicInfo/Hearts/SfxPlayer;
@onready var reset_button_layer : GlowNode = $BasicInfo/ResetButton;
@onready var reset_progress_panel : Panel = $BasicInfo/ResetButton/ResetProgress;
@onready var level_buttons_layer : Node2D = $ChoiceBox/LevelButtons;
@onready var card_choices_layer : Node2D = $ChoiceBox/CardChoices;
@onready var choice_button_layer : GlowNode = $ChoiceBox/ChoiceButton;

func _ready() -> void:
	sfx_player.finished.connect( func():
		if !data.has_max_life():
			get_hearts()[data.lives_left].off();
		for i in range(data.lives_left):
			get_hearts()[i].on(get_heart_color());	
		if data.lives_left == 0:
			emit_signal("death");
	);
	spawn_level_buttons();

func spawn_level_buttons() -> void:
	var level_button : LevelButton;
	var position : Vector2 = LEVEL_BUTTON_STARTING_POSITION;
	for i in range(System.Rules.FIGHT_CHOICES):
		level_button = System.Instance.load_child(System.Paths.LEVEL_BUTTON, level_buttons_layer);
		level_button.scale *= 0.77;
		level_button.position = position;
		position.x += abs(LEVEL_BUTTON_STARTING_POSITION.x);
		level_buttons.append(level_button);
		level_button.pressed.connect(_on_level_button_pressed);

func _on_level_button_pressed(level_data : LevelData) -> void:
	if !is_active:
		return;
	is_active = false;
	data.chosen_opponent = level_data.deck_id - 1000;
	if data.chosen_opponent == 0:
		data.chosen_opponent = GameplayEnums.Character.PEITSE;
	emit_signal("enter_level", level_data);

func update_level_buttons() -> void:
	var character_id : int;
	var opponent : Dictionary;
	var level_data : LevelData;
	for i in range(System.Rules.FIGHT_CHOICES):
		character_id = data.fight_choices[i];
		opponent = data.all_opponents[character_id];
		level_data = LevelData.from_json({
			"opponent": GameplayEnums.TranslateCharacterBack[character_id],
			"song": opponent.song,
			"background": opponent.background,
			"deck": 1000 + (0 if character_id == GameplayEnums.Character.PEITSE else character_id),
			"deck2": 1000
		})
		level_buttons[i].init(level_data);

func get_heart_color() -> Heart.HeartColor:
	return Heart.HeartColor.RED if data.has_max_life() else Heart.HeartColor.PINK;

func set_origin_point() -> void:
	origin_point = position;

func init(roguelike_data : RoguelikeData):
	data = roguelike_data;
	update_progress_label();
	death_progress = 0;
	if data.lives_left == 0:
		reset_button_layer.shutter();
		choice_button_layer.shutter();
		is_active = false;
	else:
		reset_button_layer.activate_animations();
		choice_button_layer.activate_animations();
		is_active = true;
	update_death_progress_panel();
	update_level_buttons();
	update_hearts();

func update_progress_label() -> void:
	var progress : float = float(data.cards_bought) / float(data.card_goal);
	progress_label.text = "%s / %s cards" % [data.cards_bought, data.card_goal];
	green_panel.size.x = min(1, progress) * PROGRESS_PANEL_SIZE.x;
	green_panel.add_theme_stylebox_override("panel", get_full_progress_style("#34aa04", "#205814", progress < 1));

func get_full_progress_style(bg_color : String, border_color : String, is_nonfull : bool = false) -> StyleBoxFlat:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = bg_color;
	style.border_width_bottom = 4;
	style.border_width_left = 4;
	style.border_width_right = 0 if is_nonfull else 4;
	style.border_width_top = 4;
	style.border_color = border_color;
	style.border_blend = true;
	style.corner_radius_bottom_left = 13;
	style.corner_radius_bottom_right = 7 if is_nonfull else 13;
	style.corner_radius_top_left = 13;
	style.corner_radius_top_right = 7 if is_nonfull else 13;
	return style;

func get_full_death_progress_style() -> StyleBoxFlat:
	return get_full_progress_style("#4e094a", "716af7");

func get_nonfull_death_progress_style() -> StyleBoxFlat:
	return get_full_progress_style("#4e094a", "716af7", true);

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
	get_hearts()[data.lives_left].on(Heart.HeartColor.RED if data.has_max_life(1) else Heart.HeartColor.PINK);
	await System.wait(System.random.randf_range(0.3, 0.6));
	play_heart_lose_sound(false);
	get_hearts()[data.lives_left].on(Heart.HeartColor.YELLOW);

func play_heart_lose_sound(is_standalone : bool = true) -> void:
	var sound : Resource;
	if Config.MUTE_SFX:
		return;
	sound = load("res://Assets/SFX/LifeLoss/live-loss%s.wav" % System.random.randi_range(1, 3));
	sfx_player.stream = sound;
	sfx_player.volume_db = Config.NO_VOLUME if Config.MUTE_SFX else Config.SFX_VOLUME + Config.GUN_VOLUME;
	sfx_player.pitch_scale = System.game_speed;
	sfx_player.play();

func _on_die_pressed() -> void:
	if is_dying or !is_active:
		return;
	death_speed = System.random.randf_range(DEATH_MIN_SPEED, DEATH_MAX_SPEED);
	is_undeathing = false;
	is_dying = true;

func _on_die_released() -> void:
	if !is_dying or !is_active:
		return;
	death_speed = System.random.randf_range(UNDEATH_MIN_SPEED, UNDEATH_MAX_SPEED);
	is_dying = false;
	is_undeathing = true;

func death_progress_frame(delta : float) -> void:
	var was_full : bool = death_progress == 1;
	if !(is_dying or is_undeathing):
		return;
	if is_dying:
		death_progress += death_speed * delta * System.game_speed;
		if death_progress >= 1:
			death_progress = 1;
			is_dying = false;
			play_heart_lose_sound();
			emit_signal("death");
	if is_undeathing:
		death_progress -= death_speed * delta * System.game_speed;
		if death_progress <= 0:
			death_progress = 0;
			is_undeathing = false;
	update_death_progress_panel(was_full);

func update_death_progress_panel(was_full : bool = true) -> void:
	reset_progress_panel.size.x = death_progress * DEATH_PANEL_SIZE.x;
	update_dying_hearts()
	if death_progress == 1:
		reset_progress_panel.add_theme_stylebox_override("panel", get_full_death_progress_style());
	elif was_full:
		reset_progress_panel.add_theme_stylebox_override("panel", get_nonfull_death_progress_style());

func update_dying_hearts() -> void:
	var index : int;
	for heart in get_hearts():
		if data.lives_left > index:
			if death_progress >= 0.8 - 0.3 * index:
				heart.on(Heart.HeartColor.YELLOW);
			else:
				heart.on(get_heart_color());
		else:
			break;
		index += 1;
