extends Nexus

@onready var level_buttons_layer : Node2D = $LevelButtons;
@onready var background_music : AudioStreamPlayer2D = $BackgroundMusic;
@onready var showcase_card : GameplayCard = $ShowcaseCard/Card;
@onready var showcase_card_layer : Node2D = $ShowcaseCard;
@onready var leds_layer : Node2D = $Leds;
@onready var led_frame_timer : Timer = $Timers/LedFrameTimer;
@onready var labels_layer : GlowNode = $LabelsLayer;

func _ready() -> void:
	var save_data : Dictionary = System.Data.read_save_data();
	spawn_level_buttons(save_data);
	operate_showcase_layer();
	spawn_leds();
	labels_layer.activate_animations();

func spawn_leds() -> void:
	var position : Vector2 = LED_STARTING_POSITION;
	var led : Led;
	for i in range(LEDS_PER_COLUMN):
		led = System.Instance.load_child(LED_PATH, leds_layer);
		led.position = position;
		leds_left.append(led);
		
		led = System.Instance.load_child(LED_PATH, leds_layer);
		led.position = Vector2(-position.x, position.y);
		leds_right.append(led);
		
		position += Vector2((-1 if i % 3 == 0 else 1) * (1 if i < 10 else -0.5) * LED_MARGIN.x, LED_MARGIN.y);
	led_frame_timer.wait_time = LED_FRAME_WAIT;
	led_frame_timer.start();
 
func init(music_position : float) -> void:
	background_music.play(music_position);
	is_active = true;

func operate_showcase_layer() -> void:
	if System.Debug.SHOWCASE_CARD_ID != 0:	
		showcase_card.card_data = System.Data.load_card(System.Debug.SHOWCASE_CARD_ID);
		showcase_card.update_visuals();
		showcase_card_layer.visible = true;
	else:
		showcase_card_layer.visible = false;

func spawn_level_buttons(save_data : Dictionary) -> void:
	var current_position : Vector2 = LEVEL_BUTTONS_STARTING_POSITION;
	var button : LevelButton;
	var buttons : int;
	for i in range(System.Rules.MAX_LEVELS):
		button = System.Instance.load_child(LEVEL_BUTTON_PATH, level_buttons_layer);
		button.position = current_position;
		current_position.x += LEVEL_BUTTON_X_MARGIN;
		buttons += 1;
		button.init(System.Data.read_level(i + 1), save_data.levels_unlocked == i + 1);
		if i < save_data.levels_unlocked:
			button.pressed.connect(_on_level_pressed);
		else:
			button.hide_button();
		if buttons % LEVEL_BUTTONS_PER_ROW == 0:
			current_position.y += LEVEL_BUTTON_Y_MARGIN;
			current_position.x = LEVEL_BUTTONS_STARTING_POSITION.x;

func _on_level_pressed(level_data : LevelData) -> void:
	if !is_active:
		return;
	is_active = false;
	emit_signal("enter_level", level_data);

func _on_background_music_finished() -> void:
	background_music.play();

func _on_led_frame_timer_timeout() -> void:
	led_frame();

func led_frame() -> void:
	shut_leds(red_lex_index - RED_LED_SPEED);
	shut_leds(current_led_row);
	shut_leds(current_led_row + LEDS_BETWEEN_BURSTS);
	shut_leds(current_led_row - LEDS_BETWEEN_BURSTS);
	current_led_row += 1;
	for i in range(LEDS_IN_BURST - 1):
		light_leds(current_led_row - LEDS_BETWEEN_BURSTS + i);
	for i in range(LEDS_IN_BURST):
		light_leds(current_led_row + i);
	for i in range(LEDS_IN_BURST - 1):
		light_leds(current_led_row + LEDS_BETWEEN_BURSTS + i);
	if current_led_row == LEDS_PER_COLUMN:
		current_led_row = 0;
	light_leds(red_lex_index, Led.LedColor.RED);
	red_lex_index += RED_LED_SPEED;
	if red_lex_index >= LEDS_PER_COLUMN:
		red_lex_index -= LEDS_PER_COLUMN;

func light_leds(index : int, led_color : Led.LedColor = Led.LedColor.WHITE) -> void:
	var leds : Array = get_leds_on_row(index);
	for led in leds:
		led.on(led_color);

func get_leds_on_row(index : int) -> Array:
	if index < 0:
		index += LEDS_PER_COLUMN;
	if index >= LEDS_PER_COLUMN:
		index -= LEDS_PER_COLUMN;
	return [
		leds_left[index],
		leds_right[index]
	];

func shut_leds(index : int) -> void:
	var leds : Array = get_leds_on_row(index);
	for led in leds:
		led.off();
