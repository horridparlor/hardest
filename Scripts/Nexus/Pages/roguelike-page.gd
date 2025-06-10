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
@onready var panel_sprite : Sprite2D = $Sprite2D;
@onready var keywords_hints : RichTextLabel = $ChoiceBox/CardChoices/KeywordsHints;
@onready var card_choice_label : Label = $ChoiceBox/ChoiceButton/Label;

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
	panel_sprite.material.set_shader_parameter("opacity", BACKGROUND_OPACITY);
	choice_button_layer.rotation_degrees = System.random.randf_range(-CHOICE_BUTTON_ROTATION, CHOICE_BUTTON_ROTATION);

func spawn_level_buttons() -> void:
	var level_button : LevelButton;
	var position : Vector2 = LEVEL_BUTTON_STARTING_POSITION;
	level_button = System.Instance.load_child(System.Paths.LEVEL_BUTTON, level_buttons_layer);
	level_button.position = position;
	level_buttons.append(level_button);

func _on_level_button_pressed(level_data : LevelData) -> void:
	if !is_active:
		return;
	is_active = false;
	data.chosen_opponent = level_data.deck_id - 1000;
	if data.chosen_opponent == 0:
		data.chosen_opponent = GameplayEnums.Character.PEITSE;
	emit_signal("enter_level", level_data);

func update_level_buttons() -> void:
	var level_data : LevelData = get_level_data();
	level_buttons[0].init(level_data);

func get_level_data() -> LevelData:
	var character_id : int = data.next_opponent;
	var opponent : Dictionary = data.all_opponents[character_id];
	return LevelData.from_json({
		"opponent": GameplayEnums.TranslateCharacterBack[character_id],
		"song": opponent.song,
		"background": opponent.background,
		"deck": 1000 + (0 if character_id == GameplayEnums.Character.PEITSE else character_id),
		"deck2": 1000,
		"isRoguelike": true,
		"pointGoal": data.point_goal
	});

func get_heart_color() -> Heart.HeartColor:
	return Heart.HeartColor.RED if data.has_max_life() else Heart.HeartColor.PINK;

func init(roguelike_data : RoguelikeData):
	data = roguelike_data;
	has_picked = false;
	update_progress_label();
	death_progress = 0;
	if data.lives_left == 0:
		reset_button_layer.shutter();
		choice_button_layer.shutter();
		is_active = false;
	else:
		choice_button_layer.activate_animations();
		reset_button_layer.glow();
		is_active = true;
	update_death_progress_panel();
	update_level_buttons();
	delete_cards();
	keywords_hints.modulate.a = 0;
	if data.card_choices_left.size() > 0:
		level_buttons_layer.visible = false;
		show_card_choice();
	else:
		choice_button_layer.full_shutter();
		show_fight_choices();
	update_hearts();

func delete_cards() -> void:
	for card in cards:
		card.queue_free();
	cards = [];

func show_card_choice() -> void:
	var card : GameplayCard;
	var card_data : CardData;
	var position : Vector2 = LEVEL_BUTTON_STARTING_POSITION + Vector2(-CARD_X_MARGIN, -35);
	cards = [];
	for i in range(System.Rules.CARD_CHOICES):
		card_data = System.Data.load_card(data.card_choices_left[0][i]);
		card = System.Instance.load_child(System.Paths.CARD, card_choices_layer);
		card.card_data = card_data;
		card.init();
		card.scale *= 1.2;
		card.position = position;
		position.x += CARD_X_MARGIN;
		card.pressed.connect(_on_focus_card);
		card.despawned.connect(_on_card_despawned);
		card.full_shutter();
		cards.append(card);
	cards[1]._on_button_pressed();
	choice_button_layer.glow();
	card_choice_label.text = System.Random.item([
		"CHOOSE",
		"GRAB IT",
		"PICK IT",
		"PACK IT",
		"TAKE IT",
		"LICK IT",
		"SNATCH IT",
		"POLISH IT",
		"STEAL IT",
		"HAGGLE IT",
		"BECOME IT",
		"FEEL IT",
	]);

func _on_card_despawned(card : GameplayCard) -> void:
	cards.erase(card);
	card.queue_free();

func _on_focus_card(card : GameplayCard) -> void:
	if !cards.has(card) or !is_active:
		return;
	for c in cards:
		c.shutter();
	card.glow();
	focused_card = card;
	keywords_hints.text = card.get_keyword_hints();
	keywords_hints.modulate.a = 1;

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
	if data.lives_left == 0:
		_on_death();
		return;
	for i in range(data.lives_left):
		get_hearts()[i].on(Heart.HeartColor.RED if data.has_max_life(1 if data.lost_heart else 0) else Heart.HeartColor.PINK);
	if data.lost_heart and !data.has_max_life():
		heart_losing_effect();

func heart_losing_effect() -> void:
	get_hearts()[data.lives_left].on(Heart.HeartColor.RED if data.has_max_life(1) else Heart.HeartColor.PINK);
	await System.wait(System.random.randf_range(0.5, 0.8));
	play_heart_lose_sound(false);
	get_hearts()[data.lives_left].on(Heart.HeartColor.YELLOW);
	data.lost_heart = false;

func play_heart_lose_sound(is_standalone : bool = true) -> void:
	var sound : Resource;
	sound = load("res://Assets/SFX/LifeLoss/live-loss%s.wav" % System.random.randi_range(1, 3));
	play_sound(sound, Config.GUN_VOLUME);

func play_sound(sound : Resource, added_volume : int = 0) -> void:
	sfx_player.stream = sound;
	sfx_player.volume_db = Config.NO_VOLUME if Config.MUTE_SFX else Config.SFX_VOLUME + added_volume;
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
			_on_death();
	if is_undeathing:
		death_progress -= death_speed * delta * System.game_speed;
		if death_progress <= 0:
			death_progress = 0;
			is_undeathing = false;
	update_death_progress_panel(was_full);

func _on_death() -> void:
	play_heart_lose_sound();
	emit_signal("death");

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

func _on_pack_it_triggered() -> void:
	if !is_active or data.card_choices_left.size() == 0 or !focused_card:
		return;
	pack_card();

func pack_card() -> void:
	var despawn_x : float = System.Window_.x / 2 + GameplayCard.SIZE.x / 2;
	var despawn_position : Vector2 = Vector2(System.random.randf_range(-despawn_x, despawn_x), -System.Window_.y + GameplayCard.SIZE.y / 2);
	for card in cards:
		if card != focused_card:
			card.pressed.disconnect(_on_focus_card);
			card.dissolve();
	data.your_cards = data.your_cards + [focused_card.card_data.to_json()];
	data.card_choices_left.remove_at(0);
	data.cards_bought += 1;
	update_progress_label();
	focused_card.despawn(despawn_position);
	focused_card = null;
	play_collection_sound();
	await System.wait(System.random.randf_range(COLLECTING_MIN_WAIT, COLLECTING_MAX_WAIT));
	if data.card_choices_left.size() > 0:
		show_card_choice();
	else:
		show_fight_choices();
		is_active = false;
	emit_signal("save");

func play_collection_sound() -> void:
	var sound : Resource = load("res://Assets/SFX/Inventory/stashing-sound.wav");
	play_sound(sound, Config.GUN_VOLUME / 2);

func show_fight_choices() -> void:
	choice_button_layer.shutter();
	level_buttons_layer.visible = true;
	level_buttons_layer.modulate.a = 0;
	level_buttons_reveal_speed = System.random.randf_range(LEVEL_BUTTONS_MIN_REVEAL_SPEED, LEVEL_BUTTONS_MAX_REVEAL_SPEED);
	is_revealing_level_buttons = true;
	_on_level_button_pressed(get_level_data());

func reveal_level_buttons_frame(delta : float) -> void:
	var amount : float = level_buttons_reveal_speed * delta * System.game_speed;
	if !is_revealing_level_buttons:
		return;
	level_buttons_layer.modulate.a += amount;
	keywords_hints.modulate.a -= amount;
	if level_buttons_layer.modulate.a >= 1:
		level_buttons_layer.modulate.a = 1;
		keywords_hints.modulate.a = 0;
		is_revealing_level_buttons = false;
	card_choice_label.text = "FIGHT";
