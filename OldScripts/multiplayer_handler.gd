extends Node

var peer = ENetMultiplayerPeer.new()
var game_start : bool = false
var number_of_players : int
var amount_of_players_ready : int
var all_players : Array[String]
#var player_ids : Array[int]

signal go_mode
signal get_into_position
signal restart
@export var player_scene : PackedScene
### UI
@export var hud : Control
var server_hud : Panel
var host_button : BaseButton
var join_button : BaseButton 
var start_button : BaseButton
var end_of_game_ui : Control
var start_agian_button : BaseButton

func _ready():
	server_hud = hud.get_node("serverpanel")
	host_button = server_hud.get_node("VBoxContainer/Host")
	join_button = server_hud.get_node("VBoxContainer/Join")
	start_button = server_hud.get_node("VBoxContainer/Start")
	end_of_game_ui = hud.get_node("EndGamePanel")
	start_agian_button = hud.get_node("EndGamePanel/Button")
	
	host_button.connect("button_down", _host_game)
	join_button.connect("button_down", _join_game)
	start_button.connect("button_down", _on_start_button_getting_pressed)
	start_agian_button.connect("button_down", _start_rematch)
func _host_game() -> void:
	# create the host
	peer.create_server(6969)
	multiplayer.multiplayer_peer = peer
	# Call the "add_player" function every time someone connects to the server.
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_connected.connect(count_players)
	add_player()
	#count_players()
	# change ui
	host_button.hide()
	join_button.hide()
	start_button.show()

func _join_game() -> void:
	# create the client
	peer.create_client("127.0.0.1", 6969)
	multiplayer.multiplayer_peer = peer
	# change the ui
	server_hud.hide()


#func count_players(id = 1):
#	player_ids.append(id)


func add_player(id = 1):
	number_of_players += 1
	# create the player and give it all the neceacery data
	var player : RigidBody3D = player_scene.instantiate()
	player.data["name"] = "Player " + str(number_of_players)
	player.name = str(id)
	#print(player.name)
	call_deferred("add_child", player, true)
		

#func exit_game(id):
#	multiplayer.peer_disconnected.connect(remove_player)
#	remove_player(id)
		
		
func _make_list_of_players(players_id):
	rpc("_update_list_of_players", players_id)
	
@rpc("call_local", "any_peer")
func _update_list_of_players(players_id):
	all_players.append(players_id)
	number_of_players = all_players.size()
	#print(number_of_players)
	

func _player_ready():
	rpc_id(1, "_count_ready_players")
	
@rpc("any_peer", "call_local")
func _count_ready_players():
	amount_of_players_ready += 1
	if amount_of_players_ready == number_of_players:
		rpc("action_phase")
		
@rpc("call_local")
func action_phase():
	go_mode.emit()
	amount_of_players_ready = 0
	$Timer.start()

func _on_start_button_getting_pressed() -> void:
	server_hud.hide()
	get_into_position.emit()
	rpc("start_the_game")
	
@rpc("call_local")
func start_the_game():
	game_start = true

func _on_something_fell(body: Node3D) -> void:
	if not game_start:
		body.linear_velocity = Vector3(0, 0, 0)
		body.position = Vector3(0, 0.25, 0)
	else:
		# I don't know why this line of code is here. But it errors out when it's not there, so it stays
		body.get_child(3).public_visibility = false
		number_of_players -= 1
		print(number_of_players)
		remove_player(body.name.to_int())
		
func remove_player(id):
	rpc_id(1, "_remove_player", id)
	
@rpc("any_peer", "call_local")
func _remove_player(id):
	#print(number_of_players)
	var player : RigidBody3D = get_node_or_null(str(id))
	if is_instance_valid(player) && player:
		player.free()
	
		
func _on_finishing_action_phase() -> void:
	if not is_multiplayer_authority():
		return
	#print(number_of_players)
	if number_of_players == 1:
		for player_id in all_players:
			var player : RigidBody3D = get_node_or_null(player_id)
			if player != null:
				rpc("_end_of_game", player.data)
	if number_of_players < 1:
		rpc("_end_of_game_tie")
					

@rpc("call_local")
func _end_of_game(data):
	var win_screen : Label = end_of_game_ui.get_node("Victory")
	win_screen.text = data["name"] + " wins"
	win_screen.add_theme_color_override("font_color", data["colour"])
	hud.show()
	end_of_game_ui.show()

		
@rpc("call_local")
func _end_of_game_tie():
	var win_screen : Label = end_of_game_ui.get_node("Victory")
	win_screen.text = "No one wins"
	win_screen.add_theme_color_override("font_color", Color.WHITE)
	hud.show()
	end_of_game_ui.show()

func _start_rematch():
	server_hud.show()
	rpc("rematch")
	
@rpc("call_local", "any_peer")
func rematch():
	print("rematch")
	for player_id in all_players:
		var player : RigidBody3D = get_node_or_null(player_id)
		if player != null:
			#print("die")
			player.get_child(3).public_visibility = false
			player.free()
	number_of_players = 0
	amount_of_players_ready = 0
	if multiplayer.get_unique_id() == 1:
		for player_id in all_players:
			add_player(player_id)
	print(all_players)
	game_start = false
	all_players.clear()
	end_of_game_ui.hide()
	restart.emit()
