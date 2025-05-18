const INDIFFERENT_DISTANCE : float = 0.01;
const WINDOW_CIRCUMRADIUS : float = sqrt(pow(System.Window_.x / 2, 2) + pow(System.Window_.y / 2, 2));

static func is_default(vector : Vector2) -> bool:
	return is_same(vector, default());

static func default() -> Vector2:
	return Vector2(0, 0);

static func default_scale() -> Vector2:
	return Vector2(1, 1);

static func equal(vector_a : Vector2, vector_b : Vector2 = default(), extra_distance : float = 0) -> bool:
	return vector_a.distance_to(vector_b) <= INDIFFERENT_DISTANCE + extra_distance;

static func synchronize(target : Vector2, current : Vector2) -> Vector2:
	var direction : Vector2 = Vector2(System.Floats.direction(current.x), System.Floats.direction(current.y));
	target = Vector2(direction.x * abs(target.x), direction.y * abs(target.y));
	return target;

static func have_distance(point_a : Vector2, point_b : Vector2, min_distance : float) -> bool:
	return point_a.distance_to(point_b) >= min_distance;

static func slide_towards(point_a : Vector2, point_b : Vector2,
delta : float, min_speed : float = 0) -> Vector2:
	var distance : float = point_a.distance_to(point_b) * delta * System.game_speed;
	return point_a.move_toward(point_b, max(distance, min_speed));

static func is_inside_window(position : Vector2, size : Vector2) -> bool:
	return position.distance_to(default()) - get_cirmumradius(size) < WINDOW_CIRCUMRADIUS;

static func get_cirmumradius(size : Vector2) -> float:
	return sqrt(pow(size.x / 2, 2) + pow(size.y / 2, 2));

static func move_away(position : Vector2, away_from : Vector2, distance : float) -> Vector2:
	var direction : Vector2 = (position - away_from).normalized();
	return position + distance * direction;
