extends Home

@onready var scene_layer : Node2D = $SceneLayer;

func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit();

func _ready() -> void:
	System.random.randomize();
	System.create_directories();
	DisplayServer.window_set_current_screen(System.Display);
	set_process_input(true);
	open_nexus();
	
func open_nexus() -> void:
	nexus = System.Instance.load_child(NEXUS_PATH, scene_layer);
	nexus.enter_level.connect(open_gameplay);
	nexus.is_active = true;
	
func open_gameplay(level_data : LevelData) -> void:
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);
	gameplay.init(level_data);
	nexus.queue_free();

func _on_game_over() -> void:
	var old_scene : Gameplay = gameplay;
	open_nexus();
	old_scene.queue_free();
