extends SpringButton

func _ready() -> void:
	pressed.connect(on_press);
	released.connect(on_release);

func _process(delta: float) -> void:
	var distance : float;
	if !is_pressing:
		return;
	distance = get_local_mouse_position().distance_to(pressed_position);
	if distance > MAX_RANGE_FROM_PRESSED:
		is_pressing = false;

func on_press() -> void:
	pressed_position = get_local_mouse_position();
	pressed_time = Time.get_unix_time_from_system();
	is_pressing = true;

func on_release() -> void:
	if !is_pressing:
		return;
	is_pressing = false;
	if Time.get_unix_time_from_system() - pressed_time > MAX_PRESS_TIME:
		return;
	emit_signal("triggered");
	
