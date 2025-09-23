const INDIFFERENT_DISTANCE : float = 0.01;
const WINDOW_CIRCUMRADIUS : float = sqrt(pow(System.Window_.x / 2, 2) + pow(System.Window_.y / 2, 2));

static func is_default(vector : Vector2) -> bool:
	return is_same(vector, Vector2.ZERO);

static func default_scale() -> Vector2:
	return Vector2(1, 1);

static func equal(vector_a : Vector2, vector_b : Vector2 = Vector2.ZERO, extra_distance : float = 0) -> bool:
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
	var square_condition : bool = (abs(position.x) - size.x) > (System.Window_.x if !is_desktop() else System.Window_.x * 3) / 2 \
		or (abs(position.y) - size.y) > System.Window_.y / 2;
	var circumradius_condition : bool = position.distance_to(Vector2.ZERO) - get_cirmumradius(size) < (WINDOW_CIRCUMRADIUS if !is_desktop() else WINDOW_CIRCUMRADIUS * 3);
	return !square_condition and circumradius_condition;
	
static func is_desktop() -> bool:
	var platform := OS.get_name().to_lower();
	return platform == "windows" or platform == "linux" or platform == "macos";

static func put_inside_window(position : Vector2, size : Vector2 = Vector2.ZERO) -> Vector2:
	var window_margin : Vector2 = System.Window_ / 2;
	var margin : Vector2 = size / 2;
	return Vector2(
		clamp(position.x, -window_margin.x + margin.x, window_margin.x - margin.x),
		clamp(position.y, -window_margin.y + margin.y, window_margin.y - margin.y)
	)

static func get_cirmumradius(size : Vector2) -> float:
	return sqrt(pow(size.x / 2, 2) + pow(size.y / 2, 2));

static func move_away(position : Vector2, away_from : Vector2, distance : float) -> Vector2:
	var direction : Vector2 = (position - away_from).normalized();
	return position + distance * direction;

static func parse_fraction(message: String) -> Vector2:
	var parts : Array = message.split(",");
	if parts.size() != 2:
		return Vector2.ZERO;
	var x : float = float(parts[0].split("/")[1]);
	var y : float = float(parts[1].split("/")[1]);
	return Vector2(x, y);

static func to_fraction(vector : Vector2) -> String:
	return "0/%s,0/%s" % [vector.x, vector.y];

static func get_scale_position(position : Vector2) -> Vector2:
	return (position + System.Window_ / 2) / System.Window_;
