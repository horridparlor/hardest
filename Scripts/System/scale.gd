const WITHER : int = 10;
const MIN_BASE : float = 1.0 / 100;
const FULL_CYCLE : int = 360;

static func floats(value : float, min_value : float, max_value : float) -> float:
	return min(max(value, min_value), max_value);

static func vectors(vector : Vector2, min_vector : Vector2, max_vector : Vector2) -> Vector2:
	for axis in ["x", "y"]:
		vector[axis] = floats(vector[axis], min_vector[axis], max_vector[axis]);
	return vector;

static func baseline(value : float, base : float, delta : float) -> float:
	base = round_base(base);
	value += WITHER * (get_min_distance(value, base)) * delta * System.game_speed;
	if abs(get_min_distance(value, base)) < MIN_BASE:
		value = base;
	return value;

static func round_base(base : float) -> float:
	return 0 if base == FULL_CYCLE else base;

static func get_min_distance(value : float, base : float) -> float:
	return base - value;

static func equal(value : float, base : float) -> bool:
	return abs(round_base(base) - value) <= MIN_BASE;
