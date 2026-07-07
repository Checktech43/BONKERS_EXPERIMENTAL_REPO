extends Node


@export var size : float
@export var boarder_size: float

func get_random_position(maps_scale) -> Vector3:
	printerr("function 'get_random_position' was not overriden")
	return Vector3(0, 0, 0)
