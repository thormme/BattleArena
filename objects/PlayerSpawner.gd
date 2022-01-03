extends Spatial
class_name PlayerSpawner


export (Mover.Team) var team: int = Mover.Team.TEAM_1
export var slot: int = 0


const PlayerScene: Resource = preload("res://objects/Player.tscn")

func _ready():
	hide()
	
	transform.origin.y = 0 # Consider projecting down
	
	var id = get_tree().get_network_unique_id()
	if id == NetworkManager.HOST_ID:
		for player_id in NetworkManager.player_info.keys():
			# Currently slot specific, consider doing it by team and player presence
			if NetworkManager.player_info[player_id].team == team && NetworkManager.player_info[player_id].slot == slot:
				spawn_player(player_id)


func spawn_player(id: int):
	var player_info = NetworkManager.player_info[id]
	NetworkManager.create_node_instance(PlayerScene.resource_path, [player_info.team, id, self.transform.origin], "", self.get_path(), "_handle_player_created", [id])


# Update player_info with new instance
func _handle_player_created(player_node_path: String, id: int):
	if get_tree().has_network_peer():
		var info = NetworkManager.get_player_info_copy(id)
		info.instance = player_node_path
		# TODO: Find a better way to do this
		# This avoids sending the update over the network, since this call already is synced
		# Otherwise the instance would be set before it exists on the client
		NetworkManager._update_player_info(id, info)

