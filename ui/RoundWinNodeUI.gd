extends PanelContainer

export var win_number: int = 1
export (Mover.Team) var team: int = Mover.Team.TEAM_1
export var inactive_color: Color = Color(0x00b1ffff)
export var active_color: Color = Color(0x02d100ff)

onready var background = $BackgroundImage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MatchManager.connect("round_ended", self, "_handle_round_ended")
		
func _handle_round_ended(round_number: int, winning_team, wins: Dictionary) -> void:
	set_wins(wins[team])

func set_wins(num_wins: int) -> void:
	if num_wins >= win_number:
		background.modulate = active_color
	else:
		background.modulate = inactive_color
