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
