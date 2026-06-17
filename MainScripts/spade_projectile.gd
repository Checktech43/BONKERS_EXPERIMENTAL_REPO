extends RigidBody3D

var speed: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var forward = -transform.basis.z # "-transform.basis.z" means forward in Godot
	apply_force(forward * speed * 50 * delta)
	sync_position(position)
@rpc("authority", "unreliable", "call_local")
func sync_position(pos):
	position = pos
