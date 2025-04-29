extends GameplayCard

@onready var name_label : Label = $NameLabel;
@onready var type_label : Label = $TypeLabel;
@onready var panel : Panel = $Panel;
@onready var left_type_icon : Sprite2D = $TypeIcons/LeftIcon;
@onready var right_type_icon : Sprite2D = $TypeIcons/RightIcon;
@onready var card_art : Sprite2D = $ArtLayer/CardArt;
@onready var keywords_label : Label = $KeywordsLabel;
@onready var background_pattern : Sprite2D = $Pattern;

func update_visuals() -> void:
	if card_data.is_buried:
		bury();
		return;
	update_name_label(card_data.card_name);
	type_label.text = CardEnums.CardTypeName[card_data.card_type];
	type_label.add_theme_font_size_override("font_size", TYPE_FONT_SIZE_SMALL if card_data.card_type == CardEnums.CardType.SCISSORS else TYPE_FONT_SIZE_BIG);
	update_panel(card_data.card_type);
	update_type_icons(card_data.card_type);
	update_card_art();
	update_keywords_text(card_data.keywords);

func bury() -> void:
	card_data.is_buried = true;
	update_name_label("Buried");
	type_label.text = "???";
	update_keywords_text([CardEnums.Keyword.BURIED]);
	card_art.texture = null;
	update_panel(CardEnums.CardType.MIMIC);
	update_type_icons(CardEnums.CardType.MIMIC);

func update_name_label(message : String) -> void:
	name_label.text = message;
	name_label.add_theme_font_size_override("font_size", 88 if message.length() > 12 else 104);

func update_panel(card_type : CardEnums.CardType) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	var pattern : Resource = load(BACKGROUND_PATTERN_PATH % [CardEnums.CardTypeName[card_type]]);
	style.bg_color = get_panel_bg_color(card_type);
	style.border_color = get_panel_border_color(card_type);
	style.border_width_left = BORDER_WIDTH;
	style.border_width_right = BORDER_WIDTH;
	style.border_width_top = BORDER_WIDTH;
	style.border_width_bottom = BORDER_WIDTH;
	style.corner_radius_top_left = BORDER_RADIUS;
	style.corner_radius_top_right = BORDER_RADIUS;
	style.corner_radius_bottom_left = BORDER_RADIUS;
	style.corner_radius_bottom_right = BORDER_RADIUS;
	panel.add_theme_stylebox_override("panel", style);
	background_pattern.texture = pattern;

func update_type_icons(card_type : CardEnums.CardType) -> void:
	var sprite_texture : Resource = load(TYPE_ICON_PATH % [CardEnums.CardTypeName[card_type].to_lower()]);
	left_type_icon.texture = sprite_texture;
	right_type_icon.texture = sprite_texture;

func update_card_art() -> void:
	var art_texture : Resource = load(CARD_ART_PATH % [card_data.card_id]);
	card_art.texture = art_texture;

func update_keywords_text(keywords : Array) -> void:
	var keywords_text : Array;
	for keyword in keywords:
		keywords_text.append(CardEnums.KeywordNames[keyword] if CardEnums.KeywordNames.has(keyword) else "?");
	keywords_label.text = "\n".join(keywords_text);

func get_panel_bg_color(card_type : CardEnums.CardType) -> String:
	match card_type:
		CardEnums.CardType.ROCK:
			return ROCK_BG_COLOR;
		CardEnums.CardType.PAPER:
			return PAPER_BG_COLOR;
		CardEnums.CardType.SCISSORS:
			return SCISSORS_BG_COLOR;
		CardEnums.CardType.GUN:
			return GUN_BG_COLOR;
	return MIMIC_BG_COLOR;

func get_panel_border_color(card_type : CardEnums.CardType) -> String:
	match card_type:
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
