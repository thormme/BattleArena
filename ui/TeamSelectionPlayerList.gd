extends ItemList

export var team = Mover.Team.TEAM_1

func _ready():
	NetworkManager.connect("player_changed_team", self, "_on_Control_player_changed_team")
	NetworkManager.connect("player_connected", self, "_handle_player_connected")

func _handle_player_connected(id: int):
	_on_Control_player_changed_team(id, null)

func _on_Control_player_changed_team(player_id, old_team):
	var player_info = NetworkManager.player_info[player_id]
	if player_info.team == team:
		self.add_item(player_info.name, null, false)
	if old_team == team:
		self.remove_item(self.items.find(player_info.name))
