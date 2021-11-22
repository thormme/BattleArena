extends Control



onready var ReadyButton: Button = $ReadyButton

signal player_changed_team(player_info, old_team) # player_info: Dictionary, old_team: Mover.Team 
signal player_changed_ready(player_info, ready) # player_info: Dictionary, ready: bool 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _update_player_team_event(event, new_team): # new_team: Mover.Team
	if event is InputEventMouseButton:
		var mouseEvent: InputEventMouseButton = event
		if mouseEvent.button_index == 1 && mouseEvent.pressed == false:
			if get_tree().has_network_peer():
				_update_player_team(get_tree().get_network_unique_id(), new_team)
				rpc("_remote_update_team", get_tree().get_network_unique_id(), new_team)

func _update_player_team(player_id: int, new_team):
		var player_info = NetworkManager.player_info[player_id]
		var old_team = player_info.team
		player_info.team = new_team
		emit_signal("player_changed_team", player_info, old_team)

remote func _remote_update_team(player_id: int, new_team):
	_update_player_team(player_id, new_team)

func _on_TeamBoxTeam1_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.TEAM_1)
	
func _on_TeamBoxTeam2_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.TEAM_2)
	
func _on_TeamBoxUnassigned_gui_input(event: InputEvent):
	_update_player_team_event(event, Mover.Team.SPECTATOR)


func spawn_player():
	var id = get_tree().get_network_unique_id()
	var player_info = NetworkManager.player_info[id]
	#NetworkManager.create_node_instance(PlayerScene.resource_path, [player_info.team, id], str(id))

func start_match():
	NetworkManager.goto_scene("res://stages/main.tscn")
	
	# Wait for stage to load before creating playing to let connections by set up
	#NetworkManager.call_deferred("create_node_instance", [PlayerScene.resource_path, [player_info.team, id], str(id)])

func _update_player_ready(player_id: int, ready: bool):
		var player_info = NetworkManager.player_info[player_id]
		player_info.ready = ready
		emit_signal("player_changed_ready", player_info, ready)
		var all_ready = true
		for info in NetworkManager.player_info.values():
			if !info.ready:
				all_ready = false
				break
		if all_ready:
			start_match()

remote func _remote_update_ready(player_id: int, ready: bool):
	_update_player_ready(player_id, ready)

func _on_ReadyButton_toggled(button_pressed: bool):
	if get_tree().has_network_peer():
		_update_player_ready(get_tree().get_network_unique_id(), button_pressed)
		rpc("_remote_update_ready", get_tree().get_network_unique_id(), button_pressed)

