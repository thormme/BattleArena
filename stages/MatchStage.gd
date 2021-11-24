extends Node
class_name MatchStage

const PlayerScene: Resource = preload("res://objects/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var id = get_tree().get_network_unique_id()
	print("ready stage ", id)
	if id == NetworkManager.HOST_ID:
		for player_id in NetworkManager.player_info.keys():
			if NetworkManager.player_info[player_id].team != Mover.Team.SPECTATOR:
				spawn_player(player_id)

func spawn_player(id: int):
	var player_info = NetworkManager.player_info[id]
	NetworkManager.create_node_instance(PlayerScene.resource_path, [player_info.team, id], self.get_path(), self.get_path(), "_handle_player_created", [id])
	


# Update player_info with new instance
func _handle_player_created(player_node_path: String, id: int):
	if get_tree().has_network_peer():
		var info = NetworkManager.get_player_info_copy(id)
		info.instance = player_node_path
		print("setting instance ", player_node_path)
		NetworkManager.update_player_info(id, info)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
