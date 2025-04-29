extends Nexus

@onready var level_buttons_layer : Node2D = $LevelButtons;
@onready var background_music : AudioStreamPlayer2D = $Background/BackgroundMusic;

func _ready() -> void:
	var save_data : Dictionary = System.Data.read_save_data();
	spawn_level_buttons(save_data);

func spawn_level_buttons(save_data : Dictionary) -> void:
	var current_position : Vector2 = LEVEL_BUTTONS_STARTING_POSITION;
	var button : LevelButton;
	var buttons : int;
	for i in range(System.Rules.MAX_LEVELS):
		button = System.Instance.load_child(LEVEL_BUTTON_PATH, level_buttons_layer);
		button.position = current_position;
		current_position.x += LEVEL_BUTTON_X_MARGIN;
		buttons += 1;
		button.init(System.Data.read_level(i + 1));
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
