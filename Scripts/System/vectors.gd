const INDIFFERENT_DISTANCE : float = 0.01;

static func is_default(vector : Vector2) -> bool:
	return is_same(vector, default());

static func default() -> Vector2:
	return Vector2(0, 0);

static func equal(vector_a : Vector2, vector_b : Vector2 = default(), extra_distance : float = 0) -> bool:
	return vector_a.distance_to(vector_b) <= INDIFFERENT_DISTANCE + extra_distance;

static func synchronize(target : Vector2, current : Vector2) -> Vector2:
	var direction : Vector2 = Vector2(System.Floats.direction(current.x), System.Floats.direction(current.y));
	target = Vector2(direction.x * abs(target.x), direction.y * abs(target.y));
	return target;

static func have_distance(point_a : Vector2, point_b : Vector2, min_distance : float) -> bool:
	return point_a.distance_to(point_b) >= min_distance;

static func slide_towards(point_a : Vector2, point_b : Vector2,
speed_multiplier : float, delta : float, min_speed : float = 0) -> Vector2:
	var distance : float = max(point_a.distance_to(point_b), min_speed);
	var movement : float = distance * speed_multiplier * delta;
	return point_a.move_toward(point_b, movement);
