extends Node

var net_mode : String = "ENet"
var peer
var lobbies = {}
var lobby_id : int
var is_host: bool = false
var is_joining: bool = false



func _ready():
	if net_mode == "ENet":
		peer = ENetMultiplayerPeer.new()
	else:
		peer = SteamMultiplayerPeer.new()
	print("Steam Initialized ", Steam.steamInit(480, true)) # 480 should be replaced with the games steam id once we have a steam page
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	
	
	#multiplayer.connected_to_server.connect(
	#func():
		#print("CONNECTED TO SERVER")
	#)
	#multiplayer.connection_failed.connect(
		#func():
			#print("CONNECTION FAILED")
	#)
	#multiplayer.peer_connected.connect(
		#func(id):
			#print("PEER CONNECTED:", id)
	#)


func host_game() -> void:
	if net_mode == "ENet":
		peer.create_server(6969)
		multiplayer.multiplayer_peer = peer
		go_to_lobby()
	elif net_mode == "Steam":
		# create the host
		Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)
		#multiplayer.peer_connected.connect(count_players)
	
	
	
	#var id = multiplayer.get_unique_id()
	#create_lobby(id)
	#count_players()
	# change ui

func _on_lobby_created(result: int, lobby_id: int):
	print("GABEN")
	if result == Steam.Result.RESULT_OK:
		self.lobby_id = lobby_id
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		var owner = Steam.getLobbyOwner(lobby_id)
		print("Lobby owner: ", owner)
		multiplayer.multiplayer_peer = peer
		# Call the "add_player" function every time someone connects to the server.
		
		multiplayer.peer_connected.connect(
			func(id):
				print("PEER CONNECTED:", id)
		)
		#$MapSelection.visible = true
		
		#$MutiplayerHud/LobbyCode.text = str(lobby_id)
		#$MutiplayerHud/LobbyCode/Button.visible = true
		go_to_lobby()
		


func join_game(entered_code = "123456789"):
	is_joining = true
	if net_mode == "ENet":
		peer.create_client("127.0.0.1", 6969)
		multiplayer.multiplayer_peer = peer
		go_to_lobby()
	elif net_mode == "Steam":
		var code_entered : String = entered_code
		print("Attempting to join lobby:", code_entered)
		Steam.joinLobby(code_entered.to_int())
	
	# create the client
	#peer.create_client("127.0.0.1", 6969)
	#
	#multiplayer.connected_to_server.connect(
		#func():
			#request_join_lobby.rpc_id(1, code_entered)
	#)
	
func _process(delta: float) -> void:
	Steam.run_callbacks()


func _on_lobby_joined(lobby_id : int, permissions : int, locked : bool, response : int):
	if ! is_joining:
		return
	self.lobby_id = lobby_id
	#var owner = Steam.getLobbyOwner(lobby_id)
	print("LOBBY JOINED SIGNAL")
	print("Lobby:", lobby_id)
	print("Response:", response)
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	#var result = peer.create_client(owner)
	#print("create_client result:", result)
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.connected_to_server.connect(
		func():
			print("CONNECTED TO SERVER")
	)
	multiplayer.multiplayer_peer = peer
	
	
	is_joining = false
	go_to_lobby()
	

	
@rpc("any_peer")
func request_join_lobby(code: String):
	var sender_id = multiplayer.get_remote_sender_id()
	code = code.to_upper()
	#print(lobbies)
	if lobbies.has(code):
		lobbies[code]["players"].append(sender_id)
		return true
	else:
		join_failed.rpc_id(sender_id, sender_id)
		return false
		
@rpc
func join_success():				
	pass
@rpc("call_local")
func join_failed(sender_id):
	print("die")
	multiplayer.multiplayer_peer.close()
	

func generate_lobby_code(length := 6) -> String:
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code = ""

	for i in range(length):
		code += chars[randi() % chars.length()]

	return code
	
func go_to_lobby():
	get_tree().change_scene_to_file("res://MainScenes/main.tscn")
