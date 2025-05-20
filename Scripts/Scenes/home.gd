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
	if Input.is_action_just_pressed("ui_cancel"):
		if gameplay != null:
			close_gameplay();
			return;
		get_tree().quit();
	base_rotation_frame(delta);
	zoom_frame(delta);
	scene_layer.rotation_degrees = System.base_rotation;
	edges.rotation_degrees = System.base_rotation;
	if Config.DEV_MODE:
		process_dev_mode_shortcut_actions();

func process_dev_mode_shortcut_actions() -> void:
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit();
	if Input.is_action_just_pressed("slow_game"):
		set_game_speed(Config.MIN_GAME_SPEED);
		background_music.pitch_scale = System.game_speed;
	if Input.is_action_just_pressed("accelerate_game"):
		set_game_speed(System.game_speed + 1);
		background_music.pitch_scale = System.game_speed;
	if Input.is_action_just_pressed("screenshot"):
		System.Json.take_screenshot(self);
	if Input.is_action_just_pressed("toggle_auto_play"):
		System.auto_play = !System.auto_play;
		if System.auto_play and gameplay and gameplay.can_play_card:
			gameplay._on_auto_play_timer_timeout();
		elif !System.auto_play and gameplay and !gameplay.auto_play_timer.is_stopped():
			gameplay.can_play_card = true;
	if Input.is_action_just_pressed("card_for_you"):
		if gameplay:
			gameplay.player_one.spawn_card(Config.SPAWNED_CARD);
	if Input.is_action_just_pressed("card_for_opponent"):
		if gameplay:
			gameplay.player_two.spawn_card(Config.SPAWNED_CARD);
	if Input.is_action_just_pressed("hot_action_1") and gameplay:
		gameplay.time_stop_effect_in();
	if Input.is_action_just_pressed("hot_action_2") and gameplay:
		gameplay.time_stop_effect_out();
	if Input.is_action_just_pressed("hot_action_3") and gameplay:
		pass;

func open_starting_scene() -> void:
	if save_data.tutorial_levels_won < 0 and Config.SHOWCASE_CARD_ID == 0:
		spawn_introduction_level();
		return;
	open_nexus();

func spawn_introduction_level(level_index : int = System.Levels.INTRODUCTION_LEVEL) -> void:
	open_gameplay(System.Data.read_level(level_index));

func open_nexus() -> void:
	if Config.AUTO_LEVEL != 0:
		spawn_introduction_level(Config.AUTO_LEVEL);
		return;
	nexus = System.Instance.load_child(NEXUS_PATH, scene_layer);
	nexus.enter_level.connect(_on_open_gameplay);
	nexus.page_changed.connect(_on_nexus_page_changed);
	nexus.death.connect(_on_roguelike_death);
	nexus.save.connect(_on_roguelike_save);
	System.game_speed = 1;
	nexus.init(max(0, save_data.tutorial_levels_won), save_data.open_page, save_data.roguelike_data);
	save_data.roguelike_data.lost_heart = false;

func _on_roguelike_save() -> void:
	save_data.roguelike_data = nexus.roguelike_page.data;
	save_data.write();

func _on_roguelike_death() -> void:
	save_data.roguelike_data = RoguelikeData.new();
	save_data.write();
	nexus.update_roguelike_data(save_data.roguelike_data);

func _on_nexus_page_changed(open_page : Nexus.NexusPage) -> void:
	save_data.open_page = open_page;
	save_data.write();

func _on_open_gameplay(level_data_ : LevelData) -> void:
	level_data = level_data_;
	zoom_in(level_data.position);

func in_roguelike_mode() -> bool:
	return save_data.open_page == Nexus.NexusPage.ROGUELIKE;

func open_gameplay(level_data_ : LevelData = level_data) -> void:
	level_data = level_data_;
	if in_roguelike_mode():
		write_roguelike_decks();
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_over);
	gameplay.zoom_to.connect(_on_zoom_to);
	gameplay.quick_zoom_to.connect(_on_quick_zoom_to);
	gameplay.play_song.connect(_on_play_song);
	gameplay.stop_music.connect(_on_stop_music);
	gameplay.stop_music_if_special.connect(_on_stop_music_if_special);
	gameplay.play_prev_song.connect(_on_play_prev_song);
	gameplay.init(level_data);
	if System.Instance.exists(nexus):
		nexus.queue_free();
	reset_base_rotation();
	reset_camera();

func write_roguelike_decks() -> void:
	var chosen_opponent : int = save_data.roguelike_data.chosen_opponent;
	var gun_chance : int = Decklist.DEFAULT_GUN_CHANCE + (1 if chosen_opponent == GameplayEnums.Character.JUKULIUS else 0);
	System.Data.write_decklist(1000, save_data.roguelike_data.your_cards, gun_chance);
	System.Data.write_decklist(1000 + chosen_opponent, \
		save_data.roguelike_data.all_opponents[chosen_opponent].cards, gun_chance);

func _on_stop_music_if_special() -> void:
	if save_data.current_song < 1000:
		is_song_locked = true;
		return;
	_on_stop_music();

func _on_play_prev_song() -> void:
	if is_song_locked:
		is_song_locked = false;
		return;
	save_data.current_song = prev_song;
	is_song_locked = true;
	load_music();
	background_music.play(prev_song_position);
	await System.wait(0.2);
	is_song_locked = false;

func _on_stop_music() -> void:
	if save_data.current_song < 1000:
		prev_song = save_data.current_song;
		prev_song_position = background_music.get_playback_position();
		save_data.current_song = 1001;
	background_music.stop();

func _on_play_song(song_id : int, pitch : float) -> void:
	save_data.current_song = song_id;
	load_music(pitch);

func reset_base_rotation() -> void:
	min_base_rotation_error = 1;
	max_base_rotation_error = 1;
	base_rotation_left_speed_error = 1;
	base_rotation_right_speed_error = 1;

func _on_game_over(did_win : bool) -> void:
	save_data.roguelike_data.money += gameplay.player_one.points;
	if did_win:
		process_victory();
	else:
		process_loss();
	save_data.roguelike_data.get_new_choices();
	save_data.write();
	close_gameplay();

func close_gameplay() -> void:
	var old_scene : Gameplay = gameplay;
	open_nexus();
	old_scene.queue_free();

func _on_background_music_finished() -> void:
	var song_id : int;
	if is_song_locked:
		return;
	save_data.last_played_songs.append(save_data.current_song);
	if save_data.last_played_songs.size() > Config.WAIT_BEFORE_SONG_TO_REPEAT:
		save_data.last_played_songs.remove_at(0);
	if save_data.current_song == 1001 and !save_data.last_played_songs.has(1002):
		save_data.current_song = 1002;
	elif level_data and level_data.song_id != 1 and \
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
	give_opponent_card_drop(true);
	give_opponent_card_drop();
	if save_data.tutorial_levels_won < level_data.id - 1:
		save_data.tutorial_levels_won += 1;
		save_data.tutorial_levels_won = min(System.Levels.MAX_TUTORIAL_LEVELS, save_data.tutorial_levels_won);

func process_loss() -> void:
	save_data.tutorial_levels_won = max(0, save_data.tutorial_levels_won);
	if in_roguelike_mode():
		save_data.roguelike_data.lives_left -= 1;
		save_data.roguelike_data.lost_heart = true;
		give_opponent_card_drop();

func give_opponent_card_drop(confirmed_rare : bool = false) -> void:
	var chosen_opponent : int = save_data.roguelike_data.chosen_opponent;
	var opponent : Dictionary = save_data.roguelike_data.all_opponents[chosen_opponent];
	var card_pool : Dictionary = opponent.card_pool;
	if card_pool.keys().is_empty():
		return;
	var rare_chance : int = opponent.rare_chance;
	var source : Array = card_pool[CollectionEnums.Rarity.RARE] if confirmed_rare or System.Random.chance(rare_chance) else card_pool[CollectionEnums.Rarity.COMMON];
	var card_drop : int = System.Random.item(source);
	if rare_chance <= 0:
		return;
	opponent.cards.append(card_drop);
