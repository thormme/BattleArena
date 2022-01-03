extends Control



onready var ReadyButton: Button = $ReadyButton

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.connect("player_changed_ready", self, "_update_player_ready")
	NetworkManager.connect("player_changed_team", self, "_update_player_team_event")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _get_next_open_team_slot(team):
	var slots = {}
	for info in NetworkManager.player_info.values():
		if info.slot != -1:
			if !slots.has(info.team):
				slots[info.team] = []
			slots[info.team].append(info.slot)
	if !slots.has(team):
		return 0
	var team_slots = slots[team]
	team_slots.sort()
	var prev = -1
	for slot in team_slots:
		if slot != prev + 1:
			return prev + 1
		prev = slot
	return prev + 1

func _update_player_team_event(event, new_team): # new_team: Mover.Team
	if event is InputEventMouseButton:
		var mouseEvent: InputEventMouseButton = event
		if mouseEvent.button_index == 1 && mouseEvent.pressed == false:
			if get_tree().has_network_peer():
				var info = NetworkManager.get_player_info_copy(get_tree().get_network_unique_id())
				info.team = new_team
				info.slot = _get_next_open_team_slot(new_team)
				NetworkManager.update_player_info(get_tree().get_network_unique_id(), info)

func _on_TeamBoxTeam1_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.TEAM_1)
	
func _on_TeamBoxTeam2_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.TEAM_2)
	
func _on_TeamBoxUnassigned_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.SPECTATOR)


func start_match():
	MatchManager.start_match()
	
	# Wait for stage to load before creating playing to let connections by set up
	#NetworkManager.call_deferred("create_node_instance", [PlayerScene.resource_path, [player_info.team, id], str(id)])

func _update_player_ready(player_id: int, ready: bool):
		var all_ready = true
		for info in NetworkManager.player_info.values():
			if !info.ready:
				all_ready = false
				break
		if all_ready:
			start_match()

func _on_ReadyButton_toggled(button_pressed: bool):
	if get_tree().has_network_peer():
		var info = NetworkManager.get_player_info_copy(get_tree().get_network_unique_id())
		info.ready = button_pressed
		NetworkManager.update_player_info(get_tree().get_network_unique_id(), info)

