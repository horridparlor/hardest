static func item(array : Array) -> Variant:
	return array[System.random.randi()%array.size()];

static func instance_id() -> int:
	System.running_instance_id += 1;
	return System.running_instance_id;

static func key(dictionary : Dictionary) -> Variant:
	return item(dictionary.keys())

static func chance(x : int) -> bool:
	return randf() < (1.0 / x)

static func boolean() -> bool:
	return item([true, false]);
	
static func one_of_two(a, b, chance : int = 1):
	if System.random.randi_range(0, chance) == 0:
		return b;
	return a;

static func x() -> float:
	return System.random.randf_range(-System.Window_.x / 2, System.Window_.x / 2);

static func direction() -> int:
	return item([1, -1]);

static func vector(min : float, max : float, random : RandomNumberGenerator = System.random) -> Vector2:
	return Vector2(
		direction() * random.randf_range(min, max),
		direction() * random.randf_range(min, max)
	);
