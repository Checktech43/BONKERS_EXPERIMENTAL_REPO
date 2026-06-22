extends Node

@export var size : float
var random_circle : int
func _ready():
	random_circle = randi_range(0, 1)
	
func get_random_position(maps_scale) -> Vector3:
	var circles : Array[Vector3] = [Vector3(10, 0.25, 0), Vector3(-10, 0.25, 0)]
	var radius : float = randf_range(0, maps_scale / 2 * size)
	var angle : float = randf_range(0, 2 * PI)
	var x : float = radius * cos(angle)
	var z : float = radius * sin(angle)
	var random_pos : Vector3 = circles[random_circle]
	random_circle += 1
	if random_circle == 2:
		random_circle = 0
	random_pos.x += x
	random_pos.z += z
	random_pos *= maps_scale
	
	
	return random_pos
