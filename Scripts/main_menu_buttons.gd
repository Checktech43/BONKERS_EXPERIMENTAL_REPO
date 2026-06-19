extends Node

signal went_to_cosmetics
var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Hide the join code panel when the game starts
	$Control/JoinCodePanel.visible = false
	
	# 2. Connect the main menu buttons
	$Control/HostButton.pressed.connect(MultiplayerHandler.host_game)
	$Control/Join.pressed.connect(_on_open_join_panel)
	
	# 3. Connect the buttons INSIDE the JoinCodePanel
	$Control/JoinCodePanel/CloseButton.pressed.connect(_on_close_join_panel)
	$Control/JoinCodePanel/JoinGameButton.pressed.connect(_on_submit_join_code)
	
	went_to_cosmetics.connect($".."._on_switch_to_customize)

# Opens the panel and readies the input field
func _on_open_join_panel() -> void:
	$Control/JoinCodePanel.visible = true
	$Control/JoinCodePanel/JoinCodeInput.text = "" # Clear any previous entry
	$Control/JoinCodePanel/JoinCodeInput.grab_focus() # Automatically let them start typing

# Closes the panel and hides it from view/clicks
func _on_close_join_panel() -> void:
	$Control/JoinCodePanel.visible = false

# Grabs the text typed by the player and sends it to your multiplayer handler
func _on_submit_join_code() -> void:
	var entered_code = $Control/JoinCodePanel/JoinCodeInput.text
	
	# Check if the player actually typed something before trying to join
	if entered_code.strip_edges() != "":
		MultiplayerHandler.join_game(entered_code)
	else:
		print("Lobby code cannot be empty!")

func _on_pressing_cosmetics() -> void:
	went_to_cosmetics.emit()

func _on_pressing_settings() -> void:
	pass # Replace with function body.

func _on_pressing_quit() -> void:
	pass # Replace with function body.
