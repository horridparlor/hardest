extends GlowNode
class_name GameplayCard

signal pressed(_self)
signal released(_self)
signal despawned(_self)

const MIN_SCALE = 0.2;
const MAX_SCALE = 1.0;
const MIN_SCALE_VECTOR : Vector2 = Vector2(MIN_SCALE, MIN_SCALE);
const MAX_SCALE_VECTOR : Vector2 = Vector2(MAX_SCALE, MAX_SCALE);
const SPEED : int = 6;
const SIZE : Vector2 = Vector2(MIN_SCALE * 900, MIN_SCALE * 1400);
const BORDER_WIDTH : int = 24;
const BORDER_RADIUS : int = 60;
const TYPE_ICON_PATH : String = "res://Assets/Art/CardIcons/%s_120.png";
const TYPE_FONT_SIZE_BIG : int = 128;
const TYPE_FONT_SIZE_SMALL : int = 128;
const CARD_ART_PATH : String = "res://Assets/Art/CardArt/%s.png";
const ROTATION_SPEED : float = 0.12;

const ROCK_BG_COLOR = "#008242";
const ROCK_BORDER_COLOR = "#7bffc3";
const PAPER_BG_COLOR = "#3683cf";
const PAPER_BORDER_COLOR = "#92cffd";
const SCISSORS_BG_COLOR = "#f9662d";
const SCISSORS_BORDER_COLOR = "#ffbf8d";
const MIMIC_BG_COLOR = "#b420b6";
const MIMIC_BORDER_COLOR = "#fbcafb";
const GUN_BG_COLOR = "#a2a037";
const GUN_BORDER_COLOR = "#fbe100";

const CARD_SCALE : Dictionary = {
	CardEnums.Zone.DECK: MIN_SCALE_VECTOR,
	CardEnums.Zone.HAND: MIN_SCALE_VECTOR,
	CardEnums.Zone.FIELD: MIN_SCALE_VECTOR,
	CardEnums.Zone.GRAVE: MIN_SCALE_VECTOR
}

var card_data : CardData = CardData.new();
var is_moving : bool;
var following_mouse : bool;
var goal_position : Vector2;
var starting_position : Vector2;
var is_despawning : bool;

func init() -> void:
	rescale(true);
	update_visuals();
	activate_animations();

func update_visuals() -> void:
	pass;

func rescale(is_instant : bool = false) -> void:
	if is_instant:
		scale = CARD_SCALE[card_data.zone];
		return;

func _process(delta: float) -> void:
	if !(is_moving or following_mouse):
		return;
	move_card(delta);

func move_card(delta : float) -> void:
	var card_margin : Vector2 = GameplayCard.SIZE / 2;
	var original_position : Vector2 = position;
	position = System.Vectors.slide_towards(position, (get_local_mouse_position() - starting_position) if following_mouse else goal_position, SPEED, delta);
	if is_moving and System.Vectors.equal(position, goal_position):
		is_moving = false;
		if is_despawning:
			emit_signal("despawned", self);
	if following_mouse:
		position = Vector2(
			min(System.Window_.x / 2 - card_margin.x, max(position.x, -System.Window_.x / 2 + card_margin.x)),
			min(System.Window_.y / 2 - card_margin.y, max(position.y, -System.Window_.y / 2 + card_margin.y))
		);
	rotate_card(position - original_position, delta);

func rotate_card(position_change : Vector2, delta : float) -> void:
	if !System.Vectors.equal(position_change):
		rotation_degrees += ROTATION_SPEED * position_change.x;
	rotation_degrees = System.Scale.baseline(rotation_degrees, 0, delta);

func toggle_follow_mouse(value : bool = true) -> void:
	following_mouse = value;
	starting_position = get_local_mouse_position();
	starting_position.y = (starting_position.y + GameplayCard.SIZE.y) / 2;
	
func despawn() -> void:
	is_despawning = true;
	goal_position = Vector2(System.Window_.x, goal_position.y);
	is_moving = true;
