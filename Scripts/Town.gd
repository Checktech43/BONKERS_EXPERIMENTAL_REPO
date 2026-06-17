extends Node
@export var main_menu_buttons: CanvasLayer
@export var Change_skin_hud: CanvasLayer
@export var camera: Camera3D
@export var camera_offset_for_customisation : Vector3
@export var defalut_camera_offset : Vector3



func _on_switch_to_customize():
	main_menu_buttons.hide()
	Change_skin_hud.show()
	camera.position = camera_offset_for_customisation
	
func _return_to_main_menu() -> void:
	main_menu_buttons.show()
	Change_skin_hud.hide()
	camera.position = defalut_camera_offset
