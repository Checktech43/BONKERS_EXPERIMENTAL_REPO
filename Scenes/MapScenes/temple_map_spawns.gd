extends "res://Scenes/MapScenes/map_spawns.gd"

func get_random_position(maps_scale) -> Vector3:
	var x : float = randf_range(-maps_scale / 2 * size, maps_scale / 2 * size)
	var z : float = randf_range(-maps_scale / 2 * size, maps_scale / 2 * size)
	return Vector3(x, 0.25, z)
