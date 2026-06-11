extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("HammerAction")
	on_animation_finished()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func on_animation_finished():
	await get_tree().create_timer(1.5).timeout
	$".".queue_free()
