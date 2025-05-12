const LED_CLOCK_ERROR : float = 0.001;

static func light_leds(index : int, leds_per_column : int, columns : Array, led_color : Led.LedColor = Led.LedColor.WHITE) -> void:
	var leds : Array = get_leds_on_row(index, leds_per_column, columns);
	for led in leds:
		led.on(led_color);

static func get_leds_on_row(index : int, leds_per_column : int, columns : Array) -> Array:
	var row : Array;
	if index < 0:
		index += leds_per_column;
	if index >= leds_per_column:
		index -= leds_per_column;
	for column in columns:
		row.append(column[index]);
	return row;

static func shut_leds(index : int, leds_per_column : int, columns : Array) -> void:
	var leds : Array = get_leds_on_row(index, leds_per_column, columns);
	for led in leds:
		led.off();

static func index_tick(index : int, leds_per_column : int, tick_speed : int = 1) -> float:
	index += tick_speed;
	if index >= leds_per_column:
		index -= leds_per_column;
	elif index < 0:
		index += leds_per_column;
	return index;
