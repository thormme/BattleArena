extends Reference
class_name PlayerInfo

var name: String
var team
var ready: bool
var instance: Player

func _init(_name: String, _team, _ready: bool, _instance: Player):
	name = _name
	team = _team
	ready = _ready
	instance = _instance
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
