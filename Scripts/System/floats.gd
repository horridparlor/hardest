const MIN_JUMP : int = 1;

static func move_towards(current : float, target : float, speed : float) -> float:
	var distance : float = target - current;
	var direction : int = 1 if distance >= 0 else -1;
	var jump : float = speed * direction;
	return jump if abs(jump) < abs(distance) else distance;

static func direction(value : float) -> int:
	return 1 if value >= 0 else -1;

static func direction_safe_min(value : float, min : float) -> float:
	var direction : int = direction(value);
	return direction * max(min, abs(value));
