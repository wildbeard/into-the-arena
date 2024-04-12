extends Area2D

func isColliding():
	return get_overlapping_areas().size() > 0

func getPushVector():
	if !isColliding():
		return Vector2.ZERO

	var areas = get_overlapping_areas()
	var area = areas[0]
	
	return area.global_position.direction_to(self.global_position).normalized()
