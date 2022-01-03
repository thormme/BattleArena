extends PanelContainer


var cooldown = false
export var ability_node_name = "Ability1"

onready var label = $BackgroundImage/Label

var _player
var _ability

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connect("player_created", self, "_handle_player_created")

func _handle_Ability_charging(_prev_state) -> void:
	print("castcharge")
	label.text = "Casting"
	
func _handle_Ability_started_cooldown(timer) -> void:
	cooldown = true
	
func _handle_Ability_finished_cooldown() -> void:
	label.text = "Ready"
	cooldown = false
	
func _physics_process(delta) -> void:
	if cooldown == true:
		label.text = str(_ability.cooldown_timer.time_left).pad_decimals(1)
		
func _handle_player_created(player, local) -> void:
	if local:
		set_player(player)

func set_player(player_node: Player) -> void:
	_player = player_node
	_ability = _player.get_node(ability_node_name)
	if _ability.is_connected("charging", self, "_handle_Ability_charging"):
		_ability.disconnect("charging", self, "_handle_Ability_charging")
		_ability.disconnect("finished_cooldown", self, "_handle_Ability_finished_cooldown")
		_ability.disconnect("started_cooldown", self, "_handle_Ability_started_cooldown")
	_ability.connect("charging", self, "_handle_Ability_charging")
	_ability.connect("finished_cooldown", self, "_handle_Ability_finished_cooldown")
	_ability.connect("started_cooldown", self, "_handle_Ability_started_cooldown")
