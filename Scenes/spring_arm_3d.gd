extends SpringArm3D

@export var mouse_sensitivity: float = 0.005

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.y * mouse_sensitivity
