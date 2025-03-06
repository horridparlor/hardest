static func safe_get(source : Dictionary, key : String, default = null):
	if source.has(key):
		return source[key];
	else:
		return default;
