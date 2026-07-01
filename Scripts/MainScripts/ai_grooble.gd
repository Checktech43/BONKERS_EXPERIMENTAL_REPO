extends "res://Scripts/MainScripts/player_physics.gd"

@export_enum("Braindead", "Somewhat Competent", "Actually Kind of Good", "Older Brother") var ai_level: int
var visible_players = []

	
	
	
func _process(state):	
	if random:
		rotation = Vector3(0, 0, 0)
		lock_rotation = true
		position = starting_pos
		random = false
	target_dir = (target - global_position).normalized()
	cpu_logic()
	
func _physics_process(delta: float) -> void:
		if planning:
			$RayCast3D.rotation.y += 360 * delta
			if $RayCast3D.rotation.y > 99999:
				$RayCast3D.rotation.y = 0 # this is to prevent the game from crashing if the raycast rotates for too long
	
func cpu_logic():
	
	### AI level zero means braindead difficulty
	### All it does is pick a random direction and goes.
	if ai_level == 0 and planning:
		rotation.y = randi_range(0, 360)
		print("GOTTA MAKE A MOVE TO A TOWN THAT'S RIGHT FOR ME")
		player_is_ready()
		
	
	
	### the ai uses a constantly rotating raycast to detect players around it
	if $RayCast3D.is_colliding() and planning and ai_level > 0:
		var collider = $RayCast3D.get_collider()
		if collider.is_in_group("player") and !visible_players.has(collider):
			visible_players.append(collider)
			print(visible_players)
			
		
		var target = await score_players()
		#var closest_player = find_closest_player()
		look_at(target.global_position)
		
		var direction_safety = check_direction_safety()
		player_is_ready()
		print("I ART READYETH")
		send_ghost()
	
func find_closest_player() -> RigidBody3D:
	var closest_player = null
	var closest_distance = INF
	var collider = $RayCast3D.get_collider()
	print(collider)
	if !visible_players.has(collider):
				visible_players.append(collider)
				for target in visible_players:
					var distance = global_position.distance_squared_to(target.global_position)
					if distance < closest_distance:
						closest_distance = distance
						closest_player = target
								
	return closest_player
	
	
### The AI scores players based on how close they are, how close they are to an edge, etc
### The player with the highest score will be the on the AI targets
func score_players() -> RigidBody3D:
	var highest_score = 0
	var highest_scorer
	
	
	for player in visible_players:
		var score = 0
		score += 100.0 / global_position.distance_to(player.global_position)
		if ai_level >= 2:
			
			var target_danger = await check_target_danger(player)
			if target_danger < 2:
				score += 50
			
		
		if score > highest_score:
			highest_score = score
			highest_scorer = player
	
	return highest_scorer
	
func player_is_ready() -> void:
	# Lock in the power and diriction of the player, and tell the server that they are ready.
	locked_in_power = power * 100 + 275
	locked_in_target_dir = Vector3(target_dir.x, 0, target_dir.z)
	if playing_game:
		is_player_ready = true
		planning = false
		$arrow_Bonkers.visible = false
	else:
		push()
	
	
	
### To check how much danger the target is in, the AI sends a ghost cube on it's position.
### The ghost cube has five raycasts pointing down from it colliding with the ground.
### The less raycasts which are colliding, the more danger the target is in.
func check_target_danger(player: RigidBody3D) -> float:
	var ghost_cube = load("res://Scenes/ghost_grooble.tscn")
	var cube_to_send = ghost_cube.instantiate()
	
	add_child(cube_to_send)
	cube_to_send.global_position = player.global_position
	
	await get_tree().physics_frame
		
	var ghost_rays = cube_to_send.ghost_rays
	#print("THE RAYS WHICH EXIST ARE:" + str(ghost_rays))
	var support = 0
	
		
	
	
	for ray in ghost_rays:
		ray.force_raycast_update()
		print(ray.enabled)
		if ray.is_colliding():
			support += 1
	
	#print("THIS CUBE HAS " + str(support) + " / 5 SAFENESS")
	
	return support
	
	
### There are raycasts underneath the arrow used for choosing player power.
### If any of the raycasts returns nothing, it's probably not safe to move in the current direction.
func check_direction_safety() -> bool:
	var arrow_rays = $arrow_Bonkers.get_children()
	for object in arrow_rays:
		if !object.is_in_group("raycast"):
			arrow_rays.erase(object)
			
			
	var rays_colliding = 0
	for ray in arrow_rays:
		if ray.is_colliding():
			print(ray.get_collider())
			ray.force_raycast_update()
			rays_colliding += 1
			
	#print("THIS DIRECTION HAS " + str(rays_colliding) + " / 6 SAFETY")
	
	if rays_colliding >= 5:
		return true
	else:
		return false
		
		
func send_ghost():
	#print("GHOST BUSTERS")
	var ghost_cube = load("res://Scenes/ghost_grooble.tscn")
	var cube_to_send = ghost_cube.instantiate()
	
	cube_to_send.inherited_power = power
	add_child(cube_to_send)
	cube_to_send.rotation.y = rotation.y
	cube_to_send.global_position = self.global_position 
	
func planning_phase():
	planning = true
	is_player_ready = false
