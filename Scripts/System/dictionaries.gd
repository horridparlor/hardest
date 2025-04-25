static func safe_get(source : Dictionary, key : String, default = null):
	if source.has(key):
		return source[key];
	else:
		return default;

static func make_safe(source : Dictionary, default : Dictionary) -> void:
	for key in default:
		if !source.has(key):
			source[key] = default[key];
