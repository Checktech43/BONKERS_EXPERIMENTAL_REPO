extends Node

const CLICK_SOUND = preload("res://Assets/Sounds/soundfx/ui/ButtonPress.mp3") 
const HOVER_SOUND = preload("res://Assets/Sounds/soundfx/ui/Hover.mp3") 

# Tracks which buttons are currently being hovered
var hovered_buttons: Array[Button] = []

# Tracks active tweens for each button so we can stop them instantly
var active_tweens: Dictionary = {}

# Permanent single audio players to prevent overlapping/distortion
var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

func _ready() -> void:
	# Initialize single audio channels on setup
	hover_player = AudioStreamPlayer.new()
	hover_player.stream = HOVER_SOUND
	hover_player.volume_db = -18.0 # <--- ADD THIS (Lower number = quieter hover)
	add_child(hover_player)
	
	click_player = AudioStreamPlayer.new()
	click_player.stream = CLICK_SOUND
	click_player.volume_db = -15.0  # <--- ADD THIS (Lower number = quieter click)
	add_child(click_player)

	

	# Wait one frame to make sure the UI layout is fully calculated
	await get_tree().process_frame
	
	# Find EVERY button inside the UI canvas layer
	var parent_ui = get_parent()
	_setup_buttons_recursive(parent_ui)



func _setup_buttons_recursive(node: Node) -> void:
	if node is Button:
		# SAFETY GUARD: Prevent duplicate connections
		if node.has_meta("juiced"):
			return
			
		node.set_meta("juiced", true)
		
		# CRUCIAL: Remember the exact layout position of this button before any animations touch it
		node.set_meta("original_pos", node.position)

		# Connect the signals to our animation functions
		node.mouse_entered.connect(_on_button_hover.bind(node))
		node.mouse_exited.connect(_on_button_normal.bind(node))
		node.pressed.connect(_on_button_pressed.bind(node))
		
		# Set pivot offset to center so it scales from the middle
		node.pivot_offset = node.size / 2.0
		# Make sure it updates pivot if resized
		node.resized.connect(func(): 
			node.pivot_offset = node.size / 2.0
			# Update original position metadata if something shifts it safely
			if not hovered_buttons.has(node):
				node.set_meta("original_pos", node.position)
		)
		
	for child in node.get_children():
		_setup_buttons_recursive(child)

# --- ANIMATIONS ---

func _on_button_hover(btn: Button) -> void:
	if not hovered_buttons.has(btn):
		hovered_buttons.append(btn)
		hover_player.play()
		
	# Get its permanent home position from metadata
	var original_pos = btn.get_meta("original_pos", btn.position)
	
	# Clear any running reset tweens
	if active_tweens.has(btn) and is_instance_valid(active_tweens[btn]):
		active_tweens[btn].kill()
		
	# Scale up to 1.15 smoothly
	var scale_tween = create_tween()
	scale_tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Start the figure-8 loop
	_play_breezy_loop(btn, original_pos)

func _on_button_normal(btn: Button) -> void:
	hovered_buttons.erase(btn)
	
	# INSTANTLY kill the figure-8 loop so it stops moving away
	if active_tweens.has(btn) and is_instance_valid(active_tweens[btn]):
		active_tweens[btn].kill()
		
	var original_pos = btn.get_meta("original_pos", btn.position)
	
	# Smoothly return to original size AND original position at the exact same time
	var reset_tween = create_tween().set_parallel(true)
	reset_tween.tween_property(btn, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_property(btn, "position", original_pos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	active_tweens[btn] = reset_tween

func _on_button_pressed(btn: Button) -> void:
	click_player.play()
	
	# If clicked, temporarily squish it down and pop back up to hover scale
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.05).set_trans(Tween.TRANS_QUAD)

# --- LOOPING FIGURE-8 IDLE ANIMATION ---

func _play_breezy_loop(btn: Button, original_pos: Vector2) -> void:
	# Double check we are still hovering before starting a new loop cycle
	if not hovered_buttons.has(btn):
		return
		
	var wave_tween = create_tween()
	active_tweens[btn] = wave_tween
	
	var t1 = 0.12
	var t2 = 0.22
	
	# --- Right Lobe ---
	wave_tween.tween_property(btn, "position", original_pos + Vector2(2, -2), t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.tween_property(btn, "position", original_pos + Vector2(4, 0), t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.tween_property(btn, "position", original_pos + Vector2(2, 2), t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# --- Cross Over Center ---
	wave_tween.tween_property(btn, "position", original_pos + Vector2(-2, -2), t2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# --- Left Lobe ---
	wave_tween.tween_property(btn, "position", original_pos + Vector2(-4, 0), t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wave_tween.tween_property(btn, "position", original_pos + Vector2(-2, 2), t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# On loop finish, repeat the cycle seamlessly
	wave_tween.finished.connect(func(): _play_breezy_loop(btn, original_pos))
