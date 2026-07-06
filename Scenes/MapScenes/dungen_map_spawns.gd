extends "res://Scenes/MapScenes/map_spawns.gd"



@export var size_of_hole : float

enum number_type {POSITIVE, NEGATIVE}
func get_random_position(maps_scale) -> Vector3:
	var x : float = randf_range(maps_scale / 2 * size_of_hole, maps_scale / 2 * size)
	var z : float = randf_range (maps_scale / 2 * size_of_hole, maps_scale / 2 * size)
	var positive_or_negative = randi_range(1, 2)
	if positive_or_negative == 2:
		x = x - (x * 2)
		z = z - (z * 2)
	return Vector3(x, 0.25, z)
