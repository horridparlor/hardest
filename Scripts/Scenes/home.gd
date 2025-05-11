extends Home

@onready var scene_layer : Node2D = $SceneLayer;

func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if gameplay != null:
			_on_game_over();
			return;
		get_tree().quit();

func _ready() -> void:
	System.random.randomize();
	System.create_directories();
	DisplayServer.window_set_current_screen(System.Display);
	set_process_input(true);
	open_starting_scene();

func open_starting_scene() -> void:
	var save_data : Dictionary = System.Data.read_save_data();
	if save_data.levels_unlocked == 0:
		spawn_introduction_level(save_data);
		return;
	open_nexus();

func spawn_introduction_level(save_data : Dictionary) -> void:
	open_gameplay(System.Data.read_level(System.Levels.INTRODUCTION_LEVEL));

func open_nexus(music_position : float = 0) -> void:
	nexus = System.Instance.load_child(NEXUS_PATH, scene_layer);
	nexus.enter_level.connect(open_gameplay);
	nexus.init(music_position);
	
func open_gameplay(level_data : LevelData) -> void:
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);
	gameplay.init(level_data);
	if System.Instance.exists(nexus):
		nexus.queue_free();

func _on_game_over(music_position : float = 0) -> void:
	var old_scene : Gameplay = gameplay;
	open_nexus(music_position);
	old_scene.queue_free();
