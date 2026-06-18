extends Node


@export var size : float


func get_random_position(maps_scale) -> Vector3:
	var circles : Array[Vector3] = [Vector3(0, 0, 0), Vector3(12, 0, 12), Vector3(-12, 0, -12), Vector3(12, 0, -12), Vector3(-12, 0, 12)]
	var radius : float = randf_range(0, maps_scale / 2 * size)
	var angle : float = randf_range(0, 2 * PI)
	var x : float = radius * cos(angle)
	var z : float = radius * sin(angle)
	var random_pos : Vector3 = circles[randi_range(0, 4)]
	random_pos.x += x
	random_pos.z += z
	random_pos *= maps_scale
	
	
	return random_pos
