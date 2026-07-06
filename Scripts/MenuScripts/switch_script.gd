extends BaseButton


signal toggle_switch
func _ready():
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_joining)
	
func _toggled(new_state) -> void:
	toggle_switch.emit(name, new_state)
	change_other_players_modifers.rpc(new_state)
	
@rpc("authority")
func change_other_players_modifers(new_state) -> void:
	set_pressed_no_signal(new_state)
	toggle_switch.emit(name, new_state)
	
func _on_player_joining(id):
	change_other_players_modifers.rpc(button_pressed)
