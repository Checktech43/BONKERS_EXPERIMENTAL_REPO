extends RigidBody3D

### movement variables for planing phase
var speed: float = 0.1
var target: Vector3
var power: float = 5
var target_dir: Vector3
var starting_pos : Vector3

### The varibles that are actully used for the movement in the action phase
var locked_in_power : float
var locked_in_target_dir : Vector3

### bools
var planning : bool = true # planning makes it so that you can't get ready twice
var random : bool = false
var playing_game : bool = false
var coloured : bool = false
var can_jump : bool = false
var is_player_ready : bool
var unlimited_power : bool




### other stuff
var is_pointing_at_floor : Dictionary
@export var animation_player: AnimationPlayer 
# This data is usless if you want to add data for the players put it in the "multiplayer_handler" script.
var data : Dictionary = {"name" : "Jombom", "colour" : Color.BLUE}
var cosmmetics : Node3D
signal is_ready
var weapon
var has_weapon = true
var knockback_multiplier = 1

@export var mouse_sensitivity: float = 0.003
@export var rotation_smoothness := 12.0
@export var cosmmetics_scene : PackedScene
@onready var spring_arm = $SpringArm3D

@export var is_ghost := false:
	set(value):
		is_ghost = value

		set_collision_layer_value(2, !value)
		set_collision_layer_value(3, value)
		set_collision_mask_value(2, !value)

var target_yaw = 0

var spade: PackedScene = load("res://Scenes/spade_projectile.tscn")
var hammer: PackedScene = load("res://Scenes/hammer.tscn")



func _ready() -> void:
		
	$arrow_Bonkers.visible = false
	$SpringArm3D/Camera3D.current = false
	$arrow_Bonkers.basis.z.z = -power / 2
	# Connect all the signals between the players and everything else in the main scene.
	is_ready.connect($".."._player_ready)
	#$"../../Camera3D".connect("mouse", _look_at_mouse)
		
		
func _unhandled_input(event: InputEvent) -> void:
	if coloured == false && is_multiplayer_authority() && NOTIFICATION_SCENE_INSTANTIATED:
		change_skin(1)
		multiplayer.peer_connected.connect(change_skin)
		coloured = true
	if !playing_game:
		return
	if event is InputEventMouseMotion and planning:
		target_yaw -= event.relative.x * mouse_sensitivity


func _physics_process(delta: float) -> void:
	if planning and is_multiplayer_authority():
		target_dir = (target - global_position).normalized()
		rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		rotation_smoothness * delta
		)
	
func go_to_random_position(new_pos):
	starting_pos = new_pos
	linear_velocity = Vector3(0, 0, 0)
	random = true



	
		
func _process(state):	
	# For some reason when trying to change the position of the cube in the "go_to_random_position" function
	# The cube just does not teleport to the new position.
	# so you have to change the position here instead.
	if random:
		rotation = Vector3(0, 0, 0)
		lock_rotation = true
		position = starting_pos
		random = false
	target_dir = (target - global_position).normalized()
	

func planning_phase():
	if is_multiplayer_authority():
		planning = true
		is_player_ready = false
		$arrow_Bonkers.visible = true
	
func _input(event):
	if !playing_game or !is_multiplayer_authority():
		return
	if event.is_action_pressed("confirm") && planning:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and !$"../..".card_menu.visible:
			player_is_ready()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# the behaver of the scroll wheel 
	if event.is_action_pressed("add_more") && planning && power < 10:
		power += 1
		change_arrow_size()
	if event.is_action_pressed("remove_some") && planning && power > 1:
		power -= 1
		change_arrow_size()
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("jump") and is_multiplayer_authority() and can_jump:
		jump()
	if event.is_action_pressed("weapon") and has_weapon and weapon != null and is_multiplayer_authority():
		spawn_weapon.rpc(weapon.resource_path)
		
		
func push():
	if is_multiplayer_authority():
		update_rotation.rpc(rotation.y) 
	var forward = -transform.basis.z
	apply_force(forward * locked_in_power)

	

# Rotation is only synched when all players are moving
@rpc("authority", "call_remote")
func update_rotation(y_rotation: float):
	rotation.y = y_rotation

func jump():
	apply_central_force(Vector3(0, 70, 0) * 10)
	can_jump = false


# Let the other clients control their cube.
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	position = Vector3(0, 0.5, 0)
	

func _look_at_mouse(mouse) -> void:
	if not is_multiplayer_authority():
		return
	is_pointing_at_floor = mouse
	if mouse != {}  and planning == true:
		target = mouse["position"]
		look_at(target)
		
		
		# We only care about rotating from side to side,
		# so when the "look_at" function changes any of the other rotation axis
		# we just change them back to normal before doing anything else
		if rotation.x != 0 or rotation.z != 0:
			rotation.x = 0
			rotation.z = 0
		

func toggle_ragdoll_mode(game_state):
	if not is_multiplayer_authority():
		return
		
		
	if game_state:
		$arrow_Bonkers.visible = true
		$SpringArm3D/Camera3D.current = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$SpringArm3D/Camera3D.current = true
		$"../../Camera3D".current = false
		lock_rotation = true
	else:
		$arrow_Bonkers.visible = false
		$SpringArm3D/Camera3D.current = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$SpringArm3D/Camera3D.current = false
		$"../../Camera3D".current = true
		lock_rotation = false
		
		
func change_arrow_size():
	$arrow_Bonkers.basis.z.z = -power / 2


	
@rpc("any_peer", "call_local")
func spawn_weapon(weapon_id: String):
	var scene = load(weapon_id)
	var current_weapon = scene.instantiate()
	add_child(current_weapon)
	current_weapon.global_position = $WeaponSpawn.global_position
	current_weapon.rotation.y = rotation.y
	has_weapon = false
	
func recieve_knockback(direction: Vector3, force: float):
	
	
	var final_force = force * knockback_multiplier
	
	apply_impulse(direction.normalized() * final_force)

func player_is_ready() -> void:
	if not is_multiplayer_authority():
		return
			
	# Lock in the power and diriction of the player, and tell the server that they are ready.
	locked_in_power = power * 100 + 275
	locked_in_target_dir = Vector3(target_dir.x, 0, target_dir.z)
	if playing_game:
		is_player_ready = true	
		is_ready.emit()
		planning = false
		$arrow_Bonkers.visible = false
	else:
		push()


func _on_body_entered(body: Node) -> void:
	var enemy_force : float = abs(body.linear_velocity.x) + abs(body.linear_velocity.z)
	var your_force : float = abs(linear_velocity.x) + abs(linear_velocity.z)
	if your_force > enemy_force:
		body.recieve_knockback(transform.basis.z, your_force)
	elif your_force == enemy_force:
		body.recieve_knockback(transform.basis.z, your_force)
		recieve_knockback(transform.basis.z, enemy_force)
	else:
		recieve_knockback(transform.basis.z, enemy_force)
		
	if body.is_in_group("players") and body.knockback_multiplier == 2:
		body.recieve_knockback(transform.basis.z, 5)
	if body.is_in_group("hammer"):
		knockback_multiplier = 2

# id is an argument that the "peer_connected" signal allways passes, so it's just kind of there
func change_skin(id):
	cosmmetics = cosmmetics_scene.instantiate()
	#print(cosmmetics.get_child(0).get_child(0).name)
	$Cloths.add_child(cosmmetics)
	var skin : String = ""
	var hat : String = ""
	var beard : String = ""
	var glasses : String = ""
	var other : String = ""
	#if $Cloths.get_children().size() > 0:
	$Cloths.get_child(0).queue_free()
	if cosmmetics.get_node("Skin").get_children().size() > 0:
		skin  = cosmmetics.get_node("Skin").get_child(0).name
	if cosmmetics.get_node("Hat").get_children().size() > 0:
		hat = cosmmetics.get_node("Hat").get_child(0).name
	if cosmmetics.get_node("Beard").get_children().size() > 0:
		beard  = cosmmetics.get_node("Beard").get_child(0).name
	if cosmmetics.get_node("Glasses").get_children().size() > 0:
		glasses  = cosmmetics.get_node("Glasses").get_child(0).name
	if cosmmetics.get_node("Other").get_children().size() > 0:
		other  = cosmmetics.get_node("Other").get_child(0).name
	rpc("change_skin_for_others", skin, hat, beard, glasses, other)
	
			
@rpc ("any_peer", "call_remote")
func change_skin_for_others(skin, hat, beard, glasses, other):
	cosmmetics = cosmmetics_scene.instantiate()
	cosmmetics.change_look(skin, "Skin")
	cosmmetics.change_look(hat, "Hat")
	cosmmetics.change_look(beard, "Beard")
	cosmmetics.change_look(glasses, "Glasses")
	cosmmetics.change_look(other, "Other")
	$Cloths.add_child(cosmmetics)
	if $Cloths.get_children().size() > 0:
		$Cloths.get_child(0).queue_free()
