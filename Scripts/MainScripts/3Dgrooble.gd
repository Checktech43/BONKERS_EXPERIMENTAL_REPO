extends Node

func _on_picking_skin(skin) -> void:
	get_child(-1).free()
	skin.scale = Vector3(0.5, 0.5, 0.5)
	add_child(skin)
	# comment
	
	
