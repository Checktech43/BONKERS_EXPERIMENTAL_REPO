extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		var players = $"../Players".get_children()
		for player in players:
			player.freeze = false
			player.is_ghost = false
			player.scale = Vector3(1, 1, 1)
			if player.knockback_multiplier == 2:
				player.knockback_multiplier = 1
		if players.size() <= 1:
			visible = false
		

func _on_queen_hearts_pressed() -> void:
	var players = $"../Players".get_children()
	for player in players:
		player.weapon = player.hammer
		player.has_weapon = true
	visible = false


func _on_jack_spades_pressed() -> void:
	if !visible:
		return
	var players = $"../Players".get_children()
	for player in players:
		player.weapon = player.spade
		player.has_weapon = true
	visible = false


func _on_two_clubs_pressed() -> void:
	visible = false
	
	if multiplayer.is_server():
		request_swap()
	else:
		request_swap.rpc()


@rpc("any_peer")
func request_swap():
	if !multiplayer.is_server():
		print("nuh uh")
		return
	
	var players = $"../Players".get_children()

	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()
	
	var target_id
	
	var sender_player = null
	var targets = []

	for player in players:
		if player.name == str(sender_id):
			sender_player = player
		else:
			targets.append(player)

	if sender_player == null or targets.is_empty():
		return # do nothing if there is no player to switch with

	var target_player = targets.pick_random()
	target_id = int(target_player.name)

	var player_1_pos = sender_player.global_position
	var player_2_pos = target_player.global_position
	
	# the switching of players is performed on the owner of each player due to authority shenanigans
	move_player.rpc_id(target_id, player_1_pos, target_id)
	move_player.rpc_id(sender_id, player_2_pos, sender_id)
	
@rpc("authority", "call_local")
func move_player(new_position, id):
	print(new_position)
	var players = $"../Players".get_children()
	var player_to_move
	for player in players:
		if player.get_multiplayer_authority() == id:
			player_to_move = player
		
	await get_tree().process_frame # a single frame delay is needed to prevent synchronization issues
	player_to_move.global_position = new_position
	print(player_to_move.global_position)
	
	
	
func _on_ace_diamonds_pressed() -> void:
	if !visible:
		return
	#if is_multiplayer_authority():
	visible = false
	var players = $"../Players".get_children()
	for player in players:
		player.freeze = true
	

func _on_ghost_card_button_down() -> void:
	if !visible:
		return
	visible = false
	var players = $"../Players".get_children()
	for player in players:
		player.is_ghost = true


func _on_big_card_button_down() -> void:
	if !visible:
		return
	visible = false
	var players = $"../Players".get_children()
	for player in players:
		await get_tree().process_frame # a single frame delay is needed to prevent sync issues
		player.scale = Vector3(3, 3, 3)

	


func _on_jump_button_down() -> void:
	if !visible:
		return
	visible = false
	var players = $"../Players".get_children()
	for player in players:
		player.can_jump = true
