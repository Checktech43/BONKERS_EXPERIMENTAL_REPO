extends Node

signal went_to_cosmetics
var peer = ENetMultiplayerPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/Play/HostButton.pressed.connect(MultiplayerHandler.host_game)
	$Control/Play/JoinButton.pressed.connect(MultiplayerHandler.join_game)
	$Control/Play/Join.pressed.connect(MultiplayerHandler.join_game)
	went_to_cosmetics.connect($".."._on_switch_to_customize)
	
	
#func _on_pressing_play(id) -> void:
	#if id == 0:
	#	_on_pressing_host()
	#elif id == 1:
	#	_on_pressing_join()

#func _on_pressing_host() -> void:
	#print("goob")
	#peer.create_server(6969)
	#multiplayer.multiplayer_peer = peer
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")


#func _on_pressing_join() -> void:
	#peer.create_client("127.0.0.1", 6969)
	#multiplayer.multiplayer_peer = peer
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_pressing_cosmetics() -> void:
	went_to_cosmetics.emit()


func _on_pressing_settings() -> void:
	pass # Replace with function body.


func _on_pressing_quit() -> void:
	pass # Replace with function body.
