extends Node

var game_start : bool = false

signal action_phase_time
signal restart
signal change_game_state
signal game_over


@export var player_scene : PackedScene
@export var hud : Control
@export var card_menu: Control


func _ready():
	if multiplayer.get_unique_id() == 1:
		add_player()
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_player)
	

func player_disconnected(id):
	_remove_player(id)


# Keep in mind That when the cubes are first joining the game,
# that only the host calls this function
func add_player(id : int = 1):
	# create the player and give it all the neceacery data
	var player : RigidBody3D = player_scene.instantiate()
	player.name = str(id)
	player.position = Vector3(0, 0.25, 0)
	$Players.add_child(player)


func _on_all_players_ready() -> void:
	action_phase_time.emit()
	$ActionPhaseTimer.start()

func on_start_button_getting_pressed() -> void:
	rpc("start_the_game")
	
@rpc("call_local")
func start_the_game():
	game_start = true
	change_game_state.emit(game_start)

func _on_something_fell(body: Node3D) -> void:
	if not game_start:
		body.linear_velocity = Vector3(0, 0, 0)
		body.position = Vector3(0, 0.5, 0)
	else:
		# I don't know why this line of code is here. But it errors out when it's not there, so it stays
		body.get_node("MultiplayerSynchronizer").public_visibility = false
		
		remove_player(body.name.to_int())
		if $Players.get_children().size() <= 1:
			$EndOfGameDelay.start()
		
func remove_player(id):
	rpc_id(1, "_remove_player", id)
	
@rpc("any_peer", "call_local")
func _remove_player(id):
	print("man im dead")
	var player : RigidBody3D = get_node_or_null("Players/" + str(id))
	if player:
		player.free()
		print("The " + str(id) + " cube is dead!")
	
 
		
func _check_for_winners() -> void:
	if $Players.get_children().size() == 1:
		for player in $Players.get_children():
			if player != null:
				rpc("_end_of_game", player.data)
	if $Players.get_children().size() < 1:
		var no_one_wins : Dictionary = {"name" : "nobody", "colour" : Color.WHITE}
		rpc("_end_of_game", no_one_wins)
		
	
@rpc("authority", "call_local")
func card_menu_show():
	card_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if $Players.get_children().size() < 1:
		card_menu_hide.rpc()
		return
	

@rpc("any_peer", "call_local")
func card_menu_hide():
	card_menu.visible = false
					

@rpc("call_local", "any_peer")
func _end_of_game(data):
	card_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	game_over.emit(data)
	game_start = false
	change_game_state.emit(game_start)
	restart.emit()
	print("end_game")
	$VictoryTimer.start()

func start_rematch():
	if multiplayer.get_unique_id() == 1:
		add_player(multiplayer.get_unique_id())
	else:
		rpc_id(1, "rematch", multiplayer.get_unique_id())
	
@rpc("call_local", "any_peer")
func rematch(id):
	print("rematch")
	add_player(id)
	
func _on_finishing_action_phase():
	if !is_multiplayer_authority():
		return
	card_menu_show.rpc()
	
	
func _on_victory_timeout() -> void:
	for player in $Players.get_children():
		if player != null && is_multiplayer_authority():
			player.get_node("MultiplayerSynchronizer").public_visibility = false
			remove_player(player.name.to_int())

### I don't think this does anything
func _on_button_button_down() -> void:
	DisplayServer.clipboard_set($MutiplayerHud/LobbyCode.text)
