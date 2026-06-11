extends Node



var number_of_cubes_ready : int = 0
signal all_players_ready
	
func _player_ready():
	rpc("_count_ready_players")
	
@rpc("any_peer", "call_local")
func _count_ready_players():
	number_of_cubes_ready += 1
	if number_of_cubes_ready == get_children().size():
		number_of_cubes_ready = 0
		# Goes to the "Main Node" hehehehehehehe
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


func _telaport_players(max_distance) -> void:
	for player in get_children():
		player.go_to_random_position(max_distance)

### I don't think this function is used for anything usefull
func _on_restart() -> void:
	number_of_cubes_ready = 0
