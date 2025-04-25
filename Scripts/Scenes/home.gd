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
	open_gameplay();
	
func open_gameplay() -> void:
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);

func _on_game_over() -> void:
	var old_scene : Gameplay = gameplay;
	open_gameplay();
	old_scene.queue_free();
