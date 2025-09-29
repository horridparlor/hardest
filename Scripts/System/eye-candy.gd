const VICTORY_POPPET_SPEED : float = 0.26;
const MIN_VICTORY_POPPETS : int = 50;
const MAX_VICTORY_POPPETS : int = 100;
const MAX_CARD_POPPETS : int = 40;
const POPPETS_RANDOM_ADDITION : int = 10;

static func spawn_negative_drained_poppet(card : CardData, player : Player, gameplay : Gameplay) -> int:
	var poppet : Poppet;
	var drained : int;
	var color_pool : Dictionary = {
		Poppet.PoppetColor.BLUE: 1,
		Poppet.PoppetColor.RED: 2,
		Poppet.PoppetColor.GOLD: 5,
		Poppet.PoppetColor.RAINBOW: 20
	};
	var chosen_color : Poppet.PoppetColor;
	var points : int = 1;
	if player.points < 1:
		return drained;
	if player.points < 3 and System.Random.chance(5):
		color_pool.erase(Poppet.PoppetColor.RED);
	if player.points < 10 and System.Random.chance(20):
		color_pool.erase(Poppet.PoppetColor.GOLD);
	if player.points < 40 and System.Random.chance(100):
		color_pool.erase(Poppet.PoppetColor.RAINBOW);
	chosen_color = System.Random.item(color_pool.keys());
	for i in range(System.random.randi_range(1, 6 if chosen_color == Poppet.PoppetColor.BLUE else 1)):
		if player.points < color_pool[chosen_color]:
			break;
		player.points -= color_pool[chosen_color];
		drained += color_pool[chosen_color];
		gameplay.update_point_visuals();
		poppet = spawn_poppet_for_card(card, player, gameplay, chosen_color, true);
		gameplay.above_cards_layer.remove_child(poppet);
		gameplay.cards_layer2.add_child(poppet);
		if gameplay.get_card(card):
			poppet.set_goal_node(gameplay.get_card(card));
	return drained;

static func spawn_poppets(points : int, card : CardData, player : Player, gameplay : Gameplay) -> void:
	var color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE;
	var count : int = points;
	var extra_count : int;
	var is_negative : bool = points < 0;
	if is_negative:
		points = abs(points);
		count = abs(count);
	if points > 19:
		color = Poppet.PoppetColor.RAINBOW;
		count /= 9;
		extra_count = points - 5 * count + System.random.randi_range(0, 5);
	elif points > 4:
		color = Poppet.PoppetColor.GOLD;
		count /= 4;
		extra_count = points - 4 * count + System.random.randi_range(0, 3);
	elif points > 1:
		color = Poppet.PoppetColor.RED;
		count /= 2;
		extra_count = points - 2 * count + System.random.randi_range(0, 1);
	for i in range(min(MAX_CARD_POPPETS, count)):
		spawn_poppet_for_card(card, player, gameplay, color, is_negative);
	for i in range(min(MAX_CARD_POPPETS, extra_count)):
		spawn_poppet_for_card(card, player, gameplay, Poppet.PoppetColor.BLUE, is_negative);

static func spawn_poppet_for_card(card : CardData, player : Player, gameplay : Gameplay, color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE, is_negative : bool = false) -> Poppet:
	var goal_position : Vector2
	if !gameplay.get_card(card):
		return;
	goal_position = (gameplay.your_point_panel.position if player == gameplay.player_one else gameplay.opponents_point_panel.position) + Vector2(235, 95) + Vector2(System.random.randf_range(-130, 130), System.random.randf_range(-50, 50));
	return spawn_poppet(gameplay.get_card(card).position + System.Random.vector(0, 50), goal_position, gameplay, color, is_negative);

static func spawn_poppet(spawn_position : Vector2, goal_position : Vector2, gameplay : Gameplay, color : Poppet.PoppetColor, is_negative : bool = false) -> Poppet:
	var poppet : Poppet;
	poppet = System.Instance.load_child(System.Paths.POPPET, gameplay.above_cards_layer);
	poppet.position = spawn_position;
	poppet.rotation_degrees = System.random.randf_range(-40, 40);
	poppet.move_to(goal_position, color);
	if is_negative:
		poppet.make_negative();
		poppet.position = goal_position;
		poppet.goal_position = goal_position + Vector2(0, -System.Window_.y / 4);
	gameplay.poppets[poppet.instance_id] = poppet;
	return poppet;

static func spawn_victory_poppets(gameplay : Gameplay) -> void:
	var colors : Array = get_victory_poppet_colors(gameplay);
	var count : int = min(MAX_VICTORY_POPPETS, MIN_VICTORY_POPPETS + gameplay.player_one.points) + System.random.randi_range(-POPPETS_RANDOM_ADDITION, POPPETS_RANDOM_ADDITION);
	for i in range(count):
		spawn_victory_poppet(System.Random.item(colors), gameplay);

static func get_victory_poppet_colors(gameplay : Gameplay) -> Array:
	var colors : Array = [Poppet.PoppetColor.BLUE];
	var points : int = gameplay.player_one.points;
	if points >= 10:
		colors.append(Poppet.PoppetColor.RED);
	if points >= 40:
		colors.append(Poppet.PoppetColor.GOLD);
	if points >= 100:
		colors.append(Poppet.PoppetColor.RAINBOW);
	return colors;

static func spawn_victory_poppet(color : Poppet.PoppetColor, gameplay : Gameplay) -> void:
	var y_margin : float = System.Window_.y / 2 + 2 * Poppet.MAX_SIZE.y / 2;
	var spawn_point : Vector2 = Vector2(System.random.randf_range(-System.Window_.x / 2, System.Window_.x / 2), y_margin);
	var goal_point : Vector2 = Vector2(System.random.randf_range(-System.Window_.x / 2, System.Window_.x / 2), -y_margin);
	var poppet : Poppet = spawn_poppet(spawn_point, goal_point, gameplay, color);
	poppet.speed *= VICTORY_POPPET_SPEED;

static func play_tentacles_shooting_animation(card : CardData, enemy : CardData, gameplay : Gameplay, do_zoom : bool = false, slow_down : bool = false, do_fade : bool = false) -> Array:
	var tentacles : Array;
	var gameplay_card : GameplayCard = gameplay.get_card(card);
	if !gameplay_card:
		return tentacles;
	var enemy_position : Vector2 = get_shooting_enemy_position(card, enemy, gameplay);
	var count : int = min(Gameplay.MAX_TENTACLES, (8 if !slow_down else 2) + (2 if !slow_down else 1) * get_count_of_bullets_shot(card));
	var tentacle : Tentacle;
	if count <= 0:
		return tentacles;
	for i in range(count):
		tentacle = System.Instance.load_child(System.Paths.TENTACLE, gameplay.cards_layer);
		if slow_down:
			tentacle.slow_down();
		if do_fade:
			tentacle.do_fade = true;
		tentacle.init(gameplay_card, gameplay.get_card(enemy), enemy_position, i < 2);
		tentacles.append(tentacle);
		if do_zoom and i == 0 and !do_fade:
			gameplay.zoom_to_node(tentacle);
	gameplay_card.recoil(-enemy_position);
	gameplay.move_card_front(gameplay_card);
	return tentacles;

static func play_bullets_shooting_animation(card : CardData, enemy : CardData, gameplay : Gameplay, do_zoom : bool = false, slow_down : bool = false) -> Array:
	var bullets : Array;
	var bullet : Bullet;
	if !gameplay.get_card(card):
		return bullets;
	var enemy_position : Vector2 = get_shooting_enemy_position(card, enemy, gameplay);
	var count : int = get_count_of_bullets_shot(card);
	if count <= 0:
		return bullets;
	for i in range(count):
		if i > 0:
			enemy_position += System.Random.vector(Gameplay.MIN_BULLET_MARGIN, Gameplay.MAX_BULLET_MARGIN);
		bullet = System.Data.load_bullet(card.bullet_id, gameplay.cards_layer);
		if slow_down:
			bullet.slow_down();
			bullet.position += System.Random.vector(0, 64);
		bullet.init(enemy_position - (gameplay.get_card(card).get_recoil_position() if gameplay.get_card(card) else Vector2.ZERO), i < 2);
		bullets.append(bullet);
		if do_zoom and i == 0:
			gameplay.zoom_to_node(bullet);
	if gameplay.get_card(card):
		gameplay.get_card(card).recoil(enemy_position);
	if card.shoots_wet_bullets():
		System.AutoEffects.make_card_wet(enemy, gameplay, true, false);
	return bullets;

static func get_shooting_enemy_position(card : CardData, enemy : CardData, gameplay : Gameplay) -> Vector2:
	return gameplay.get_card(enemy).get_recoil_position() if (enemy and gameplay.get_card(enemy)) else -gameplay.get_card(card).get_recoil_position();

static func get_count_of_bullets_shot(card : CardData) -> int:
	var count : int = 1;
	if card.stopped_time_advantage > 1:
		return -1;
	if CollectionEnums.TURRET_SHOOTING_CARDS.has(card.card_id):
		count = System.random.randi_range(5, 10);
		if card.has_rare_stamp():
			count *= 2;
	elif card.has_champion():
		count = System.random.randi_range(3, 5);
		if card.has_rare_stamp():
			count *= 2;
	elif card.has_pair():
		count = 2;
	if card.has_multiply() and count == 1 and card.get_multiplier() > 1:
		count = min(8, card.get_multiplier());
	if count == 1 and CollectionEnums.TRIPLE_SHOOTING_CARDS.has(card.card_id):
		count = 3;
	return count;

static func victim_effect(card : CardData, gameplay : Gameplay) -> void:
	gameplay.play_rattlesnake_sound();
	if gameplay.get_card(card):
		gameplay.get_card(card).rattlesnake_effect();

static func card_shine_effect(card : GameplayCard, gameplay : Gameplay) -> void:
	card.wet_effect(get_shine_effect_color(card.card_data.card_type));

static func get_shine_effect_color(card_type : CardEnums.CardType) -> Color:
	match card_type:
		CardEnums.CardType.ROCK:
			return GameplayCard.SHADER_COLOR_GREEN;
		CardEnums.CardType.PAPER:
			return GameplayCard.SHADER_COLOR_BLUE;
		CardEnums.CardType.SCISSORS:
			return GameplayCard.SHADER_COLOR_ORANGE;
		CardEnums.CardType.BEDROCK:
			return GameplayCard.SHADER_COLOR_NEON;
		CardEnums.CardType.ZIPPER:
			return GameplayCard.SHADER_COLOR_SILVER;
		CardEnums.CardType.ROCKSTAR:
			return GameplayCard.SHADER_COLOR_RED;
		CardEnums.CardType.ROCK:
			return GameplayCard.SHADER_COLOR_GREEN;
		CardEnums.CardType.ROCK:
			return GameplayCard.SHADER_COLOR_GREEN;
	return GameplayCard.SHADER_COLOR_GOLD;
