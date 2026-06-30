extends Node

var game_start : bool = false
var dead_boys : Array[RigidBody3D]
signal action_phase_time
signal restart
signal change_game_state
signal game_over


@export var player_scene : PackedScene
@export var hud : Control
@export var card_menu: Control


func _ready():
	if multiplayer.is_server():
		add_player()
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_player)


# Keep in mind that when the cubes are first joining the game,
# only the host calls this function
func add_player(id : int = 1):
	# create the player and give it all the neceacery data
	var player : RigidBody3D = player_scene.instantiate()
	player.name = str(id)
	player.position = Vector3(0, 0.25, 0)
	if !game_start:
		$Players.add_child(player, true)


func _on_all_players_ready() -> void:
	action_phase_time.emit()
	$ActionPhaseTimer.start()

func on_start_button_getting_pressed() -> void:
	call_deferred("rpc", "start_the_game")
	
@rpc("call_local")
func start_the_game():
	game_start = true
	change_game_state.emit(game_start)

func _on_something_fell(body: Node3D) -> void:
	if not body.is_class("RigidBody3D"): return
	if not game_start:
		body.linear_velocity = Vector3(0, 0, 0)
		body.position = Vector3(0, 0.5, 0)
	else:
		body.get_node("MultiplayerSynchronizer").public_visibility = false
		if is_multiplayer_authority():
			rpc("remove_player", body.name.to_int())
			$Players.remove_child(body)
			print(dead_boys)
			$EndOfGameDelay.start()
		
		
		
@rpc("any_peer", "call_local")
func remove_player(id):
	#print("man im dead")
	var player : RigidBody3D = get_node_or_null("Players/" + str(id))
	if player:
		dead_boys.append(player)
		#print($Players.get_children())
		player.playing_game = false
		player.planning = true
	
	#print("The " + str(id) + " cube is dead!")
	

	
	
func _check_for_winners() -> void:
	print(dead_boys)
	if $Players.get_children().size() == 1:
		rpc("_end_of_game", $Players.get_child(0).data)
	elif $Players.get_children().size() < 1:
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
	print("end_game")
	$VictoryTimer.start()

func start_rematch():
	rpc("rematch")

	
@rpc("call_local", "authority")
func rematch():
	print(dead_boys)
	for player in dead_boys:
		$Players.add_child(player)
		player.get_node("MultiplayerSynchronizer").public_visibility = true
	print("rematch")
	$CurrentMap.go_to_lobby()
	#if is_multiplayer_authority():
	restart.emit()

	
func _on_finishing_action_phase():
	if !is_multiplayer_authority():
		return
	card_menu_show.rpc()
	
	
func _on_victory_timeout() -> void:
	if $Players.get_children().size() > 0 && is_multiplayer_authority():
		$Players.get_child(0).get_node("MultiplayerSynchronizer").public_visibility = false
		rpc_id(1, "remove_player", $Players.get_child(0).name.to_int())
		$Players.remove_child($Players.get_child(0))

func _on_button_button_down() -> void:
	DisplayServer.clipboard_set($MutiplayerHud/LobbyCode.text)
