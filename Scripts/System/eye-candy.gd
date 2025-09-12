const VICTORY_POPPET_SPEED : float = 0.26;
const MIN_VICTORY_POPPETS : int = 50;
const MAX_VICTORY_POPPETS : int = 100;
const MAX_CARD_POPPETS : int = 40;
const POPPETS_RANDOM_ADDITION : int = 10;

static func spawn_poppets(points : int, card : CardData, player : Player, gameplay : Gameplay) -> void:
	var color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE;
	var count : int = points;
	var extra_count : int;
	if points > 12:
		color = Poppet.PoppetColor.RAINBOW;
		count /= 6;
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
		spawn_poppet_for_card(card, player, gameplay, color);
	for i in range(min(MAX_CARD_POPPETS, extra_count)):
		spawn_poppet_for_card(card, player, gameplay);

static func spawn_poppet_for_card(card : CardData, player : Player, gameplay : Gameplay, color : Poppet.PoppetColor = Poppet.PoppetColor.BLUE) -> void:
	var goal_position : Vector2
	if !gameplay.get_card(card):
		return;
	goal_position = (gameplay.your_point_panel.position if player == gameplay.player_one else gameplay.opponents_point_panel.position) + Vector2(235, 95) + Vector2(System.random.randf_range(-130, 130), System.random.randf_range(-50, 50));
	spawn_poppet(gameplay.get_card(card).position + System.Random.vector(0, 50), goal_position, gameplay, color);

static func spawn_poppet(spawn_position : Vector2, goal_position : Vector2, gameplay : Gameplay, color : Poppet.PoppetColor) -> Poppet:
	var poppet : Poppet;
	poppet = System.Instance.load_child(System.Paths.POPPET, gameplay.above_cards_layer);
	poppet.position = spawn_position;
	poppet.rotation_degrees = System.random.randf_range(-40, 40);
	poppet.move_to(goal_position, color);
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
