extends Node

var game_start : bool = false
var dead_boys : Array[RigidBody3D]
signal action_phase_time
signal restart
signal change_game_state
signal game_over


@export var player_scene : PackedScene
@export var hud : CanvasLayer
@export var card_menu: CanvasLayer

### game modifers
var fast_pace : bool = false
var cards : bool = true
var free_movement = false
var modifiers : Dictionary[String, bool]


func _ready():
	if multiplayer.is_server():
		add_player()
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_player)
	modifiers = {"Cards": true,
	"FastPace": false,
	"FreeMovement": false,
	"UnlimitedTime": false,
	}


# Keep in mind That when the cubes are first joining the game,
# that only the host calls this function
func add_player(id : int = 1):
	if game_start: return
	# create the player and give it all the neceacery data
	var player : RigidBody3D = player_scene.instantiate()
	player.name = str(id)
	player.position = Vector3(0, 0.25, 0)
	$Players.add_child(player, true)


func _on_switching_modifier(switch_name, new_state):
	modifiers[switch_name] = new_state
	print(modifiers)
	
func _on_player_joining():
	update_modifiers_for_joining_player.rpc(modifiers)

@rpc("authority")
func update_modifiers_for_joining_player(host_modifiers):
	modifiers = host_modifiers
	
func _on_all_players_ready() -> void:
	action_phase_time.emit()
	if modifiers["FastPace"] == true:
		$ActionPhaseTimer.start(1)
	else:
		$ActionPhaseTimer.start()

func on_start_button_getting_pressed() -> void:
	rpc("start_the_game")
	
@rpc("call_local")
func start_the_game():
	if modifiers["UnlimitedTime"] == false:
		$PlanningTimer.start()
	game_start = true
	change_game_state.emit(game_start)

func _on_something_fell(body: Node3D) -> void:
	if not body.is_class("RigidBody3D"): return
	if not game_start:
		body.linear_velocity = Vector3(0, 0, 0)
		body.position = Vector3(0, 0.5, 0)
	else:
		body.get_node("MultiplayerSynchronizer").public_visibility = false # I don't know why this line of code is here. But it errors out when it's not there, so it stays
		if is_multiplayer_authority():
			#rpc("remove_player", body.name.to_int())
			body.queue_free()
			$EndOfGameDelay.start()
		
@rpc("any_peer", "call_local")
func remove_player(id):
	print("man im dead")
	var player : RigidBody3D = get_node_or_null("Players/" + str(id))
	#if player:
	#	player.queue_free()
	
	print("The " + str(id) + " cube is dead!")
	
 
@rpc("authority", "call_local")		
func add_bot():
	var bot = load("res://Scenes/ai_grooble.tscn").instantiate()
	$Players.add_child(bot)
	
@rpc("authority", "call_local")
func remove_bot():
	for player in $Players.get_children():
		if player.is_in_group("ai"):
			player.queue_free()
			break
		
		
		
func _check_for_winners() -> void:
	if $Players.get_children().size() == 1:
		rpc("_end_of_game", $Players.get_child(0).data)
	elif $Players.get_children().size() < 1:
		var no_one_wins : Dictionary = {"name" : "nobody", "colour" : Color.WHITE}
		rpc("_end_of_game", no_one_wins)
		
	
@rpc("any_peer", "call_local")
func card_menu_show():
	card_menu.on_visible()
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
	add_player()
	for player_id in multiplayer.get_peers():
		add_player(player_id)
	rpc("rematch")

	
@rpc("call_local", "authority")
func rematch():
	print("rematch")
	$CurrentMap.go_to_lobby()
	#if is_multiplayer_authority():
	restart.emit()

	
func _on_finishing_action_phase():
	if modifiers["UnlimitedTime"] == true:
		pass
	elif modifiers["FastPace"] == true:
		$PlanningTimer.start(1)
	else:
		$PlanningTimer.start()
	if !is_multiplayer_authority():
		return
	if modifiers["Cards"] == true:
		card_menu_show.rpc()
	
	
func _on_victory_timeout() -> void:
	if $Players.get_children().size() > 0 && is_multiplayer_authority():
		$Players.get_child(0).get_node("MultiplayerSynchronizer").public_visibility = false
		$Players.get_child(0).queue_free()
		#rpc("remove_player", $Players.get_child(0).name.to_int())


func _on_button_button_down() -> void:
	DisplayServer.clipboard_set($MutiplayerHud/LobbyCode.text)
