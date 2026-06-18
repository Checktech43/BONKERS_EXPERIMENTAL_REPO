extends RigidBody3D

var inherited_power

@onready var ghost_rays = $RayCasts.get_children()

var timer = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inherited_power:
		push()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		queue_free() # this is to prevent an army of ghosts from building up over the course of the game
	
func _physics_process(delta: float) -> void:
	for ray in ghost_rays:
		ray.force_raycast_update()
	
func push():
	var power = inherited_power * 100 + 500
	var forward = -transform.basis.z
	apply_force(forward * power)
