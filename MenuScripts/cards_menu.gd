extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		var players = $"../Players".get_children()
		for player in players:
			player.freeze = false
			if player.knockback_multiplier == 2:
				player.knockback_multiplier = 1
		if players.size() <= 1:
			visible = false
		

func _on_queen_hearts_pressed() -> void:
	visible = false


func _on_jack_spades_pressed() -> void:
	if !visible:
		return
	#if is_multiplayer_authority():
	var players = $"../Players".get_children()
	for player in players:
		player.has_weapon = true
	visible = false


func _on_two_clubs_pressed() -> void:
	visible = false


func _on_ace_diamonds_pressed() -> void:
	if !visible:
		return
	#if is_multiplayer_authority():
	visible = false
	var players = $"../Players".get_children()
	for player in players:
		player.freeze = true
	
