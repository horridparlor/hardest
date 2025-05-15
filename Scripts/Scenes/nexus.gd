extends Nexus

@onready var level_buttons_layer : Node2D = $LevelButtons;
@onready var showcase_card : GameplayCard = $ShowcaseCard/Card;
@onready var showcase_card_layer : Node2D = $ShowcaseCard;
@onready var cards_back_layer : Node2D = $BackgroundCards/CardsBack;
@onready var cards_back_layer2 : Node2D = $BackgroundCards/CardsBack2;
@onready var cards_front_layer : Node2D = $BackgroundCards/CardsFront;
@onready var cards_front_layer2 : Node2D = $BackgroundCards/CardsFront2;
@onready var leds_layer : Node2D = $Leds;
@onready var labels_layer : GlowNode = $LabelsLayer;
@onready var hint_label : Label = $LabelsLayer/HintLabel;

@onready var led_frame_timer : Timer = $Timers/LedFrameTimer;
@onready var card_spawn_timer : Timer = $Timers/CardSpawnTimer;
@onready var auto_start_timer : Timer = $Timers/AutoStartTimer;

func _ready() -> void:
	operate_showcase_layer();
	spawn_leds();
	labels_layer.activate_animations();

func spawn_a_background_card() -> void:
	var is_back : bool = System.Random.boolean();
	var layer : Node2D = System.Random.item(
		[cards_back_layer, cards_back_layer2] if is_back \
		else [cards_front_layer, cards_front_layer2]	
	);
	var card : GameplayCard = instance_background_card(layer);
	card_spawn_timer.wait_time = System.random.randf_range(MIN_CARD_SPAWN_WAIT, MAX_CARD_SPAWN_WAIT) * System.game_speed_multiplier;
	if is_back:
		card.scale *= BACKGROUND_CARDS_SCALE;
	card_spawn_timer.start();

func spawn_leds() -> void:
	var position : Vector2 = LED_STARTING_POSITION;
	var led : Led;
	for i in range(LEDS_PER_COLUMN):
		led = System.Instance.load_child(System.Paths.LED, leds_layer);
		led.position = position;
		leds_left.append(led);
		
		led = System.Instance.load_child(System.Paths.LED, leds_layer);
		led.position = Vector2(-position.x, position.y);
		leds_right.append(led);
		
		position += Vector2((-1 if i % 3 == 0 else 1) * (1 if i < 10 else -0.5) * LED_MARGIN.x, LED_MARGIN.y);
	led_frame_timer.wait_time = LED_FRAME_WAIT * System.game_speed_multiplier;
	led_frame_timer.start();
 
func init(levels_unlocked_ : int) -> void:
	levels_unlocked = levels_unlocked_;
	is_active = true;
	spawn_level_buttons(levels_unlocked);
	spawn_a_background_card();
	if levels_unlocked == System.Levels.MAX_TUTORIAL_LEVELS:
		hint_label.text = "YOU WON THE DEMO";
	if Config.AUTO_START:
		auto_start_timer.wait_time = AUTO_START_WAIT * System.game_speed_multiplier;
		auto_start_timer.start();

func auto_start_level() -> void:
	var button : LevelButton;
	if levels_unlocked >= System.Levels.MAX_TUTORIAL_LEVELS:
		return;
	button = level_buttons[levels_unlocked];
	button.trigger();

func operate_showcase_layer() -> void:
	if Config.SHOWCASE_CARD_ID != 0:	
		showcase_card.card_data = System.Data.load_card(Config.SHOWCASE_CARD_ID);
		showcase_card.update_visuals();
		showcase_card.update_card_art(true);
		showcase_card_layer.visible = true;
	else:
		showcase_card_layer.visible = false;

func spawn_level_buttons(levels_unlocked : int) -> void:
	var current_position : Vector2 = LEVEL_BUTTONS_STARTING_POSITION;
	var button : LevelButton;
	var buttons : int;
	var level_data : LevelData;
	for i in range(System.Rules.MAX_LEVELS):
		button = System.Instance.load_child(LEVEL_BUTTON_PATH, level_buttons_layer);
		button.position = current_position;
		current_position.x += LEVEL_BUTTON_X_MARGIN;
		buttons += 1;
		level_data = System.Data.read_level(i + 2);
		level_data.is_locked = i > levels_unlocked or Config.SHOWCASE_CARD_ID != 0
		button.init(level_data, levels_unlocked == i);
		button.pressed.connect(_on_level_pressed);
		level_buttons.append(button);
		if buttons % LEVEL_BUTTONS_PER_ROW == 0:
			current_position.y += LEVEL_BUTTON_Y_MARGIN;
			current_position.x = LEVEL_BUTTONS_STARTING_POSITION.x;

func _on_level_pressed(level_data : LevelData) -> void:
	if !is_active:
		return;
	is_active = false;
	emit_signal("enter_level", level_data);

func _on_led_frame_timer_timeout() -> void:
	led_frame_timer.stop();
	led_frame();
	led_wait += System.Random.direction() * System.Leds.LED_CLOCK_ERROR;
	led_wait = max(System.Leds.MIN_LED_WAIT, led_wait);
	led_frame_timer.wait_time = led_wait * System.game_speed_multiplier;
	led_frame_timer.start();

func get_led_columns() -> Array:
	return [
		leds_left,
		leds_right
	];

func led_frame() -> void:
	System.Leds.shut_leds(red_led_index - RED_LED_SPEED, LEDS_PER_COLUMN, get_led_columns());
	System.Leds.shut_leds(current_led_row, LEDS_PER_COLUMN, get_led_columns());
	System.Leds.shut_leds(current_led_row + LEDS_BETWEEN_BURSTS, LEDS_PER_COLUMN, get_led_columns());
	System.Leds.shut_leds(current_led_row - LEDS_BETWEEN_BURSTS, LEDS_PER_COLUMN, get_led_columns());
	current_led_row = System.Leds.index_tick(current_led_row, LEDS_PER_COLUMN);
	for i in range(LEDS_IN_BURST - 1):
		System.Leds.light_leds(current_led_row - LEDS_BETWEEN_BURSTS + i, LEDS_PER_COLUMN, get_led_columns());
	for i in range(LEDS_IN_BURST):
		System.Leds.light_leds(current_led_row + i, LEDS_PER_COLUMN, get_led_columns());
	for i in range(LEDS_IN_BURST - 1):
		System.Leds.light_leds(current_led_row + LEDS_BETWEEN_BURSTS + i, LEDS_PER_COLUMN, get_led_columns());
	if current_led_row == LEDS_PER_COLUMN:
		current_led_row = 0;
	System.Leds.light_leds(red_led_index, LEDS_PER_COLUMN, get_led_columns(), red_led_color);
	red_led_index = System.Leds.index_tick(red_led_index, LEDS_PER_COLUMN, RED_LED_SPEED);
	if red_led_index < RED_LED_SPEED:
		red_led_color = Led.LedColor.RED;
		if System.Random.chance(RED_LED_COLOR_CHANGE_CHANCE):
			red_led_color = Led.LedColor.BLUE;
			if System.Random.chance(RED_LED_COLOR_CHANGE_CHANCE * RED_LED_COLOR_CHANGE_CHANCE):
				red_led_color = Led.LedColor.YELLOW;

func _on_card_spawn_timer_timeout() -> void:
	card_spawn_timer.stop();
	spawn_a_background_card();

func _on_auto_start_timer_timeout() -> void:
	auto_start_timer.stop();
	auto_start_level();
