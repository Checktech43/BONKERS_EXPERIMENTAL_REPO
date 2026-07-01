extends Node

signal all_players_ready
var ready_players = []

var number_of_cubes_ready : int = 0

func _player_ready():
	_count_ready_players.rpc()
	
@rpc("any_peer", "call_local")
func _count_ready_players():
	var players = get_children()
	number_of_cubes_ready += 1
	var human_players = []

	for player in players:
		if !player.is_in_group("ai"):
			human_players.append(player)
			
	if number_of_cubes_ready == human_players.size():
		number_of_cubes_ready = 0
		ready_players = []
		all_players_ready.emit()
		


func on_action_phase() -> void:
	for player in get_children():
		player.push()


func _on_action_phase_end() -> void:
	for player in get_children():
		player.planning_phase()


func _on_change_game_state(new_state) -> void:
	for player in get_children():
		player.playing_game = new_state
		player.toggle_ragdoll_mode(new_state)
	for player in get_children():
		player.unlimited_power = $"..".modifiers["FreeMovement"]
		


func _telaport_players(player, max_distance) -> void:
	player.go_to_random_position(max_distance)
		

### I don't think this function is used for anything useful
func _on_restart() -> void:
	pass
