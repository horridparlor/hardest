extends Node
class_name SpyData

var card : CardData;
var player : Player;
var opponent : Player;
var chain : int;
var zone : CardEnums.Zone;
var spy_type : GameplayEnums.SpyType;

func _init(
	card_ : CardData,
	player_ : Player,
	opponent_ : Player,
	chain_ : int = 1,
	zone_ : CardEnums.Zone = CardEnums.Zone.HAND,
	spy_type_ : GameplayEnums.SpyType = GameplayEnums.SpyType.FIGHT
) -> void:
	card = card_;
	player = player_;
	opponent = opponent_;
	chain = chain_;
	zone = zone_;
	spy_type = spy_type_;
