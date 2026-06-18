extends Node

@export var size : float


func get_random_position(maps_scale) -> Vector3:
	var radius : float = randf_range(0, maps_scale / 2 * size)
	var angle : float = randf_range(0, 2 * PI)
	var x : float = radius * cos(angle)
	var z : float = radius * sin(angle)
	
	return Vector3(x, 0, z)
