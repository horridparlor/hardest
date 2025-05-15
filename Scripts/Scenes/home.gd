extends Home

@onready var scene_layer : Node2D = $SceneLayer;
@onready var edges : Node2D = $Edges;

func init() -> void:
	background_music.finished.connect(_on_background_music_finished);
	open_starting_scene();
	if save_data.next_song != 0:
		save_data.current_song = save_data.next_song;
		save_data.next_song = 0;
		load_music();
	else:
		_on_background_music_finished();

func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if gameplay != null:
			close_gameplay();
			return;
		get_tree().quit();
	base_rotation_frame(delta);
	zoom_frame(delta);
	scene_layer.rotation_degrees = System.base_rotation;
	edges.rotation_degrees = System.base_rotation;

func open_starting_scene() -> void:
	if save_data.tutorial_levels_won < 0 and Config.SHOWCASE_CARD_ID == 0:
		spawn_introduction_level();
		return;
	open_nexus();

func spawn_introduction_level() -> void:
	open_gameplay(System.Data.read_level(System.Levels.INTRODUCTION_LEVEL));

func open_nexus() -> void:
	nexus = System.Instance.load_child(NEXUS_PATH, scene_layer);
	nexus.enter_level.connect(_on_open_gameplay);
	nexus.init(max(0, save_data.tutorial_levels_won));

func _on_open_gameplay(level_data_ : LevelData) -> void:
	level_data = level_data_;
	zoom_in(level_data.position);

func open_gameplay(level_data_ : LevelData = level_data) -> void:
	level_data = level_data_;
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);
	gameplay.zoom_to.connect(_on_zoom_to);
	gameplay.quick_zoom_to.connect(_on_quick_zoom_to);
	gameplay.init(level_data);
	if System.Instance.exists(nexus):
		nexus.queue_free();
	reset_base_rotation();
	reset_camera();

func reset_base_rotation() -> void:
	min_base_rotation_error = 1;
	max_base_rotation_error = 1;
	base_rotation_left_speed_error = 1;
	base_rotation_right_speed_error = 1;

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

func _on_background_music_finished() -> void:
	var song_id : int;
	save_data.last_played_songs.append(save_data.current_song);
	if save_data.last_played_songs.size() > Config.WAIT_BEFORE_SONG_TO_REPEAT:
		save_data.last_played_songs.remove_at(0);
	if level_data and level_data.song_id != 1 and \
	!save_data.last_played_songs.has(level_data.song_id) and level_data.song_id != save_data.current_song:
		save_data.current_song = level_data.song_id;
	else:
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
		save_data.tutorial_levels_won = min(System.Levels.MAX_TUTORIAL_LEVELS, save_data.tutorial_levels_won);
		save_data.write();

func process_loss() -> void:
	save_data.tutorial_levels_won = max(0, save_data.tutorial_levels_won);
	save_data.write();
