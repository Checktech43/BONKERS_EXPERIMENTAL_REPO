extends Node3D

var round_counter : int
var playes_started_with : int
@export var lobby : Node3D
@export var loaded_map : PackedScene
signal players_random_pos


func on_game_start() -> void:
	multiplayer.peer_connected.connect(joining_late)
	call_deferred("rpc", "rearange_all_things")
	
	
	
@rpc("call_local")
func rearange_all_things():
	lobby = get_child(0)
	var all_players = $"../Players"
	var resizes_needed : int =  all_players.get_children().size()
	instantiate_map()
	resize_map(resizes_needed)
	set_players_at_random_positions()
	
	
		
	
		
func resize_map(number_of_changes):
	scale = Vector3(0.5, 0.5, 0.5)
	for change_in_size in number_of_changes:
		scale = scale * 1.2
		


func _on_round_end() -> void:
	var resizes_needed : int = $"../Players".get_children().size()
	resize_map(resizes_needed)
	
func set_players_at_random_positions():
	var map : Node3D = get_child(-1)
	var size : float = scale.x
	
	var all_players = $"../Players".get_children()
	
	for player in all_players:
		players_random_pos.emit(player, map.get_random_position(size))
		
@rpc("authority")
func instantiate_map():
	remove_child(get_child(0))
	add_child(loaded_map.instantiate())
	
func joining_late(id):
	rpc_id(id, "update_late_client_on_things")
	var all_players = $"../Players"
	var resizes_needed : int =  all_players.get_children().size()
	resize_map(resizes_needed)
	
@rpc
func update_late_client_on_things():
	var all_players = $"../Players"
	var resizes_needed : int =  all_players.get_children().size()
	resize_map(resizes_needed)
	instantiate_map()
	
	
func go_to_lobby():
	get_child(0).queue_free()
	add_child(lobby)


func _on_game_reset() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.disconnect(joining_late)
