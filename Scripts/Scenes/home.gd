extends Home

@onready var scene_layer : Node2D = $SceneLayer;
@onready var edges : Node2D = $Edges;
@onready var roguelike_page : RoguelikePage = $RoguelikePage;

@onready var cards_back_layer : Node2D = $BackgroundCards/CardsBack;
@onready var cards_back_layer2 : Node2D = $BackgroundCards/CardsBack2;
@onready var cards_front_layer : Node2D = $BackgroundCards/CardsFront;
@onready var cards_front_layer2 : Node2D = $BackgroundCards/CardsFront2;

func init() -> void:
	background_music.finished.connect(_on_background_music_finished);
	init_roguelike_page();
	open_starting_scene();
	if save_data.next_song != 0:
		save_data.current_song = save_data.next_song;
		save_data.next_song = 0;
		load_music();
	else:
		_on_background_music_finished();

func init_roguelike_page() -> void:
	roguelike_page.set_origin_point();
	roguelike_page.visible = false;
	roguelike_page.roll_out();
	roguelike_page.death.connect(_on_roguelike_death);
	roguelike_page.enter_level.connect(func(level_data : LevelData): in_roguelike_mode = true; write_roguelike_decks(); _on_open_gameplay(level_data));
	roguelike_page.save.connect(_on_roguelike_save);

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !gameplay or !Config.DEV_MODE:
			get_tree().quit();
			return;
		replay_same_level();
	if Config.DO_ROTATE_SCREEN:
		base_rotation_frame(delta);
	zoom_frame(delta);
	scene_layer.rotation_degrees = System.base_rotation;
	edges.rotation_degrees = System.base_rotation;
	process_dev_mode_shortcut_actions();

func process_dev_mode_shortcut_actions() -> void:
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit();
	if !Config.DEV_MODE:
		return;
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
			gameplay.player_one.spawn_card_from_id(Config.SPAWNED_CARD);
	if Input.is_action_just_pressed("card_for_opponent"):
		if gameplay:
			gameplay.player_two.spawn_card_from_id(Config.SPAWNED_CARD);
	if Input.is_action_just_pressed("hot_action_1"):
		if gameplay:
			gameplay.time_stop_effect_in();
		elif nexus:
			nexus.next_showcase_card();
	if Input.is_action_just_pressed("hot_action_2"):
		if gameplay:
			gameplay.time_stop_effect_out();
		elif nexus:
			nexus.screenshot_showcase_card();
	if Input.is_action_just_pressed("hot_action_3") and gameplay:
		pass;
	if Input.is_action_just_pressed("host_game"):
		network.host(multiplayer);
	if Input.is_action_just_pressed("join_game"):
		network.join(multiplayer);

func open_starting_scene() -> void:
	if Config.SHOW_TITLE:
		System.Instance.load_child(System.Paths.TITLE, self);
		return;
	if Config.SHOWCASE_CARD_ID != 0:
		nexus = System.Instance.load_child(System.Paths.NEXUS, self);
		nexus.operate_showcase_layer();
		is_song_locked = true;
		return;
	if Config.AUTO_LEVEL != 0:
		in_roguelike_mode = false;
		open_gameplay(System.Data.read_level(Config.AUTO_LEVEL));
		return;
	if save_data.tutorial_levels_won < 0:
		spawn_introduction_level();
		return;
	if save_data.tutorial_levels_won < System.Levels.MAX_TUTORIAL_LEVELS:
		open_next_tutorial_level();
	else:
		in_roguelike_mode = true;
		open_roguelike_page_modal();
		open_roguelike_level_to_background();

func open_roguelike_level_to_background() -> void:
	var old_gameplay : Gameplay = gameplay;
	gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.is_preloaded = true;
	gameplay.init(roguelike_page.get_level_data(), false);
	if System.Instance.exists(old_gameplay):
		old_gameplay.queue_free();

func open_next_tutorial_level() -> void:
	if save_data.tutorial_levels_won == System.Levels.MAX_TUTORIAL_LEVELS:
		save_data.roguelike_data = RoguelikeData.new();
		open_roguelike_page_modal();
		return;
	open_gameplay(System.Data.read_level(save_data.tutorial_levels_won + 2));

func spawn_introduction_level(level_index : int = System.Levels.INTRODUCTION_LEVEL) -> void:
	open_gameplay(System.Data.read_level(level_index));

func _on_roguelike_save() -> void:
	save_data.roguelike_data = roguelike_page.data;
	save_data.write();

func _on_roguelike_death() -> void:
	save_data.roguelike_data = RoguelikeData.new();
	save_data.write();
	roguelike_page.init(save_data.roguelike_data);
	if System.Instance.exists(gameplay):
		gameplay.init(roguelike_page.get_level_data(), false);

func _on_open_gameplay(level_data_ : LevelData) -> void:
	old_gameplay = gameplay if System.Instance.exists(gameplay) and !gameplay.is_preloaded else null;
	level_data = level_data_;
	open_roguelike_level_to_background();
	zoom_in(level_data.position);

func open_gameplay(level_data_ : LevelData = level_data) -> void:
	level_data = level_data_;
	has_game_ended = false;
	if !System.Instance.exists(gameplay) or !gameplay.is_preloaded:
		if System.Instance.exists(gameplay):
			gameplay.queue_free();
		gameplay = System.Instance.load_child(GAMEPLAY_PATH, scene_layer);
	gameplay.game_over.connect(_on_game_ended);
	gameplay.zoom_to.connect(_on_zoom_to);
	gameplay.quick_zoom_to.connect(_on_quick_zoom_to);
	gameplay.play_song.connect(_on_play_song);
	gameplay.stop_music.connect(_on_stop_music);
	gameplay.stop_music_if_special.connect(_on_stop_music_if_special);
	gameplay.play_prev_song.connect(_on_play_prev_song);
	set_game_speed(1);
	if gameplay.is_preloaded:
		gameplay.is_preloaded = false;
		gameplay.init(level_data);
	else:
		gameplay.init(level_data);
	for node in [old_gameplay]:
		if System.Instance.exists(node):
			node.queue_free();
	stop_background_cards();
	reset_base_rotation();
	reset_camera();
	roguelike_page.roll_out();

func stop_background_cards() -> void:
	card_spawn_timer.stop();
	for card in background_cards.duplicate():
		if !System.Instance.exists(card):
			background_cards.erase(card);
			continue;
		card.dissolve(2);

func write_roguelike_decks() -> void:
	var chosen_opponent : int = save_data.roguelike_data.chosen_opponent;
	System.Data.write_decklist(1000, save_data.roguelike_data.your_cards.duplicate());
	System.Data.write_decklist(1000 + chosen_opponent, \
		save_data.roguelike_data.all_opponents[chosen_opponent].cards.duplicate());

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
	if Config.MUTE_MUSIC:
		return;
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

func _on_game_ended() -> void:
	if is_zooming or is_quick_zooming:
		gameplay.game_over_timer.start();
		return;
	has_game_ended = true;
	_on_game_over(gameplay.did_win);
	if in_roguelike_mode:
		open_roguelike_page_modal();
	else:
		if !gameplay.did_win and level_data.id != System.Levels.INTRODUCTION_LEVEL:
			replay_same_level(); 
		else:
			open_next_tutorial_level();
	save_data.roguelike_data.lost_heart = false;

func replay_same_level() -> void:
	open_gameplay(level_data);

func open_roguelike_page_modal() -> void:
	roguelike_page.init(save_data.roguelike_data);
	roguelike_page.visible = true;
	roguelike_page.roll_in();
	spawn_a_background_card();

func _on_game_over(did_win : bool) -> void:
	save_data.roguelike_data.money += gameplay.player_one.points;
	save_data.roguelike_data.point_goal = max(save_data.roguelike_data.point_goal + System.Rules.MIN_POINT_INCREASE, System.Rules.POINT_GOAL_MULTIPLIER * save_data.roguelike_data.point_goal);
	save_data.roguelike_data.rounds_played += 1;
	if did_win:
		process_victory();
	else:
		process_loss();
	if in_roguelike_mode:
		add_created_cards_to_decklists();
		remove_burned_cards_from_decklists();
		save_permanently_altered_cards_to_decklists();
	save_data.roguelike_data.get_new_choices(level_data.opponent, gameplay.player_one.decklist.burned_cards.size() > 0);
	save_data.write();

func remove_burned_cards_from_decklists() -> void:
	for spawn_id in gameplay.player_one.decklist.burned_cards:
		for card in save_data.roguelike_data.your_cards.duplicate():
			if card["spawn_id"] == spawn_id:
				save_data.roguelike_data.your_cards.erase(card);
				break;
	for spawn_id in gameplay.player_two.decklist.burned_cards:
		for card in save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.duplicate():
			if card["spawn_id"] == spawn_id:
				save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.erase(card);
				break;

func add_created_cards_to_decklists() -> void:
	var card : Dictionary;
	for c in gameplay.player_one.decklist.created_cards:
		card = c;
		save_data.roguelike_data.your_cards.append(card);
	for c in gameplay.player_two.decklist.created_cards:
		card = c;
		save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.append(card);				

func save_permanently_altered_cards_to_decklists() -> void:
	for spawn_id in gameplay.player_one.decklist.altered_cards:
		for card in save_data.roguelike_data.your_cards.duplicate():
			if card["spawn_id"] == spawn_id:
				save_data.roguelike_data.your_cards.erase(card);
				save_data.roguelike_data.your_cards.append(gameplay.player_one.decklist.altered_cards[spawn_id]);
				break;
	for spawn_id in gameplay.player_two.decklist.altered_cards:
		for card in save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.duplicate():
			if card["spawn_id"] == spawn_id:
				save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.erase(card);
				save_data.roguelike_data.all_opponents[save_data.roguelike_data.chosen_opponent].cards.append(gameplay.player_two.decklist.altered_cards[spawn_id]);
				break;

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
	if in_roguelike_mode:
		give_opponent_card_drop(save_data.roguelike_data.chosen_opponent, true);
		for id in save_data.roguelike_data.all_opponents.keys():
			give_opponent_card_drop(id);
	if save_data.tutorial_levels_won < level_data.id - 1:
		save_data.tutorial_levels_won += 1;
		save_data.tutorial_levels_won = min(System.Levels.MAX_TUTORIAL_LEVELS, save_data.tutorial_levels_won);

func process_loss() -> void:
	save_data.tutorial_levels_won = max(0, save_data.tutorial_levels_won);
	if in_roguelike_mode:
		save_data.roguelike_data.lives_left -= 1;
		save_data.roguelike_data.lost_heart = true;
		give_opponent_card_drop(save_data.roguelike_data.chosen_opponent);

func give_opponent_card_drop(opponent_id : int, confirmed_rare : bool = false) -> void:
	var opponent : Dictionary = save_data.roguelike_data.all_opponents[opponent_id];
	if typeof(opponent.card_pool) == TYPE_ARRAY or opponent.card_pool.keys().is_empty():
		return;
	var card_pool : Dictionary = opponent.card_pool;
	var rare_chance : int = opponent.rare_chance;
	var source : Array = card_pool[CollectionEnums.Rarity.RARE] if confirmed_rare or System.Random.chance(rare_chance) else card_pool[CollectionEnums.Rarity.COMMON];
	if System.Random.chance(max(System.Rules.MIN_GOD_CHANCE, System.Rules.ZESCANOR_CHANCE - save_data.roguelike_data.rounds_played * System.Rules.GOD_CHANCE_EASING * rare_chance)):
		source = CollectionEnums.CARDS_TO_COLLECT[CollectionEnums.House.GOD];
	var card_id : int = System.Random.item(source);
	var card_data : CardData = System.Data.load_card(card_id);
	var card_drop : Dictionary = {
		"id": card_id,
		"stamp": CardEnums.TranslateStampBack[save_data.roguelike_data.get_stamp_for_spawned_card(card_data, opponent.rare_chance)],
		"variant": CardEnums.TranslateVariantBack[save_data.roguelike_data.get_variant_for_spawned_card(card_data, opponent.rare_chance)],
		"is_holographic": save_data.roguelike_data.get_is_holo_for_spawned_card(opponent.rare_chance),
		"spawn_id": System.random.randi()
	};
	if opponent_id == GameplayEnums.Character.MERITUULI and !card_data.has_digital():
		card_drop.stamp = CardEnums.TranslateStampBack[CardEnums.Stamp.BLUETOOTH];
	if rare_chance <= 0:
		return;
	opponent.cards.append(card_drop);

func spawn_a_background_card() -> void:
	var is_back : bool = System.Random.boolean();
	var layer : Node2D = System.Random.item(
		[cards_back_layer, cards_back_layer2] if is_back \
		else [cards_front_layer, cards_front_layer2]	
	);
	var card : GameplayCard = instance_background_card(layer);
	card.despawned.connect(_on_card_despawned);
	card_spawn_timer.wait_time = System.random.randf_range(MIN_CARD_SPAWN_WAIT, MAX_CARD_SPAWN_WAIT) * System.game_speed_additive_multiplier;
	if is_back:
		card.scale *= BACKGROUND_CARDS_SCALE;
	if card.card_data.is_god():
		card.dissolve();
	card_spawn_timer.start();
	background_cards.append(card);

func _on_card_despawned(card : GameplayCard) -> void:
	background_cards.erase(card);
	if !System.Instance.exists(card):
		return;
	card.queue_free();
