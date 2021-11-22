extends Node


const PlayerScene: Resource = preload("res://objects/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var id = get_tree().get_network_unique_id()
	print("ready stage ", id)
	if id == NetworkManager.HOST_ID:
		spawn_player(id)
	else:
		rpc_id(NetworkManager.HOST_ID, "spawn_player", id)

remote func spawn_player(id: int):
	var player_info = NetworkManager.player_info[id]
	NetworkManager.create_node_instance(PlayerScene.resource_path, [player_info.team, id])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
