extends RoguelikePage

@onready var progress_label : Label = $BasicInfo/ProgressLabel;
@onready var green_panel : Panel = $BasicInfo/GreenPanel;

func init(roguelike_data : RoguelikeData):
	data = roguelike_data;
	origin_point = position;
	update_progress_label();

func update_progress_label() -> void:
	var progress : float = float(data.cards_bought) / float(data.card_goal);
	progress_label.text = "%s / %s cards" % [data.cards_bought, data.card_goal];
	green_panel.size.x = progress * PROGRESS_PANEL_SIZE.x;
	if progress == 1:
		green_panel.add_theme_stylebox_override("panel", get_full_progress_style());

func get_full_progress_style() -> StyleBoxFlat:
	var style : StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = "#34aa04";
	style.border_width_bottom = 4;
	style.border_width_left = 4;
	style.border_width_right = 4;
	style.border_width_top = 4;
	style.border_color = "#205814";
	style.border_blend = true;
	style.corner_radius_bottom_left = 13;
	style.corner_radius_bottom_right = 13;
	style.corner_radius_top_left = 13;
	style.corner_radius_top_right = 13;
	return style;
