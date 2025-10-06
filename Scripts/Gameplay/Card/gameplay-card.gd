extends GameplayCard

@onready var behind_layer : Node2D = $BehindLayer;
@onready var name_label : RichTextLabel = $NameLabel;
@onready var type_label : Label = $TypeLabel;
@onready var left_panel : Panel = $LeftPanel;
@onready var right_panel : Panel = $RightPanel;
@onready var left_type_icon : Sprite2D = $TypeIcons/LeftIcon;
@onready var right_type_icon : Sprite2D = $TypeIcons/RightIcon;
@onready var card_art : Sprite2D = $ArtLayer/CardArt;
@onready var art_background : Panel = $ArtLayer/Panel;
@onready var keywords_label : Label = $KeywordsLabel;
@onready var background_pattern : Sprite2D = $Pattern;
@onready var top_pattern : Sprite2D = $Pattern2;
@onready var stamp : Sprite2D = $Stamp;
@onready var blue_stars_layer : Node2D = $BlueStars;

func update_visuals(gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	if card_data.is_buried:
		bury();
		return;
	update_name_label(card_data.card_name);
	type_label.text = CardEnums.CardTypeName[card_data.card_type];
	type_label.add_theme_font_size_override("font_size", TYPE_FONT_SIZE_SMALL if [
		CardEnums.CardType.BEDROCK,
		CardEnums.CardType.ROCKSTAR
		].has(card_data.card_type) else TYPE_FONT_SIZE_BIG);
	update_panel(card_data.card_type);
	update_type_icons(card_data.card_type);
	update_card_art();
	update_keywords_text(card_data.get_keywords(), gained_keyword);
	update_stamp();
	if card_data.has_emp():
		has_emp_visuals = true;
		update_emp_visuals();
	else:
		add_art_base_shader();
	if Config.TEXTLESS_CARDS:
		for node in [
			name_label,
			keywords_label,
			type_label
		]:
			node.visible = false;

func add_art_base_shader(do_force : bool = false) -> void:
	if !System.Instance.exists(card_data) or (card_art.material and !do_force):
		return;
	if card_data.is_negative_variant():
		has_negative_visuals = true;
	if card_data.is_holographic:
		has_holographic_visuals = true;
	if card_data.is_foil:
		has_foil_visuals = true;
	card_art.material = System.Shaders.card_art(card_data.is_negative_variant(), card_data.is_holographic, card_data.is_foil);

func update_stamp() -> void:
	var texture : Resource;
	if is_dissolving or card_data.stamp == CardEnums.Stamp.NULL:
		stamp.texture = null;
		return;
	texture = load("res://Assets/Art/Stamps/%s.png" % CardEnums.TranslateStampBack[card_data.stamp]);
	stamp.texture = texture;

func update_emp_visuals() -> void:
	if card_art.material:
		return;
	card_art.material = System.Shaders.emp_shader(card_data.is_negative_variant(), card_data.is_holographic, card_data.is_foil);
	card_art.update_shader();

func bury() -> void:
	card_data.is_buried = true;
	update_name_label("Buried");
	type_label.text = "???";
	update_keywords_text([CardEnums.Keyword.BURIED]);
	card_art.texture = null;
	update_panel(CardEnums.CardType.MIMIC);
	update_type_icons(CardEnums.CardType.MIMIC);
	stamp.texture = null;

func update_name_label(message : String) -> void:
	var name_length : int = message.length();
	var font = name_label.get_theme_font("normal_font");
	var font_size : int;
	if message.contains("[i]"):
		name_length -= "[i][/i]".length();
	name_label.text = "[center]" + message + "[/center]";
	font_size = 88 if name_length > 12 else 104;
	if font_size == 88 and font.get_string_size(message, font_size).x > 150:
		font_size = 80;
	name_label.add_theme_font_size_override("normal_font_size", font_size);
	name_label.add_theme_font_size_override("italics_font_size", font_size);
	name_label.position.y = -629 + (104 - 88 - (font_size - 88) / 2) if font_size <= 88 else -629;

func update_panel(card_type : CardEnums.CardType) -> void:
	var left_style : StyleBoxFlat = StyleBoxFlat.new();
	var right_style : StyleBoxFlat = StyleBoxFlat.new();
	var pattern : Resource = load(BACKGROUND_PATTERN_PATH % [CardEnums.CardTypeName[card_type]]);
	for style in [left_style, right_style]:
		style.bg_color = get_panel_bg_color(get_left_type(card_type));
		style.border_color = get_panel_border_color(get_left_type(card_type));
		style.border_width_left = BORDER_WIDTH;
		style.border_width_top = BORDER_WIDTH;
		style.border_width_bottom = BORDER_WIDTH;
		style.corner_radius_top_left = BORDER_RADIUS;
		style.corner_radius_bottom_left = BORDER_RADIUS;
		if !card_data.is_multi_type():
			style.border_width_right = BORDER_WIDTH;
			style.corner_radius_top_right = BORDER_RADIUS;
			style.corner_radius_bottom_right = BORDER_RADIUS;
	left_panel.add_theme_stylebox_override("panel", left_style);
	if card_data.is_multi_type():
		for style in [right_style]:
			style.bg_color = get_panel_bg_color(get_right_type(card_type));
			style.border_color = get_panel_border_color(get_right_type(card_type));
			style.border_width_left = 0;
			style.corner_radius_top_left = 0;
			style.corner_radius_bottom_left = 0;
			style.border_width_right = BORDER_WIDTH;
			style.corner_radius_top_right = BORDER_RADIUS;
			style.corner_radius_bottom_right = BORDER_RADIUS;
		right_panel.add_theme_stylebox_override("panel", right_style);
		left_panel.size.x = 451;
		right_panel.visible = true;
	else:
		left_panel.size.x = 900;
		right_panel.visible = false;
	background_pattern.texture = pattern;
	top_pattern.texture = pattern;

func update_type_icons(card_type : CardEnums.CardType) -> void:
	var left_sprite_texture : Resource;
	var right_sprite_texture : Resource;
	var is_multi : bool = CardEnums.is_multi_type(card_type);
	left_sprite_texture = load(TYPE_ICON_PATH % [CardEnums.CardTypeName[get_left_type(card_type)].to_lower()]);
	left_type_icon.texture = left_sprite_texture;
	if is_multi:
		right_sprite_texture = load(TYPE_ICON_PATH % [CardEnums.CardTypeName[get_right_type(card_type)].to_lower()]);
	else:
		right_sprite_texture = left_sprite_texture;
	right_type_icon.texture = right_sprite_texture;

func get_left_type(card_type : CardEnums.CardType) -> CardEnums.CardType:
	match card_type:
		CardEnums.CardType.BEDROCK:
			return CardEnums.CardType.PAPER;
		CardEnums.CardType.ZIPPER:
			return CardEnums.CardType.SCISSORS;
		CardEnums.CardType.ROCKSTAR:
			return CardEnums.CardType.ROCK;
	return card_type;

func get_right_type(card_type : CardEnums.CardType) -> CardEnums.CardType:
	match card_type:
		CardEnums.CardType.BEDROCK:
			return CardEnums.CardType.ROCK;
		CardEnums.CardType.ZIPPER:
			return CardEnums.CardType.PAPER;
		CardEnums.CardType.ROCKSTAR:
			return CardEnums.CardType.SCISSORS;
	return card_type;

func update_card_art(do_full_art : bool = false) -> void:
	var art_texture : Resource = load((CARD_FULLART_PATH if do_full_art else CARD_ART_PATH) % [card_data.card_id]);
	var art_scale : float = MAX_SCALE if do_full_art else 1 / MIN_SCALE;
	card_art.texture = art_texture;
	card_art.scale = Vector2(art_scale, art_scale);

func update_keywords_text(keywords : Array, gained_keyword : CardEnums.Keyword = CardEnums.Keyword.NULL) -> void:
	var keywords_text : Array;
	if card_data.is_in_hand() and gained_keyword != CardEnums.Keyword.NULL and !keywords.has(gained_keyword) and keywords.size() < System.Rules.MAX_KEYWORDS:
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

func dissolve(multiplier : float = 1) -> void:
	var shader_material : ShaderMaterial = System.Shaders.dissolve_shader();
	var shader_material2 : ShaderMaterial = System.Shaders.dissolve_shader();
	var card_art_shader_material : ShaderMaterial = System.Shaders.dissolve_shader(card_data.is_negative_variant(), card_data.is_holographic, card_data.is_foil);
	shader_material2.set_shader_parameter("opacity", BACKGROUND_PATTERN_OPACITY);
	for node in get_shader_layers(false):
		node.material = shader_material;
	hide_multiplier_bar();
	card_art.material = card_art_shader_material;
	background_pattern.material = shader_material2;
	dissolve_speed = System.random.randf_range(MIN_DISSOLVE_SPEED, MAX_DISSOLVE_SPEED) * multiplier;
	stamp.texture = null;
	is_dissolving = true;
	is_despawning = true;
	is_moving = false;

func get_shader_layers(include_multiplier_bar : bool = true) -> Array:
	return [
		self,
		background_pattern,
		name_label,
		type_label,
		keywords_label,
		art_background,
		left_type_icon,
		right_type_icon,
		left_panel,
		right_panel,
		stamp
	] + ([] if System.Instance.exists(card_data) and card_data.is_negative_variant() else [card_art]) + \
	(multiplier_bar.get_shader_layers() if System.Instance.exists(multiplier_bar) and include_multiplier_bar else []) \
	+ (rattle.get_shader_layers() if System.Instance.exists(rattle) else []) \
	+ (glow_sticks.get_shader_layers() if System.Instance.exists(glow_sticks) else []);

func get_custom_shader_layers() -> Array:
	return [card_art];

func dissolve_frame(delta : float) -> void:
	dissolve_value += dissolve_speed * delta * (FLOW_DISSOLVE_MULTIPLIER if is_flowing else 1);
	if dissolve_value >= MAX_DISSOLVE_VALUE:
		is_dissolving = false;
		emit_signal("despawned", self);
	left_panel.material.set_shader_parameter("threshold", dissolve_value);
	background_pattern.material.set_shader_parameter("threshold", dissolve_value);
	card_art.material.set_shader_parameter("threshold", dissolve_value);
	if System.Instance.exists(particle_effect):
		particle_effect.modulate.a = 1.0 - pow(dissolve_value, 2);

func wet_effect(color : Color = SHADER_COLOR_BLUE) -> void:
	var shader : Resource = load(System.Paths.OCEAN_SHADER);
	var shader_material : ShaderMaterial = ShaderMaterial.new();
	shader_material.shader = shader;
	shader_material.set_shader_parameter("water_color", color);
	top_pattern.material = shader_material;
	top_pattern.visible = true;
	top_pattern.modulate.a = 0;
	update_top_pattern_shader_opacity();
	is_out_ocean = false;
	is_in_ocean = true;

func update_top_pattern_shader_opacity() -> void:
	top_pattern.material.set_shader_parameter("opacity", top_pattern.modulate.a);

func in_ocean_frame(delta : float) -> void:
	top_pattern.modulate.a += delta * OCEAN_IN_SPEED * System.game_speed;
	update_top_pattern_shader_opacity()
	if top_pattern.modulate.a >= BACKGROUND_PATTERN_OPACITY:
		top_pattern.modulate.a = BACKGROUND_PATTERN_OPACITY;
		is_in_ocean = false;
		ocean_timer.start();

func out_ocean_frame(delta : float) -> void:
	top_pattern.modulate.a -= delta * OCEAN_OUT_SPEED * System.game_speed;
	update_top_pattern_shader_opacity()
	if top_pattern.modulate.a <= 0:
		top_pattern.modulate.a = 0;
		is_out_ocean = false;
		top_pattern.material = null;
		top_pattern.visible = false;

func shine_star_effect() -> void:
	if !System.Instance.exists(shine_star):
		shine_star = System.Instance.load_child(System.Paths.SHINE_STAR, self);
	shine_star.position = SHINE_STAR_POSITION;
	shine_star.flicker();

func die() -> void:
	if particle_effect:
		for node in get_shader_layers():
			node.visible = false;
		is_dying = true;
	else:
		queue_free();
