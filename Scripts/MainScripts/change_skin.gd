extends BaseButton


signal change_skin
func _pressed() -> void:
	change_skin.emit(name)
