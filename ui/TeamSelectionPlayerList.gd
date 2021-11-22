extends ItemList

export var team = Mover.Team.TEAM_1

func _on_Control_player_changed_team(player_info, old_team):
	if player_info.team == team:
		self.add_item(player_info.name, null, false)
	if old_team == team:
		self.remove_item(self.items.find(player_info.name))
