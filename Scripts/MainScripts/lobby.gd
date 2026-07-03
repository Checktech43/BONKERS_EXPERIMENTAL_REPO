extends Node

signal game_has_started
signal pass_modifiers_to_main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		$LobbyMenu/Start.show()
		for switch in $LobbyMenu/VBoxContainer.get_children():
			switch.disabled = false
	game_has_started.connect($"..".on_game_start)
	game_has_started.connect($"../..".on_start_button_getting_pressed)
	pass_modifiers_to_main.connect($"../.."._on_switching_modifier)
	
	## Kim jon un is a master of goon
# all this function does is pass the map choosen by the "MapSelection" scene
# and gives it to the "Main" scene to use.
func _on_picking_map(map_on_screen):
	$"..".loaded_map = map_on_screen
	

func _on_start_pressed() -> void:
	game_has_started.emit()
	
func _on_switching_modifier(switch_name, new_state):
	pass_modifiers_to_main.emit(switch_name, new_state)
	
	
