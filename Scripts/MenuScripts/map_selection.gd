extends Node
signal seleacted_map
@export var maps : Array[PackedScene]
@export var map_offset : Vector3 = Vector3(0, 5, 0)
@export var map_size : float = 0.25
var map_index : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.get_unique_id() == 1:
		multiplayer.peer_connected.connect(call_map_change_rpc)
		
		# Checktech43 if you are reading this and trying to fixing the UI,
		# make sure to change the path of the buttons below so the game does not crash.
		get_node("LeftButton").disabled = false 
		get_node("RightButton").disabled = false
		
	if !seleacted_map.is_connected($".."._on_picking_map):
		seleacted_map.connect($".."._on_picking_map)



func _on_button_button_down() -> void:
	map_index -= 1
	if map_index < 0:
		map_index = maps.size() - 1
	rpc("map_change", map_index)


func _on_button_2_button_down() -> void:
	map_index += 1
	if map_index >= maps.size():
		map_index = 0
	rpc("map_change", map_index)
	
# id is an argument that the "peer_connected" signal allways passes, so it's just kind of there
func call_map_change_rpc(id):
	#map_change(map_index)
	rpc("map_change", map_index)
	
@rpc("authority", "call_local")
func map_change(index):
	var map : PackedScene = maps[index]
	seleacted_map.emit(map)
	get_child(-1).queue_free()
	var actual_map : Node3D = map.instantiate()
	var map_to_spawn = actual_map.get_child(0)
	actual_map.remove_child(map_to_spawn)
	map_to_spawn.owner = null
	map_to_spawn.position = Vector3(map_offset)
	map_to_spawn.scale = Vector3(map_size, map_size, map_size)
	map_to_spawn.name = "Display"
	add_child(map_to_spawn)
	
	


func _on_start_pressed() -> void:
	print(multiplayer)
	if multiplayer.peer_connected.is_connected(call_map_change_rpc):
		multiplayer.peer_connected.disconnect(call_map_change_rpc)
