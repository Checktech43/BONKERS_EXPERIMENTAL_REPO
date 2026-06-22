extends Camera3D

####################################

# Unused Camera script
# for when the game was suposed to be viewed
# from an orthaganel position.


#########################################
signal mouse(mouse_pos)
var sensativaty : float = 0.2
var camera_mode : bool = false
var move_speed : float = 10
func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state # "space_state" is magic
	var mousepos = get_viewport().get_mouse_position() # "mousepos" is were the mouse is on a 2D Vector on your screen
#
	var start_of_ray : Vector3 = project_ray_origin(mousepos) # start the ray from the camra
	var end_of_ray : Vector3 = start_of_ray + project_ray_normal(mousepos) * 1000 # end the ray some distance away
	var query = PhysicsRayQueryParameters3D.create(start_of_ray, end_of_ray)  # create the ray
	
	## collide with the floor
	query.collide_with_areas = true
	## do collide not with players
	query.collide_with_bodies = false
	
	## This gives us data on what the ray passed through and at what point it pased it at.
	var data_on_ray_from_mouse : Dictionary = space_state.intersect_ray(query)
	mouse.emit(data_on_ray_from_mouse)
	
	
#### Debug camera controls
func _process(delta):
	var place_to_move : Vector3
	if camera_mode:
		var move_dir : Vector3
		if Input.is_action_pressed("slide_to_the_left"):
			move_dir = Vector3.LEFT
		if Input.is_action_pressed("slide_to_the_right"):
			move_dir += Vector3.RIGHT
		if Input.is_action_pressed("forward"):
			move_dir += Vector3.FORWARD
		if Input.is_action_pressed("backward"):
			move_dir += Vector3.BACK
		place_to_move = move_dir * move_speed * delta
		translate(place_to_move)
	else:
		place_to_move.x = 0
		place_to_move.y = 0
		
		
#### Normal Camera controls
func _input(event):
	if event.is_action_pressed("rotate_camera"):
		camera_mode = true
	if event is InputEventMouseMotion && camera_mode:
		rotation_degrees -= Vector3(clampf(event.screen_relative.y, -90, 90), event.screen_relative.x, 0) * sensativaty 
	if event.is_action_released("rotate_camera"):
		camera_mode = false
		
	if event.is_action_pressed("zoom_in") && camera_mode:
		if fov > 50:
			fov -= 3
	if event.is_action_pressed("zoom_out") && camera_mode:
		if fov < 100:
			fov += 3
			
