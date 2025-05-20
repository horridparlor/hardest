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
#Current choices on nexus
var card_choices_left : Array;
var fight_choices : Array;
var lost_heart : bool;

func _init() -> void:
	lives_left = System.Rules.STARTING_LIVES;
	your_houses = get_starting_houses();
	card_goal = System.Rules.CARD_GOAL;
	money = System.Rules.STARTING_MONEY;
	rare_chance = System.random.randi_range(System.Rules.MIN_RARE_CHANCE, System.Rules.MAX_RARE_CHANCE);
	card_pool = get_card_pool(your_houses);
	
	your_cards = System.Rules.DEFAULT_CARDS;
	opponents = get_opponents();
	rare_opponents = get_rare_opponents();
	super_rare_opponents #? TODO;
	
	card_choices_left = get_starting_card_choices();
	fight_choices = get_starting_fight_choices();

func has_max_life(additional : int = 0) -> bool:
	return lives_left + additional >= System.Rules.STARTING_LIVES;

func get_starting_fight_choices() -> Array:
	return get_fight_choices([
		GameplayEnums.Character.ERIKA,
		GameplayEnums.Character.PETE,
		GameplayEnums.Character.LOTTE,
		GameplayEnums.Character.MARK,
		GameplayEnums.Character.RAISEN
	]);

func get_fight_choices(options : Array = opponents.keys()) -> Array:
	var choices : Array;
	var fight_id : int;
	for i in range(System.Rules.FIGHT_CHOICES):
		while true:
			fight_id = System.Random.item(options);
			if choices.has(fight_id):
				continue;
			break;
		choices.append(fight_id);
	return choices;

func get_card_choices() -> Array:
	var choices : Array;
	var pool : Array;
	var card_id : int;
	for i in range(System.Rules.CARD_CHOICES):
		if System.Random.chance(rare_chance):
			pool = card_pool[CollectionEnums.Rarity.RARE];
		else:
			pool = card_pool[CollectionEnums.Rarity.COMMON];
		while true:
			card_id = System.Random.item(pool);
			if choices.has(card_id):
				continue;
			break;
		choices.append(card_id);
	return choices;

func get_starting_card_choices() -> Array:
	var choices = [6, 7, 8];
	choices.shuffle();
	if System.Random.chance(rare_chance):
		choices.pop_back();
		choices.append(System.Random.item([
			12,
			14,
			15,
			18,
			19,
			20,
			22,
			23,
			27,
			28,
			30,
			32,
			37,
			40,
			41,
			46,
			47,
			53
		]));
		choices.shuffle();
	return choices;

func get_card_pool(houses : Array) -> Dictionary:
	var pool : Dictionary = {
		CollectionEnums.Rarity.COMMON: [],
		CollectionEnums.Rarity.RARE: []
	};
	for house in houses:
		for common in CollectionEnums.CARDS_TO_COLLECT[house][CollectionEnums.Rarity.COMMON]:
			pool[CollectionEnums.Rarity.COMMON].append(common);
		for rare in CollectionEnums.CARDS_TO_COLLECT[house][CollectionEnums.Rarity.RARE]:
			pool[CollectionEnums.Rarity.RARE].append(rare);
	return pool;

func get_opponents() -> Dictionary:
	return {
		GameplayEnums.Character.ERIKA: {
			"cards": [
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
			"rare_chance": 2
		},
		GameplayEnums.Character.PETE: {
			"cards": [
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
			"rare_chance": 6
		},
		GameplayEnums.Character.LOTTE: {
			"cards": [
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
			"rare_chance": 3
		},
		GameplayEnums.Character.MARK: {
			"cards": [
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
			"rare_chance": 4
		},
		GameplayEnums.Character.KORVEK: {
			"cards": [
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
			"rare_chance": 4
		},
		GameplayEnums.Character.RAISEN: {
			"cards": [
				41,
				44,
				45,
				
				13
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.KAWAII
			]),
			"rare_chance": 5
		},
		GameplayEnums.Character.SIMOONI: {
			"cards": [
				47,
				48,
				49,
				
				46
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.HIGHTECH
			]),
			"rare_chance": 5
		},
		GameplayEnums.Character.JUKULIUS: {
			"cards": [
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
			"rare_chance": 1
		},
		GameplayEnums.Character.MERITUULI: {
			"cards": [
				31,
				32,
				33,
				34,
				
				39,
				
				40,
				35
			],
			"card_pool": get_card_pool([
				CollectionEnums.House.HIGHTECH,
				CollectionEnums.House.KAWAII
			]),
			"rare_chance": 0
		},
		GameplayEnums.Character.AGENT: {
			"cards": [
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
			"rare_chance": 2
		}
	};

func get_rare_opponents() -> Dictionary:
	return {
		GameplayEnums.Character.PEITSE: {
			"cards": [],
			"card_pool": [],
			"rare_chance": 0
		}
	};

func get_starting_houses() -> Array:
	var houses : Array = [CollectionEnums.House.DELUSIONAL];
	var other_houses : Array = [
		CollectionEnums.House.CHAMPION,
		CollectionEnums.House.DEMONIC,
		CollectionEnums.House.HIGHTECH,
		CollectionEnums.House.KAWAII	
	];
	var extra_houses : int;
	while true:
		if System.Random.chance(System.Rules.EXTRA_STARTING_HOUSE_CHANCE):
			extra_houses += 1;
			if extra_houses == 4:
				break;
		else:
			break;
	other_houses.shuffle();
	for i in range(extra_houses):
		houses.append(other_houses.pop_back());
	return houses;

static func from_json(json : Dictionary) -> RoguelikeData:
	var data : RoguelikeData = RoguelikeData.new();
	data.eat_json(json);
	return data;

func eat_json(data : Dictionary) -> void:
	lives_left = data.lives_left;
	your_houses = data.your_houses;
	cards_bought = data.cards_bought;
	money = data.money;
	has_won = data.has_won;
	rare_chance = data.rare_chance;
	
	your_cards = data.your_cards;
	opponents = data.opponents;
	rare_opponents = data.rare_opponents;
	super_rare_opponents = data.super_rare_opponents;
	
	card_choices_left = data.card_choices_left;
	fight_choices = data.fight_choices;

func to_json() -> Dictionary:
	return {
		"lives_left": lives_left,
		"your_houses": your_houses,
		"cards_bought": cards_bought,
		"card_goal": card_goal,
		"money": money,
		"has_won": has_won,
		"rare_chance": rare_chance,
		"your_cards": your_cards,
		"opponents": opponents,
		"rare_opponents": rare_opponents,
		"super_rare_opponents": super_rare_opponents,
		"card_choices_left": card_choices_left,
		"fight_choices": fight_choices
	}
