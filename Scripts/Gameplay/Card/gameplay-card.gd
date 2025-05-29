extends GameplayCard

@onready var name_label : Label = $NameLabel;
@onready var type_label : Label = $TypeLabel;
@onready var panel : Panel = $Panel;
@onready var left_type_icon : Sprite2D = $TypeIcons/LeftIcon;
@onready var right_type_icon : Sprite2D = $TypeIcons/RightIcon;
@onready var card_art : Sprite2D = $ArtLayer/CardArt;
@onready var art_background : Panel = $ArtLayer/Panel;
@onready var keywords_label : Label = $KeywordsLabel;
@onready var background_pattern : Sprite2D = $Pattern;

func update_visuals(gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	if card_data.is_buried:
		bury();
		return;
	update_name_label(card_data.card_name);
	type_label.text = CardEnums.CardTypeName[card_data.card_type];
	type_label.add_theme_font_size_override("font_size", TYPE_FONT_SIZE_SMALL if card_data.card_type == CardEnums.CardType.SCISSORS else TYPE_FONT_SIZE_BIG);
	update_panel(card_data.card_type);
	update_type_icons(card_data.card_type);
	update_card_art();
	update_keywords_text(card_data.keywords.duplicate(), gained_keyword);
	if card_data.has_emp():
		update_emp_visuals();

func update_emp_visuals() -> void:
	if card_art.material:
		return;
	var shader : Resource = load("res://Shaders/CardEffects/emp-radiation-shader.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	card_art.material = shader_material;
	card_art.update_shader();

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

func update_card_art(do_full_art : bool = false) -> void:
	var art_texture : Resource = load((CARD_FULLART_PATH if do_full_art else CARD_ART_PATH) % [card_data.card_id]);
	var art_scale : float = MAX_SCALE if do_full_art else 1 / MIN_SCALE;
	card_art.texture = art_texture;
	card_art.scale = Vector2(art_scale, art_scale);

func update_keywords_text(keywords : Array, gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	var keywords_text : Array;
	if card_data.zone == CardEnums.Zone.HAND and gained_keyword != CardEnums.Keyword.NULL and !keywords.has(gained_keyword) and keywords.size() < System.Rules.MAX_KEYWORDS:
		keywords.push_back(gained_keyword);
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
		CardEnums.CardType.GOD:
			return GOD_BG_COLOR;
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
		CardEnums.CardType.GOD:
			return GOD_BORDER_COLOR;
	return MIMIC_BORDER_COLOR;

func _on_button_pressed() -> void:
	emit_signal("pressed", self);

func _on_button_released() -> void:
	emit_signal("released", self);

func get_dissolve_shader_material() -> ShaderMaterial:
	var shader : Resource = load("res://Shaders/CardEffects/card-dissolve.gdshader");
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	shader_material.set_shader_parameter("viewport_size", System.Window_);
	shader_material.set_shader_parameter("opacity", 1);
	return shader_material;

func dissolve() -> void:
	var shader_material : ShaderMaterial = get_dissolve_shader_material();
	var shader_material2 : ShaderMaterial = get_dissolve_shader_material();
	shader_material2.set_shader_parameter("opacity", 0.32);
	for node in get_shader_layers():
		node.material = shader_material;
	background_pattern.material = shader_material2;
	dissolve_speed = System.random.randf_range(MIN_DISSOLVE_SPEED, MAX_DISSOLVE_SPEED);
	is_dissolving = true;
	is_despawning = true;
	is_moving = false;

func get_shader_layers() -> Array:
	return [
		background_pattern,
		name_label,
		type_label,
		keywords_label,
		card_art,
		art_background,
		left_type_icon,
		right_type_icon,
		panel
	];

func dissolve_frame(delta : float) -> void:
	dissolve_value += dissolve_speed * delta * (FLOW_DISSOLVE_MULTIPLIER if is_flowing else 1);
	if dissolve_value >= MAX_DISSOLVE_VALUE:
		is_dissolving = false;
		emit_signal("despawned", self);
	panel.material.set_shader_parameter("threshold", dissolve_value);
	background_pattern.material.set_shader_parameter("threshold", dissolve_value);
