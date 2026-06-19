extends Node

var main_scene : Node3D
var end_of_game_ui : Control
var start_agian_button : Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_scene = $".."
	end_of_game_ui = get_node("EndGamePanel")
	start_agian_button = get_node("EndGamePanel/Button")
	start_agian_button.connect("button_down", main_scene.start_rematch)
	




func _on_rematch() -> void:
	end_of_game_ui.hide()
	start_agian_button.hide()
	
func _on_game_end(data) -> void:
	var win_screen : Label = end_of_game_ui.get_node("Victory")
	win_screen.text = data["name"] + " wins"
	win_screen.add_theme_color_override("font_color", data["colour"])
	end_of_game_ui.show()
	



func _on_victory_timeout() -> void:
	if multiplayer.is_server():
		start_agian_button.show()
