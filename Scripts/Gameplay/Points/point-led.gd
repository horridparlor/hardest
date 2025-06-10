extends PointLed

@onready var green_panel : Panel = $GreenPanel;
@onready var red_panel : Panel = $RedPanel;

func on() -> void:
	green_panel.visible = true;
	red_panel.visible = false;

func off() -> void:
	red_panel.visible = true;
	green_panel.visible = false;

func get_nodes() -> Array:
	return [
		green_panel,
		red_panel
	];
