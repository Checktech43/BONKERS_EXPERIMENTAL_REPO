extends Node3D

var round_counter : int
var playes_started_with : int
@export var loaded_map : PackedScene
signal players_message


func on_game_start() -> void:
	rpc("rearange_all_things")
	
	
@rpc("call_local")	
func rearange_all_things():
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
	var size : float = map.size * scale.x / 2
	players_message.emit(size)

func instantiate_map():
	remove_child(get_child(0))
	add_child(loaded_map.instantiate())
	
# I'm thinking of delating this if it's not going to be used by anyone
func _on_game_reset() -> void:
	pass
