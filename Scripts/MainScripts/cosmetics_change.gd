extends Node

func change_look(cosmetic_name, cosmetic_type = "Skin"):
	if cosmetic_name == "": return
	
	var cosmetic = load("res://" + cosmetic_type + "s/" + cosmetic_name + ".glb").instantiate()
	var cosmetic_slot : Node3D = get_node(cosmetic_type)
	
	if cosmetic_type == "Skin":
		cosmetic.scale = Vector3(0.5, 0.5, 0.5)
	if cosmetic_slot.get_children().size() > 0:
		cosmetic_slot.get_child(0).free()
	cosmetic_slot.add_child(cosmetic)
	return cosmetic
	
	
