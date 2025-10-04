extends PointMeter

@onready var goal_points : Label = $GoalPoints;
@onready var extra_led_timer : Timer = $Timers/ExtraLedTimer;
@onready var negative_led_timer : Timer = $Timers/NegativeLedTimer;

@onready var point_led_1 : PointLed = $PointLed1;
@onready var point_led_2 : PointLed = $PointLed2;
@onready var point_led_3 : PointLed = $PointLed3;
@onready var point_led_4 : PointLed = $PointLed4;
@onready var point_led_5 : PointLed = $PointLed5;
@onready var point_led_6 : PointLed = $PointLed6;

func _ready() -> void:
	leds = get_point_leds();

func set_max_points(max_points_ : int) -> void:
	max_points = max_points_;
	goal_points.text = str(max_points);

func set_points(points : int) -> void:
	var leds_to_light : Array = get_leds_to_light(points);
	shut_leds();
	for led in leds_to_light:
		led.on();
		led.visible = true;
	if points > max_points:
		light_extra_leds(points);
	if points < 0:
		light_negative_leds(points);

func get_leds_to_light(points : int) -> Array:
	var leds_to_light : Array;
	if points >= max_points:
		return get_point_leds();
	elif points == 0:
		return leds_to_light;
	if points > 0:
		leds_to_light.append(point_led_1);
	if points > 1/5.0 * max_points:
		leds_to_light.append(point_led_2);
	if points > 2/5.0 * max_points:
		leds_to_light.append(point_led_3);
	if points > 3/5.0 * max_points:
		leds_to_light.append(point_led_4);
	if points > 4/5.0 * max_points:
		leds_to_light.append(point_led_5);
	return leds_to_light + get_negatives_to_light(points);

func get_negatives_to_light(points : int) -> Array:
	var leds : Array;
	var index : float;
	if points >= 0:
		return leds;
	for led in negative_leds:
		if index == 0:
			index += 1;
			continue;
		if points > min_points * abs(index / negative_leds.size()):
			leds.append(led);
		index += 1;
	return leds;

func shut_leds() -> void:
	for led in get_point_leds() + negative_leds:
		led.off();

func get_point_leds() -> Array:
	return [
		point_led_1,
		point_led_2,
		point_led_3,
		point_led_4,
		point_led_5,
		point_led_6	
	];

func light_extra_led() -> void:
	var led : PointLed;
	led = System.Instance.load_child(System.Paths.POINT_LED, self);
	leds.append(led);
	led.on();
	led.position = led_position;
	led_position += EXTRA_LEDS_MARGIN;
	extra_leds_to_light -= 1;
	if extra_leds_to_light == 0:
		return;
	extra_led_timer.wait_time = System.random.randf_range(EXTRA_LEDS_MIN_BETWEEN_WAIT, EXTRA_LEDS_MAX_BETWEEN_WAIT) * System.game_speed_multiplier;
	extra_led_timer.start();

func light_negative_led() -> void:
	var led : PointLed;
	led = System.Instance.load_child(System.Paths.POINT_LED, self);
	leds.append(led);
	negative_leds.append(led);
	led.off();
	led.position = negative_led_position;
	negative_led_position -= EXTRA_LEDS_MARGIN;
	negative_leds_to_light -= 1;
	if negative_leds_to_light == 0:
		return;
	negative_led_timer.wait_time = System.random.randf_range(NEGATIVE_LEDS_MIN_BETWEEN_WAIT, NEGATIVE_LEDS_MAX_BETWEEN_WAIT) * System.game_speed_multiplier;
	negative_led_timer.start();

func _on_extra_led_timer_timeout() -> void:
	extra_led_timer.stop();
	light_extra_led();

func get_nodes() -> Array:
	var nodes : Array;
	var led : PointLed;
	for l in leds:
		led = l;
		nodes += led.get_nodes();
	return nodes;

func _on_negative_led_timer_timeout() -> void:
	negative_led_timer.stop();
	light_negative_led();

func mirror() -> void:
	goal_points.position.x = -goal_points.size.x + 20;

func reset_leds() -> void:
	extra_leds_to_light = 0;
	extras_lit = 0;
	negative_leds_to_light = 0;
	negatives_lit = 0;
	for led in negative_leds:
		led.queue_free();
	for led in leds:
		if !get_point_leds().has(led):
			led.queue_free();
