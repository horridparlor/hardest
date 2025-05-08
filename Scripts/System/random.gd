static func item(array : Array) -> Variant:
	return array[System.random.randi()%array.size()];

static func instance_id() -> int:
	return System.random.randi();

static func key(dictionary : Dictionary) -> Variant:
	return item(dictionary.keys())

static func chance(x : int) -> bool:
	return randf() < (1.0 / x)

static func boolean() -> bool:
	return item([true, false]);
	
static func one_of_two(a, b, chance : int):
	if System.random.randi_range(0, chance) == 0:
		return b;
	return a;
