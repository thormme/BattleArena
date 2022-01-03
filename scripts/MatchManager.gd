extends Node

signal round_started(round_number)
signal round_ended(round_number, team, wins)


var players_alive: Dictionary = {} # ID -> Alive
var team_num_players: Dictionary = {} # Team -> Number of Players

var _round_number: int = -1
var _team_wins: Dictionary = {} # Team -> Num Wins
var _round_active = false

func _ready() -> void:
	NetworkManager.connect("player_changed_instance", self, "_handle_player_instance")

func _handle_player_instance(player_id: int, _old_instance: Player):
	var instance = get_node(NetworkManager.player_info[player_id].instance)
	if instance != null:
		instance.connect("killed", self, "_handle_player_killed", [player_id])

func _handle_player_killed(caster: Mover, player_id: int):
	print("player_killed")
	players_alive[player_id] = false
	
	var players_still_alive: bool = false
	var num_team_players_alive: Dictionary = {}
	for team in team_num_players.keys():
		num_team_players_alive[team] = 0
		for player in players_alive.keys():
			if NetworkManager.player_info[player].team == team && players_alive[player]:
				num_team_players_alive[team] += 1
	var teams_alive: Array = []
	for team in num_team_players_alive.keys():
		if num_team_players_alive[team] > 0:
			teams_alive.append(team)
	if teams_alive.size() <= 1:
		var winning_team
		if teams_alive.size() == 1:
			winning_team = teams_alive[0]
		else:
			# For a draw
			winning_team = Player.Team.SPECTATOR
		end_match(winning_team)
	

func start_match():
	NetworkManager.goto_scene("res://stages/main.tscn")
	_round_number += 1
	# Count the number of players on each team
	for player in NetworkManager.player_info.keys():
		var team = NetworkManager.player_info[player].team
		# Count only players assigned to a team
		if NetworkManager.player_info[player].team != Player.Team.SPECTATOR && NetworkManager.player_info[player].team != Player.Team.WORLD:
			players_alive[player] = true
			if !team_num_players.has(team):
				team_num_players[team] = 0
			team_num_players[team] += 1
			if !_team_wins.has(team):
				_team_wins[team] = 0
	_round_active = true
	emit_signal("round_started")

func end_match(team = Player.Team.SPECTATOR):
	if !_round_active:
		return
	if team != Player.Team.SPECTATOR:
		_team_wins[team] += 1
	_round_active = false
	emit_signal("round_ended", _round_number, team, _team_wins)
	start_match()
