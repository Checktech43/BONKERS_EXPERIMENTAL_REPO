extends Node


@export var size : float
@export var size_of_hole : float

func get_random_position(maps_scale) -> Vector3:
	var radius : float = randf_range(size_of_hole, maps_scale / 2 * size)
	var angle : float = randf_range(0, 2 * PI)
	radius = maps_scale / 2 * size
	var x : float = radius * cos(angle)
	var z : float = radius * sin(angle)
	return Vector3(x, 0.25, z)
