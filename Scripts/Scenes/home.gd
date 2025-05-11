extends Home

@onready var scene_layer : Node2D = $SceneLayer;
@onready var background_music : AudioStreamPlayer2D = $BackgroundMusic;

func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if gameplay != null:
			close_gameplay();
			return;
		get_tree().quit();

func _ready() -> void:
	System.random.randomize();
	System.create_directories();
	DisplayServer.window_set_current_screen(System.Display);
	set_process_input(true);
	save_data = System.Data.load_save_data();
	open_starting_scene();
	load_music();

func open_starting_scene() -> void:
	if save_data.tutorial_levels_won < 0:
		spawn_introduction_level();
		return;
	open_nexus();

func spawn_introduction_level() -> void:
	open_gameplay(System.Data.read_level(System.Levels.INTRODUCTION_LEVEL));

func open_nexus() -> void:
	nexus = System.Instance.load_child(NEXUS_PATH, scene_layer);
	nexus.enter_level.connect(open_gameplay);
	nexus.init(max(0, save_data.tutorial_levels_won));
	
func open_gameplay(level_data_ : LevelData) -> void:
	level_data = level_data_;
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);
	gameplay.init(level_data);
	if System.Instance.exists(nexus):
		nexus.queue_free();

func _on_game_over(did_win : bool) -> void:
	if did_win:
		process_victory();
	else:
		process_loss();
	close_gameplay();

func close_gameplay() -> void:
	var old_scene : Gameplay = gameplay;
	open_nexus();
	old_scene.queue_free();

func load_music() -> void:
	var song : Resource = System.Data.load_song(save_data.current_song);
	background_music.stream = song;
	background_music.play();

func _on_background_music_finished() -> void:
	var song_id : int;
	save_data.last_played_songs.append(save_data.current_song);
	if save_data.last_played_songs.size() > Config.MAX_SONG_ID / 3:
		save_data.last_played_songs.remove_at(0);
	while true:
		song_id = System.random.randi_range(1, Config.MAX_SONG_ID);
		if save_data.last_played_songs.has(song_id):
			continue;
		save_data.current_song = song_id;
		break;
	save_data.write();
	load_music();

func process_victory() -> void:
	if save_data.tutorial_levels_won < level_data.id - 1:
		save_data.tutorial_levels_won += 1;
		save_data.write();

func process_loss() -> void:
	save_data.tutorial_levels_won = max(0, save_data.tutorial_levels_won);
	save_data.write();
