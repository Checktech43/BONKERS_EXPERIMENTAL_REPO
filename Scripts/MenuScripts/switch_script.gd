extends BaseButton


signal toggle_switch
func _toggled(new_state) -> void:
	toggle_switch.emit(name, new_state)
