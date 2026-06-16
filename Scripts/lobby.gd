extends Node
var modifiers : Dictionary[String, bool]
signal game_has_started

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		$LobbyMenu/Start.show()
	game_has_started.connect($"..".on_game_start)
	game_has_started.connect($"../..".on_start_button_getting_pressed)
	# modifiers have yet to be added
	modifiers = {"cards": true,
	"one_second_chaos": false,
	}
	
	## Kim jon un is a master of goon
# all this function does is pass the map choosen by the "MapSelection" scene
# and gives it to the "Main" scene to use.
func _on_picking_map(map_on_screen):
	$"..".loaded_map = map_on_screen
	

func _on_start_pressed() -> void:
	game_has_started.emit()
	
	
	
