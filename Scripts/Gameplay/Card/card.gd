extends GameplayCard

@onready var name_label : Label = $NameLabel;
@onready var type_label : Label = $TypeLabel;
@onready var panel : Panel = $Panel;
@onready var left_type_icon : Sprite2D = $TypeIcons/LeftIcon;
@onready var right_type_icon : Sprite2D = $TypeIcons/RightIcon;
@onready var card_art : Sprite2D = $ArtLayer/CardArt;

func update_visuals() -> void:
	name_label.text = card_data.card_name;
	type_label.text = CardEnums.CardTypeName[card_data.card_type];
	type_label.add_theme_font_size_override("font_size", TYPE_FONT_SIZE_SMALL if card_data.card_type == CardEnums.CardType.SCISSORS else TYPE_FONT_SIZE_BIG);
	update_panel();
	update_type_icons();
	update_card_art();

func update_panel() -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = get_panel_bg_color();
	style.border_color = get_panel_border_color();
	style.border_width_left = BORDER_WIDTH;
	style.border_width_right = BORDER_WIDTH;
	style.border_width_top = BORDER_WIDTH;
	style.border_width_bottom = BORDER_WIDTH;
	style.corner_radius_top_left = BORDER_RADIUS;
	style.corner_radius_top_right = BORDER_RADIUS;
	style.corner_radius_bottom_left = BORDER_RADIUS;
	style.corner_radius_bottom_right = BORDER_RADIUS;
	panel.add_theme_stylebox_override("panel", style);

func update_type_icons() -> void:
	var sprite_texture : Resource = load(TYPE_ICON_PATH % [CardEnums.CardTypeName[card_data.card_type].to_lower()]);
	left_type_icon.texture = sprite_texture;
	right_type_icon.texture = sprite_texture;

func update_card_art() -> void:
	var art_texture : Resource = load(CARD_ART_PATH % [card_data.card_id]);
	card_art.texture = art_texture;

func get_panel_bg_color() -> String:
	match card_data.card_type:
		CardEnums.CardType.ROCK:
			return ROCK_BG_COLOR;
		CardEnums.CardType.PAPER:
			return PAPER_BG_COLOR;
		CardEnums.CardType.SCISSORS:
			return SCISSORS_BG_COLOR;
		CardEnums.CardType.GUN:
			return GUN_BG_COLOR;
	return MIMIC_BG_COLOR;

func get_panel_border_color() -> String:
	match card_data.card_type:
		CardEnums.CardType.ROCK:
			return ROCK_BORDER_COLOR;
		CardEnums.CardType.PAPER:
			return PAPER_BORDER_COLOR;
		CardEnums.CardType.SCISSORS:
			return SCISSORS_BORDER_COLOR;
		CardEnums.CardType.GUN:
			return GUN_BORDER_COLOR;
	return MIMIC_BORDER_COLOR;

func _on_button_pressed() -> void:
	emit_signal("pressed", self);

func _on_button_released() -> void:
	emit_signal("released", self);
