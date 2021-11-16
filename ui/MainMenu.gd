extends Control

onready var ip_text_node: TextEdit = get_node("VBoxContainer/CenterContainer4/HBoxContainer/TextEdit")

func _on_ClientButton_button_up():
	NetworkManager.goto_scene("res://stages/main.tscn")
	
	# Wait for stage to load before creating playing to let connections by set up
	NetworkManager.call_deferred("connect_client", ip_text_node.text, NetworkManager.SERVER_PORT)


func _on_ServerButton_button_up():
	NetworkManager.goto_scene("res://stages/main.tscn")
	
	# Wait for stage to load before creating playing to let connections by set up
	NetworkManager.call_deferred("connect_server", NetworkManager.SERVER_PORT)
