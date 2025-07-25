const CARDS_FOLDER_PATH : String = "Cards/";
const DECKLIST_FOLDER_PATH : String = "Decklists/";
const LEVEL_FOLDER_PATH : String = "Levels/";
const SONGS_FOLDER_PATH : String = "Songs/";
const BULLETS_FOLDER_PATH : String = "CardEffects/Bullets/";

const SAVE_DATA_PATH : String = "save-data";
const SOUL_BANKS_SAVE_PATH : String = "card-souls/";

const DEFAULT_SONG_DATA : Dictionary = {
	"id": 1,
	"name": "Beyond Redemption"
}

static func read_card(card_id : int) -> Dictionary:
	var data : Dictionary = System.Dictionaries.make_safe(System.Json.read_data(CARDS_FOLDER_PATH + str(card_id)), CardData.DEFAULT_DATA);
	if data.override_type == null:
		data.override_type = data.type;
	return data;

static func load_card(card_id : int) -> CardData:
	return CardData.from_json(read_card(card_id));

static func get_basic_card(card_type : CardEnums.CardType) -> CardData:
	return CardData.from_json(read_card(CardEnums.BasicIds[card_type]));

static func read_decklist(decklist_id : int) -> Decklist:
	var data : Dictionary;
	if decklist_id >= 1000:
		data = System.Json.read_save(DECKLIST_FOLDER_PATH + str(decklist_id));
	else:
		data = System.Json.read_data(DECKLIST_FOLDER_PATH + str(decklist_id));
	if System.Json.is_error(data):
		data = System.Json.read_data(DECKLIST_FOLDER_PATH + str(1));
	return Decklist.from_json(data);

static func write_decklist(decklist_id : int, cards : Array) -> void:
	var data : Dictionary = {
		"id": decklist_id,
		"title": "Roguelike decklist",
		"cards": cards
	};
	System.Json.write_save(data, DECKLIST_FOLDER_PATH + str(decklist_id));

static func read_level(level_id : int) -> LevelData:
	return LevelData.from_json(
		System.Json.read_data(LEVEL_FOLDER_PATH + str(level_id))
	);

static func fill_decklist(cards : Array) -> Dictionary:
	var decklist : Dictionary;
	for card in cards:
		match typeof(card):
			TYPE_DICTIONARY:
				if !decklist.has(card):
					decklist[card.id] = card.count;
				else:
					decklist[card.id] += card.count;
			TYPE_FLOAT:
				if !decklist.has(card):
					decklist[card] = 1;
				else:
					decklist[card] += 1;
	return decklist;

static func load_save_data() -> SaveData:
	var json : Dictionary = System.Json.read_save(SAVE_DATA_PATH);
	if System.Json.is_error(json):
		write_save_data(SaveData.DEFAULT_DATA);
	return SaveData.from_json(json);

static func write_save_data(data : Dictionary) -> void:
	System.Json.write_save(data, SAVE_DATA_PATH);

static func add_card_soul_to_character(character_id : GameplayEnums.Character, controller : GameplayEnums.Controller, card : CardData) -> void:
	var soul_bank : CardSoulBank = get_soul_bank(character_id, controller);
	soul_bank.add_card(card);
	soul_bank.save();

static func get_soul_bank(character_id : GameplayEnums.Character, controller : GameplayEnums.Controller) -> CardSoulBank:
	var soul_bank : CardSoulBank;
	var json : Dictionary = System.Json.read_save(SOUL_BANKS_SAVE_PATH + ("0" if controller == GameplayEnums.Controller.PLAYER_ONE else str(character_id)));
	if System.Json.is_error(json):
		soul_bank = CardSoulBank.new(character_id, controller);
	else:
		soul_bank = CardSoulBank.from_json(json);
	return soul_bank;

static func load_card_souls_for_character(character_id : int, controller : GameplayEnums.Controller,
	amount : int = System.Rules.MAX_HAND_SIZE - System.Rules.HAND_SIZE
) -> Array:
	var soul_bank : CardSoulBank = get_soul_bank(character_id, controller);
	var card_souls : Array = soul_bank.pull_cards(amount);
	soul_bank.save();
	return card_souls;

static func save_soul_bank(soul_bank : CardSoulBank) -> void:
	System.Json.write_save(soul_bank.to_json(), SOUL_BANKS_SAVE_PATH + str("0" if soul_bank.controller == GameplayEnums.Controller.PLAYER_ONE else soul_bank.character_id));

static func load_song(song_id : int) -> Resource:
	var song_data : Dictionary = System.Json.read_data(SONGS_FOLDER_PATH + str(song_id));
	song_data = System.Dictionaries.make_safe(song_data, DEFAULT_SONG_DATA);
	return load(System.Paths.SONG % song_data.name);

static func load_bullet(bullet_id : int, parent : Node) -> Bullet:
	var data : Dictionary = System.Json.read_data(BULLETS_FOLDER_PATH + str(bullet_id));
	var bullet_data : BulletData = BulletData.from_json(data);
	var bullet : Bullet = System.Instance.load_child(System.Paths.BULLET, parent);
	bullet.set_data(bullet_data);
	return bullet;
