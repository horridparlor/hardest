extends Node
class_name RoguelikeData

#General information
var lives_left : int;
var your_houses : Array;
var cards_bought : int;
var card_goal : int;
var money : int;
var has_won : bool;
var rare_chance : int;
var card_pool : Dictionary;
#Decklists
var your_cards : Array;
var opponents : Dictionary;
var rare_opponents : Dictionary;
var super_rare_opponents : Dictionary;
var all_opponents : Dictionary;
#Current choices on nexus
var card_choices_left : Array;
var next_opponent : int;
var lost_heart : bool;
var chosen_opponent : int;
var point_goal : int;
var rounds_played : int;
var has_seeded : bool;

func _init() -> void:
	lives_left = System.Rules.STARTING_LIVES;
	point_goal = System.Rules.VICTORY_POINTS;
	your_houses = get_starting_houses();
	card_goal = System.Rules.CARD_GOAL;
	money = System.Rules.STARTING_MONEY;
	rare_chance = System.random.randi_range(System.Rules.MIN_RARE_CHANCE, System.Rules.MAX_RARE_CHANCE);
	card_pool = get_card_pool(your_houses, true);
	
	your_cards = System.Rules.DEFAULT_CARDS;
	opponents = get_opponents();
	rare_opponents = get_rare_opponents();
	super_rare_opponents #? TODO;
	all_opponents = opponents.duplicate();
	for key in rare_opponents:
		all_opponents[key] = rare_opponents[key];
	for key in opponents:
		opponents[key] = null;
	for key in rare_opponents:
		rare_opponents[key] = null;
	for key in super_rare_opponents:
		super_rare_opponents[key] = null;
	for opponent_id in all_opponents:
		var new_cards : Array;
		for card in all_opponents[opponent_id].cards:
			new_cards.append({
				"id": card,
				"spawn_id": System.random.randi()
			});
		all_opponents[opponent_id].cards = new_cards;
	
	card_choices_left = get_starting_card_choices();
	next_opponent = get_starting_opponent();

func has_max_life(additional : int = 0) -> bool:
	return lives_left + additional >= System.Rules.STARTING_LIVES;

func get_starting_opponent() -> int:
	return System.Random.item([
		GameplayEnums.Character.ERIKA,
		GameplayEnums.Character.PETE,
		GameplayEnums.Character.LOTTE,
		GameplayEnums.Character.MARK,
		GameplayEnums.Character.RAISEN
	]);

func get_new_choices(current_opponent : int = 0, force_max_choices : bool = false) -> void:
	var opponent_choices : Array = opponents.keys();
	var picks : int = System.Rules.CARD_PICKS_PER_ROUND;
	if System.Random.chance(3) and !force_max_choices:
		picks -= 1;
	opponent_choices.erase(current_opponent);
	card_choices_left = [];
	for i in range(picks):
		card_choices_left.append(get_card_choices());
	next_opponent = get_next_opponent(opponent_choices);

func get_next_opponent(options : Array = opponents.keys()) -> int:
	var choices : Array;
	var fight_id : int = System.Random.item(options);
	if System.Random.chance(System.Rules.CHANCE_FOR_RARE_OPPONENT):
		fight_id = System.Random.item(rare_opponents.keys());
	return fight_id;

func get_card_choices(confirmed_rare : bool = false) -> Array:
	var choices : Array;
	var pool : Array;
	var card_id : int;
	var includes_scam : bool;
	var includes_god : bool;
	var card_data : CardData;
	var chosen_ids : Dictionary;
	var super_rares : Dictionary;
	var super_rares_amount : int;
	for card in card_pool[CollectionEnums.Rarity.SUPER_RARE]:
		super_rares[card] = null;
	for i in range(System.Rules.CARD_CHOICES):
		if confirmed_rare or System.Random.chance(rare_chance):
			pool = card_pool[CollectionEnums.Rarity.RARE];
			super_rares_amount = super_rares.keys().size();
			if super_rares_amount > 0 and System.Random.chance((pool.size() * System.Rules.SUPER_RARE_MULTIPLIER_TO_RARE + super_rares_amount) / super_rares_amount):
				pool = super_rares.keys();
		elif !includes_scam and System.Random.chance(System.Rules.SCAM_DROP_CHANCE):
			pool = CollectionEnums.ONLY_PLAYER_CARDS_TO_COLLECT[CollectionEnums.House.SCAM];
			includes_scam = true;
		elif !includes_god and System.Random.chance(max(System.Rules.MIN_GOD_CHANCE, System.Rules.ZESCANOR_CHANCE - rounds_played * System.Rules.GOD_CHANCE_EASING * rare_chance)):
			pool = CollectionEnums.CARDS_TO_COLLECT[CollectionEnums.House.GOD];
			includes_god = true;
		else:
			pool = card_pool[CollectionEnums.Rarity.COMMON];
		while true:
			card_id = System.Random.item(pool);
			if chosen_ids.has(card_id):
				continue;
			chosen_ids[card_id] = null;
			super_rares.erase(card_id);
			break;
		card_data = System.Data.load_card(card_id);
		choices.append({
			"id": card_id,
			"stamp": CardEnums.TranslateStampBack[get_stamp_for_spawned_card(card_data)],
			"variant": CardEnums.TranslateVariantBack[get_variant_for_spawned_card(card_data)],
			"is_holographic": get_is_holo_for_spawned_card(rare_chance)
		});
		card_data.queue_free();
	if Config.SEEDED_CARD != 0 and !has_seeded and cards_bought > System.random.randi_range(10, 20):
		choices[1].id = Config.SEEDED_CARD;
		has_seeded = true;
	return choices;

func get_is_holo_for_spawned_card(foil_chance : int = rare_chance) -> bool:
	return System.Random.chance(max(System.Rules.MIN_HOLO_CHANCE, System.Rules.HOLO_BASE_CHANCE + System.Rules.HOLO_CHANCE_MULTIPLIER * rare_chance - System.Rules.HOLO_CHANCE_EASING * rounds_played));

func get_stamp_for_spawned_card(card_data : CardData, rare_stamp_chance : int = rare_chance) -> CardEnums.Stamp:
	var possible_stamps : Array;
	if rounds_played >= System.Rules.RARE_STAMP_BECOMES_COMMON_AFTER_ROUND \
	or System.Random.chance(System.Rules.RARE_STAMP_CHANCE_MULTIPLIER):
		possible_stamps.append(CardEnums.Stamp.RARE);
	if !card_data.has_digital():
		possible_stamps.append(CardEnums.Stamp.BLUETOOTH);
	if !card_data.has_pair():
		possible_stamps.append(CardEnums.Stamp.DOUBLE);
	if !card_data.has_buried():
		possible_stamps.append(CardEnums.Stamp.MOLE);
	if possible_stamps.size() and System.Random.chance(System.Rules.STAMP_CHANCE + rare_stamp_chance - (rounds_played * System.Rules.STAMP_CHANCE_LESSENS_BY_ROUND)):
		return System.Random.item(possible_stamps);
	return CardEnums.Stamp.NULL;

func get_variant_for_spawned_card(card_data : CardData, variant_chance : int = rare_chance) -> CardEnums.CardVariant:
	var negative_chance : int = max(System.Rules.NEGATIVE_MIN_BASE_CHANCE, System.Rules.BASE_NEGATIVE_CARD_CHANCE - rounds_played * System.Rules.NEGATIVE_BASE_CHANCE_EASING_PER_ROUND) + variant_chance * max(System.Rules.NEGATIVE_MIN_MULTIPLIER, System.Rules.NEGATIVE_CARD_CHANCE_MULTIPLIER - rounds_played * System.Rules.NEGATIVE_MULTIPLIER_EASING_PER_ROUND);
	if System.Random.chance(negative_chance):
		return CardEnums.CardVariant.NEGATIVE;
	return CardEnums.CardVariant.REGULAR;

func get_starting_card_choices() -> Array:
	return [get_card_choices(true), get_card_choices(), get_card_choices()];

func get_card_pool(houses : Array, is_player : bool = false) -> Dictionary:
	var pool : Dictionary = {
		CollectionEnums.Rarity.COMMON: [],
		CollectionEnums.Rarity.RARE: [],
		CollectionEnums.Rarity.SUPER_RARE: []
	};
	for house in houses:
		for common in CollectionEnums.CARDS_TO_COLLECT[house][CollectionEnums.Rarity.COMMON] + \
		(CollectionEnums.ONLY_PLAYER_CARDS_TO_COLLECT[house][CollectionEnums.Rarity.COMMON] if is_player else []):
			pool[CollectionEnums.Rarity.COMMON].append(common);
		for rare in CollectionEnums.CARDS_TO_COLLECT[house][CollectionEnums.Rarity.RARE] + \
		(CollectionEnums.ONLY_PLAYER_CARDS_TO_COLLECT[house][CollectionEnums.Rarity.RARE] if is_player else []):
			pool[CollectionEnums.Rarity.RARE].append(rare);
		for super_rare in CollectionEnums.CARDS_TO_COLLECT[house][CollectionEnums.Rarity.SUPER_RARE] + \
		(CollectionEnums.ONLY_PLAYER_CARDS_TO_COLLECT[house][CollectionEnums.Rarity.SUPER_RARE] if is_player else []):
			pool[CollectionEnums.Rarity.SUPER_RARE].append(super_rare);
	return pool;

func get_opponents() -> Dictionary:
	return {
		GameplayEnums.Character.ERIKA: {
			"cards": [
				1,
				2,
				3,
				1,
				2,
				3,
				4,
				5
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.KAWAII,
				CollectionEnums.House.CHAMPION
			]),
			"rare_chance": 2,
			"song": 1,
			"backgrounds": [
				11,
				31
			]
		},
		GameplayEnums.Character.PETE: {
			"cards": [
				1,
				2,
				3,
				1,
				2,
				3,
				4,
				5,
				
				6,
				7,
				8
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.DELUSIONAL
			]),
			"rare_chance": 6,
			"song": 14,
			"backgrounds": [
				2,
				34
			]
		},
		GameplayEnums.Character.LOTTE: {
			"cards": [
				1,
				2,
				3,
				1,
				2,
				3,
				
				6,
				7,
				8,
				
				20,
				
				18,
				19
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.KAWAII,
				CollectionEnums.House.DELUSIONAL
			]),
			"rare_chance": 3,
			"song": 2,
			"backgrounds": [
				15,
				24,
			]
		},
		GameplayEnums.Character.MARK: {
			"cards": [
				9,
				10,
				11,
				9,
				10,
				11,
				
				15,
				16,
				17,
				
				27
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.DELUSIONAL,
				CollectionEnums.House.CHAMPION
			]),
			"rare_chance": 4,
			"song": 7,
			"backgrounds": [
				14,
				33
			]
		},
		GameplayEnums.Character.KORVEK: {
			"cards": [
				24,
				25,
				26,
				24,
				25,
				26,
				
				23,
				27
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.DEMONIC,
				CollectionEnums.House.CHAMPION
			]),
			"rare_chance": 4,
			"song": 5,
			"backgrounds": [
				5,
				26,
			]
		},
		GameplayEnums.Character.RAISEN: {
			"cards": [
				41,
				44,
				45,
				41,
				44,
				45,
				132,
				113,
				137,
				
				13
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.KAWAII
			]),
			"rare_chance": 5,
			"song": 6,
			"backgrounds": [
				6,
				32
			]
		},
		GameplayEnums.Character.SIMOONI: {
			"cards": [
				47,
				48,
				49,
				47,
				48,
				49,
				47,
				48,
				49,
				
				46
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.HIGHTECH
			]),
			"rare_chance": 5,
			"song": 10,
			"backgrounds": [
				18
			]
		},
		GameplayEnums.Character.JUKULIUS: {
			"cards": [
				36,
				37,
				38,
				31,
				32,
				33,
				
				36,
				37,
				38,
				31,
				32,
				33,
				
				40,
				
				39,
				46,
				57
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.CHAMPION,
				CollectionEnums.House.HIGHTECH,
				CollectionEnums.House.DELUSIONAL,
				CollectionEnums.House.DEMONIC
			]),
			"rare_chance": 1,
			"song": 1,
			"backgrounds": [
				9,
				30
			]
		},
		GameplayEnums.Character.MERITUULI: {
			"cards": [
				31,
				32,
				33,
				
				31,
				32,
				33,
				
				31,
				32,
				33,
				
				34,
				34,
				
				39,
				
				40
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.HIGHTECH,
				CollectionEnums.House.KAWAII
			]),
			"rare_chance": 4,
			"song": 3,
			"backgrounds": [
				4,
				25,
			]
		},
		GameplayEnums.Character.AGENT: {
			"cards": [
				1,
				2,
				3,
				1,
				2,
				3,
				4,
				5,
				
				53,
				54,
				55,
				
				19,
				27,
				39,
				46
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.CHAMPION,
				CollectionEnums.House.HIGHTECH
			]),
			"rare_chance": 2,
			"song": 15,
			"backgrounds": [
				10,
				22
			]
		},
		GameplayEnums.Character.SWARMYARD: {
			"cards": [
				8,
				14,
				24,
				29,
				52,
				56,
				73,
				80,
				89,
				94,
				94,
				94,
				107,
				100,
				111,
				111
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.SCISSOR
			]),
			"rare_chance": 3,
			"song": 21,
			"backgrounds": [
				20
			]
		},
		GameplayEnums.Character.SISTERS: {
			"cards": [
				1,
				2,
				3,
				5,
				20,
				20,
				60,
				91,
				92,
				93,
				94,
				113,
				119,
				
				136,
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.DIVINE,
				CollectionEnums.House.KAWAII
			]),
			"rare_chance": 4,
			"song": 22,
			"backgrounds": [
				23
			]
		}
	};

func get_rare_opponents() -> Dictionary:
	return {
		GameplayEnums.Character.PEITSE: {
			"cards": [],
			"card_pool": [],
			"rare_chance": 0,
			"song": 20,
			"backgrounds": [
				1
			]
		},
		GameplayEnums.Character.LOTTE_ANT_QUEEN: {
			"cards": [
				18,
				44,
				59,
				67,
				74,
				91,
				113,
				120,
				123,
				127,
				131
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.CHAMPION,
				CollectionEnums.House.DIVINE
			]),
			"rare_chance": 1,
			"song": 11,
			"backgrounds": [
				27,
				29
			]
		},
		GameplayEnums.Character.PETE_BADASS: {
			"cards": [
				101,
				102,
				103,
				110,
				121,
				122,
				122,
				124,
				124,
				125,
				125,
				128,
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.DELUSIONAL,
				CollectionEnums.House.DEMONIC
			]),
			"rare_chance": 2,
			"song": 12,
			"backgrounds": [
				28
			]
		}
	};

func get_starting_houses() -> Array:
	var houses : Array;
	var all_houses : Array = [
		CollectionEnums.House.CHAMPION,
		CollectionEnums.House.DELUSIONAL,
		CollectionEnums.House.DEMONIC,
		CollectionEnums.House.DIVINE,
		CollectionEnums.House.HIGHTECH,
		CollectionEnums.House.KAWAII	
	];
	var extra_houses : int = 0;
	while System.Random.chance(System.Rules.CHANCE_FOR_EXTRA_HOUSE):
		extra_houses += 1;
		if extra_houses == System.Rules.HOUSES_COUNT - System.Rules.STARTING_HOUSES_COUNT:
			break;
	all_houses.shuffle();
	for i in range(System.Rules.STARTING_HOUSES_COUNT + extra_houses):
		houses.append(all_houses.pop_back());
	if Config.AUTO_HOUSE != CollectionEnums.House.NULL:
		return [Config.AUTO_HOUSE];
	return houses;

static func from_json(json : Dictionary) -> RoguelikeData:
	var data : RoguelikeData = RoguelikeData.new();
	data.eat_json(json);
	return data;

func eat_json(data : Dictionary) -> void:
	data = System.Dictionaries.make_safe(data, {
		"rounds_played": 0,
		"has_seeded": false
	});
	lives_left = data.lives_left;
	point_goal = data.point_goal;
	rounds_played = data.rounds_played;
	your_houses = data.your_houses.map(func(house): return int(house));
	card_pool = get_card_pool(your_houses, true);
	cards_bought = data.cards_bought;
	money = data.money;
	has_won = data.has_won;
	rare_chance = data.rare_chance;
	has_seeded = data.has_seeded;
	
	your_cards = data.your_cards;
	for key in data.opponents:
		opponents[int(key)] = data.opponents[key];
	for key in data.rare_opponents:
		rare_opponents[int(key)] = data.rare_opponents[key];
	for key in data.super_rare_opponents:
		super_rare_opponents[int(key)] = data.super_rare_opponents[key];
	for key in data.all_opponents:
		all_opponents[int(key)] = convert_opponent(data.all_opponents[key]);
	
	card_choices_left = data.card_choices_left;
	next_opponent = data.next_opponent;

func convert_opponent(data : Dictionary) -> Dictionary:
	var card_pool : Dictionary;
	if data.card_pool.is_empty():
		data.card_pool = {};
		return data;
	card_pool[CollectionEnums.Rarity.COMMON] = data.card_pool[str(CollectionEnums.Rarity.COMMON)];
	card_pool[CollectionEnums.Rarity.RARE] = data.card_pool[str(CollectionEnums.Rarity.RARE)];
	card_pool[CollectionEnums.Rarity.SUPER_RARE] = data.card_pool[str(CollectionEnums.Rarity.SUPER_RARE)];
	data.card_pool = card_pool;
	return data;

func to_json() -> Dictionary:
	return {
		"lives_left": lives_left,
		"point_goal": point_goal,
		"rounds_played": rounds_played,
		"your_houses": your_houses,
		"cards_bought": cards_bought,
		"card_goal": card_goal,
		"money": money,
		"has_won": has_won,
		"rare_chance": rare_chance,
		"has_seeded": has_seeded,
		"your_cards": your_cards,
		"opponents": opponents,
		"rare_opponents": rare_opponents,
		"super_rare_opponents": super_rare_opponents,
		"all_opponents": all_opponents,
		"card_choices_left": card_choices_left,
		"next_opponent": next_opponent
	}
