extends Node
@export var cosmetices_scene : PackedScene
signal on_pressing_return
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_pressing_return.connect($".."._return_to_main_menu)
	for button in get_child(0).get_children():
		button.change_skin.connect(on_button_pressed)


func _on_return() -> void:
	on_pressing_return.emit()
	
	
func on_button_pressed(cosmetic_str, cosmetic_type = "Skin") -> void:
	var grooble : Node3D = get_node("../Cosmetics")
	var cosmetic : Node3D = grooble.change_look(cosmetic_str, cosmetic_type)
	cosmetic.owner = grooble # The cosmetic has to be owned by the grooble or else it will not be packed in to the "Cosmetices" scene
	cosmetices_scene.pack(grooble)
	
	
