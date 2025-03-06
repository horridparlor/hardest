static func item(array : Array) -> Variant:
	return array[System.random.randi()%array.size()];

static func instance_id() -> int:
	return System.random.randi();

static func key(dictionary : Dictionary) -> Variant:
	return item(dictionary.keys())

static func chance(x : int) -> bool:
	return randf() < (1.0 / x)
