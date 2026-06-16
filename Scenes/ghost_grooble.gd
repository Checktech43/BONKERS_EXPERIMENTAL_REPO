extends RigidBody3D

var inherited_power

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	push()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func push():
	var power = inherited_power * 100 + 500
	var forward = -transform.basis.z
	apply_force(forward * power)
